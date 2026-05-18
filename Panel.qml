import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Compositor
import qs.Services.Media
import qs.Services.UI
import qs.Widgets

// Control-center style detail panel. Follows Noctalia SmartPanel
// contract (Item root, geometryPlaceholder, contentPreferredWidth/Height,
// allowAttach). Glass capsule with top highlight + drop-shadow.
Item {
  id: root

  property var pluginApi: null

  readonly property var geometryPlaceholder: panelContainer
  property real contentPreferredWidth:  420 * Style.uiScaleRatio
  property real contentPreferredHeight: 540 * Style.uiScaleRatio
  readonly property bool allowAttach: true

  anchors.fill: parent

  // ── Reactive state ───────────────────────────────────────
  readonly property var cfg: pluginApi?.pluginSettings || ({})

  readonly property bool mediaActive: MediaService.trackTitle.length > 0
  readonly property var notifModel: NotificationService.popupModel || null
  readonly property int notifCount: notifModel ? notifModel.count : 0

  // Active window via CompositorService
  property string activeWindowTitle: ""
  property string activeWindowAppId: ""

  function refreshActiveWindow() {
    const w = CompositorService.getFocusedWindow ? CompositorService.getFocusedWindow() : null
    if (w) {
      root.activeWindowTitle = w.title || ""
      root.activeWindowAppId = w.appId || ""
    } else {
      root.activeWindowTitle = ""
      root.activeWindowAppId = ""
    }
  }

  Connections {
    target: CompositorService
    function onActiveWindowChanged() { root.refreshActiveWindow() }
    function onWindowListChanged()   { root.refreshActiveWindow() }
    function onWorkspaceChanged()    { root.refreshActiveWindow() }
  }

  // Live clock
  property string clockText: Qt.formatTime(new Date(), "HH:mm:ss")
  property string dateText: Qt.formatDate(new Date(), "ddd, MMM d")
  Timer {
    interval: 1000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: {
      const d = new Date()
      root.clockText = Qt.formatTime(d, "HH:mm:ss")
      root.dateText  = Qt.formatDate(d, "ddd, MMM d")
    }
  }

  // Live MPRIS position
  property real mediaPos: 0
  property real mediaLen: 0
  Timer {
    interval: 500; running: root.mediaActive; repeat: true; triggeredOnStart: true
    onTriggered: {
      root.mediaPos = MediaService.currentPosition || 0
      root.mediaLen = MediaService.trackLength || 0
    }
  }
  function fmtTime(s) {
    if (s <= 0 || isNaN(s)) return "0:00"
    const m = Math.floor(s / 60), r = Math.floor(s) % 60
    return m + ":" + (r < 10 ? "0" : "") + r
  }

  // Weather from shared cache
  property string weatherTemp: ""
  property string weatherCondition: ""
  Timer {
    interval: 10 * 60 * 1000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: if (!wxProbe.running) wxProbe.running = true
  }
  Process {
    id: wxProbe
    running: false
    command: ["sh", "-c", "cat \"$HOME/.cache/ns-dynamic-island/weather.json\" 2>/dev/null || true"]
    stdout: StdioCollector {
      onStreamFinished: {
        const t = (text || "").trim()
        if (t.length === 0) return
        try {
          const j = JSON.parse(t)
          root.weatherTemp = j.temp || ""
          root.weatherCondition = j.condition || ""
        } catch (e) {}
      }
    }
    onExited: running = false
  }

  // Battery
  property int batteryLevel: -1
  property string batteryState: ""
  Timer {
    interval: 30000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: if (!batProbe.running) batProbe.running = true
  }
  Process {
    id: batProbe
    running: false
    command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*/; do [ -d \"$b\" ] && c=$(cat \"$b\"capacity 2>/dev/null) && s=$(cat \"$b\"status 2>/dev/null) && echo \"$c|$s\" && break; done"]
    stdout: StdioCollector {
      onStreamFinished: {
        const line = (text || "").trim()
        if (line.length === 0) { root.batteryLevel = -1; root.batteryState = ""; return }
        const parts = line.split("|")
        const lvl = parseInt(parts[0])
        if (!isNaN(lvl)) { root.batteryLevel = lvl; root.batteryState = (parts[1] || "").trim() }
      }
    }
    onExited: running = false
  }

  // System volume (polled)
  property int volumePct: 0
  property bool volumeMuted: false
  Timer {
    interval: 1000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: if (!volProbe.running) volProbe.running = true
  }
  Process {
    id: volProbe
    running: false
    command: ["sh", "-c",
      "if command -v wpctl >/dev/null 2>&1; then " +
      "  out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null); " +
      "  v=$(echo \"$out\" | awk '{print $2}'); m=0; echo \"$out\" | grep -q MUTED && m=1; " +
      "  awk -v v=\"$v\" -v m=\"$m\" 'BEGIN{printf \"%d|%d\\n\", v*100, m}'; " +
      "elif command -v pactl >/dev/null 2>&1; then " +
      "  v=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk -F'/' 'NR==1{gsub(\"%\",\"\",$2); gsub(\" \",\"\",$2); print $2}'); " +
      "  m=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}'); " +
      "  [ \"$m\" = \"yes\" ] && mm=1 || mm=0; echo \"${v:-0}|$mm\"; " +
      "else echo \"0|0\"; fi"]
    stdout: StdioCollector {
      onStreamFinished: {
        const parts = (text || "").trim().split("|")
        root.volumePct = parseInt(parts[0]) || 0
        root.volumeMuted = (parts[1] || "0") === "1"
      }
    }
    onExited: running = false
  }
  function setVolume(v) {
    Quickshell.execDetached(["sh", "-c",
      "if command -v wpctl >/dev/null 2>&1; then wpctl set-volume @DEFAULT_AUDIO_SINK@ "
      + (v / 100.0).toFixed(2) + "; elif command -v pactl >/dev/null 2>&1; then pactl set-sink-volume @DEFAULT_SINK@ "
      + (v | 0) + "%; fi"])
  }

  // Workspaces via CompositorService
  readonly property var workspaces:
    CompositorService.workspaces ? CompositorService.workspaces : null

  Component.onCompleted: refreshActiveWindow()

  function weatherIcon() {
    const c = (root.weatherCondition || "").toLowerCase()
    if (c.indexOf("snow") !== -1) return "weather-snow"
    if (c.indexOf("rain") !== -1) return "weather-rain"
    if (c.indexOf("cloud") !== -1) return "weather-cloud"
    if (c.indexOf("fog") !== -1) return "weather-fog"
    return "weather-sun"
  }

  function batteryIcon() {
    if (batteryState === "Charging") return "battery-charging"
    if (batteryLevel >= 90) return "battery-full"
    if (batteryLevel >= 60) return "battery-high"
    if (batteryLevel >= 30) return "battery-medium"
    if (batteryLevel >= 10) return "battery-low"
    return "battery-empty"
  }

  function volumeIcon() {
    if (volumeMuted) return "volume-mute"
    if (volumePct >= 67) return "volume-high"
    if (volumePct >= 34) return "volume-medium"
    if (volumePct > 0)   return "volume-low"
    return "volume-off"
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    Rectangle {
      id: glassPanel
      anchors {
        fill: parent
        margins: Style.marginS
      }
      color: Qt.alpha(Style.capsuleColor, Style.opacityHeavy)
      radius: Style.radiusL
      border.color: Style.capsuleBorderColor
      border.width: Style.capsuleBorderWidth
      clip: true

      // Top highlight band for glass effect
      Rectangle {
        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          margins: 1
        }
        height: parent.height * 0.35
        radius: parent.radius
        gradient: Gradient {
          GradientStop { position: 0.0; color: Qt.alpha("#ffffff", 0.10) }
          GradientStop { position: 1.0; color: Qt.alpha("#ffffff", 0.0) }
        }
      }

      Flickable {
        anchors {
          fill: parent
          margins: Style.marginM
        }
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
          id: column
          width: parent.width
          spacing: Style.marginM

          // ── Header: big clock + date + weather ─────
          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 0
              NText {
                text: root.clockText
                color: Color.mOnSurface
                pointSize: Style.fontSizeXXXL
                font.weight: Font.Bold
                font.family: "monospace"
              }
              NText {
                text: root.dateText
                color: Color.mOnSurfaceVariant
                pointSize: Style.fontSizeS
              }
            }
            ColumnLayout {
              Layout.alignment: Qt.AlignTop | Qt.AlignRight
              spacing: 2
              visible: root.weatherTemp.length > 0
              RowLayout {
                spacing: 4
                Layout.alignment: Qt.AlignRight
                NIcon { icon: root.weatherIcon(); color: Color.mOnSurfaceVariant; applyUiScale: true }
                NText {
                  text: root.weatherTemp
                  color: Color.mOnSurface
                  pointSize: Style.fontSizeL
                  font.weight: Font.Medium
                }
              }
              NText {
                visible: root.weatherCondition.length > 0
                text: root.weatherCondition
                color: Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXS
                Layout.alignment: Qt.AlignRight
              }
            }
          }

          // ── Workspace switcher ─────────────────────
          RowLayout {
            Layout.fillWidth: true
            visible: root.workspaces && root.workspaces.count > 0
            spacing: 4

            Repeater {
              model: root.workspaces
              delegate: Rectangle {
                Layout.preferredWidth: model.isFocused ? 22 : 14
                Layout.preferredHeight: 8
                radius: 4
                color: model.isFocused
                  ? Color.mPrimary
                  : (wsArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.5) : Qt.alpha(Color.mOnSurfaceVariant, 0.4))

                Behavior on Layout.preferredWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                  id: wsArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    Quickshell.execDetached(["sh", "-c",
                      "if command -v niri >/dev/null 2>&1; then niri msg action focus-workspace "
                      + (model.idx !== undefined ? model.idx : (model.id || 0))
                      + " 2>/dev/null; elif command -v hyprctl >/dev/null 2>&1; then hyprctl dispatch workspace "
                      + (model.id || 0) + " 2>/dev/null; fi"])
                  }
                }
              }
            }
          }

          NDivider { Layout.fillWidth: true }

          // ── Active window ─────────────────────────
          RowLayout {
            Layout.fillWidth: true
            visible: root.activeWindowTitle.length > 0
            spacing: Style.marginS

            NIcon { icon: "window"; color: Color.mOnSurfaceVariant; applyUiScale: true }
            ColumnLayout {
              Layout.fillWidth: true
              spacing: 0
              NText {
                Layout.fillWidth: true
                text: root.activeWindowTitle
                color: Color.mOnSurface
                pointSize: Style.fontSizeM
                font.weight: Font.Medium
                elide: Text.ElideRight
              }
              NText {
                visible: root.activeWindowAppId.length > 0
                text: root.activeWindowAppId
                color: Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXS
              }
            }
          }

          NDivider {
            Layout.fillWidth: true
            visible: root.activeWindowTitle.length > 0 && root.mediaActive
          }

          // ── Media (full controls + scrubbing) ─────
          ColumnLayout {
            Layout.fillWidth: true
            visible: root.mediaActive
            spacing: Style.marginS

            RowLayout {
              Layout.fillWidth: true
              spacing: Style.marginM

              Rectangle {
                width: 64 * Style.uiScaleRatio
                height: 64 * Style.uiScaleRatio
                radius: 10
                color: Color.mSurfaceVariant
                clip: true

                Image {
                  anchors.fill: parent
                  source: MediaService.trackArtUrl
                  fillMode: Image.PreserveAspectCrop
                  visible: MediaService.trackArtUrl.length > 0 && status === Image.Ready
                  asynchronous: true; cache: true
                  sourceSize.width: width * 2
                  sourceSize.height: height * 2
                }
                NIcon {
                  anchors.centerIn: parent
                  icon: "music"
                  color: Color.mPrimary
                  visible: MediaService.trackArtUrl.length === 0
                  applyUiScale: true
                }

                // Subtle accent ring
                Rectangle {
                  anchors.fill: parent
                  radius: parent.radius
                  color: "transparent"
                  border.color: Qt.alpha(Color.mPrimary, 0.45)
                  border.width: 1
                }
              }

              ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                NText {
                  Layout.fillWidth: true
                  text: MediaService.trackTitle
                  color: Color.mOnSurface
                  pointSize: Style.fontSizeL
                  font.weight: Font.Bold
                  elide: Text.ElideRight
                }
                NText {
                  Layout.fillWidth: true
                  text: MediaService.trackArtist
                  color: Color.mOnSurfaceVariant
                  pointSize: Style.fontSizeS
                  elide: Text.ElideRight
                }

                // Position / duration
                RowLayout {
                  Layout.fillWidth: true
                  Layout.topMargin: 2
                  NText {
                    text: root.fmtTime(root.mediaPos)
                    color: Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeXS
                    font.family: "monospace"
                  }
                  Item { Layout.fillWidth: true }
                  NText {
                    text: root.fmtTime(root.mediaLen)
                    color: Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeXS
                    font.family: "monospace"
                  }
                }

                // Scrubbable progress bar
                Item {
                  Layout.fillWidth: true
                  Layout.preferredHeight: 8

                  Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 3
                    anchors.bottomMargin: 3
                    radius: 1
                    color: Qt.alpha(Color.mOutline, 0.4)

                    Rectangle {
                      anchors.left: parent.left
                      anchors.top: parent.top
                      anchors.bottom: parent.bottom
                      width: parent.width * (root.mediaLen > 0 ? Math.min(1, root.mediaPos / root.mediaLen) : 0)
                      radius: 1
                      color: Color.mPrimary
                      Behavior on width { NumberAnimation { duration: 350 } }
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    enabled: root.mediaLen > 0
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: (mouse) => {
                      const frac = Math.max(0, Math.min(1, mouse.x / width))
                      const p = MediaService.currentPlayer
                      if (!p) return
                      const target = frac * root.mediaLen
                      if (typeof p.seek === "function") p.seek(target)
                      else if (typeof p.setPosition === "function") p.setPosition(target)
                      root.mediaPos = target
                    }
                  }
                }
              }
            }

            RowLayout {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignHCenter
              spacing: Style.marginS

              NIconButton {
                icon: "media-prev"
                enabled: MediaService.canGoPrevious
                onClicked: { const p = MediaService.currentPlayer; if (p && MediaService.canGoPrevious) p.previous() }
              }
              NIconButton {
                icon: MediaService.isPlaying ? "media-pause" : "media-play"
                onClicked: { const p = MediaService.currentPlayer; if (!p) return; if (MediaService.isPlaying) p.pause(); else p.play() }
              }
              NIconButton {
                icon: "media-next"
                enabled: MediaService.canGoNext
                onClicked: { const p = MediaService.currentPlayer; if (p && MediaService.canGoNext) p.next() }
              }
            }
          }

          NDivider {
            Layout.fillWidth: true
            visible: root.mediaActive
          }

          // ── Volume slider ──────────────────────────
          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NIcon {
              icon: root.volumeIcon()
              color: root.volumeMuted ? Color.mError : Color.mOnSurfaceVariant
              applyUiScale: true
            }

            Item {
              Layout.fillWidth: true
              Layout.preferredHeight: 18

              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 4
                radius: 2
                color: Qt.alpha(Color.mOutline, 0.5)

                Rectangle {
                  anchors.left: parent.left
                  anchors.top: parent.top
                  anchors.bottom: parent.bottom
                  width: parent.width * (root.volumePct / 100.0)
                  radius: 2
                  color: root.volumeMuted ? Color.mError : Color.mPrimary
                  Behavior on width { NumberAnimation { duration: 200 } }
                }
              }

              Rectangle {
                width: 12; height: 12; radius: 6
                color: root.volumeMuted ? Color.mError : Color.mPrimary
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(parent.width - width, parent.width * (root.volumePct / 100.0) - width / 2))
                border.color: Color.mSurface
                border.width: 2
                Behavior on x { NumberAnimation { duration: 200 } }
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                  const v = Math.max(0, Math.min(100, Math.round(mouse.x / width * 100)))
                  root.setVolume(v)
                  root.volumePct = v
                }
                onPositionChanged: (mouse) => {
                  if (!pressed) return
                  const v = Math.max(0, Math.min(100, Math.round(mouse.x / width * 100)))
                  root.setVolume(v)
                  root.volumePct = v
                }
              }
            }

            NText {
              text: root.volumePct + "%"
              color: Color.mOnSurfaceVariant
              pointSize: Style.fontSizeS
              font.family: "monospace"
              Layout.preferredWidth: 36
            }
          }

          // ── Battery row ────────────────────────────
          RowLayout {
            Layout.fillWidth: true
            visible: root.batteryLevel >= 0
            spacing: Style.marginS

            NIcon {
              icon: root.batteryIcon()
              color: root.batteryLevel <= 10 && root.batteryState !== "Charging"
                     ? Color.mError : Color.mOnSurfaceVariant
              applyUiScale: true
            }
            NText {
              Layout.fillWidth: true
              text: root.batteryLevel + "% · " + (root.batteryState || "Unknown")
              color: Color.mOnSurface
              pointSize: Style.fontSizeM
            }
          }

          NDivider {
            Layout.fillWidth: true
            visible: root.notifCount > 0
          }

          // ── Notification list ──────────────────────
          ColumnLayout {
            Layout.fillWidth: true
            visible: root.notifCount > 0
            spacing: 4

            NText {
              text: "Notifications · " + root.notifCount
              color: Color.mOnSurfaceVariant
              pointSize: Style.fontSizeXS
              font.weight: Font.Medium
            }

            Repeater {
              model: Math.min(5, root.notifCount)
              delegate: Rectangle {
                id: notifCard
                Layout.fillWidth: true
                Layout.preferredHeight: notifRow.implicitHeight + 12
                radius: 8
                color: Qt.alpha(Color.mSurfaceVariant, 0.55)
                border.color: Qt.alpha(Color.mOutline, 0.3)
                border.width: 1

                readonly property var n: root.notifModel ? root.notifModel.get(index) : null
                readonly property int urgency: n && n.urgency !== undefined ? n.urgency : 1
                readonly property color accent:
                    urgency === 2 ? Color.mError
                  : urgency === 0 ? Color.mOnSurfaceVariant
                  : Color.mTertiary

                RowLayout {
                  id: notifRow
                  anchors.fill: parent
                  anchors.margins: 6
                  spacing: 8

                  Rectangle {
                    Layout.preferredWidth: 4
                    Layout.fillHeight: true
                    radius: 2
                    color: notifCard.accent
                  }
                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    NText {
                      Layout.fillWidth: true
                      text: notifCard.n
                        ? (notifCard.n.summary || notifCard.n.appName || "Notification")
                        : ""
                      color: Color.mOnSurface
                      pointSize: Style.fontSizeS
                      font.weight: Font.Medium
                      elide: Text.ElideRight
                    }
                    NText {
                      Layout.fillWidth: true
                      visible: notifCard.n && notifCard.n.body && notifCard.n.body.length > 0
                      text: notifCard.n ? notifCard.n.body : ""
                      color: Color.mOnSurfaceVariant
                      pointSize: Style.fontSizeXS
                      elide: Text.ElideRight
                      maximumLineCount: 2
                      wrapMode: Text.WordWrap
                    }
                  }
                  NIconButton {
                    icon: "close"
                    onClicked: {
                      if (notifCard.n) {
                        try { notifCard.n.dismiss() } catch (e) {}
                      }
                    }
                  }
                }
              }
            }
          }

          // Push the action row to bottom
          Item { Layout.fillHeight: true; Layout.minimumHeight: Style.marginS }

          NDivider { Layout.fillWidth: true }

          // ── Quick actions ─────────────────────────
          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NIconButton {
              icon: "moon"
              Layout.fillWidth: true
              onClicked: {
                if (!root.pluginApi || !root.pluginApi.pluginSettings) return
                root.pluginApi.pluginSettings.dndEnabled = !root.pluginApi.pluginSettings.dndEnabled
                try { root.pluginApi.saveSettings() } catch (e) {}
              }
            }
            NIconButton {
              icon: "timer"
              Layout.fillWidth: true
              onClicked: Quickshell.execDetached(["sh", "-c",
                "qs ipc call plugin:ns-dynamic-island pomodoroToggle 2>/dev/null || true"])
            }
            NIconButton {
              icon: "eye"
              Layout.fillWidth: true
              onClicked: {
                if (!root.pluginApi || !root.pluginApi.pluginSettings) return
                root.pluginApi.pluginSettings.overlayEnabled =
                  !root.pluginApi.pluginSettings.overlayEnabled
                try { root.pluginApi.saveSettings() } catch (e) {}
              }
            }
            NIconButton {
              icon: "settings"
              Layout.fillWidth: true
              onClicked: Quickshell.execDetached(["sh", "-c",
                "qs ipc call noctalia settings:plugins 2>/dev/null || true"])
            }
          }
        }
      }
    }
  }
}
