import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property string filename: main.downloadName
  readonly property real progress: main.downloadProgress // 0..1
  readonly property int speedKb: main.downloadSpeedKb

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
        border.color: Qt.alpha(Color.mPrimary, 0.7)
        border.width: 1

        Rectangle {
          anchors.bottom: parent.bottom
          anchors.left: parent.left
          width: parent.width
          height: parent.height * Math.max(0, Math.min(1, root.progress))
          radius: parent.radius
          color: Qt.alpha(Color.mPrimary, 0.45)
          Behavior on height { NumberAnimation { duration: 300 } }
        }
      }
      NIcon {
        anchors.centerIn: parent
        icon: "download"
        pointSize: Style.fontSizeS
        color: Color.mPrimary
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: root.filename.length > 0 ? root.filename : "Downloading…"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded
        text: Math.round(root.progress * 100) + "% · " + root.speedKb + " KB/s"
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
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
          color: Color.mPrimary
          radius: 1
          Behavior on width { NumberAnimation { duration: 400 } }
        }
      }
    }
  }
}
