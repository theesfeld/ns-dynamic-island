import QtQuick
import qs.Commons

// Material-style click ripple. Call spawn(x, y) at the click coordinates.
Item {
  id: root
  anchors.fill: parent
  clip: true

  function spawn(x, y, tint) {
    rippleCircle.color = Qt.alpha(tint || Color.mPrimary, 0.35)
    rippleCircle.x = x - rippleCircle.width / 2
    rippleCircle.y = y - rippleCircle.height / 2
    rippleAnim.restart()
  }

  Rectangle {
    id: rippleCircle
    width: 12
    height: 12
    radius: 6
    color: Qt.alpha(Color.mPrimary, 0.3)
    opacity: 0
    scale: 1
  }

  ParallelAnimation {
    id: rippleAnim
    NumberAnimation { target: rippleCircle; property: "scale"; from: 1; to: 30; duration: 540; easing.type: Easing.OutCubic }
    SequentialAnimation {
      NumberAnimation { target: rippleCircle; property: "opacity"; from: 0.6; to: 0.6; duration: 80 }
      NumberAnimation { target: rippleCircle; property: "opacity"; to: 0; duration: 480; easing.type: Easing.OutQuad }
    }
  }
}
