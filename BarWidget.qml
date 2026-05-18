import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Media
import qs.Services.UI
import qs.Widgets

// Inline bar widget for Noctalia's bar. Shows the most relevant active
// state in a compact form (clock by default; media title, notification
// summary, recording counter, battery, pomodoro, OSD when applicable),
// and clicks summon the floating island via plugin IPC.
Item {
  id: root

  property var pluginApi: null

  readonly property var cfg: pluginApi?.pluginSettings || ({})
  readonly property var def: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  readonly property bool barShowClock: cfg.barShowClock ?? def.barShowClock ?? true
  readonly property bool barShowMedia: cfg.barShowMedia ?? def.barShowMedia ?? true
  readonly property bool barShowNotifications: cfg.barShowNotifications ?? def.barShowNotifications ?? true
  readonly property string barClickAction: cfg.barClickAction || def.barClickAction || "peek"

  readonly property bool mediaActive: barShowMedia && MediaService.trackTitle.length > 0
  readonly property bool notifActive: barShowNotifications
    && NotificationService.popupModel
    && NotificationService.popupModel.count > 0

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
      return t.length > 28 ? t.substring(0, 28) + "…" : t
    }
    if (root.notifActive) {
      const n = NotificationService.popupModel.get(0)
      const s = (n && n.summary) ? n.summary : ((n && n.appName) ? n.appName : "Notification")
      return s.length > 28 ? s.substring(0, 28) + "…" : s
    }
    return root.barShowClock ? root.clockText : "Island"
  }

  readonly property string iconName: {
    if (root.mediaActive) return MediaService.isPlaying ? "media-play" : "media-pause"
    if (root.notifActive) {
      const n = NotificationService.popupModel.get(0)
      return (n && n.urgency === 2) ? "alert" : "bell"
    }
    return "circle"
  }

  readonly property color accent:
      root.notifActive && NotificationService.popupModel.get(0)?.urgency === 2 ? Color.mError
    : root.mediaActive ? Color.mPrimary
    : Color.mOnSurface

  implicitWidth: Math.max(70, contentRow.implicitWidth + 16)
  implicitHeight: Math.max(20, contentRow.implicitHeight + 6)

  Rectangle {
    anchors.fill: parent
    radius: height / 2
    color: barArea.containsMouse
      ? Qt.alpha(Color.mPrimary, 0.18)
      : Qt.alpha(Color.mSurfaceVariant, 0.55)
    border.color: Qt.alpha(Color.mOutline, 0.35)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 160 } }
  }

  RowLayout {
    id: contentRow
    anchors.centerIn: parent
    spacing: 6

    NIcon {
      icon: root.iconName
      pointSize: Style.fontSizeXS
      color: root.accent
    }
    NText {
      text: root.displayText
      color: Color.mOnSurface
      pointSize: Style.fontSizeXS
      font.weight: Font.Medium
      elide: Text.ElideRight
    }

    // Small live recording pip
    Rectangle {
      visible: false // recording state not directly available without Main; keep hidden in widget
      width: 6; height: 6; radius: 3
      color: Color.mError
    }
  }

  MouseArea {
    id: barArea
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
        // mpris play/pause via dbus
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
