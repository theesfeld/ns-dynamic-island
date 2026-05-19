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

// Bar widget for Noctalia — a true mini dynamic island. Glass-morphism
// capsule with multi-layered highlights, drop shadow, hover lift, click
// ripple, and live state from every interesting subsystem.
Item {
  id: root

  // Plugin API (injected by PluginService)
  property var pluginApi: null

  // Bar widget contract (Noctalia)
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
  readonly property int  activeWindowMaxChars:  cfg.activeWindowMaxChars  ?? defaults.activeWindowMaxChars  ?? 28
  readonly property int  mediaTitleMaxChars:    cfg.mediaTitleMaxChars    ?? defaults.mediaTitleMaxChars    ?? 22

  // Visual settings
  readonly property bool glassEffect:    cfg.glassEffect    ?? defaults.glassEffect    ?? true
  readonly property bool hoverLift:      cfg.barHoverLift   ?? defaults.barHoverLift   ?? true
  readonly property bool clickRipple:    cfg.barClickRipple ?? defaults.barClickRipple ?? true
  readonly property bool dynamicAccent:  cfg.barDynamicAccent ?? defaults.barDynamicAccent ?? true

  // ── Active window (via CompositorService) ────────────────
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

  // ── Polled state ─────────────────────────────────────────
  property bool   recordingActive: false
  property string recordingElapsed: ""
  property real   recordingStartedAtMs: 0

  property int    batteryLevel: -1
  property string batteryState: ""

  property string weatherTemp: ""
  property string weatherCondition: ""

  // Pomodoro live state — mirrored from Main.qml via pluginSettings
  readonly property string pomodoroPhase: cfg.pomodoroLivePhase || "idle"
  readonly property int    pomodoroRemainingSec: cfg.pomodoroLiveRemaining || 0
  readonly property int    pomodoroLiveTotal: cfg.pomodoroLiveTotal || 0
  readonly property bool   pomodoroActive: pomodoroPhase !== "idle"

  property bool   micInUse: false
  property bool   camInUse: false

  // ── Services (reactive) ──────────────────────────────────
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

  // ── Weather (from shared cache file) ─────────────────────
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

  // ── Privacy (mic / cam) polling ──────────────────────────
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

  // Dynamic accent — color the capsule subtly based on what's "primary"
  readonly property color dynamicAccentColor: {
    if (!dynamicAccent) return Color.mPrimary
    if (notifActive && notifUrgency === 2) return Color.mError
    if (recordingActive) return Color.mError
    if (batteryLevel >= 0 && batteryLevel <= 10 && batteryState !== "Charging") return Color.mError
    if (pomodoroActive && pomodoroPhase === "work") return Color.mError
    if (mediaActive) return Color.mPrimary
    if (notifActive) return Color.mTertiary
    return Color.mPrimary
  }

  // ── Dimensions ───────────────────────────────────────────
  readonly property real contentWidth: content.implicitWidth + Style.marginM * 2
  readonly property real contentHeight: capsuleHeight

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  Behavior on implicitWidth { NumberAnimation { duration: Style.animationNormal; easing.type: Easing.OutCubic } }

  // ── Visual capsule with glass-morphism ───────────────────
  Item {
    id: capsuleWrapper
    width: root.contentWidth
    height: root.contentHeight
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    scale: (root.hoverLift && mouseArea.containsMouse) ? 1.04 : 1.0

    Behavior on scale {
      NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutCubic }
    }

    // Drop shadow under the capsule — multi-layer for depth
    Rectangle {
      anchors.fill: parent
      anchors.margins: -4
      radius: parent.height / 2 + 2
      color: "transparent"
      visible: root.glassEffect
      border.color: Qt.alpha("#000000", Style.shadowOpacity * 0.10)
      border.width: 3
      z: -2
    }
    Rectangle {
      anchors.fill: parent
      anchors.margins: -2
      radius: parent.height / 2
      color: "transparent"
      visible: root.glassEffect
      border.color: Qt.alpha("#000000", Style.shadowOpacity * 0.22)
      border.width: 2
      z: -2
    }
    Rectangle {
      anchors.fill: parent
      anchors.margins: -1
      radius: parent.height / 2
      color: "transparent"
      visible: root.glassEffect
      border.color: Qt.alpha("#000000", Style.shadowOpacity * 0.36)
      border.width: 1
      z: -2
    }

    // Main capsule background
    Rectangle {
      id: visualCapsule
      anchors.fill: parent
      radius: Style.radiusL
      color: mouseArea.containsMouse
        ? Color.mHover
        : (root.glassEffect ? Qt.alpha(Style.capsuleColor, 0.78) : Style.capsuleColor)
      border.color: mouseArea.containsMouse
        ? Qt.alpha(root.dynamicAccentColor, 0.65)
        : Style.capsuleBorderColor
      border.width: Style.capsuleBorderWidth
      clip: true

      Behavior on color { ColorAnimation { duration: Style.animationFast } }
      Behavior on border.color { ColorAnimation { duration: Style.animationFast } }

      // Idle breathing — when nothing active, the capsule gently breathes
      readonly property bool isIdle:
          !root.mediaActive && !root.notifActive && !root.recordingActive
       && !root.pomodoroActive && !root.batteryShouldShow
       && !(root.barShowPrivacy && (root.micInUse || root.camInUse))

      SequentialAnimation on opacity {
        running: visualCapsule.isIdle && root.glassEffect
        loops: Animation.Infinite
        NumberAnimation { to: 0.88; duration: 2400; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0;  duration: 2400; easing.type: Easing.InOutSine }
      }

      // Glass top-edge highlight — stronger sheen
      Rectangle {
        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          margins: 1
        }
        height: parent.height * 0.60
        radius: parent.radius
        visible: root.glassEffect
        gradient: Gradient {
          GradientStop { position: 0.0;  color: Qt.alpha("#ffffff", 0.22) }
          GradientStop { position: 0.55; color: Qt.alpha("#ffffff", 0.05) }
          GradientStop { position: 1.0;  color: Qt.alpha("#ffffff", 0.0) }
        }
      }

      // Bottom inner shadow — gives depth
      Rectangle {
        anchors {
          left: parent.left
          right: parent.right
          bottom: parent.bottom
          margins: 1
        }
        height: parent.height * 0.35
        radius: parent.radius
        visible: root.glassEffect
        gradient: Gradient {
          GradientStop { position: 0.0; color: Qt.alpha("#000000", 0.0) }
          GradientStop { position: 1.0; color: Qt.alpha("#000000", 0.18) }
        }
      }

      // Dynamic accent line at the very bottom — progress when applicable
      Rectangle {
        anchors {
          left: parent.left
          right: parent.right
          bottom: parent.bottom
          leftMargin: parent.radius
          rightMargin: parent.radius
        }
        height: 2
        opacity: 0.6
        color: Qt.alpha(Color.mOutline, 0.4)
        visible: root.dynamicAccent

        // Progress overlay: shown for media (position), pomodoro (countdown),
        // recording (elapsed seconds modulo 60 for an animated sweep).
        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          color: root.dynamicAccentColor
          opacity: 0.85

          readonly property real progressFrac: {
            if (root.mediaActive && MediaService.trackLength > 0) {
              return Math.max(0, Math.min(1, MediaService.currentPosition / MediaService.trackLength))
            }
            if (root.pomodoroActive && root.pomodoroRemainingSec > 0) {
              // pomodoroRemainingSec / total, but bar widget doesn't know total;
              // use the work-min default proportionally.
              return 0   // bar widget doesn't have access to pomodoro total, skip
            }
            return 0
          }

          width: parent.width * progressFrac
          Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.Linear } }
        }
      }
    }

    // Critical urgency / recording / low battery glow ring
    readonly property bool glowOn:
        (root.notifActive && root.notifUrgency === 2)
     || root.recordingActive
     || (root.batteryLevel >= 0 && root.batteryLevel <= 10 && root.batteryState !== "Charging")

    Rectangle {
      anchors.fill: parent
      anchors.margins: -3
      radius: parent.height / 2 + 3
      color: "transparent"
      border.width: 1
      border.color: Color.mError
      visible: capsuleWrapper.glowOn
      z: -1

      SequentialAnimation on opacity {
        running: capsuleWrapper.glowOn
        loops: Animation.Infinite
        NumberAnimation { to: 0.3; duration: 900; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
      }
    }

    // Click ripple (spawned on press)
    Item {
      anchors.fill: parent
      clip: true
      visible: root.clickRipple

      Rectangle {
        id: ripple
        width: 12; height: 12
        radius: 6
        color: Qt.alpha(root.dynamicAccentColor, 0.4)
        opacity: 0
        scale: 1

        ParallelAnimation {
          id: rippleAnim
          NumberAnimation { target: ripple; property: "scale"; from: 1; to: 25; duration: 500; easing.type: Easing.OutCubic }
          SequentialAnimation {
            NumberAnimation { target: ripple; property: "opacity"; from: 0.55; to: 0.55; duration: 60 }
            NumberAnimation { target: ripple; property: "opacity"; to: 0; duration: 440; easing.type: Easing.OutQuad }
          }
        }
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
          font.weight: Font.Medium
          elide: Text.ElideRight
          Layout.maximumWidth: 240
        }
      }

      Rectangle {
        visible: root.barShowActiveWindow && root.activeWindowTitle.length > 0
          && (root.mediaActive || root.recordingActive || root.notifActive
              || root.pomodoroActive || root.batteryShouldShow
              || (root.barShowPrivacy && (root.micInUse || root.camInUse)))
        Layout.preferredWidth: 1
        Layout.preferredHeight: parent.height * 0.55
        color: Qt.alpha(Color.mOutline, 0.5)
      }

      // ── Media (with album art chip) ──────────────────
      RowLayout {
        spacing: 4
        visible: root.mediaActive

        // Album art chip (tiny rounded square)
        Item {
          width: capsuleHeight * 0.62
          height: width
          visible: MediaService.trackArtUrl && MediaService.trackArtUrl.length > 0
          Layout.alignment: Qt.AlignVCenter

          Rectangle {
            anchors.fill: parent
            radius: 3
            color: Qt.alpha(Color.mSurfaceVariant, 0.6)
            clip: true

            Image {
              anchors.fill: parent
              source: MediaService.trackArtUrl
              fillMode: Image.PreserveAspectCrop
              visible: status === Image.Ready
              asynchronous: true
              cache: true
              sourceSize.width: width * 2
              sourceSize.height: height * 2
            }
            // accent ring
            Rectangle {
              anchors.fill: parent
              radius: parent.radius
              color: "transparent"
              border.color: Qt.alpha(Color.mPrimary, 0.45)
              border.width: 1
            }
          }
        }
        NIcon {
          visible: !(MediaService.trackArtUrl && MediaService.trackArtUrl.length > 0)
          icon: MediaService.isPlaying ? "media-play" : "media-pause"
          color: Color.mPrimary
          applyUiScale: true

          // Subtle pulse while playing
          SequentialAnimation on scale {
            running: MediaService.isPlaying
            loops: Animation.Infinite
            NumberAnimation { to: 1.12; duration: 700; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
          }
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
              || root.pomodoroActive || root.batteryShouldShow
              || (root.barShowPrivacy && (root.micInUse || root.camInUse)))
        Layout.preferredWidth: 1
        Layout.preferredHeight: parent.height * 0.55
        color: Qt.alpha(Color.mOutline, 0.5)
      }

      // ── Recording ────────────────────────────────────
      RowLayout {
        spacing: 4
        visible: root.barShowRecording && root.recordingActive

        Item {
          width: 10; height: 10

          Rectangle {
            anchors.centerIn: parent
            width: 8; height: 8; radius: 4
            color: Color.mError
            SequentialAnimation on opacity {
              running: root.recordingActive
              loops: Animation.Infinite
              NumberAnimation { to: 0.35; duration: 700; easing.type: Easing.InOutSine }
              NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
            }
          }
          // Halo ring
          Rectangle {
            anchors.centerIn: parent
            width: 8; height: 8; radius: 4
            color: "transparent"
            border.color: Qt.alpha(Color.mError, 0.6)
            border.width: 1
            SequentialAnimation on scale {
              running: root.recordingActive
              loops: Animation.Infinite
              NumberAnimation { to: 2.0; duration: 1400; easing.type: Easing.OutQuad }
              NumberAnimation { to: 1.0; duration: 0 }
            }
            SequentialAnimation on opacity {
              running: root.recordingActive
              loops: Animation.Infinite
              NumberAnimation { from: 0.7; to: 0; duration: 1400; easing.type: Easing.OutQuad }
              NumberAnimation { to: 0.7; duration: 0 }
            }
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
          SequentialAnimation on opacity {
            running: root.micInUse
            loops: Animation.Infinite
            NumberAnimation { to: 0.4; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
          }
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
              || root.recordingActive || root.notifActive || root.pomodoroActive
              || root.batteryShouldShow
              || (root.barShowPrivacy && (root.micInUse || root.camInUse)))
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

    onPressed: (mouse) => {
      if (!root.clickRipple) return
      ripple.x = mouse.x - ripple.width / 2
      ripple.y = mouse.y - ripple.height / 2
      rippleAnim.restart()
    }

    onClicked: (mouse) => {
      Logger.i("ns-dynamic-island", "bar click",
        mouse.button === Qt.LeftButton ? "left" :
        mouse.button === Qt.RightButton ? "right" : "middle")

      // Middle: media play/pause via service directly
      if (mouse.button === Qt.MiddleButton) {
        const p = MediaService.currentPlayer
        if (p) { if (MediaService.isPlaying) p.pause(); else p.play() }
        return
      }
      // Right: dismiss top notification if any, otherwise toggle DND
      if (mouse.button === Qt.RightButton) {
        if (root.notifActive && root.firstNotif) {
          try { root.firstNotif.dismiss() } catch (e) {
            Logger.w("ns-dynamic-island", "dismiss failed:", e)
          }
        }
        if (pluginApi && pluginApi.pluginSettings) {
          pluginApi.pluginSettings.dndEnabled = !pluginApi.pluginSettings.dndEnabled
          try { pluginApi.saveSettings() } catch (e) {
            Logger.w("ns-dynamic-island", "saveSettings failed:", e)
          }
        }
        return
      }
      // Left: toggle the detail panel. QML-injected methods may not pass
      // a typeof === "function" check, so just try the call and let it
      // throw if the method isn't there.
      if (!pluginApi) {
        Logger.w("ns-dynamic-island", "no pluginApi on left click")
        return
      }
      try {
        pluginApi.togglePanel(root.screen, root)
      } catch (e1) {
        Logger.w("ns-dynamic-island", "togglePanel failed:", e1, "— trying openPanel")
        try {
          pluginApi.openPanel(root.screen, root)
        } catch (e2) {
          Logger.w("ns-dynamic-island", "openPanel also failed:", e2)
        }
      }
    }

    // Scroll wheel: adjust system volume
    onWheel: (event) => {
      const sign = event.angleDelta.y > 0 ? 1 : -1
      Quickshell.execDetached(["sh", "-c",
        "if command -v wpctl >/dev/null 2>&1; then wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "
        + (sign > 0 ? "5%+" : "5%-")
        + "; elif command -v pactl >/dev/null 2>&1; then pactl set-sink-volume @DEFAULT_SINK@ "
        + (sign > 0 ? "+5%" : "-5%") + "; fi"])
    }
  }
}
