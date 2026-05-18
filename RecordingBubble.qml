import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root

  RowLayout {
    anchors.centerIn: parent
    spacing: 6

    Item {
      Layout.preferredWidth: 12
      Layout.preferredHeight: 12

      Rectangle {
        id: dot
        anchors.centerIn: parent
        width: 10
        height: 10
        radius: width / 2
        color: Color.mError

        SequentialAnimation on opacity {
          loops: Animation.Infinite
          running: true
          NumberAnimation { to: 0.35; duration: 700; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
        }
      }

      // Soft halo to suggest pulsing
      Rectangle {
        anchors.centerIn: parent
        width: dot.width
        height: dot.height
        radius: width / 2
        color: "transparent"
        border.color: Qt.alpha(Color.mError, 0.6)
        border.width: 1

        SequentialAnimation on scale {
          loops: Animation.Infinite
          running: true
          NumberAnimation { to: 1.8; duration: 1400; easing.type: Easing.OutQuad }
          NumberAnimation { to: 1.0; duration: 0 }
        }
        SequentialAnimation on opacity {
          loops: Animation.Infinite
          running: true
          NumberAnimation { from: 0.7; to: 0; duration: 1400; easing.type: Easing.OutQuad }
          NumberAnimation { to: 0.7; duration: 0 }
        }
      }
    }

    NText {
      text: "REC"
      pointSize: Style.fontSizeXS
      font.weight: Font.Bold
      color: Color.mError
    }
  }
}
