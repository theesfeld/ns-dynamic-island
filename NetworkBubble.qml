import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property string state: main.netState
  readonly property string ssid: main.netSsid
  readonly property bool vpn: main.netVpn
  readonly property int signal: main.netSignal // 0-100

  function netIcon() {
    if (state === "wifi") {
      if (signal >= 75) return "wifi-high"
      if (signal >= 50) return "wifi-medium"
      if (signal >= 25) return "wifi-low"
      return "wifi-off"
    }
    if (state === "ethernet") return "network-wired"
    if (state === "disconnected") return "network-off"
    return "network"
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
        color: Qt.alpha(Color.mPrimary, 0.18)
      }
      NIcon {
        anchors.centerIn: parent
        icon: root.netIcon()
        pointSize: Style.fontSizeS
        color: root.state === "disconnected" ? Color.mError : Color.mPrimary
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: {
          if (root.state === "wifi") return root.ssid.length > 0 ? root.ssid : "Wi-Fi"
          if (root.state === "ethernet") return "Wired"
          if (root.state === "disconnected") return "Disconnected"
          return "Network"
        }
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded
        text: root.vpn ? "VPN active"
            : root.state === "wifi" ? (root.signal + "% signal")
            : root.state
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }
    }

    Rectangle {
      visible: root.vpn
      Layout.preferredWidth: 6; Layout.preferredHeight: 6
      Layout.alignment: Qt.AlignVCenter
      radius: 3
      color: Color.mTertiary
    }
  }
}
