import QtQuick
import qs.Commons

// Pseudo audio-level bars — pure CSS-style animation, not real audio data.
// Bars heights oscillate in randomized but coordinated phases so it looks alive.
Row {
  id: root
  spacing: 2
  property color tint: Color.mPrimary
  property bool playing: false
  property int barCount: 4
  property int maxHeight: 12

  Repeater {
    model: root.barCount
    delegate: Rectangle {
      width: 2
      height: 3 + (index % 3) * 2
      anchors.verticalCenter: parent.verticalCenter
      radius: 1
      color: root.tint

      readonly property int phase: index * 130

      SequentialAnimation on height {
        running: root.playing
        loops: Animation.Infinite
        PauseAnimation { duration: phase }
        NumberAnimation { to: root.maxHeight; duration: 320 + (index * 47); easing.type: Easing.InOutSine }
        NumberAnimation { to: 3;              duration: 280 + (index * 53); easing.type: Easing.InOutSine }
        NumberAnimation { to: root.maxHeight * 0.6; duration: 260; easing.type: Easing.InOutSine }
        NumberAnimation { to: 4;              duration: 300; easing.type: Easing.InOutSine }
      }

      // Pause state: bars at a calm low height
      Behavior on height {
        enabled: !root.playing
        NumberAnimation { duration: 200 }
      }
    }
  }
}
