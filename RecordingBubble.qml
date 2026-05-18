import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  // Live elapsed time since recording started
  property string elapsed: ""

  Timer {
    interval: 1000
    running: main.recordingActive && main.recordingStartedAtMs > 0
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      const secs = Math.max(0, Math.floor((Date.now() - main.recordingStartedAtMs) / 1000))
      const h = Math.floor(secs / 3600)
      const m = Math.floor((secs % 3600) / 60)
      const s = secs % 60
      root.elapsed = (h > 0 ? h + ":" + (m < 10 ? "0" : "") : "") + m + ":" + (s < 10 ? "0" : "") + s
    }
  }

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
        SequentialAnimation on scale {
          loops: Animation.Infinite
          running: main.iconMicroAnimations
          NumberAnimation { to: 1.18; duration: 700; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
        }
      }

      // Halo ring
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
          NumberAnimation { to: 2.0; duration: 1400; easing.type: Easing.OutQuad }
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
      text: root.elapsed.length > 0 ? root.elapsed : "REC"
      pointSize: Style.fontSizeXS
      font.weight: Font.Bold
      font.family: "monospace"
      color: Color.mError
    }
  }
}
