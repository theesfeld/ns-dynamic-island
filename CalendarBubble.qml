import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property string title: main.calendarNextTitle
  readonly property string when: main.calendarNextWhen
  readonly property color accent: main.calendarNextColor.length > 0
                                  ? main.calendarNextColor
                                  : Color.mPrimary

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
        color: Qt.alpha(root.accent, 0.2)
      }
      NIcon {
        anchors.centerIn: parent
        icon: "calendar"
        pointSize: Style.fontSizeS
        color: root.accent
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: root.title.length > 0 ? root.title : "No upcoming event"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded && root.when.length > 0
        text: root.when
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }
    }
  }
}
