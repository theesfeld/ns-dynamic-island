import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root

  RowLayout {
    anchors.centerIn: parent
    spacing: 6

    Rectangle {
      Layout.preferredWidth: 10
      Layout.preferredHeight: 10
      radius: width / 2
      color: Color.mError

      SequentialAnimation on opacity {
        loops: Animation.Infinite
        running: true
        NumberAnimation { to: 0.35; duration: 700; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
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
