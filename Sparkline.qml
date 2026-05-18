import QtQuick
import qs.Commons

// Mini sparkline chart: feed it a numeric value via push(v) and it
// keeps a sliding window. Renders as a polyline.
Item {
  id: root
  implicitWidth: 60
  implicitHeight: 16

  property color stroke: Color.mPrimary
  property color fill: Qt.alpha(Color.mPrimary, 0.25)
  property int capacity: 30
  property real minVal: 0
  property real maxVal: 100
  property var samples: []   // numeric

  function push(v) {
    const s = samples.slice()
    s.push(v)
    while (s.length > capacity) s.shift()
    samples = s
    canvas.requestPaint()
  }

  function reset() {
    samples = []
    canvas.requestPaint()
  }

  Canvas {
    id: canvas
    anchors.fill: parent
    onPaint: {
      const ctx = getContext("2d")
      ctx.reset()
      const s = root.samples
      if (!s || s.length < 2) return
      const w = width, h = height
      const lo = root.minVal, hi = root.maxVal
      const span = Math.max(0.001, hi - lo)
      const stepX = w / (root.capacity - 1)

      // Fill polygon
      ctx.beginPath()
      ctx.moveTo(0, h)
      for (let i = 0; i < s.length; i++) {
        const x = i * stepX
        const norm = Math.max(0, Math.min(1, (s[i] - lo) / span))
        const y = h - norm * h
        ctx.lineTo(x, y)
      }
      ctx.lineTo((s.length - 1) * stepX, h)
      ctx.closePath()
      ctx.fillStyle = root.fill
      ctx.fill()

      // Stroke line
      ctx.beginPath()
      for (let i = 0; i < s.length; i++) {
        const x = i * stepX
        const norm = Math.max(0, Math.min(1, (s[i] - lo) / span))
        const y = h - norm * h
        if (i === 0) ctx.moveTo(x, y)
        else ctx.lineTo(x, y)
      }
      ctx.lineWidth = 1.5
      ctx.strokeStyle = root.stroke
      ctx.stroke()
    }
  }
}
