import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property int remaining: main.timerRemainingSec
  readonly property int total: main.timerTotalSec
  readonly property real progress: total > 0 ? 1.0 - (remaining / total) : 0
  readonly property string label: main.timerLabel

  function mmss(s) {
    const m = Math.floor(s / 60)
    const r = s % 60
    return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
  }

  RowLayout {
    anchors.fill: parent
    spacing: 8

    Item {
      Layout.preferredWidth: Math.max(18, parent.height - 8)
      Layout.preferredHeight: Math.max(18, parent.height - 8)
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.alpha(Color.mTertiary, 0.18)
        border.color: Qt.alpha(Color.mTertiary, 0.7)
        border.width: 1
      }
      NIcon {
        anchors.centerIn: parent
        icon: "timer"
        pointSize: Style.fontSizeS
        color: Color.mTertiary
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
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
        visible: root.expanded && root.label.length > 0
        text: root.label
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
          color: Color.mTertiary
          radius: 1
          Behavior on width { NumberAnimation { duration: 500 } }
        }
      }
    }

    NIconButton {
      visible: root.expanded
      icon: "close"
      onClicked: main.timerStop()
    }
  }
}
