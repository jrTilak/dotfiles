import QtQuick
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root

  moduleName: "jrtilak.widget-drawer"

  // The nested objects deliberately use the same inline settings shape as a
  // normal bar.layout entry: { "id": "plugin.id", ...pluginSettings }.
  readonly property var entries: normalizedEntries(setting("contains", []))
  readonly property bool includeTray: setting("includeTray", true) !== false
  readonly property int animationDuration: Math.max(0, Number(setting("animationDuration", 320)))
  readonly property int hoverCloseDelay: Math.max(0, Number(setting("hoverCloseDelay", 200)))
  readonly property var shellConfig: bar && bar.shell ? bar.shell.shellConfig : null
  readonly property string section: containingSection()
  // A right-section drawer grows toward the start of the bar; left and
  // center drawers grow toward the end. On a vertical bar those directions
  // naturally become up/down instead of left/right.
  readonly property bool opensTowardStart: section === "right"
  readonly property string revealDirection: vertical
    ? (opensTowardStart ? "up" : "down")
    : (opensTowardStart ? "left" : "right")
  readonly property real collapsedChevronRotation: vertical
    ? (opensTowardStart ? 90 : 270)
    : (opensTowardStart ? 0 : 180)

  property var childSlots: []
  property int panelStateRevision: 0
  property bool hoverHeld: false
  property bool pinnedOpen: false
  property bool suppressHoverUntilLeave: false
  property bool traySurfaceOpen: false

  readonly property bool childPanelOpen: {
    var revision = panelStateRevision
    if (traySurfaceOpen) return true
    for (var i = 0; i < childSlots.length; i++) {
      var item = childSlots[i] ? childSlots[i].activeItem : null
      if (itemKeepsDrawerOpen(item)) return true
    }
    return false
  }
  readonly property bool expanded: pinnedOpen || hoverHeld || childPanelOpen

  implicitWidth: layoutLoader.item ? layoutLoader.item.implicitWidth : 0
  implicitHeight: layoutLoader.item ? layoutLoader.item.implicitHeight : 0
  visible: entries.length > 0

  function entryId(entry) {
    if (typeof entry === "string") return entry
    if (entry && typeof entry === "object" && entry.id !== undefined && entry.id !== null)
      return String(entry.id)
    return ""
  }

  function itemKeepsDrawerOpen(item) {
    return !!(item && (item.opened === true
      || item.popupOpen === true
      || item.managePopupOpen === true
      || item.trayMenuOpen === true))
  }

  function normalizedEntries(values) {
    // shell.json arrays cross the QML boundary as sequence values on some Qt
    // builds, where Array.isArray() is false even though length/index work.
    var source = values && typeof values.length === "number" ? values : []
    var result = []
    var seen = ({})

    for (var i = 0; i < source.length; i++) {
      var entry = source[i]
      var id = entryId(entry)
      if (bar && typeof bar.canonicalWidgetId === "function") id = bar.canonicalWidgetId(id)
      if (id === "" || id === moduleName || seen[id]) continue

      if (typeof entry === "string") result.push({ id: id })
      else {
        var copy = ({ id: id })
        for (var key in entry) if (key !== "id") copy[key] = entry[key]
        result.push(copy)
      }
      seen[id] = true
    }

    return result
  }

  function inlineSettings(entry) {
    var result = ({})
    if (!entry || typeof entry !== "object") return result
    for (var key in entry) if (key !== "id") result[key] = entry[key]
    return result
  }

  // Mirrored entries in top-level plugins[] keep third-party widgets loaded
  // and give native widget settings somewhere that shell.updateEntryInline()
  // already knows how to persist. Inline values in contains[] take priority.
  function persistedSettings(id) {
    var result = ({})
    var config = shellConfig
    var plugins = config && config.plugins && typeof config.plugins.length === "number"
      ? config.plugins : []
    for (var i = 0; i < plugins.length; i++) {
      if (entryId(plugins[i]) !== id) continue
      for (var key in plugins[i]) if (key !== "id") result[key] = plugins[i][key]
      break
    }
    return result
  }

  function settingsFor(entry) {
    var id = entryId(entry)
    var result = persistedSettings(id)
    var overrides = inlineSettings(entry)
    for (var key in overrides) result[key] = overrides[key]
    return result
  }

  function containingSection() {
    var config = bar ? bar.layoutConfig : null
    var sections = ["left", "center", "right"]
    for (var s = 0; s < sections.length; s++) {
      var values = config && config[sections[s]] && typeof config[sections[s]].length === "number"
        ? config[sections[s]] : []
      for (var i = 0; i < values.length; i++)
        if (entryId(values[i]) === moduleName) return sections[s]
    }
    return "right"
  }

  function registerChild(slot) {
    if (!slot || childSlots.indexOf(slot) !== -1) return
    var next = childSlots.slice()
    next.push(slot)
    childSlots = next
    if (bar && typeof bar.registerModuleSlot === "function") bar.registerModuleSlot(slot)
    panelStateRevision++
  }

  function unregisterChild(slot) {
    var next = childSlots.filter(function(candidate) { return candidate !== slot })
    childSlots = next
    if (bar && typeof bar.unregisterModuleSlot === "function") bar.unregisterModuleSlot(slot)
    panelStateRevision++
  }

  function togglePinned() {
    if (pinnedOpen) {
      pinnedOpen = false
      hoverHeld = false
      suppressHoverUntilLeave = true
    } else {
      pinnedOpen = true
      hoverHeld = true
    }
  }

  onBarChanged: {
    // Nested virtual slots may be constructed before the host injects bar.
    // Register them once it arrives and refresh their injected properties.
    for (var i = 0; i < childSlots.length; i++) {
      if (bar && typeof bar.registerModuleSlot === "function") bar.registerModuleSlot(childSlots[i])
      if (childSlots[i] && typeof childSlots[i].injectProperties === "function")
        childSlots[i].injectProperties()
    }
  }

  Component.onDestruction: {
    if (!bar || typeof bar.unregisterModuleSlot !== "function") return
    for (var i = 0; i < childSlots.length; i++) bar.unregisterModuleSlot(childSlots[i])
  }

  HoverHandler {
    id: drawerHover

    onHoveredChanged: {
      if (hovered) {
        closeTimer.stop()
        if (!root.suppressHoverUntilLeave) root.hoverHeld = true
      } else {
        root.suppressHoverUntilLeave = false
        closeTimer.restart()
      }
    }
  }

  Timer {
    id: closeTimer
    interval: root.hoverCloseDelay
    onTriggered: if (!root.pinnedOpen) root.hoverHeld = false
  }

  IpcHandler {
    target: "jrtilak.widget-drawer"

    function status(): string {
      var children = []
      for (var i = 0; i < root.childSlots.length; i++) {
        var slot = root.childSlots[i]
        children.push({
          id: slot ? slot.moduleName : "",
          registered: !!(slot && slot.registryEntry),
          loaded: !!(slot && slot.activeItem),
          visible: !!(slot && slot.visible),
          opened: !!(slot && root.itemKeepsDrawerOpen(slot.activeItem))
        })
      }
      return JSON.stringify({
        settings: root.settings,
        entries: root.entries,
        childSlots: children,
        includeTray: root.includeTray,
        trayItemCount: layoutLoader.item && layoutLoader.item.trayItemCount !== undefined
          ? layoutLoader.item.trayItemCount : 0,
        section: root.section,
        revealDirection: root.revealDirection,
        expanded: root.expanded,
        pinnedOpen: root.pinnedOpen,
        hovered: root.hoverHeld
      })
    }

    function open(): void {
      root.pinnedOpen = true
      root.hoverHeld = true
    }

    function close(): void {
      root.pinnedOpen = false
      root.hoverHeld = false
    }

    function toggle(): void { root.togglePinned() }
  }

  Loader {
    id: layoutLoader
    sourceComponent: root.vertical ? verticalDrawer : horizontalDrawer
  }

  component DrawerToggle: BarIconButton {
    bar: root.bar
    text: "\uf053"
    textRotation: root.collapsedChevronRotation + (root.expanded ? 180 : 0)
    tooltipText: root.pinnedOpen ? "Close widget drawer" : "Widget drawer"

    Behavior on textRotation {
      NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
    }

    onPressed: function(button) {
      if (button === Qt.LeftButton) root.togglePinned()
    }
  }

  component DrawerChild: Item {
    id: slot

    required property var entry
    readonly property string moduleName: root.entryId(entry)
    readonly property var moduleSettings: root.settingsFor(entry)
    readonly property var registryEntry: {
      var widgets = root.bar && root.bar.barWidgetRegistry
        ? root.bar.barWidgetRegistry.widgets : ({})
      return widgets[moduleName] || null
    }
    readonly property var activeItem: widgetLoader.item
    property string region: root.section

    implicitWidth: activeItem && activeItem.visible !== false ? activeItem.implicitWidth : 0
    implicitHeight: activeItem && activeItem.visible !== false ? activeItem.implicitHeight : 0
    // Omarchy also routes registered WidgetButton clicks globally and does not
    // account for ancestor clipping. Collapse the actual child geometry so
    // those registered targets cannot overlap the neighboring module slots.
    width: root.expanded ? implicitWidth : 0
    height: root.expanded ? implicitHeight : 0
    // Keep the host visible. QML propagates an invisible parent's state into
    // its child, so binding this back to activeItem.visible creates a cycle
    // where every otherwise-visible widget remains hidden forever.
    visible: true

    function injectProperties() {
      var item = widgetLoader.item
      if (!item) return
      if ("bar" in item) item.bar = root.bar
      if ("moduleName" in item) item.moduleName = slot.moduleName
      if ("settings" in item) item.settings = slot.moduleSettings
      root.panelStateRevision++
    }

    Component.onCompleted: root.registerChild(slot)
    Component.onDestruction: if (root) root.unregisterChild(slot)
    onModuleSettingsChanged: injectProperties()

    Loader {
      id: widgetLoader
      anchors.fill: parent
      active: slot.registryEntry !== null
      sourceComponent: slot.registryEntry ? slot.registryEntry.component : null
      onLoaded: {
        slot.injectProperties()
        Qt.callLater(slot.injectProperties)
      }
    }

    Connections {
      target: widgetLoader.item
      ignoreUnknownSignals: true
      function onOpenedChanged() { root.panelStateRevision++ }
      function onPopupOpenChanged() { root.panelStateRevision++ }
      function onManagePopupOpenChanged() { root.panelStateRevision++ }
      function onTrayMenuOpenChanged() { root.panelStateRevision++ }
    }
  }

  component DrawerChildrenRow: Row {
    readonly property int trayItemCount: trayIcons.itemCount
    // Clipping only hides pixels. Omarchy's global click router also ignores
    // ancestor clipping and enabled state, so hide the registered targets too.
    visible: root.expanded
    enabled: root.expanded
    spacing: 0

    TrayIcons {
      id: trayIcons
      bar: root.bar
      enabled: root.includeTray
      onOpenedChanged: {
        root.traySurfaceOpen = opened
        root.panelStateRevision++
      }
      Component.onDestruction: if (root) root.traySurfaceOpen = false
    }

    Repeater {
      model: root.entries
      DrawerChild { required property var modelData; entry: modelData }
    }
  }

  component DrawerChildrenColumn: Column {
    readonly property int trayItemCount: trayIcons.itemCount
    // Apply the same hit-test guard when the bar is vertical.
    visible: root.expanded
    enabled: root.expanded
    spacing: 0

    TrayIcons {
      id: trayIcons
      bar: root.bar
      enabled: root.includeTray
      onOpenedChanged: {
        root.traySurfaceOpen = opened
        root.panelStateRevision++
      }
      Component.onDestruction: if (root) root.traySurfaceOpen = false
    }

    Repeater {
      model: root.entries
      DrawerChild { required property var modelData; entry: modelData }
    }
  }

  Component {
    id: horizontalDrawer

    Item {
      id: horizontalRoot

      property real revealExtent: root.expanded ? childrenRow.implicitWidth : 0
      readonly property alias trayItemCount: childrenRow.trayItemCount

      implicitWidth: toggle.implicitWidth + revealExtent
      implicitHeight: root.barSize

      Behavior on revealExtent {
        NumberAnimation { duration: root.animationDuration; easing.type: Easing.InOutCubic }
      }

      DrawerToggle {
        id: toggle
        width: implicitWidth
        height: implicitHeight
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
      }

      Item {
        anchors.left: toggle.right
        anchors.verticalCenter: parent.verticalCenter
        width: horizontalRoot.revealExtent
        height: root.barSize
        clip: true

        DrawerChildrenRow {
          id: childrenRow
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
        }
      }
    }
  }

  Component {
    id: verticalDrawer

    Item {
      id: verticalRoot

      property real revealExtent: root.expanded ? childrenColumn.implicitHeight : 0
      readonly property alias trayItemCount: childrenColumn.trayItemCount

      implicitWidth: root.barSize
      implicitHeight: toggle.implicitHeight + revealExtent

      Behavior on revealExtent {
        NumberAnimation { duration: root.animationDuration; easing.type: Easing.InOutCubic }
      }

      DrawerToggle {
        id: toggle
        width: implicitWidth
        height: implicitHeight
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Item {
        anchors.top: toggle.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.barSize
        height: verticalRoot.revealExtent
        clip: true

        DrawerChildrenColumn {
          id: childrenColumn
          anchors.top: parent.top
          anchors.horizontalCenter: parent.horizontalCenter
        }
      }
    }
  }
}
