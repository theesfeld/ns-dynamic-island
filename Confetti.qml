import QtQuick

// Simple confetti burst — emoji particles fan outward then fade.
Item {
  id: root
  anchors.fill: parent
  z: 50

  property int particleCount: 14

  function burst() {
    for (let i = 0; i < repeater.count; i++) {
      const p = repeater.itemAt(i)
      if (p) p.fire()
    }
  }

  Repeater {
    id: repeater
    model: root.particleCount

    delegate: Item {
      id: particle
      width: 16; height: 16
      x: root.width / 2 - 8
      y: root.height / 2 - 8
      opacity: 0

      readonly property real ang: (index / root.particleCount) * 2 * Math.PI
      readonly property real spd: 50 + (index % 5) * 12
      property real targetX: root.width / 2 - 8
      property real targetY: root.height / 2 - 8

      Text {
        id: glyph
        anchors.centerIn: parent
        text: ["🎉","✨","🥳","🎊","⭐","💫"][index % 6]
        font.pixelSize: 13
        rotation: 0
      }

      function fire() {
        flyAnim.stop()
        spinAnim.stop()
        particle.x = root.width / 2 - 8
        particle.y = root.height / 2 - 8
        particle.opacity = 1
        glyph.rotation = 0
        particle.targetX = root.width / 2 - 8 + Math.cos(ang) * spd
        particle.targetY = root.height / 2 - 8 + Math.sin(ang) * spd + 24
        flyAnim.start()
        spinAnim.start()
      }

      ParallelAnimation {
        id: flyAnim
        NumberAnimation { target: particle; property: "x"; to: particle.targetX; duration: 900; easing.type: Easing.OutQuad }
        NumberAnimation { target: particle; property: "y"; to: particle.targetY; duration: 900; easing.type: Easing.InQuad }
        NumberAnimation { target: particle; property: "opacity"; to: 0; duration: 900; easing.type: Easing.InQuad }
      }
      NumberAnimation {
        id: spinAnim
        target: glyph
        property: "rotation"
        from: 0; to: 360
        duration: 900
      }
    }
  }
}
