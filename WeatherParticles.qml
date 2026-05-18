import QtQuick
import qs.Commons

// Light particle overlay for rainy / snowy weather. Pure decorative.
Item {
  id: root
  anchors.fill: parent
  clip: true
  property string mode: "none"   // "rain" | "snow" | "none"

  Repeater {
    model: root.mode === "none" ? 0 : 10

    delegate: Rectangle {
      id: p
      property real ox: Math.random() * root.width
      property real oy: -10 - Math.random() * 20
      property real spd: root.mode === "snow"
                           ? (1.5 + Math.random() * 1.5)
                           : (2.5 + Math.random() * 2.5)
      x: ox
      y: oy
      width:  root.mode === "snow" ? 3 : 1
      height: root.mode === "snow" ? 3 : 6
      radius: root.mode === "snow" ? 1.5 : 0
      color: root.mode === "snow" ? "#ffffff" : "#9bd0ff"
      opacity: 0.55

      NumberAnimation on y {
        running: root.mode !== "none"
        loops: Animation.Infinite
        from: -10
        to: root.height + 10
        duration: Math.round(2400 / p.spd)
      }
      NumberAnimation on x {
        running: root.mode === "snow"
        loops: Animation.Infinite
        from: p.ox - 4
        to: p.ox + 4
        duration: 1800
        easing.type: Easing.InOutSine
      }
    }
  }
}
