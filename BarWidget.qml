import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.Media
import qs.Services.UI
import qs.Widgets

// Bar widget for Noctalia. Renders a compact capsule that mirrors the
// most relevant active state (media, notification, recording, OSD,
// pomodoro, battery, idle clock) and clicks summon / interact with
// the floating island via plugin IPC.
Item {
  id: root

  // Plugin API (injected by PluginService)
  property var pluginApi: null

  // Required properties for bar widgets (Noctalia contract)
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  // Settings helpers
  readonly property var cfg: pluginApi?.pluginSettings || ({})
  readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  // Per-screen bar properties
  readonly property string screenName: screen ? screen.name : ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  // ── Settings ─────────────────────────────────────────────
  readonly property bool barShowClock:         cfg.barShowClock ?? defaults.barShowClock ?? true
  readonly property bool barShowMedia:         cfg.barShowMedia ?? defaults.barShowMedia ?? true
  readonly property bool barShowNotifications: cfg.barShowNotifications ?? defaults.barShowNotifications ?? true
  readonly property string barClickAction:     cfg.barClickAction || defaults.barClickAction || "peek"

  // ── State (derived from services / settings) ─────────────
  readonly property bool mediaActive: barShowMedia && MediaService.trackTitle.length > 0
  readonly property bool notifActive: barShowNotifications
    && NotificationService.popupModel
    && NotificationService.popupModel.count > 0
  readonly property var firstNotif: notifActive
    ? NotificationService.popupModel.get(0)
    : null
  readonly property int notifUrgency: firstNotif && firstNotif.urgency !== undefined
    ? firstNotif.urgency
    : 1

  property string clockText: ""
  Timer {
    interval: 15000
    running: root.barShowClock
    repeat: true
    triggeredOnStart: true
    onTriggered: root.clockText = Qt.formatTime(new Date(), "HH:mm")
  }

  readonly property string displayText: {
    if (root.mediaActive) {
      const t = MediaService.trackTitle
      return t.length > 24 ? t.substring(0, 24) + "…" : t
    }
    if (root.notifActive) {
      const n = root.firstNotif
      const s = (n && n.summary) ? n.summary : ((n && n.appName) ? n.appName : "Notification")
      return s.length > 24 ? s.substring(0, 24) + "…" : s
    }
    return root.barShowClock ? root.clockText : "Island"
  }

  readonly property string iconName: {
    if (root.mediaActive) return MediaService.isPlaying ? "player-play" : "player-pause"
    if (root.notifActive) return root.notifUrgency === 2 ? "alert" : "bell"
    return "circle"
  }

  readonly property color accent:
      root.notifActive && root.notifUrgency === 2 ? Color.mError
    : root.mediaActive ? Color.mPrimary
    : Color.mOnSurface

  // ── Dimensions ───────────────────────────────────────────
  readonly property real contentWidth: content.implicitWidth + Style.marginM * 2
  readonly property real contentHeight: capsuleHeight

  implicitWidth: contentWidth
  implicitHeight: contentHeight

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

    // Critical glow for urgency-2 notifications
    Rectangle {
      anchors.fill: parent
      anchors.margins: -2
      radius: parent.radius + 2
      color: "transparent"
      border.color: Qt.alpha(Color.mError, 0.55)
      border.width: 1
      visible: root.notifActive && root.notifUrgency === 2

      SequentialAnimation on opacity {
        running: parent.visible
        loops: Animation.Infinite
        NumberAnimation { to: 0.4; duration: 800; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
      }
    }

    RowLayout {
      id: content
      anchors.centerIn: parent
      spacing: Style.marginS

      NIcon {
        icon: root.iconName
        color: root.accent
        applyUiScale: true
      }

      NText {
        text: root.displayText
        color: Color.mOnSurface
        pointSize: barFontSize
        font.weight: Font.Medium
        elide: Text.ElideRight
        Layout.maximumWidth: 220
      }

      // Live recording pip
      Rectangle {
        visible: false   // recording state lives in Main; bar widget can't read it directly
        width: 6; height: 6; radius: 3
        color: Color.mError
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
      if (mouse.button === Qt.RightButton) {
        Quickshell.execDetached(["sh", "-c",
          "qs ipc call plugin:ns-dynamic-island toggle 2>/dev/null || true"])
        return
      }
      if (mouse.button === Qt.MiddleButton && root.mediaActive) {
        Quickshell.execDetached(["sh", "-c",
          "playerctl play-pause 2>/dev/null || true"])
        return
      }
      const action = root.barClickAction === "toggle" ? "toggle" : "peek"
      Quickshell.execDetached(["sh", "-c",
        "qs ipc call plugin:ns-dynamic-island " + action + " 2>/dev/null || true"])
    }
  }
}
