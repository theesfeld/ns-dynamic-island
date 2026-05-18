import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

// Tiny privacy indicator: shows a colored dot when the mic (or camera) is in use.
// Sits inside an existing bubble row without claiming much horizontal space.
Item {
  id: root
  required property var main

  readonly property bool micOn: main.micInUse
  readonly property bool camOn: main.camInUse
  readonly property bool any: micOn || camOn

  implicitWidth: any ? (micOn && camOn ? 22 : 12) : 0
  implicitHeight: 12
  visible: any

  RowLayout {
    anchors.centerIn: parent
    spacing: 4

    Rectangle {
      visible: root.micOn
      width: 8; height: 8; radius: 4
      color: Color.mError

      SequentialAnimation on opacity {
        running: root.micOn
        loops: Animation.Infinite
        NumberAnimation { to: 0.55; duration: 900; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
      }
    }

    Rectangle {
      visible: root.camOn
      width: 8; height: 8; radius: 4
      color: Color.mTertiary
    }
  }
}
