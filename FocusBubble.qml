import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

// Shown when Do-Not-Disturb / Focus mode is active. Acts as a status pip.
Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded

  RowLayout {
    anchors.fill: parent
    spacing: 6

    Item {
      Layout.preferredWidth: Math.max(18, parent.height - 8)
      Layout.preferredHeight: Math.max(18, parent.height - 8)
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.alpha(Color.mTertiary, 0.22)
        border.color: Qt.alpha(Color.mTertiary, 0.7)
        border.width: 1
      }
      NIcon {
        anchors.centerIn: parent
        icon: "moon"
        pointSize: Style.fontSizeS
        color: Color.mTertiary
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: "Do not disturb"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded
        text: "Notifications silenced"
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }
    }
  }
}
