import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons

PanelWindow {
  id: islandWindow

  required property var main
  property bool topAnchor: main.position === "top"

  visible: main.shouldShow
  color: "transparent"

  anchors {
    top: islandWindow.topAnchor
    bottom: !islandWindow.topAnchor
    left: true
    right: true
  }
  margins.top: islandWindow.topAnchor ? main.marginPx : 0
  margins.bottom: !islandWindow.topAnchor ? main.marginPx : 0

  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "ns-dynamic-island"
  implicitHeight: main.islandHeight + 16

  // Centered, width-animating pill container. We size to the content rather
  // than a full-width bar so clicks only land on the pill itself.
  Item {
    id: centerSlot
    width: parent.width
    height: parent.height

    Rectangle {
      id: pill
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.horizontalCenterOffset: main.horizontalOffset
      anchors.verticalCenter: parent.verticalCenter

      readonly property int mediaW: main.mediaActive ? (main.expanded ? main.expandedWidth : main.compactWidth) : 0
      readonly property int notifW: main.notificationActive ? (main.expanded ? main.expandedWidth : main.compactWidth) : 0
      readonly property int recW: main.recordingActive ? 92 : 0
      readonly property int idleW: (!main.anyBubbleActive && main.idleVisible) ? main.compactWidth : 0

      // Combined width: dual-bubble lays out side by side; otherwise the
      // single active bubble defines the width. Spacing between bubbles
      // lives inside bubbleRow.
      readonly property int gap: 6
      readonly property int activeCount: (main.mediaActive ? 1 : 0) + (main.notificationActive ? 1 : 0) + (main.recordingActive ? 1 : 0)
      readonly property int combinedWidth: {
        if (main.dualBubble && activeCount > 1) {
          // Keep media/notification at their compact width when paired with a
          // second bubble to avoid overflowing the screen.
          const m = main.mediaActive ? main.compactWidth : 0
          const n = main.notificationActive ? main.compactWidth : 0
          const r = recW
          const pieces = [m, n, r].filter(x => x > 0)
          return pieces.reduce((a, b) => a + b, 0) + gap * (pieces.length - 1)
        }
        if (mediaW > 0) return mediaW
        if (notifW > 0) return notifW
        if (recW > 0) return recW
        if (idleW > 0) return idleW
        return main.compactWidth
      }

      width: combinedWidth
      height: main.islandHeight
      radius: main.cornerRadius
      color: Qt.alpha(Color.mSurface, 0.92)
      border.color: Qt.alpha(Color.mOutline, 0.35)
      border.width: 1
      clip: true
      opacity: main.shouldShow ? 1 : 0

      Behavior on width {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
      }
      Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.InOutQuad }
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onEntered: if (main.hoverToExpand) main.hovered = true
        onExited: main.hovered = false
        onClicked: (mouse) => {
          if (mouse.button === Qt.MiddleButton) {
            main.mediaPlayPause()
            return
          }
          // Left click on media bubble: toggle play/pause
          if (main.mediaActive && !main.notificationActive) {
            main.mediaPlayPause()
          }
        }
      }

      RowLayout {
        id: bubbleRow
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: pill.gap

        // Media bubble
        MediaBubble {
          visible: main.mediaActive
          main: islandWindow.main
          Layout.fillHeight: true
          Layout.preferredWidth: {
            if (!main.mediaActive) return 0
            if (main.dualBubble && pill.activeCount > 1) return main.compactWidth - 12
            return (main.expanded ? main.expandedWidth : main.compactWidth) - 12
          }
        }

        // Notification bubble
        NotificationBubble {
          visible: main.notificationActive
          main: islandWindow.main
          Layout.fillHeight: true
          Layout.preferredWidth: {
            if (!main.notificationActive) return 0
            if (main.dualBubble && pill.activeCount > 1) return main.compactWidth - 12
            return (main.expanded ? main.expandedWidth : main.compactWidth) - 12
          }
        }

        // Recording indicator
        RecordingBubble {
          visible: main.recordingActive
          Layout.fillHeight: true
          Layout.preferredWidth: 80
        }

        // Idle (clock / weather)
        IdleBubble {
          visible: !main.anyBubbleActive && main.idleVisible
          main: islandWindow.main
          Layout.fillHeight: true
          Layout.fillWidth: true
        }
      }
    }
  }
}
