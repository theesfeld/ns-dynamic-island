import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property string event: main.btEvent     // "connected" | "disconnected" | "pairing"
  readonly property string device: main.btDevice

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
      }
      NIcon {
        anchors.centerIn: parent
        icon: "bluetooth"
        pointSize: Style.fontSizeS
        color: Color.mTertiary
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: root.device.length > 0 ? root.device : "Bluetooth"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded
        text: root.event === "connected" ? "Connected"
            : root.event === "disconnected" ? "Disconnected"
            : root.event === "pairing" ? "Pairing…"
            : ""
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }
    }
  }
}
