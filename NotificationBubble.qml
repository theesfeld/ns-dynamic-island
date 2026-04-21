import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property var notif: main.activeNotification

  RowLayout {
    anchors.fill: parent
    spacing: 8
    visible: root.notif !== null

    Item {
      Layout.preferredWidth: parent.height - 8
      Layout.preferredHeight: parent.height - 8
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.alpha(Color.mTertiary, 0.25)

        Image {
          anchors.fill: parent
          source: root.notif ? root.notif.image : ""
          fillMode: Image.PreserveAspectCrop
          visible: root.notif && root.notif.image && root.notif.image.length > 0
          asynchronous: true
        }

        NIcon {
          anchors.centerIn: parent
          icon: "bell"
          visible: !root.notif || !root.notif.image || root.notif.image.length === 0
          color: Color.mTertiary
        }
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: root.notif ? (root.notif.summary || root.notif.appName) : ""
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
      }

      NText {
        Layout.fillWidth: true
        visible: root.expanded && root.notif && root.notif.body.length > 0
        text: root.notif ? root.notif.body : ""
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
        maximumLineCount: 2
        wrapMode: Text.WordWrap
      }
    }
  }
}
