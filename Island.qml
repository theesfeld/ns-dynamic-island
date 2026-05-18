import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons

PanelWindow {
  id: islandWindow

  required property var main
  readonly property bool topAnchor: main.position === "top"

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

  implicitHeight: main.islandHeight + 36

  // Input mask: only the pill (plus the open context menu) accept pointer
  // events; the rest of the panel surface passes clicks through to the
  // bar beneath. Without this, the layer-shell surface ends up either
  // swallowing clicks across the full screen width or accepting none at
  // all (compositor-dependent) — either way the user can't interact
  // with the pill.
  mask: Region {
    item: pill
    Region {
      item: ctxMenu
      intersection: Intersection.Combine
    }
  }

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
    interval: 260
    repeat: false
    onTriggered: islandWindow.actuallyVisible = main.shouldShow
  }

  // Soft glow that activates on critical state (notification urgency 2,
  // battery critical, hot CPU, or active recording).
  readonly property bool glowActive: main.criticalGlow && (
       (main.notificationActive && main.activeNotification && main.activeNotification.urgency === 2)
    || (main.batteryActive && main.batteryCritical)
    || (main.cpuActive && main.cpuTempC >= main.cpuTempCritical)
    || main.recordingActive
  )

  readonly property color glowColor: {
    if (main.recordingActive) return Color.mError
    if (main.batteryCritical && main.batteryActive) return Color.mError
    if (main.cpuTempC >= main.cpuTempCritical && main.cpuActive) return Color.mError
    if (main.notificationActive && main.activeNotification && main.activeNotification.urgency === 2) return Color.mError
    return Color.mPrimary
  }

  // Time-of-day tint applied subtly to the idle pill background.
  readonly property color todTint: {
    if (!main.timeOfDayTint) return "transparent"
    const h = new Date().getHours()
    if (h >= 5 && h < 8)   return Qt.rgba(1.0, 0.78, 0.55, 0.10) // sunrise
    if (h >= 8 && h < 17)  return Qt.rgba(1.0, 1.0, 1.0, 0.04)   // day
    if (h >= 17 && h < 20) return Qt.rgba(1.0, 0.55, 0.30, 0.12) // sunset
    return Qt.rgba(0.20, 0.30, 0.65, 0.12)                       // night
  }

  Item {
    id: centerSlot
    anchors.fill: parent

    // Outer glow (under-pill halo). Three stacked layers create a pseudo blur.
    Rectangle {
      visible: islandWindow.glowActive
      anchors.fill: pill
      anchors.margins: -12
      radius: pill.radius + 12
      color: "transparent"
      border.color: Qt.alpha(islandWindow.glowColor, 0.10)
      border.width: 6
      z: -2
      SequentialAnimation on opacity {
        running: islandWindow.glowActive
        loops: Animation.Infinite
        NumberAnimation { to: 0.55; duration: 900; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0;  duration: 900; easing.type: Easing.InOutSine }
      }
    }
    Rectangle {
      visible: islandWindow.glowActive
      anchors.fill: pill
      anchors.margins: -7
      radius: pill.radius + 7
      color: "transparent"
      border.color: Qt.alpha(islandWindow.glowColor, 0.22)
      border.width: 4
      z: -2
    }
    Rectangle {
      visible: islandWindow.glowActive
      anchors.fill: pill
      anchors.margins: -3
      radius: pill.radius + 3
      color: "transparent"
      border.color: Qt.alpha(islandWindow.glowColor, 0.45)
      border.width: 2
      z: -2
    }

    // Context menu auto-close (5s after open, in case input routing is wonky)
    Timer {
      id: ctxAutoClose
      interval: 5000
      repeat: false
      onTriggered: ctxMenu.visible = false
    }

    // Context menu (sibling of pill so it isn't clipped)
    Rectangle {
      id: ctxMenu
      visible: false
      property var items: []
      onVisibleChanged: if (visible) ctxAutoClose.restart(); else ctxAutoClose.stop()

      function refresh() {
        items = pill.ctxMenuModel()
        height = items.length * 26 + 12
        width = 220
      }

      width: 220
      height: 60
      radius: 10
      color: Qt.alpha(main.themeSurface, 0.98)
      border.color: Qt.alpha(main.themeOutline, 0.4)
      border.width: 1
      z: 100

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 2

        Repeater {
          model: ctxMenu.items
          delegate: Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            radius: 6
            color: ctxItemArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.22) : "transparent"

            Text {
              anchors.fill: parent
              anchors.leftMargin: 10
              verticalAlignment: Text.AlignVCenter
              text: modelData.label
              color: main.themeOnSurface
              font.pixelSize: 12 * main.textScale
            }
            MouseArea {
              id: ctxItemArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (modelData.action) modelData.action()
                ctxMenu.visible = false
              }
            }
          }
        }
      }

    }

    // Outside-click dismisser for context menu
    MouseArea {
      visible: ctxMenu.visible
      anchors.fill: parent
      z: 99
      onClicked: ctxMenu.visible = false
    }

    Rectangle {
      id: pill
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.horizontalCenterOffset: main.horizontalOffset
      anchors.verticalCenter: parent.verticalCenter

      // ── width plumbing ─────────────────────────────────
      readonly property int gap: 6

      // pieces is a derived list of [bubbleWidth] currently visible
      readonly property var pieces: {
        const arr = []
        // OSD always primary if active
        if (main.osdActive) {
          arr.push(main.expanded ? main.expandedWidth : main.compactWidth)
          return arr
        }
        if (main.mediaActive)        arr.push(main.expanded ? main.expandedWidth : main.compactWidth)
        if (main.notificationActive) arr.push(main.expanded ? main.expandedWidth : main.compactWidth)
        if (main.recordingActive)    arr.push(96)
        if (main.batteryActive)      arr.push(main.expanded ? 200 : 120)
        if (main.pomodoroActive)     arr.push(main.expanded ? 240 : 140)
        if (main.timerActive)        arr.push(main.expanded ? 220 : 130)
        if (main.networkActive)      arr.push(main.expanded ? 220 : 130)
        if (main.bluetoothActive)    arr.push(main.expanded ? 220 : 130)
        if (main.keyboardActive)     arr.push(100)
        if (main.workspaceActive)    arr.push(140)
        if (main.clipboardActive)    arr.push(main.expanded ? 220 : 140)
        if (main.screenshotActive)   arr.push(main.expanded ? 240 : 140)
        if (main.downloadActive)     arr.push(main.expanded ? 240 : 150)
        if (main.cpuActive)          arr.push(main.expanded ? 200 : 130)
        if (main.focusBubbleActive)  arr.push(main.expanded ? 200 : 130)
        if (main.calendarActive)     arr.push(main.expanded ? 220 : 140)
        if (arr.length === 0)        arr.push(main.compactWidth)
        return arr
      }

      readonly property int rawWidth: {
        if (!main.dualBubble && pieces.length > 1) {
          return pieces[0] // single-bubble mode: take first
        }
        let total = 0
        for (let i = 0; i < pieces.length; i++) total += pieces[i]
        if (!main.dualBubble) total = pieces[0] || main.compactWidth
        return total + gap * Math.max(0, pieces.length - 1)
      }

      readonly property int maxAvail:
          Math.max(120,
            islandWindow.width - 24 - Math.abs(main.horizontalOffset) * 2)

      width: Math.min(rawWidth, maxAvail)
      height: main.islandHeight
      radius: main.cornerRadius
      color: Qt.alpha(main.themeSurface, main.backdropOpacity)
      border.color: Qt.alpha(main.themeOutline, main.highContrast ? 0.9 : 0.35)
      border.width: 1
      clip: true

      opacity: main.shouldShow ? 1 : 0
      scale: main.shouldShow ? 1 : 0.92
      transformOrigin: Item.Center

      Behavior on width  { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
      Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
      Behavior on opacity{ NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
      Behavior on scale  {
        NumberAnimation {
          duration: main.springExpand ? 320 : 220
          easing.type: main.springExpand ? Easing.OutBack : Easing.OutBack
          easing.overshoot: main.springExpand ? 1.6 : 1.2
        }
      }

      // Time-of-day overlay (only meaningful in idle state)
      Rectangle {
        anchors.fill: parent
        radius: parent.radius
        visible: main.timeOfDayTint && !main.anyBubbleActive
        color: islandWindow.todTint
        z: 0
      }

      // Layered "fake blur" — extra translucent rectangles to soften the edge.
      Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        radius: parent.radius + 1
        color: Qt.alpha(main.themeSurface, main.fakeBlur ? 0.22 : 0)
        z: -1
        visible: main.fakeBlur
      }

      // Soft drop shadow
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

      // ── Pointer interactions: hover, click, swipe ──────
      MouseArea {
        id: pillArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        property real pressX: 0
        property real pressY: 0
        property bool dragging: false

        onEntered: if (main.hoverToExpand) main.hovered = true
        onExited: main.hovered = false

        onPressed: (mouse) => {
          pressX = mouse.x; pressY = mouse.y; dragging = false
        }
        onPositionChanged: (mouse) => {
          if (!pressed) return
          const dx = mouse.x - pressX
          if (Math.abs(dx) > 18) dragging = true
        }
        onReleased: (mouse) => {
          if (dragging && main.swipeGestures) {
            const dx = mouse.x - pressX
            if (Math.abs(dx) > 30) {
              if (main.notificationActive) {
                if (dx < 0) main.dismissNotification()
                else main.cycleNotification(1)
              } else if (main.mediaActive) {
                if (dx < 0) main.mediaNext()
                else main.mediaPrevious()
              }
            }
            dragging = false
            return
          }
          if (mouse.button === Qt.MiddleButton) {
            if (main.mediaActive) main.mediaPlayPause()
            return
          }
          if (mouse.button === Qt.RightButton) {
            if (main.contextMenu) {
              // Position relative to centerSlot so the menu isn't clipped by the pill.
              const p = pillArea.mapToItem(centerSlot, mouse.x, 0)
              ctxMenu.x = Math.max(8, Math.min(centerSlot.width - ctxMenu.width - 8, p.x - ctxMenu.width / 2))
              ctxMenu.y = islandWindow.topAnchor
                ? (pill.y + pill.height + 6)
                : (pill.y - ctxMenu.height - 6)
              ctxMenu.visible = true
              ctxMenu.refresh()
            } else if (main.notificationActive) {
              main.dismissNotification()
            }
            return
          }
          // Left-click
          if (main.notificationActive && !main.mediaActive) {
            main.dismissNotification()
          } else if (main.mediaActive) {
            main.mediaPlayPause()
          }
        }
      }

      function ctxMenuModel() {
        const items = []
        if (main.mediaActive) {
          items.push({ label: main.mediaIsPlaying ? "Pause" : "Play", action: () => main.mediaPlayPause() })
          items.push({ label: "Next track",     action: () => main.mediaNext() })
          items.push({ label: "Previous track", action: () => main.mediaPrevious() })
        }
        if (main.notificationActive) {
          items.push({ label: "Dismiss notification", action: () => main.dismissNotification() })
          const app = main.activeNotification ? main.activeNotification.appName : ""
          if (app && app.length > 0) {
            items.push({ label: "Mute \"" + app + "\"", action: () => {
              const a = (main.pluginApi.pluginSettings.notificationMutedApps || []).slice()
              if (a.indexOf(app) === -1) a.push(app)
              main.pluginApi.pluginSettings.notificationMutedApps = a
              main.pluginApi.saveSettings()
              main.dismissNotification()
            }})
          }
        }
        items.push({ label: main.dndEnabled ? "Disable DND" : "Enable DND", action: () => {
          main.pluginApi.pluginSettings.dndEnabled = !main.dndEnabled
          main.pluginApi.saveSettings()
        }})
        if (main.pomodoroEnabled) {
          items.push({ label: main.pomodoroActive ? "Stop pomodoro" : "Start pomodoro", action: () => {
            if (main.pomodoroActive) main.pomodoroStop(); else main.pomodoroStart()
          }})
        }
        items.push({ label: "Hide", action: () => { main.forceShown = false; main.activeNotification = null } })
        return items
      }

      // ── Bubble row (lazy loaders) ──────────────────────
      RowLayout {
        id: bubbleRow
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: pill.gap

        // OSD takes over the whole pill when active
        Loader {
          active: main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.fillWidth: true
          sourceComponent: OsdBubble {
            main: islandWindow.main
            kind: main.osdKind
            value: main.osdValue
            muted: main.osdMuted
          }
        }

        // Media
        Loader {
          active: main.mediaActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active
            ? ((main.dualBubble && pill.pieces.length > 1)
                ? main.compactWidth - 16
                : (main.expanded ? main.expandedWidth : main.compactWidth) - 16)
            : 0
          sourceComponent: MediaBubble { main: islandWindow.main }
        }

        // Notification (with stacking & action support)
        Loader {
          active: main.notificationActive && !main.osdActive && !main.dndActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active
            ? ((main.dualBubble && pill.pieces.length > 1)
                ? main.compactWidth - 16
                : (main.expanded ? main.expandedWidth : main.compactWidth) - 16)
            : 0
          sourceComponent: NotificationBubble { main: islandWindow.main }
        }

        // Recording
        Loader {
          active: main.recordingActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? 80 : 0
          sourceComponent: RecordingBubble { main: islandWindow.main }
        }

        // Battery
        Loader {
          active: main.batteryActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 184 : 104) : 0
          sourceComponent: BatteryBubble { main: islandWindow.main }
        }

        // Pomodoro
        Loader {
          active: main.pomodoroActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 224 : 124) : 0
          sourceComponent: PomodoroBubble { main: islandWindow.main }
        }

        // Timer
        Loader {
          active: main.timerActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 204 : 114) : 0
          sourceComponent: TimerBubble { main: islandWindow.main }
        }

        // Download
        Loader {
          active: main.downloadActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 224 : 134) : 0
          sourceComponent: DownloadBubble { main: islandWindow.main }
        }

        // Network
        Loader {
          active: main.networkActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 204 : 114) : 0
          sourceComponent: NetworkBubble { main: islandWindow.main }
        }

        // Bluetooth
        Loader {
          active: main.bluetoothActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 204 : 114) : 0
          sourceComponent: BluetoothBubble { main: islandWindow.main }
        }

        // Keyboard layout
        Loader {
          active: main.keyboardActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? 84 : 0
          sourceComponent: KeyboardLayoutBubble { main: islandWindow.main }
        }

        // Workspace
        Loader {
          active: main.workspaceActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? 124 : 0
          sourceComponent: WorkspaceBubble { main: islandWindow.main }
        }

        // Clipboard
        Loader {
          active: main.clipboardActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 204 : 124) : 0
          sourceComponent: ClipboardBubble { main: islandWindow.main }
        }

        // Screenshot
        Loader {
          active: main.screenshotActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 224 : 124) : 0
          sourceComponent: ScreenshotBubble { main: islandWindow.main }
        }

        // CPU temp
        Loader {
          active: main.cpuActive && !main.osdActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 184 : 114) : 0
          sourceComponent: CpuTempBubble { main: islandWindow.main }
        }

        // Focus / DND bubble
        Loader {
          active: main.focusBubbleActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 184 : 114) : 0
          sourceComponent: FocusBubble { main: islandWindow.main }
        }

        // Calendar (idle hover, only shows if no other bubble is up)
        Loader {
          active: main.calendarActive && !main.anyBubbleActive
          visible: active
          Layout.fillHeight: true
          Layout.preferredWidth: active ? (main.expanded ? 220 : 140) : 0
          sourceComponent: CalendarBubble { main: islandWindow.main }
        }

        // Idle fallback (clock + weather)
        Loader {
          active: !main.anyBubbleActive && main.idleVisible
          visible: active
          Layout.fillHeight: true
          Layout.fillWidth: true
          sourceComponent: IdleBubble { main: islandWindow.main }
        }

        // Privacy indicator (always end of row when mic/cam are in use)
        Loader {
          active: main.privacyIndicatorEnabled && (main.micInUse || main.camInUse)
          visible: active
          Layout.preferredWidth: active ? (main.micInUse && main.camInUse ? 22 : 12) : 0
          Layout.preferredHeight: 12
          Layout.alignment: Qt.AlignVCenter
          sourceComponent: MicIndicator { main: islandWindow.main }
        }
      }
    }
  }
}
