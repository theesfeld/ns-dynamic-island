import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property int level: main.batteryLevel
  readonly property string state: main.batteryState
  readonly property bool charging: state === "Charging" || state === "Full"
  readonly property bool critical: level >= 0 && level <= 10 && !charging
  readonly property bool low: level >= 0 && level <= 20 && !charging

  readonly property color accent: critical ? Color.mError
                                : low ? Color.mTertiary
                                : charging ? Color.mPrimary
                                : Color.mOnSurface

  function batteryIcon(lvl, ch) {
    if (ch) return "battery-charging"
    if (lvl >= 90) return "battery"
    if (lvl >= 60) return "battery-4"
    if (lvl >= 30) return "battery-3"
    if (lvl >= 10) return "battery-2"
    return "battery-off"
  }

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
        color: Qt.alpha(root.accent, 0.18)
        border.color: Qt.alpha(root.accent, root.critical ? 0.9 : 0.5)
        border.width: root.critical ? 1 : 0

        SequentialAnimation on opacity {
          running: root.critical
          loops: Animation.Infinite
          NumberAnimation { to: 0.55; duration: 700; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
        }
      }

      NIcon {
        anchors.centerIn: parent
        icon: root.batteryIcon(root.level, root.charging)
        pointSize: Style.fontSizeS
        color: root.accent
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: (root.level >= 0 ? root.level + "%" : "—")
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded
        text: {
          const base = root.charging
            ? (root.state === "Full" ? "Fully charged" : "Charging")
            : (root.critical ? "Critical" : (root.low ? "Low battery" : "Discharging"))
          const m = main.batteryMinutesRemaining
          if (m > 0 && root.state !== "Full") {
            const h = Math.floor(m / 60), mm = m % 60
            const suffix = h > 0 ? (h + "h " + mm + "m") : (mm + "m")
            return base + " · " + suffix + (root.charging ? " to full" : " left")
          }
          return base
        }
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }
    }
  }
}
