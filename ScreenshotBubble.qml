import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property string path: main.screenshotPath

  RowLayout {
    anchors.fill: parent
    spacing: 8

    Item {
      Layout.preferredWidth: Math.max(18, parent.height - 8)
      Layout.preferredHeight: Math.max(18, parent.height - 8)
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.fill: parent
        radius: 4
        color: Qt.alpha(Color.mSurfaceVariant, 0.85)
        clip: true

        Image {
          anchors.fill: parent
          source: root.path.length > 0 ? "file://" + root.path : ""
          fillMode: Image.PreserveAspectCrop
          visible: status === Image.Ready
          asynchronous: true
          cache: false
          sourceSize.width: width * 2
          sourceSize.height: height * 2
        }
        NIcon {
          anchors.centerIn: parent
          icon: "camera"
          pointSize: Style.fontSizeS
          color: Color.mPrimary
          visible: root.path.length === 0
        }
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: "Screenshot saved"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded && root.path.length > 0
        text: root.path.split("/").pop()
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }
    }
  }
}
