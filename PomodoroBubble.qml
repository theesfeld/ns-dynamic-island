import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property string phase: main.pomodoroPhase
  readonly property int remaining: main.pomodoroRemainingSec
  readonly property int totalForPhase: main.pomodoroPhaseTotalSec
  readonly property real progress: totalForPhase > 0 ? 1.0 - (remaining / totalForPhase) : 0
  readonly property bool isWork: phase === "work"
  readonly property bool isBreak: phase === "break" || phase === "longBreak"

  readonly property color accent: isWork ? Color.mError
                                : isBreak ? Color.mTertiary
                                : Color.mPrimary

  function mmss(s) {
    const m = Math.floor(s / 60)
    const r = s % 60
    return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
  }

  RowLayout {
    anchors.fill: parent
    spacing: 8

    // Phase icon w/ progress ring
    Item {
      Layout.preferredWidth: Math.max(18, parent.height - 8)
      Layout.preferredHeight: Math.max(18, parent.height - 8)
      Layout.alignment: Qt.AlignVCenter

      // Track ring
      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.alpha(root.accent, 0.18)
        border.color: Qt.alpha(root.accent, 0.85)
        border.width: 1
      }

      NIcon {
        anchors.centerIn: parent
        icon: root.isBreak ? "coffee" : "clock"
        pointSize: Style.fontSizeS
        color: root.accent
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: root.mmss(root.remaining)
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        font.family: "monospace"
        elide: Text.ElideRight
      }

      NText {
        Layout.fillWidth: true
        visible: root.expanded
        text: {
          const base = root.isWork
            ? "Focus — cycle " + main.pomodoroCycleCount
            : (root.phase === "longBreak" ? "Long break" : "Short break")
          if (main.pomodoroStatsEnabled && main.pomodoroTodayCycles > 0) {
            return base + " · " + main.pomodoroTodayCycles + " today (" + main.pomodoroTodayFocusMin + "m)"
          }
          return base
        }
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 2
        Layout.topMargin: 3
        visible: root.expanded
        color: Qt.alpha(Color.mOutline, 0.35)
        radius: 1

        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: parent.width * Math.max(0, Math.min(1, root.progress))
          color: root.accent
          radius: 1

          Behavior on width {
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
          }
        }
      }
    }

    // Transport: pause/resume + skip
    RowLayout {
      visible: root.expanded
      Layout.alignment: Qt.AlignVCenter
      spacing: 2

      NIconButton {
        icon: main.pomodoroPaused ? "media-play" : "media-pause"
        onClicked: main.pomodoroPaused ? main.pomodoroResume() : main.pomodoroPause()
      }
      NIconButton {
        icon: "media-next"
        onClicked: main.pomodoroSkip()
      }
      NIconButton {
        icon: "close"
        onClicked: main.pomodoroStop()
      }
    }
  }
}
