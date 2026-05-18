import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.Compositor
import qs.Services.Media
import qs.Services.UI
import qs.Widgets

// Bar widget for Noctalia — a true mini dynamic island. Shows multiple
// concurrent pieces of state in one morphing capsule:
//   [active-window-icon] window-title │ ♪ Track │ [REC 12:34] │ 🔔 │ ⏲ 19:43 │ 12:34 ☀ 22°C
// Click to open the expanded Panel.qml. Right-click for context menu.
Item {
  id: root

  // Plugin API (injected by PluginService)
  property var pluginApi: null

  // Required bar widget properties
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  readonly property var cfg: pluginApi?.pluginSettings || ({})
  readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  readonly property string screenName: screen ? screen.name : ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  // ── Settings ─────────────────────────────────────────────
  readonly property bool barShowClock:          cfg.barShowClock          ?? defaults.barShowClock          ?? true
  readonly property bool barShowWeather:        cfg.barShowWeather        ?? defaults.barShowWeather        ?? true
  readonly property bool barShowActiveWindow:   cfg.barShowActiveWindow   ?? defaults.barShowActiveWindow   ?? true
  readonly property bool barShowMedia:          cfg.barShowMedia          ?? defaults.barShowMedia          ?? true
  readonly property bool barShowNotifications:  cfg.barShowNotifications  ?? defaults.barShowNotifications  ?? true
  readonly property bool barShowRecording:      cfg.barShowRecording      ?? defaults.barShowRecording      ?? true
  readonly property bool barShowBattery:        cfg.barShowBattery        ?? defaults.barShowBattery        ?? true
  readonly property bool barShowPomodoro:       cfg.barShowPomodoro       ?? defaults.barShowPomodoro       ?? true
  readonly property bool barShowPrivacy:        cfg.barShowPrivacy        ?? defaults.barShowPrivacy        ?? true
  readonly property string barClickAction:      cfg.barClickAction || defaults.barClickAction || "panel"
  readonly property int  activeWindowMaxChars:  cfg.activeWindowMaxChars  ?? defaults.activeWindowMaxChars  ?? 28
  readonly property int  mediaTitleMaxChars:    cfg.mediaTitleMaxChars    ?? defaults.mediaTitleMaxChars    ?? 22

  // ── Active window (reactive via CompositorService) ───────
  property string activeWindowTitle: ""
  property string activeWindowAppId: ""

  function refreshActiveWindow() {
    const w = CompositorService.getFocusedWindow ? CompositorService.getFocusedWindow() : null
    if (w) {
      root.activeWindowTitle = w.title || ""
      root.activeWindowAppId = w.appId || ""
    } else if (typeof CompositorService.getFocusedWindowTitle === "function") {
      root.activeWindowTitle = CompositorService.getFocusedWindowTitle() || ""
      root.activeWindowAppId = ""
    } else {
      root.activeWindowTitle = ""
      root.activeWindowAppId = ""
    }
  }

  Connections {
    target: CompositorService
    function onActiveWindowChanged()  { root.refreshActiveWindow() }
    function onWindowListChanged()    { root.refreshActiveWindow() }
    function onWorkspaceChanged()     { root.refreshActiveWindow() }
  }

  Component.onCompleted: refreshActiveWindow()

  property bool   recordingActive: false
  property string recordingElapsed: ""
  property real   recordingStartedAtMs: 0

  property int    batteryLevel: -1
  property string batteryState: ""

  property string weatherTemp: ""
  property string weatherCondition: ""

  property bool   pomodoroActive: false
  property int    pomodoroRemainingSec: 0
  property string pomodoroPhase: "idle"

  property bool   micInUse: false
  property bool   camInUse: false

  // ── Reactive state from Noctalia services ────────────────
  readonly property bool mediaActive: barShowMedia && MediaService.trackTitle.length > 0
  readonly property bool notifActive: barShowNotifications
    && NotificationService.popupModel
    && NotificationService.popupModel.count > 0
  readonly property int notifCount: notifActive ? NotificationService.popupModel.count : 0
  readonly property var firstNotif: notifActive ? NotificationService.popupModel.get(0) : null
  readonly property int notifUrgency: firstNotif && firstNotif.urgency !== undefined
    ? firstNotif.urgency : 1

  property string clockText: ""

  Timer {
    interval: 15000
    running: root.barShowClock
    repeat: true
    triggeredOnStart: true
    onTriggered: root.clockText = Qt.formatTime(new Date(), "HH:mm")
  }

  // ── Recording polling ────────────────────────────────────
  Timer {
    interval: 3000
    running: root.barShowRecording
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!recProbe.running) recProbe.running = true
  }

  Process {
    id: recProbe
    running: false
    command: ["sh", "-c", "pgrep -x gpu-screen-recorder >/dev/null 2>&1 || pgrep -x wf-recorder >/dev/null 2>&1 || pgrep -x obs >/dev/null 2>&1 || pgrep -x kooha >/dev/null 2>&1"]
    onExited: function (exitCode) {
      const was = root.recordingActive
      const now = (exitCode === 0)
      if (now && !was) root.recordingStartedAtMs = Date.now()
      if (!now) root.recordingStartedAtMs = 0
      root.recordingActive = now
      running = false
    }
  }

  Timer {
    interval: 1000
    running: root.recordingActive && root.recordingStartedAtMs > 0
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      const secs = Math.max(0, Math.floor((Date.now() - root.recordingStartedAtMs) / 1000))
      const h = Math.floor(secs / 3600), m = Math.floor((secs % 3600) / 60), s = secs % 60
      root.recordingElapsed = (h > 0 ? h + ":" + (m < 10 ? "0" : "") : "")
        + m + ":" + (s < 10 ? "0" : "") + s
    }
  }

  // ── Battery polling ──────────────────────────────────────
  Timer {
    interval: 30000
    running: root.barShowBattery
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!batProbe.running) batProbe.running = true
  }

  Process {
    id: batProbe
    running: false
    command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*/; do [ -d \"$b\" ] && c=$(cat \"$b\"capacity 2>/dev/null) && s=$(cat \"$b\"status 2>/dev/null) && echo \"$c|$s\" && break; done"]
    stdout: StdioCollector {
      onStreamFinished: {
        const line = (text || "").trim()
        if (line.length === 0) { root.batteryLevel = -1; root.batteryState = ""; return }
        const parts = line.split("|")
        const lvl = parseInt(parts[0])
        if (isNaN(lvl)) { root.batteryLevel = -1; root.batteryState = ""; return }
        root.batteryLevel = lvl
        root.batteryState = (parts[1] || "").trim()
      }
    }
    onExited: running = false
  }

  // ── Weather: read from the shared cache file written by Main.qml ──
  Timer {
    interval: 30 * 60 * 1000
    running: root.barShowWeather
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!weatherProbe.running) weatherProbe.running = true
  }

  Process {
    id: weatherProbe
    running: false
    command: ["sh", "-c", "cat \"$HOME/.cache/ns-dynamic-island/weather.json\" 2>/dev/null || true"]
    stdout: StdioCollector {
      onStreamFinished: {
        const t = (text || "").trim()
        if (t.length === 0) return
        try {
          const j = JSON.parse(t)
          root.weatherTemp = j.temp || ""
          root.weatherCondition = j.condition || ""
        } catch (e) {}
      }
    }
    onExited: running = false
  }

  // ── Privacy (mic/cam) polling ────────────────────────────
  Timer {
    interval: 4000
    running: root.barShowPrivacy
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!privacyProbe.running) privacyProbe.running = true
  }

  Process {
    id: privacyProbe
    running: false
    command: ["sh", "-c",
      "m=0; c=0; if command -v pactl >/dev/null 2>&1; then n=$(pactl list source-outputs 2>/dev/null | grep -cE '^Source Output #' || echo 0); [ \"$n\" -gt 0 ] 2>/dev/null && m=1; fi; for d in /dev/video*; do [ -e \"$d\" ] && command -v fuser >/dev/null 2>&1 && fuser \"$d\" >/dev/null 2>&1 && c=1 && break; done; echo \"$m|$c\""]
    stdout: StdioCollector {
      onStreamFinished: {
        const line = (text || "").trim()
        if (line.length === 0) return
        const parts = line.split("|")
        root.micInUse = parts[0] === "1"
        root.camInUse = parts[1] === "1"
      }
    }
    onExited: running = false
  }

  // ── Helpers ──────────────────────────────────────────────
  function truncate(s, n) {
    if (!s) return ""
    return s.length > n ? s.substring(0, n) + "…" : s
  }

  function weatherIcon(cond) {
    const c = (cond || "").toLowerCase()
    if (c.indexOf("thunder") !== -1) return "weather-storm"
    if (c.indexOf("snow") !== -1)    return "weather-snow"
    if (c.indexOf("rain") !== -1 || c.indexOf("drizzle") !== -1) return "weather-rain"
    if (c.indexOf("cloud") !== -1)   return "weather-cloud"
    if (c.indexOf("fog") !== -1)     return "weather-fog"
    return "weather-sun"
  }

  function batteryIcon() {
    if (batteryState === "Charging") return "battery-charging"
    if (batteryLevel >= 90) return "battery-full"
    if (batteryLevel >= 60) return "battery-high"
    if (batteryLevel >= 30) return "battery-medium"
    if (batteryLevel >= 10) return "battery-low"
    return "battery-empty"
  }

  function mmss(s) {
    const m = Math.floor(s / 60), r = s % 60
    return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
  }

  function pomodoroIcon() {
    return pomodoroPhase === "work" ? "timer" : "coffee"
  }

  readonly property bool batteryShouldShow:
    barShowBattery && batteryLevel >= 0 && (batteryLevel <= 25 || batteryState === "Charging")

  // ── Dimensions ───────────────────────────────────────────
  readonly property real contentWidth: content.implicitWidth + Style.marginM * 2
  readonly property real contentHeight: capsuleHeight

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  Behavior on implicitWidth { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

  // ── Visual capsule ───────────────────────────────────────
  Rectangle {
    id: visualCapsule
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    width: root.contentWidth
    height: root.contentHeight
    color: mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
    radius: Style.radiusL
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth
    clip: true

    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 140 } }

    // Critical urgency / recording / low battery glow ring
    readonly property bool glowOn:
        (root.notifActive && root.notifUrgency === 2)
     || root.recordingActive
     || (root.batteryLevel >= 0 && root.batteryLevel <= 10 && root.batteryState !== "Charging")

    Rectangle {
      anchors.fill: parent
      anchors.margins: -2
      radius: parent.radius + 2
      color: "transparent"
      border.width: 1
      border.color: Color.mError
      visible: visualCapsule.glowOn

      SequentialAnimation on opacity {
        running: visualCapsule.glowOn
        loops: Animation.Infinite
        NumberAnimation { to: 0.4; duration: 800; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
      }
    }

    RowLayout {
      id: content
      anchors.centerIn: parent
      spacing: Style.marginS

      // ── Active window ────────────────────────────────
      RowLayout {
        spacing: 4
        visible: root.barShowActiveWindow && root.activeWindowTitle.length > 0

        NIcon {
          icon: "window"
          color: Color.mOnSurfaceVariant
          applyUiScale: true
        }
        NText {
          text: root.truncate(root.activeWindowTitle, root.activeWindowMaxChars)
          color: Color.mOnSurface
          pointSize: barFontSize
          elide: Text.ElideRight
          Layout.maximumWidth: 240
        }
      }

      Rectangle {
        visible: root.barShowActiveWindow && root.activeWindowTitle.length > 0
          && (root.mediaActive || root.recordingActive || root.notifActive
              || root.pomodoroActive || root.batteryShouldShow)
        Layout.preferredWidth: 1
        Layout.preferredHeight: parent.height * 0.55
        color: Qt.alpha(Color.mOutline, 0.5)
      }

      // ── Media ────────────────────────────────────────
      RowLayout {
        spacing: 4
        visible: root.mediaActive

        NIcon {
          icon: MediaService.isPlaying ? "player-play" : "player-pause"
          color: Color.mPrimary
          applyUiScale: true
        }
        NText {
          text: root.truncate(MediaService.trackTitle, root.mediaTitleMaxChars)
          color: Color.mOnSurface
          pointSize: barFontSize
          elide: Text.ElideRight
          Layout.maximumWidth: 220
        }
      }

      Rectangle {
        visible: root.mediaActive
          && (root.recordingActive || root.notifActive
              || root.pomodoroActive || root.batteryShouldShow)
        Layout.preferredWidth: 1
        Layout.preferredHeight: parent.height * 0.55
        color: Qt.alpha(Color.mOutline, 0.5)
      }

      // ── Recording ────────────────────────────────────
      RowLayout {
        spacing: 4
        visible: root.barShowRecording && root.recordingActive

        Rectangle {
          width: 8; height: 8; radius: 4
          color: Color.mError
          SequentialAnimation on opacity {
            running: root.recordingActive
            loops: Animation.Infinite
            NumberAnimation { to: 0.35; duration: 700; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
          }
        }
        NText {
          text: root.recordingElapsed.length > 0 ? root.recordingElapsed : "REC"
          color: Color.mError
          pointSize: barFontSize
          font.weight: Font.Bold
          font.family: "monospace"
        }
      }

      // ── Notification pip ─────────────────────────────
      RowLayout {
        spacing: 3
        visible: root.notifActive

        NIcon {
          icon: root.notifUrgency === 2 ? "alert" : "bell"
          color: root.notifUrgency === 2 ? Color.mError : Color.mTertiary
          applyUiScale: true
        }
        // Count badge
        Rectangle {
          visible: root.notifCount > 1
          radius: 8
          height: 14
          width: Math.max(16, countLabel.implicitWidth + 6)
          color: Qt.alpha(Color.mTertiary, 0.22)
          border.color: Qt.alpha(Color.mTertiary, 0.6)
          border.width: 1
          NText {
            id: countLabel
            anchors.centerIn: parent
            text: root.notifCount
            color: Color.mTertiary
            pointSize: barFontSize * 0.75
            font.weight: Font.Bold
          }
        }
      }

      // ── Pomodoro ─────────────────────────────────────
      RowLayout {
        spacing: 4
        visible: root.barShowPomodoro && root.pomodoroActive

        NIcon {
          icon: root.pomodoroIcon()
          color: root.pomodoroPhase === "work" ? Color.mError : Color.mTertiary
          applyUiScale: true
        }
        NText {
          text: root.mmss(root.pomodoroRemainingSec)
          color: Color.mOnSurface
          pointSize: barFontSize
          font.family: "monospace"
        }
      }

      // ── Privacy indicators ───────────────────────────
      RowLayout {
        spacing: 3
        visible: root.barShowPrivacy && (root.micInUse || root.camInUse)
        Rectangle {
          visible: root.micInUse
          width: 6; height: 6; radius: 3
          color: Color.mError
        }
        Rectangle {
          visible: root.camInUse
          width: 6; height: 6; radius: 3
          color: Color.mTertiary
        }
      }

      // ── Battery ──────────────────────────────────────
      RowLayout {
        spacing: 3
        visible: root.batteryShouldShow

        NIcon {
          icon: root.batteryIcon()
          color: root.batteryLevel <= 10 && root.batteryState !== "Charging"
                 ? Color.mError : Color.mOnSurfaceVariant
          applyUiScale: true
        }
        NText {
          text: root.batteryLevel + "%"
          color: Color.mOnSurface
          pointSize: barFontSize
        }
      }

      // ── Clock + weather (always rightmost) ───────────
      Rectangle {
        visible: (root.barShowClock || root.barShowWeather)
          && (root.activeWindowTitle.length > 0 || root.mediaActive
              || root.recordingActive || root.notifActive || root.pomodoroActive)
        Layout.preferredWidth: 1
        Layout.preferredHeight: parent.height * 0.55
        color: Qt.alpha(Color.mOutline, 0.5)
      }

      NText {
        visible: root.barShowClock
        text: root.clockText
        color: Color.mOnSurface
        pointSize: barFontSize
        font.weight: Font.Medium
      }

      RowLayout {
        spacing: 3
        visible: root.barShowWeather && root.weatherTemp.length > 0

        NIcon {
          icon: root.weatherIcon(root.weatherCondition)
          color: Color.mOnSurfaceVariant
          applyUiScale: true
        }
        NText {
          text: root.weatherTemp
          color: Color.mOnSurfaceVariant
          pointSize: barFontSize
        }
      }
    }
  }

  // ── Interaction ──────────────────────────────────────────
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    onClicked: (mouse) => {
      if (mouse.button === Qt.MiddleButton && root.mediaActive) {
        Quickshell.execDetached(["sh", "-c", "playerctl play-pause 2>/dev/null || true"])
        return
      }
      if (mouse.button === Qt.RightButton) {
        // Right-click: dismiss top notification or stop recording
        if (root.notifActive) {
          Quickshell.execDetached(["sh", "-c", "qs ipc call plugin:ns-dynamic-island hide 2>/dev/null || true"])
        }
        return
      }
      // Left-click: open the detail panel
      if (root.barClickAction === "panel" && pluginApi && pluginApi.openPanel) {
        if (pluginApi.panelOpenScreen) pluginApi.closePanel(root.screen)
        else pluginApi.openPanel(root.screen, root)
      } else if (root.barClickAction === "toggle") {
        Quickshell.execDetached(["sh", "-c", "qs ipc call plugin:ns-dynamic-island toggle 2>/dev/null || true"])
      } else {
        Quickshell.execDetached(["sh", "-c", "qs ipc call plugin:ns-dynamic-island peek 2>/dev/null || true"])
      }
    }
  }
}
