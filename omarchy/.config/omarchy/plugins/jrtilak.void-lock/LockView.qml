import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons

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
  property bool syncingPasswordText: false
  property date currentTime: new Date()
  property string batteryPercentage: "AC"
  property string batteryGlyph: "AC"
  property string hostName: ""
  property bool passwordMode: false
  property string commandText: ""
  property var commandHistory: []
  property int historyIndex: -1
  property string historyDraft: ""

  readonly property string userName: Quickshell.env("USER") || Quickshell.env("LOGNAME") || "user"
  readonly property string promptHost: hostName.length > 0 ? hostName : "void"
  readonly property int marginSize: Style.space(40)
  readonly property int textSize: Style.font.body
  readonly property int smallTextSize: Style.font.caption
  readonly property int logoTextSize: Style.font.bodySmall
  readonly property int passwordDotFontSize: Math.round(textSize * 1.1)
  readonly property int passwordDotLetterSpacing: Math.max(1, Math.round(textSize * 0.12))
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - Style.space(16)) / dotMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property color textColor: Color.lock.text
  readonly property color mutedColor: Color.lock.placeholder
  readonly property color accentColor: Color.lock.borderActive
  readonly property color errorColor: Color.lock.textError

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    if (passwordMode) passwordInput.forceActiveFocus()
    else commandInput.forceActiveFocus()
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

  function appendLine(line, tone) {
    terminalModel.append({
      line: String(line || ""),
      tone: tone || "normal"
    })
    Qt.callLater(scrollBottom)
  }

  function appendPrompt(command) {
    appendLine("(" + userName + "@" + promptHost + ") -[locked]", "normal")
    appendLine("$ " + command, "accent")
  }

  function scrollBottom() {
    terminalView.positionViewAtEnd()
  }

  function pushHistory(command) {
    if (!command.length) return
    if (commandHistory.length && commandHistory[commandHistory.length - 1] === command) return
    var next = commandHistory.slice()
    next.push(command)
    if (next.length > 50) next = next.slice(next.length - 50)
    commandHistory = next
  }

  function enterPasswordMode() {
    passwordMode = true
    passwordTextEdited("")
    Qt.callLater(forcePasswordFocus)
  }

  function cancelPasswordMode() {
    passwordMode = false
    passwordTextEdited("")
    appendLine("Login cancelled.", "muted")
    Qt.callLater(forcePasswordFocus)
  }

  function runCommand(raw) {
    var command = String(raw || "").trim()
    historyIndex = -1
    historyDraft = ""
    commandText = ""

    if (!command.length) {
      Qt.callLater(forcePasswordFocus)
      return
    }

    appendPrompt(command)
    pushHistory(command)

    var parts = command.split(/\s+/)
    var cmd = parts[0].toLowerCase()
    var args = parts.slice(1)

    if (cmd === "help") {
      appendLine("Available commands:", "muted")
      appendLine("  help                 show this help", "normal")
      appendLine("  login | unlock       prompt for password", "normal")
      appendLine("  whoami               show current user", "normal")
      appendLine("  whoishe              show creator info", "normal")
      appendLine("  date | time          show current date/time", "normal")
      appendLine("  hostname | host      show host name", "normal")
      appendLine("  battery              show battery status", "normal")
      appendLine("  fingerprint          show fingerprint status", "normal")
      appendLine("  clear                clear terminal output", "normal")
      appendLine("  suspend | hibernate  sleep actions", "normal")
      appendLine("  reboot | poweroff    power actions", "normal")
    } else if (cmd === "login" || cmd === "unlock") {
      appendLine("Password for " + userName + ":", "muted")
      enterPasswordMode()
      return
    } else if (cmd === "logout" || cmd === "cancel") {
      appendLine("No active login attempt.", "muted")
    } else if (cmd === "clear") {
      terminalModel.clear()
    } else if (cmd === "whoami") {
      appendLine(userName, "normal")
    } else if (cmd === "whoishe" || cmd === "whois" || cmd === "about") {
      appendLine("Name:    jrtilak", "normal")
      appendLine("Role:    developer", "normal")
      appendLine("GitHub:  github.com/jrTilak", "normal")
      appendLine("Web:     jrtilak.dev", "normal")
    } else if (cmd === "date" || cmd === "time") {
      appendLine(Qt.formatDateTime(currentTime, "dddd, dd MMMM yyyy HH:mm:ss"), "normal")
    } else if (cmd === "hostname" || cmd === "host") {
      appendLine(promptHost, "normal")
    } else if (cmd === "battery") {
      appendLine(batteryGlyph + " " + batteryPercentage, "normal")
    } else if (cmd === "fingerprint") {
      appendLine(fingerprintConfigured ? "fingerprint: ready" : "fingerprint: unavailable", fingerprintConfigured ? "accent" : "muted")
    } else if (cmd === "echo") {
      appendLine(args.join(" "), "normal")
    } else if (cmd === "uname") {
      appendLine("Linux " + promptHost + " omarchy hyprland quickshell", "normal")
    } else if (cmd === "suspend") {
      appendLine("suspending...", "muted")
      runPowerAction("suspend")
    } else if (cmd === "hibernate") {
      appendLine("hibernating...", "muted")
      runPowerAction("hibernate")
    } else if (cmd === "reboot") {
      appendLine("rebooting...", "muted")
      runPowerAction("reboot")
    } else if (cmd === "poweroff" || cmd === "shutdown") {
      appendLine("powering off...", "muted")
      runPowerAction("poweroff")
    } else {
      appendLine("bash: " + cmd + ": command not found", "error")
    }

    Qt.callLater(forcePasswordFocus)
  }

  function submitPasswordLine() {
    var submitted = passwordText
    passwordTextEdited("")
    if (submitted.length > 0) root.submitPassword(submitted)
  }

  function updateBattery(raw) {
    var fields = String(raw || "").trim().split("|")
    var capacity = Number(fields[0])
    var status = fields.length > 1 ? fields[1] : ""

    if (!isFinite(capacity)) {
      batteryPercentage = "AC"
      batteryGlyph = "AC"
      return
    }

    batteryPercentage = Math.round(capacity) + "%"
    batteryGlyph = status === "Charging" ? "CHG" : "BAT"
  }

  function runPowerAction(action) {
    if (!inputEnabled) return
    wakeRequested()
    Quickshell.execDetached(["systemctl", action])
  }

  function colorForTone(tone) {
    if (tone === "accent") return accentColor
    if (tone === "muted") return mutedColor
    if (tone === "error") return errorColor
    return textColor
  }

  onPasswordTextChanged: syncPasswordText()
  onFailureMessageChanged: {
    if (failureMessage.length > 0) {
      appendLine("[ FAIL ] " + failureMessage, "error")
      passwordMode = false
      Qt.callLater(forcePasswordFocus)
    }
  }
  onAuthenticatingPasswordChanged: {
    if (authenticatingPassword) appendLine("[ WAIT ] checking credentials...", "accent")
  }
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  Component.onCompleted: {
    syncPasswordText()
    appendLine("[ OK ] mounted /home", "muted")
    appendLine("[ OK ] loaded omarchy-shell", "muted")
    appendLine("[ OK ] armed ext-session-lock", "muted")
    appendLine("[ OK ] password pam flow ready", "muted")
    appendLine("[ LOCKED ] " + userName + "@" + promptHost, "accent")
    appendLine("Type `help` for commands or `login` to unlock.", "muted")
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
    if (!batteryProcess.running) batteryProcess.running = true
    if (!hostnameProcess.running) hostnameProcess.running = true
  }

  TextMetrics {
    id: dotMetrics
    font.family: Style.font.family
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "*".repeat(passwordInput.text.length)
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
      blur: 0.85
      blurMax: 48
      blurMultiplier: 1.3
      contrast: -0.05
    }

    Rectangle {
      anchors.fill: parent
      color: Color.background
      opacity: 0.78
    }

    Canvas {
      anchors.fill: parent
      opacity: 0.035
      onWidthChanged: requestPaint()
      onHeightChanged: requestPaint()
      onPaint: {
        var ctx = getContext("2d")
        var imageData = ctx.createImageData(width, height)
        var d = imageData.data
        for (var i = 0; i < d.length; i += 4) {
          var v = Math.random() * 255
          d[i] = v
          d[i + 1] = v
          d[i + 2] = v
          d[i + 3] = 255
        }
        ctx.putImageData(imageData, 0, 0)
      }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    Column {
      id: terminal
      anchors.fill: parent
      anchors.margins: root.marginSize
      spacing: Style.spacing.xxl

      Text {
        text: "██╗   ██╗  ██████╗  ██╗██████╗ \n██║   ██║ ██╔═══██╗ ██║██╔══██╗\n██║   ██║ ██║   ██║ ██║██║  ██║\n╚██╗ ██╔╝ ██║   ██║ ██║██║  ██║\n ╚████╔╝  ╚██████╔╝ ██║██████╔╝\n  ╚═══╝    ╚═════╝  ╚═╝╚═════╝ "
        color: root.textColor
        font.family: Style.font.family
        font.pixelSize: root.logoTextSize
        lineHeight: 0.96
      }

      Row {
        width: parent.width
        spacing: Style.spacing.xxl

        Text {
          width: parent.width * 0.42
          text: Qt.formatDateTime(root.currentTime, "yyyy-MM-dd HH:mm:ss")
          color: root.mutedColor
          font.family: Style.font.family
          font.pixelSize: root.smallTextSize
          elide: Text.ElideRight
        }

        Text {
          width: parent.width * 0.22
          text: root.batteryGlyph + " " + root.batteryPercentage
          color: root.mutedColor
          font.family: Style.font.family
          font.pixelSize: root.smallTextSize
          horizontalAlignment: Text.AlignRight
          elide: Text.ElideRight
        }

        Text {
          width: parent.width * 0.32
          text: root.fingerprintConfigured ? "fingerprint: ready" : "fingerprint: unavailable"
          color: root.fingerprintConfigured ? root.accentColor : root.mutedColor
          font.family: Style.font.family
          font.pixelSize: root.smallTextSize
          horizontalAlignment: Text.AlignRight
          elide: Text.ElideRight
        }
      }

      Rectangle {
        width: parent.width
        height: Style.spacing.hairline
        color: root.mutedColor
        opacity: 0.35
      }

      ListView {
        id: terminalView
        width: parent.width
        height: Math.max(Style.space(80), parent.height - y - promptArea.height - actionRow.height - Style.spacing.xxl * 2)
        clip: true
        spacing: Style.spacing.sm
        model: terminalModel

        delegate: Text {
          required property string line
          required property string tone

          width: terminalView.width
          text: line
          color: root.colorForTone(tone)
          opacity: tone === "muted" ? 0.75 : 1
          font.family: Style.font.family
          font.pixelSize: root.textSize
          wrapMode: Text.Wrap
        }
      }

      Column {
        id: promptArea
        width: parent.width
        spacing: Style.spacing.sm

        Text {
          width: parent.width
          visible: root.passwordMode
          text: "Password for " + root.userName + ":"
          color: root.mutedColor
          font.family: Style.font.family
          font.pixelSize: root.textSize
          elide: Text.ElideRight
        }

        Row {
          width: parent.width
          spacing: 0

          Text {
            text: root.passwordMode ? "$ " : "(" + root.userName + "@" + root.promptHost + ") -[locked]\n$ "
            color: root.textColor
            font.family: Style.font.family
            font.pixelSize: root.textSize
          }

          TextInput {
            id: commandInput
            visible: !root.passwordMode
            width: parent.width - x
            height: Math.max(Style.spacing.controlHeight, implicitHeight)
            verticalAlignment: TextInput.AlignVCenter
            activeFocusOnPress: true
            clip: true
            enabled: root.inputEnabled
            text: root.commandText
            color: root.textColor
            selectionColor: Color.lock.selection
            selectedTextColor: root.textColor
            font.family: Style.font.family
            font.pixelSize: root.textSize
            cursorVisible: activeFocus
            cursorDelegate: Rectangle {
              width: Style.space(7)
              color: commandInput.cursorVisible ? root.textColor : "transparent"
            }

            onTextChanged: {
              root.commandText = text
              root.wakeRequested()
            }

            onAccepted: root.runCommand(text)

            Keys.onPressed: function(event) {
              root.wakeRequested()
              if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_C) {
                commandInput.text = ""
                event.accepted = true
                return
              }
              if (event.key === Qt.Key_Up) {
                event.accepted = true
                if (!root.commandHistory.length) return
                if (root.historyIndex === -1) root.historyDraft = commandInput.text
                if (root.historyIndex < root.commandHistory.length - 1) root.historyIndex++
                commandInput.text = root.commandHistory[root.commandHistory.length - 1 - root.historyIndex]
                return
              }
              if (event.key === Qt.Key_Down) {
                event.accepted = true
                if (root.historyIndex < 0) return
                root.historyIndex--
                commandInput.text = root.historyIndex < 0 ? root.historyDraft : root.commandHistory[root.commandHistory.length - 1 - root.historyIndex]
              }
            }
          }

          TextInput {
            id: passwordInput
            visible: root.passwordMode
            width: parent.width - x
            height: Math.max(Style.spacing.controlHeight, implicitHeight)
            verticalAlignment: TextInput.AlignVCenter
            activeFocusOnPress: true
            clip: true
            enabled: root.inputEnabled && !root.authenticatingPassword
            readOnly: root.authenticatingPassword
            echoMode: TextInput.Password
            passwordCharacter: "*"
            passwordMaskDelay: 0
            color: root.textColor
            selectionColor: Color.lock.selection
            selectedTextColor: root.textColor
            font.family: Style.font.family
            font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)) : root.textSize
            font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
            cursorVisible: activeFocus && root.showPasswordCursor
            cursorDelegate: Rectangle {
              width: Style.space(7)
              color: passwordInput.cursorVisible ? root.textColor : "transparent"
            }

            onTextChanged: {
              if (!root.syncingPasswordText) root.passwordTextEdited(text)
              if (text.length > 0) root.wakeRequested()
              if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
            }

            onAccepted: root.submitPasswordLine()

            Keys.onPressed: function(event) {
              root.wakeRequested()
              if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_C)) {
                root.cancelPasswordMode()
                event.accepted = true
              } else if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U) {
                root.passwordTextEdited("")
                event.accepted = true
              }
            }
          }
        }
      }

      Row {
        id: actionRow
        width: parent.width
        spacing: Style.spacing.huge

        Repeater {
          model: [
            { label: "help", command: "help" },
            { label: "login", command: "login" },
            { label: "suspend", command: "suspend" },
            { label: "hibernate", command: "hibernate" },
            { label: "reboot", command: "reboot" },
            { label: "poweroff", command: "poweroff" }
          ]

          Text {
            required property var modelData
            text: "[" + modelData.label + "]"
            color: actionMouse.containsMouse ? root.accentColor : root.mutedColor
            font.family: Style.font.family
            font.pixelSize: root.smallTextSize

            MouseArea {
              id: actionMouse
              anchors.fill: parent
              enabled: root.inputEnabled
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.runCommand(modelData.command)
              onPositionChanged: root.wakeRequested()
            }
          }
        }
      }
    }
  }

  ListModel {
    id: terminalModel
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
