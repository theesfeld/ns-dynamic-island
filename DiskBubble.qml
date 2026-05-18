import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property int  pct: main.diskUsagePct
  readonly property string mount: main.diskUsageMount
  readonly property bool critical: pct >= 95
  readonly property color accent: critical ? Color.mError
                                   : (pct >= 85 ? Color.mTertiary : Color.mPrimary)

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
        border.color: Qt.alpha(root.accent, root.critical ? 0.9 : 0)
        border.width: root.critical ? 1 : 0

        SequentialAnimation on opacity {
          running: root.critical
          loops: Animation.Infinite
          NumberAnimation { to: 0.55; duration: 800; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.0;  duration: 800; easing.type: Easing.InOutSine }
        }
      }
      NIcon {
        anchors.centerIn: parent
        icon: "disk"
        pointSize: Style.fontSizeS
        color: root.accent
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: root.pct + "% full"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded
        text: (root.critical ? "Almost full · " : "") + (root.mount.length > 0 ? root.mount : "/")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }
    }
  }
}
