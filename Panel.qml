import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Compositor
import qs.Services.Media
import qs.Services.UI
import qs.Widgets

// Detail panel shown when the bar widget is clicked. Follows Noctalia's
// SmartPanel contract: root is an Item with geometryPlaceholder,
// contentPreferredWidth/Height, and allowAttach. The actual content
// lives inside panelContainer.
Item {
  id: root

  property var pluginApi: null

  // SmartPanel required properties
  readonly property var geometryPlaceholder: panelContainer
  property real contentPreferredWidth:  380 * Style.uiScaleRatio
  property real contentPreferredHeight: 320 * Style.uiScaleRatio
  readonly property bool allowAttach: true

  anchors.fill: parent

  // ── Reactive state ───────────────────────────────────────
  readonly property var cfg: pluginApi?.pluginSettings || ({})

  readonly property bool mediaActive: MediaService.trackTitle.length > 0
  readonly property var firstNotif:
    NotificationService.popupModel && NotificationService.popupModel.count > 0
    ? NotificationService.popupModel.get(0) : null
  readonly property int notifCount:
    NotificationService.popupModel ? NotificationService.popupModel.count : 0

  // Active window via CompositorService (Niri / Hyprland)
  property string activeWindowTitle: ""
  property string activeWindowAppId: ""

  function refreshActiveWindow() {
    const w = CompositorService.getFocusedWindow ? CompositorService.getFocusedWindow() : null
    if (w) {
      root.activeWindowTitle = w.title || ""
      root.activeWindowAppId = w.appId || ""
    }
  }

  Connections {
    target: CompositorService
    function onActiveWindowChanged() { root.refreshActiveWindow() }
    function onWindowListChanged()   { root.refreshActiveWindow() }
  }

  // Live clock
  property string clockText: Qt.formatTime(new Date(), "HH:mm:ss")
  Timer {
    interval: 1000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: root.clockText = Qt.formatTime(new Date(), "HH:mm:ss")
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

  // Battery from /sys
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
        height: parent.height * 0.45
        radius: parent.radius
        gradient: Gradient {
          GradientStop { position: 0.0; color: Qt.alpha("#ffffff", 0.14) }
          GradientStop { position: 1.0; color: Qt.alpha("#ffffff", 0.0) }
        }
      }

      ColumnLayout {
        anchors {
          fill: parent
          margins: Style.marginM
        }
        spacing: Style.marginS

        // ── Header: clock + weather ───────────────────
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.marginM

          NText {
            text: root.clockText
            color: Color.mOnSurface
            pointSize: Style.fontSizeXL
            font.weight: Font.Bold
            font.family: "monospace"
            Layout.fillWidth: true
          }
          NIcon {
            visible: root.weatherTemp.length > 0
            icon: root.weatherIcon()
            color: Color.mOnSurfaceVariant
            applyUiScale: true
          }
          NText {
            visible: root.weatherTemp.length > 0
            text: root.weatherTemp
            color: Color.mOnSurfaceVariant
            pointSize: Style.fontSizeM
          }
        }

        NDivider { Layout.fillWidth: true }

        // ── Active window ─────────────────────────────
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
          visible: root.activeWindowTitle.length > 0
            && (root.mediaActive || root.firstNotif !== null || root.batteryLevel >= 0)
        }

        // ── Media ─────────────────────────────────────
        ColumnLayout {
          Layout.fillWidth: true
          visible: root.mediaActive
          spacing: Style.marginS

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            Rectangle {
              width: 48 * Style.uiScaleRatio
              height: 48 * Style.uiScaleRatio
              radius: 8
              color: Color.mSurfaceVariant
              clip: true

              Image {
                anchors.fill: parent
                source: MediaService.trackArtUrl
                fillMode: Image.PreserveAspectCrop
                visible: MediaService.trackArtUrl.length > 0 && status === Image.Ready
                asynchronous: true; cache: true
              }
              NIcon {
                anchors.centerIn: parent
                icon: "music"
                color: Color.mOnSurface
                visible: MediaService.trackArtUrl.length === 0
                applyUiScale: true
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 0
              NText {
                Layout.fillWidth: true
                text: MediaService.trackTitle
                color: Color.mOnSurface
                pointSize: Style.fontSizeM
                font.weight: Font.Medium
                elide: Text.ElideRight
              }
              NText {
                Layout.fillWidth: true
                text: MediaService.trackArtist
                color: Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXS
                elide: Text.ElideRight
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
              onClicked: {
                const p = MediaService.currentPlayer
                if (p && MediaService.canGoPrevious) p.previous()
              }
            }
            NIconButton {
              icon: MediaService.isPlaying ? "media-pause" : "media-play"
              onClicked: {
                const p = MediaService.currentPlayer
                if (!p) return
                if (MediaService.isPlaying) p.pause(); else p.play()
              }
            }
            NIconButton {
              icon: "media-next"
              enabled: MediaService.canGoNext
              onClicked: {
                const p = MediaService.currentPlayer
                if (p && MediaService.canGoNext) p.next()
              }
            }
          }
        }

        NDivider {
          Layout.fillWidth: true
          visible: root.mediaActive && (root.firstNotif !== null || root.batteryLevel >= 0)
        }

        // ── Top notification ──────────────────────────
        RowLayout {
          Layout.fillWidth: true
          visible: root.firstNotif !== null
          spacing: Style.marginS

          NIcon {
            icon: root.firstNotif && root.firstNotif.urgency === 2 ? "alert" : "bell"
            color: root.firstNotif && root.firstNotif.urgency === 2 ? Color.mError : Color.mTertiary
            applyUiScale: true
          }
          ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            NText {
              Layout.fillWidth: true
              text: root.firstNotif ? (root.firstNotif.summary || root.firstNotif.appName || "") : ""
              color: Color.mOnSurface
              pointSize: Style.fontSizeM
              font.weight: Font.Medium
              elide: Text.ElideRight
            }
            NText {
              Layout.fillWidth: true
              visible: root.firstNotif && root.firstNotif.body && root.firstNotif.body.length > 0
              text: root.firstNotif ? root.firstNotif.body : ""
              color: Color.mOnSurfaceVariant
              pointSize: Style.fontSizeXS
              elide: Text.ElideRight
              wrapMode: Text.WordWrap
              maximumLineCount: 3
            }
          }
          NText {
            visible: root.notifCount > 1
            text: "+" + (root.notifCount - 1)
            color: Color.mTertiary
            pointSize: Style.fontSizeXS
            font.weight: Font.Bold
          }
        }

        NDivider {
          Layout.fillWidth: true
          visible: root.firstNotif !== null && root.batteryLevel >= 0
        }

        // ── Battery ───────────────────────────────────
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

        Item { Layout.fillHeight: true }   // push the action row to the bottom

        // ── Quick actions ─────────────────────────────
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
        }
      }
    }
  }
}
