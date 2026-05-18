import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons

PanelWindow {
  id: islandWindow

  required property var main
  readonly property bool topAnchor: main.position === "top"

  // We keep the window visible briefly after shouldShow flips false so the pill
  // can fade out smoothly. `actuallyVisible` lags shouldShow by ~220 ms.
  property bool actuallyVisible: main.shouldShow

  visible: actuallyVisible
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
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  // Enough vertical room for a soft shadow and bounce headroom.
  implicitHeight: main.islandHeight + 24

  Connections {
    target: main
    function onShouldShowChanged() {
      if (main.shouldShow) {
        hideDelay.stop()
        islandWindow.actuallyVisible = true
      } else {
        hideDelay.restart()
      }
    }
  }
  Timer {
    id: hideDelay
    interval: 240
    repeat: false
    onTriggered: islandWindow.actuallyVisible = main.shouldShow
  }

  Item {
    id: centerSlot
    anchors.fill: parent

    // The pill: width animates between compact/expanded; height animates so a
    // fresh-mount feels like a "drop" from the bezel.
    Rectangle {
      id: pill
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.horizontalCenterOffset: main.horizontalOffset
      anchors.verticalCenter: parent.verticalCenter

      readonly property int mediaW: main.mediaActive ? (main.expanded ? main.expandedWidth : main.compactWidth) : 0
      readonly property int notifW: main.notificationActive ? (main.expanded ? main.expandedWidth : main.compactWidth) : 0
      readonly property int recW: main.recordingActive ? 96 : 0
      readonly property int idleW: (!main.anyBubbleActive && main.idleVisible) ? main.compactWidth : 0

      readonly property int gap: 6
      readonly property int activeCount:
          (main.mediaActive ? 1 : 0)
        + (main.notificationActive ? 1 : 0)
        + (main.recordingActive ? 1 : 0)

      readonly property int rawWidth: {
        if (main.dualBubble && activeCount > 1) {
          // When pairing bubbles, hold each at compact width to fit screens.
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

      // Clamp to keep the pill inside the screen, accounting for offset.
      readonly property int maxAvail:
          Math.max(120,
            islandWindow.width - 24 - Math.abs(main.horizontalOffset) * 2)

      width: Math.min(rawWidth, maxAvail)
      height: main.islandHeight
      radius: main.cornerRadius
      color: Qt.alpha(Color.mSurface, 0.94)
      border.color: Qt.alpha(Color.mOutline, 0.35)
      border.width: 1
      clip: true

      opacity: main.shouldShow ? 1 : 0
      scale: main.shouldShow ? 1 : 0.92
      transformOrigin: Item.Center

      Behavior on width {
        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
      }
      Behavior on height {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
      }
      Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
      }
      Behavior on scale {
        NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
      }

      // Soft drop shadow rendered as a translucent halo beneath the pill.
      // We can't use Qt5Compat's DropShadow reliably across builds, so we
      // fake it with two stacked, blurred-look rectangles via opacity layers.
      Rectangle {
        z: -1
        anchors.fill: parent
        anchors.margins: -4
        radius: parent.radius + 4
        color: "transparent"
        border.color: Qt.alpha(Color.mShadow !== undefined ? Color.mShadow : "#000000", 0.16)
        border.width: 4
        opacity: main.shouldShow ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
      }
      Rectangle {
        z: -1
        anchors.fill: parent
        anchors.margins: -2
        radius: parent.radius + 2
        color: "transparent"
        border.color: Qt.alpha(Color.mShadow !== undefined ? Color.mShadow : "#000000", 0.22)
        border.width: 2
        opacity: main.shouldShow ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
      }

      MouseArea {
        id: pillArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onEntered: if (main.hoverToExpand) main.hovered = true
        onExited: main.hovered = false
        onClicked: (mouse) => {
          if (mouse.button === Qt.MiddleButton) {
            main.mediaPlayPause()
            return
          }
          if (mouse.button === Qt.RightButton) {
            // Right-click dismisses the notification peek without affecting media.
            if (main.notificationActive) main.dismissNotification()
            return
          }
          // Left-click: prefer dismiss-notification when a notif is the headline,
          // otherwise toggle media playback.
          if (main.notificationActive && !main.mediaActive) {
            main.dismissNotification()
          } else if (main.mediaActive) {
            main.mediaPlayPause()
          }
        }
      }

      RowLayout {
        id: bubbleRow
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: pill.gap

        MediaBubble {
          visible: main.mediaActive
          main: islandWindow.main
          Layout.fillHeight: true
          Layout.preferredWidth: {
            if (!main.mediaActive) return 0
            if (main.dualBubble && pill.activeCount > 1) return main.compactWidth - 16
            return (main.expanded ? main.expandedWidth : main.compactWidth) - 16
          }
        }

        // Divider between paired bubbles
        Rectangle {
          visible: main.dualBubble && pill.activeCount > 1 && main.mediaActive
            && (main.notificationActive || main.recordingActive)
          Layout.preferredWidth: 1
          Layout.preferredHeight: main.islandHeight * 0.55
          Layout.alignment: Qt.AlignVCenter
          color: Qt.alpha(Color.mOutline, 0.35)
        }

        NotificationBubble {
          visible: main.notificationActive
          main: islandWindow.main
          Layout.fillHeight: true
          Layout.preferredWidth: {
            if (!main.notificationActive) return 0
            if (main.dualBubble && pill.activeCount > 1) return main.compactWidth - 16
            return (main.expanded ? main.expandedWidth : main.compactWidth) - 16
          }
        }

        RecordingBubble {
          visible: main.recordingActive
          Layout.fillHeight: true
          Layout.preferredWidth: 80
        }

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
