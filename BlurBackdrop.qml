import QtQuick

// Real Gaussian blur backdrop via Qt6 MultiEffect. If MultiEffect isn't
// available on the user's Qt build, this file fails to load and the
// caller's Loader keeps the faux-blur fallback rectangles. We isolate
// the import here so a missing effect module doesn't break the plugin.
import QtQuick.Effects

Item {
  id: root
  anchors.fill: parent

  property Item source: null
  property real blurRadius: 18
  property real blurMax: 48

  MultiEffect {
    anchors.fill: parent
    source: root.source
    blurEnabled: true
    blur: 1.0
    blurMax: root.blurMax
    blurMultiplier: root.blurRadius / 32.0
    autoPaddingEnabled: false
    saturation: 0.15
    brightness: 0.04
  }
}
