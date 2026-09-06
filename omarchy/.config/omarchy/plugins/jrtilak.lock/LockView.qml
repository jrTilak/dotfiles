import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool powerActionsEnabled: false
  property bool canSuspend: false
  property bool canHibernate: false
  property bool canPowerOff: false
  property string powerConfirmationAction: ""
  property string pendingPowerAction: ""
  property string failedPowerAction: ""
  property bool syncingPasswordText: false
  property date currentTime: new Date()
  property string batteryPercentage: "AC"
  property string batteryGlyph: "󰚥"
  property string hostName: ""

  readonly property string homePath: Quickshell.env("HOME")
  readonly property string userName: Quickshell.env("USER") || Quickshell.env("LOGNAME") || "user"

  readonly property string placeholderText: "Enter Password"
  readonly property int fieldWidth: Style.space(360)
  readonly property int fieldHeight: Math.max(Style.space(48), Style.spacing.controlHeight)
  readonly property int outlineThickness: Math.max(Style.spacing.hairline, Style.normalBorderWidth)
  readonly property int fieldFontSize: Style.font.heading
  readonly property int passwordDotFontSize: Style.font.display
  readonly property int passwordDotLetterSpacing: Math.max(1, Math.round(Style.font.body * 0.25))
  readonly property int topInset: Style.space(44)
  readonly property int clockDateGap: Style.space(34)
  readonly property int avatarSize: Style.space(72)
  readonly property int powerItemWidth: Style.space(82)
  readonly property int powerItemHeight: Style.space(72)
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + Style.spacing.xxl) : 0
  // Shrink the dots to fit once the password outgrows the field, so every
  // keystroke stays visible — otherwise long passwords clip with no feedback.
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - Style.spacing.sm) / dotMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property bool errorState: failureMessage.length > 0
  readonly property var inputBorderSpec: errorState
    ? Border.surfaceSpec("lock", "border-error", Color.lock.borderError, root.outlineThickness, "border-alpha")
    : Border.surfaceSpec("lock", "border-active", Color.lock.borderActive, root.outlineThickness, "border-alpha")

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()
  signal powerActionRequested(string action)
  signal cancelPowerConfirmationRequested()

  // Cache-busts the lock background by appending `?v=`. Adding a query
  // string keeps Image's loader happy while forcing it to reload when the
  // user picks a new background mid-session.
  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  function updateBattery(raw) {
    var fields = String(raw || "").trim().split("|")
    var capacity = Number(fields[0])
    var status = fields.length > 1 ? fields[1] : ""

    if (!isFinite(capacity)) {
      batteryPercentage = "AC"
      batteryGlyph = "󰚥"
      return
    }

    batteryPercentage = Math.round(capacity) + "%"
    if (status === "Charging") batteryGlyph = "󰂄"
    else if (capacity >= 90) batteryGlyph = "󰁹"
    else if (capacity >= 70) batteryGlyph = "󰂁"
    else if (capacity >= 40) batteryGlyph = "󰁾"
    else if (capacity >= 20) batteryGlyph = "󰁻"
    else batteryGlyph = "󰂎"
  }

  function powerActionAvailable(action) {
    if (action === "suspend") return canSuspend
    if (action === "hibernate") return canHibernate
    if (action === "poweroff") return canPowerOff
    return false
  }

  function powerActionLabel(action, label) {
    if (failedPowerAction === action) return "Failed"
    if (pendingPowerAction === action) return "Working…"
    if (powerConfirmationAction === action) return "Confirm"
    return label
  }

  function powerActionAccessibleName(action, label) {
    if (failedPowerAction === action) return label + " failed"
    if (pendingPowerAction === action) return label + " in progress"
    if (powerConfirmationAction === action) return "Confirm " + label.toLowerCase()
    return label
  }

  function powerActionDescription(action) {
    if (powerConfirmationAction === action) return "Activate again to shut down this computer"
    if (action === "poweroff") return "Shut down this computer after confirmation"
    if (action === "hibernate") return "Hibernate this computer while keeping the session locked"
    return "Suspend this computer while keeping the session locked"
  }

  function activatePowerAction(action) {
    if (!powerActionsEnabled || !powerActionAvailable(action)) return
    wakeRequested()
    powerActionRequested(action)
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
    else if (powerConfirmationAction.length > 0) cancelPowerConfirmationRequested()
  }
  onAuthenticatingPasswordChanged: {
    if (authenticatingPassword && powerConfirmationAction.length > 0) cancelPowerConfirmationRequested()
    if (!authenticatingPassword && inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  onPendingPowerActionChanged: if (pendingPowerAction.length === 0 && inputEnabled) Qt.callLater(forcePasswordFocus)
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
    if (!batteryProcess.running) batteryProcess.running = true
    if (!hostnameProcess.running) hostnameProcess.running = true
  }

  // Measures the masked password at full size; passwordDotScale compares this
  // against the field width to decide how far the dots must shrink to fit.
  TextMetrics {
    id: dotMetrics
    font.family: Style.font.family
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "●".repeat(passwordInput.text.length)
  }

  Rectangle {
    anchors.fill: parent
    color: Color.background

    Image {
      id: wallpaper
      anchors.fill: parent
      source: root.loadBackground ? root.fileUrl(root.backgroundPath) : ""
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
    }

    MultiEffect {
      anchors.fill: wallpaper
      source: wallpaper
      autoPaddingEnabled: false
      blurEnabled: root.loadBackground && wallpaper.status === Image.Ready
      blur: 1.0
      blurMax: 128
      blurMultiplier: 1.25
      contrast: -0.08
    }

    // Preserve the wallpaper while keeping text legible over bright areas.
    Rectangle {
      anchors.fill: parent
      color: Color.background
      opacity: 0.24
    }

    Text {
      anchors.top: parent.top
      anchors.topMargin: root.topInset
      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.formatDateTime(root.currentTime, "HH:mm")
      color: Color.lock.text
      font.family: Style.font.family
      font.pixelSize: Style.font.displayLarge * 2
      Accessible.role: Accessible.StaticText
      Accessible.name: "Time " + text
    }

    Text {
      anchors.top: parent.top
      anchors.topMargin: root.topInset + (Style.font.displayLarge * 2) + root.clockDateGap
      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.formatDateTime(root.currentTime, "ddd, dd MMM")
      color: Color.lock.placeholder
      font.family: Style.font.family
      font.pixelSize: Style.font.iconLarge
      Accessible.role: Accessible.StaticText
      Accessible.name: "Date " + text
    }

    Row {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: Style.space(20)
      anchors.rightMargin: Style.space(24)
      spacing: Style.spacing.xl
      Accessible.role: Accessible.StaticText
      Accessible.name: "Battery " + root.batteryPercentage

      Text {
        text: root.batteryGlyph
        color: Color.lock.text
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        Accessible.ignored: true
      }

      Text {
        text: root.batteryPercentage
        color: Color.lock.text
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        Accessible.ignored: true
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    Item {
      anchors.centerIn: parent
      anchors.verticalCenterOffset: -Style.space(16)
      width: root.avatarSize
      height: root.avatarSize
      readonly property real ringWidth: Math.max(Style.spacing.hairline, Style.normalBorderWidth)

      Image {
        id: avatarImage
        anchors.fill: parent
        anchors.margins: parent.ringWidth
        source: root.fileUrl(root.homePath + "/.face")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        visible: false
      }

      Rectangle {
        id: avatarMask
        anchors.fill: avatarImage
        radius: width / 2
        color: "white"
        visible: false
      }

      OpacityMask {
        anchors.fill: avatarImage
        source: avatarImage
        maskSource: avatarMask
      }

      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: Color.lock.borderActive
        border.width: parent.ringWidth
      }
    }

    Text {
      anchors.centerIn: parent
      anchors.verticalCenterOffset: Style.space(54)
      text: root.hostName.length > 0 ? root.hostName + "@" + root.userName : root.userName
      color: Color.lock.text
      font.family: Style.font.family
      font.pixelSize: Style.font.iconLarge
      Accessible.role: Accessible.StaticText
      Accessible.name: text
    }

    BorderSurface {
      id: inputField
      width: root.fieldWidth
      height: root.fieldHeight
      anchors.centerIn: parent
      anchors.verticalCenterOffset: Style.space(116)
      color: Color.lock.background
      borderSpec: root.inputBorderSpec
      radius: Style.cornerRadius
      clip: true

      TextInput {
        id: passwordInput
        anchors.fill: parent
        anchors.topMargin: inputField.borderTop
        // Reserve the fingerprint icon's width on both sides so the centered
        // dots stay symmetric and never slide under the icon as they grow.
        anchors.rightMargin: inputField.borderRight + Style.spacing.huge + root.fingerprintReserve
        anchors.bottomMargin: inputField.borderBottom
        anchors.leftMargin: inputField.borderLeft + Style.spacing.huge + root.fingerprintReserve
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        activeFocusOnTab: true
        clip: true
        enabled: root.inputEnabled && !root.authenticatingPassword
        readOnly: root.authenticatingPassword
        echoMode: TextInput.Password
        passwordCharacter: "\u25CF"
        passwordMaskDelay: 0
        color: Color.lock.text
        selectionColor: Color.lock.selection
        selectedTextColor: Color.lock.text
        font.family: Style.font.family
        font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)) : root.fieldFontSize
        font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
        cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
        cursorDelegate: Rectangle {
          width: Style.spacing.hairline
          color: Color.lock.text
          visible: passwordInput.cursorVisible
        }

        Accessible.role: Accessible.EditableText
        Accessible.name: "Password"
        Accessible.description: root.authenticatingPassword
          ? "Checking password"
          : (root.failureMessage.length > 0
            ? root.failureMessage
            : "Enter the password for " + root.userName)
        Accessible.passwordEdit: true
        Accessible.editable: enabled && !readOnly
        Accessible.readOnly: readOnly
        Accessible.focusable: enabled
        Accessible.focused: activeFocus

        onTextChanged: {
          if (!root.syncingPasswordText) root.passwordTextEdited(text)
          if (text.length > 0) {
            root.wakeRequested()
            if (root.powerConfirmationAction.length > 0) root.cancelPowerConfirmationRequested()
          }
          if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
        }

        onAccepted: {
          var submitted = root.passwordText
          root.passwordTextEdited("")
          if (submitted.length > 0) root.submitPassword(submitted)
        }

        Keys.onPressed: function(event) {
          root.wakeRequested()
          if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
            root.passwordTextEdited("")
            if (root.powerConfirmationAction.length > 0) root.cancelPowerConfirmationRequested()
            event.accepted = true
          }
        }
      }

      Text {
        anchors.fill: passwordInput
        text: root.authenticatingPassword ? "Checking…" : (root.failureMessage.length > 0 ? root.failureMessage : root.placeholderText)
        visible: passwordInput.text.length === 0
        color: root.authenticatingPassword ? Color.lock.text : (root.failureMessage.length > 0 ? Color.lock.textError : Color.lock.placeholder)
        font.family: Style.font.family
        font.pixelSize: root.fieldFontSize
        font.italic: !root.authenticatingPassword && root.failureMessage.length > 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        Accessible.ignored: true
      }

      // Fingerprint hint pinned inside the field's right edge when a sensor is
      // enrolled, so the user knows they can touch to unlock instead of typing.
      // Matches hyprlock, which draws its fingerprint icon in the same spot.
      Text {
        id: fingerprintIcon
        objectName: "fingerprintIndicator"
        anchors.right: parent.right
        anchors.rightMargin: inputField.borderRight + Style.spacing.huge
        anchors.verticalCenter: parent.verticalCenter
        visible: root.fingerprintConfigured
        text: "󰈷"
        color: Color.lock.placeholder
        font.family: Style.font.family
        font.pixelSize: Math.round(root.fieldFontSize * 1.1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        Accessible.ignored: true
      }
    }

    Row {
      anchors.centerIn: parent
      anchors.verticalCenterOffset: Style.space(208)
      spacing: Style.spacing.sm

      Repeater {
        model: [
          { label: "Sleep", icon: "󰒲", action: "suspend" },
          { label: "Hibernate", icon: "󰤄", action: "hibernate" },
          { label: "Shutdown", icon: "⏻", action: "poweroff" }
        ]

        BorderSurface {
          id: powerButton
          required property var modelData
          width: root.powerItemWidth
          height: root.powerItemHeight
          visible: root.powerActionAvailable(modelData.action)
          enabled: visible && root.powerActionsEnabled
          activeFocusOnTab: enabled
          radius: Style.cornerRadius
          color: powerMouse.pressed && enabled
            ? Style.pressedFillFor(Color.lock.text, Color.lock.borderActive)
            : activeFocus && enabled
              ? Style.focusFillFor(Color.lock.text, Color.lock.borderActive)
              : powerMouse.containsMouse && enabled
                ? Style.hoverFillFor(Color.lock.text, Color.lock.borderActive)
                : "transparent"
          borderSpec: activeFocus && enabled
            ? Border.controlSpec("focus", Color.lock.text, Color.lock.borderActive)
            : powerMouse.containsMouse && enabled
              ? Border.controlSpec("hover-cursor", Color.lock.text, Color.lock.borderActive)
              : Border.none()
          opacity: enabled
            || root.pendingPowerAction === modelData.action
            || root.failedPowerAction === modelData.action
            || root.powerConfirmationAction === modelData.action
              ? 1.0 : 0.42

          Accessible.role: Accessible.Button
          Accessible.name: root.powerActionAccessibleName(modelData.action, modelData.label)
          Accessible.description: root.powerActionDescription(modelData.action)
          Accessible.focusable: enabled
          Accessible.focused: activeFocus
          Accessible.pressed: powerMouse.pressed
          Accessible.ignored: !visible
          Accessible.onPressAction: powerButton.activate()

          function activate() {
            if (!enabled) return
            forceActiveFocus()
            root.activatePowerAction(modelData.action)
          }

          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
              if (root.powerConfirmationAction.length > 0) root.cancelPowerConfirmationRequested()
              root.forcePasswordFocus()
              event.accepted = true
              return
            }

            if (!event.isAutoRepeat
                && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)) {
              powerButton.activate()
              event.accepted = true
            }
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.spacing.md

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: modelData.icon
              color: Color.lock.text
              font.family: Style.font.family
              font.pixelSize: Style.font.display
              Accessible.ignored: true
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: root.powerActionLabel(modelData.action, modelData.label)
              color: root.failedPowerAction === modelData.action ? Color.lock.textError : Color.lock.text
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              Accessible.ignored: true
            }
          }

          MouseArea {
            id: powerMouse
            anchors.fill: parent
            enabled: powerButton.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: powerButton.activate()
            onPositionChanged: root.wakeRequested()
          }
        }
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.currentTime = new Date()
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: if (!batteryProcess.running) batteryProcess.running = true
  }

  Process {
    id: batteryProcess
    command: ["bash", "-c", "cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1); status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1); printf '%s|%s\\n' \"$cap\" \"$status\""]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateBattery(text)
    }
  }

  Process {
    id: hostnameProcess
    command: ["hostname"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.hostName = String(text || "").trim()
    }
  }
}
