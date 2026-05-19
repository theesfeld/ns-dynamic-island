import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

// Compact OSD-style bubble used for volume and brightness peeks.
// The owner sets `kind`, `value` (0–100), `muted` (volume only).
Item {
  id: root
  required property var main
  property string kind: "volume"   // "volume" | "brightness"
  property int value: 0
  property bool muted: false

  readonly property bool expanded: main.expanded
  readonly property color accent: kind === "brightness" ? Color.mTertiary : Color.mPrimary

  function iconName() {
    if (kind === "brightness") {
      if (value >= 66) return "brightness-up"
      if (value >= 33) return "brightness-up"
      return "brightness-up"
    }
    if (muted) return "volume-mute"
    if (value <= 0) return "volume-mute"
    if (value < 34) return "volume-2"
    if (value < 67) return "volume-2"
    return "volume-high"
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
        color: Qt.alpha(root.accent, 0.18)
      }
      NIcon {
        anchors.centerIn: parent
        icon: root.iconName()
        pointSize: Style.fontSizeS
        color: root.muted ? Color.mError : root.accent
      }
    }

    // Bar + label
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: root.muted ? "Muted"
            : (root.kind === "brightness" ? "Brightness " : "Volume ") + root.value + "%"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 3
        Layout.topMargin: 4
        color: Qt.alpha(Color.mOutline, 0.35)
        radius: 1.5

        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: parent.width * Math.max(0, Math.min(1, root.value / 100))
          color: root.muted ? Qt.alpha(Color.mError, 0.85) : root.accent
          radius: 1.5

          Behavior on width {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
          }
        }
      }
    }
  }
}
