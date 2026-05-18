import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Media
import qs.Services.UI
import qs.Widgets

// Detail panel shown when the bar widget is clicked. Displays the full
// dynamic-island state with controls: media transport, notification
// dismiss, recording info, pomodoro toggle, weather, battery, DND.
Rectangle {
  id: root

  property var pluginApi: null
  readonly property var cfg: pluginApi?.pluginSettings || ({})

  implicitWidth: 360
  implicitHeight: column.implicitHeight + Style.marginL * 2

  color: Style.capsuleColor
  radius: Style.radiusL
  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth

  // ── Reactive sources ─────────────────────────────────────
  readonly property bool mediaActive: MediaService.trackTitle.length > 0
  readonly property var firstNotif:
    NotificationService.popupModel && NotificationService.popupModel.count > 0
    ? NotificationService.popupModel.get(0) : null
  readonly property int notifCount:
    NotificationService.popupModel ? NotificationService.popupModel.count : 0

  // Local state mirrors (polled)
  property string clockText: Qt.formatTime(new Date(), "HH:mm:ss")
  Timer {
    interval: 1000; running: root.visible; repeat: true; triggeredOnStart: true
    onTriggered: root.clockText = Qt.formatTime(new Date(), "HH:mm:ss")
  }

  property string activeWindowTitle: ""
  property string activeWindowAppId: ""
  Timer {
    interval: 1500; running: root.visible; repeat: true; triggeredOnStart: true
    onTriggered: if (!winProbe.running) winProbe.running = true
  }
  Process {
    id: winProbe
    running: false
    command: ["sh", "-c",
      "if command -v niri >/dev/null 2>&1; then " +
      "  niri msg --json focused-window 2>/dev/null | sed -n 's/.*\"title\":\\s*\"\\([^\"]*\\)\".*/\\1/p; s/.*\"app_id\":\\s*\"\\([^\"]*\\)\".*/APPID:\\1/p' | head -n2; " +
      "elif command -v hyprctl >/dev/null 2>&1; then " +
      "  hyprctl activewindow -j 2>/dev/null | sed -n 's/.*\"title\":\\s*\"\\([^\"]*\\)\".*/\\1/p; s/.*\"class\":\\s*\"\\([^\"]*\\)\".*/APPID:\\1/p' | head -n2; " +
      "fi"]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = (text || "").trim().split("\n")
        let title = "", appId = ""
        for (const l of lines) {
          if (l.startsWith("APPID:")) appId = l.substring(6)
          else if (title.length === 0) title = l
        }
        root.activeWindowTitle = title
        root.activeWindowAppId = appId
      }
    }
    onExited: running = false
  }

  property string weatherTemp: ""
  property string weatherCondition: ""
  Timer {
    interval: 10 * 60 * 1000; running: root.visible; repeat: true; triggeredOnStart: true
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

  property int batteryLevel: -1
  property string batteryState: ""
  Timer {
    interval: 30000; running: root.visible; repeat: true; triggeredOnStart: true
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

  // ── Layout ───────────────────────────────────────────────
  ColumnLayout {
    id: column
    anchors {
      fill: parent
      margins: Style.marginL
    }
    spacing: Style.marginM

    // Header — clock + weather
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NText {
        text: root.clockText
        color: Color.mOnSurface
        pointSize: Style.fontSizeL
        font.weight: Font.Bold
        font.family: "monospace"
        Layout.fillWidth: true
      }
      NIcon {
        visible: root.weatherTemp.length > 0
        icon: {
          const c = (root.weatherCondition || "").toLowerCase()
          if (c.indexOf("snow") !== -1) return "weather-snow"
          if (c.indexOf("rain") !== -1) return "weather-rain"
          if (c.indexOf("cloud") !== -1) return "weather-cloud"
          return "weather-sun"
        }
        color: Color.mOnSurfaceVariant
      }
      NText {
        visible: root.weatherTemp.length > 0
        text: root.weatherTemp
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeM
      }
    }

    NDivider { Layout.fillWidth: true }

    // Active window
    RowLayout {
      Layout.fillWidth: true
      visible: root.activeWindowTitle.length > 0
      spacing: Style.marginS

      NIcon { icon: "window"; color: Color.mOnSurfaceVariant }
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
        && (root.mediaActive || root.firstNotif || root.batteryLevel >= 0)
    }

    // Media
    ColumnLayout {
      Layout.fillWidth: true
      visible: root.mediaActive
      spacing: Style.marginS

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        Rectangle {
          width: 48; height: 48; radius: 8
          color: Qt.alpha(Color.mSurfaceVariant, 0.85)
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
            color: Color.mPrimary
            visible: MediaService.trackArtUrl.length === 0
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
      visible: root.mediaActive && (root.firstNotif || root.batteryLevel >= 0)
    }

    // Top notification
    ColumnLayout {
      Layout.fillWidth: true
      visible: root.firstNotif !== null
      spacing: Style.marginS

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        NIcon {
          icon: root.firstNotif && root.firstNotif.urgency === 2 ? "alert" : "bell"
          color: root.firstNotif && root.firstNotif.urgency === 2 ? Color.mError : Color.mTertiary
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
    }

    NDivider {
      Layout.fillWidth: true
      visible: root.firstNotif !== null && root.batteryLevel >= 0
    }

    // Battery
    RowLayout {
      Layout.fillWidth: true
      visible: root.batteryLevel >= 0
      spacing: Style.marginS

      NIcon {
        icon: root.batteryState === "Charging" ? "battery-charging"
          : root.batteryLevel >= 90 ? "battery-full"
          : root.batteryLevel >= 60 ? "battery-high"
          : root.batteryLevel >= 30 ? "battery-medium"
          : root.batteryLevel >= 10 ? "battery-low"
          : "battery-empty"
        color: root.batteryLevel <= 10 && root.batteryState !== "Charging"
               ? Color.mError : Color.mOnSurfaceVariant
      }
      NText {
        Layout.fillWidth: true
        text: root.batteryLevel + "% · " + (root.batteryState || "Unknown")
        color: Color.mOnSurface
        pointSize: Style.fontSizeM
      }
    }

    NDivider { Layout.fillWidth: true }

    // Quick actions
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NIconButton {
        icon: "moon"
        Layout.fillWidth: true
        onClicked: Quickshell.execDetached(["sh", "-c",
          "qs ipc call plugin:ns-dynamic-island dnd " + (root.cfg.dndEnabled ? "false" : "true")])
      }
      NIconButton {
        icon: "timer"
        Layout.fillWidth: true
        onClicked: Quickshell.execDetached(["sh", "-c",
          "qs ipc call plugin:ns-dynamic-island pomodoroToggle"])
      }
      NIconButton {
        icon: "eye"
        Layout.fillWidth: true
        onClicked: Quickshell.execDetached(["sh", "-c",
          "qs ipc call plugin:ns-dynamic-island toggle"])
      }
    }
  }
}
