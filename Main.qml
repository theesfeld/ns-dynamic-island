import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Services.Compositor
import qs.Services.Media
import qs.Services.System
import qs.Services.UI

Item {
  id: root

  property var pluginApi: null

  // ── Settings (reactive, with defaults) ───────────────────
  readonly property var cfg: pluginApi?.pluginSettings || ({})
  readonly property var def: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  readonly property bool enabled: cfg.enabled ?? def.enabled ?? true
  readonly property string position: cfg.position || def.position || "top"
  readonly property int marginPx: cfg.marginPx ?? def.marginPx ?? 6
  readonly property int horizontalOffset: cfg.horizontalOffset ?? def.horizontalOffset ?? 0
  readonly property int compactWidth: cfg.compactWidth ?? def.compactWidth ?? 180
  readonly property int expandedWidth: cfg.expandedWidth ?? def.expandedWidth ?? 440
  readonly property int islandHeight: cfg.height ?? def.height ?? 36
  readonly property int cornerRadius: cfg.cornerRadius ?? def.cornerRadius ?? 18
  readonly property int hideDelaySec: cfg.hideDelaySec ?? def.hideDelaySec ?? 4
  readonly property bool hoverToExpand: cfg.hoverToExpand ?? def.hoverToExpand ?? true
  readonly property bool autoShowOnMedia: cfg.autoShowOnMedia ?? def.autoShowOnMedia ?? true
  readonly property bool autoShowOnNotification: cfg.autoShowOnNotification ?? def.autoShowOnNotification ?? true
  readonly property int notificationDurationSec: cfg.notificationDurationSec ?? def.notificationDurationSec ?? 5
  readonly property bool detectScreenRecording: cfg.detectScreenRecording ?? def.detectScreenRecording ?? true
  readonly property int recordingPollSec: cfg.recordingPollSec ?? def.recordingPollSec ?? 3
  readonly property bool idleShowClock: cfg.idleShowClock ?? def.idleShowClock ?? true
  readonly property bool idleShowWeather: cfg.idleShowWeather ?? def.idleShowWeather ?? false
  readonly property string weatherLocation: cfg.weatherLocation || def.weatherLocation || ""
  readonly property string weatherUnits: cfg.weatherUnits || def.weatherUnits || "metric"
  readonly property bool dualBubble: cfg.dualBubble ?? def.dualBubble ?? true
  readonly property var disabledScreens: cfg.disabledScreens || def.disabledScreens || []

  // ── Media (forwarded from MediaService) ──────────────────
  // `mediaActive` stays true while paused so the bubble doesn't vanish on pause.
  readonly property bool mediaActive: MediaService.trackTitle.length > 0
  readonly property bool mediaIsPlaying: MediaService.isPlaying
  readonly property string mediaTitle: MediaService.trackTitle
  readonly property string mediaArtist: MediaService.trackArtist
  readonly property string mediaArtUrl: MediaService.trackArtUrl
  readonly property real mediaPosition: MediaService.currentPosition
  readonly property real mediaLength: MediaService.trackLength
  readonly property bool mediaCanPlay: MediaService.canPlay
  readonly property bool mediaCanPause: MediaService.canPause
  readonly property bool mediaCanNext: MediaService.canGoNext
  readonly property bool mediaCanPrev: MediaService.canGoPrevious

  // ── Notification peek (most recent) ──────────────────────
  property var activeNotification: null
  readonly property bool notificationActive: activeNotification !== null

  // ── Screen recording ─────────────────────────────────────
  property bool recordingActive: false

  // ── Weather (populated by weatherTimer) ──────────────────
  property string weatherTemp: ""
  property string weatherCondition: ""
  property string weatherCode: ""

  // ── Manual force-show (IPC) ──────────────────────────────
  property bool forceShown: false

  // ── Visibility / expansion ───────────────────────────────
  readonly property bool anyBubbleActive: mediaActive || notificationActive || recordingActive
  readonly property bool idleVisible: idleShowClock || (idleShowWeather && weatherTemp.length > 0)
  readonly property bool shouldShow: enabled && (forceShown || anyBubbleActive || idleVisible)

  property bool hovered: false
  // Expand when hovered, when media is the headline, or when a notification is peeking.
  readonly property bool expanded: hovered
    || (mediaActive && !recordingActive)
    || (autoShowOnNotification && notificationActive)

  // ── Media change → optional auto-show poke ───────────────
  Connections {
    target: MediaService
    function onTrackTitleChanged() {
      if (root.autoShowOnMedia && root.mediaTitle.length > 0) root.peek()
    }
    function onIsPlayingChanged() {
      if (root.autoShowOnMedia && MediaService.isPlaying) root.peek()
    }
  }

  // ── Notification peek ────────────────────────────────────
  Connections {
    target: NotificationService.popupModel
    function onCountChanged() {
      if (!root.autoShowOnNotification) return
      if (NotificationService.popupModel.count === 0) return
      const latest = NotificationService.popupModel.get(0)
      if (!latest) return
      root.activeNotification = {
        summary: latest.summary || "",
        body: latest.body || "",
        appName: latest.appName || "",
        image: latest.cachedImage || latest.originalImage || "",
        urgency: latest.urgency !== undefined ? latest.urgency : 1,
        timestamp: latest.timestamp || Date.now()
      }
      notificationClearTimer.restart()
    }
  }

  Timer {
    id: notificationClearTimer
    interval: Math.max(1000, root.notificationDurationSec * 1000)
    repeat: false
    onTriggered: root.activeNotification = null
  }

  // ── Screen recording detection ───────────────────────────
  Timer {
    id: recordingPoller
    interval: Math.max(1000, root.recordingPollSec * 1000)
    running: root.detectScreenRecording
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!recordingProbe.running) recordingProbe.running = true
  }

  Process {
    id: recordingProbe
    running: false
    command: ["sh", "-c", "pgrep -x gpu-screen-recorder >/dev/null 2>&1 || pgrep -x wf-recorder >/dev/null 2>&1 || pgrep -x obs >/dev/null 2>&1 || pgrep -x kooha >/dev/null 2>&1"]
    onExited: function (exitCode) {
      root.recordingActive = (exitCode === 0)
      running = false
    }
  }

  // ── Weather (wttr.in, optional) ──────────────────────────
  Timer {
    id: weatherTimer
    interval: 30 * 60 * 1000
    running: root.idleShowWeather
    repeat: true
    triggeredOnStart: true
    onTriggered: root.fetchWeather()
  }

  function fetchWeather() {
    const loc = encodeURIComponent(weatherLocation || "")
    const url = "https://wttr.in/" + loc + "?format=j1"
    const xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== XMLHttpRequest.DONE) return
      if (xhr.status !== 200) {
        Logger.w("ns-dynamic-island", "Weather fetch failed:", xhr.status)
        return
      }
      try {
        const data = JSON.parse(xhr.responseText)
        const cur = data && data.current_condition && data.current_condition[0]
        if (!cur) return
        root.weatherTemp = (weatherUnits === "imperial" ? cur.temp_F + "°F" : cur.temp_C + "°C")
        root.weatherCondition = (cur.weatherDesc && cur.weatherDesc[0] && cur.weatherDesc[0].value) || ""
        root.weatherCode = cur.weatherCode || ""
      } catch (e) {
        Logger.w("ns-dynamic-island", "Weather parse failed:", e)
      }
    }
    xhr.open("GET", url)
    xhr.send()
  }

  // ── Peek (force-show briefly) ────────────────────────────
  function peek() {
    forceShown = true
    peekTimer.restart()
  }

  Timer {
    id: peekTimer
    interval: Math.max(500, root.hideDelaySec * 1000)
    repeat: false
    onTriggered: root.forceShown = false
  }

  // ── Media transport passthrough ──────────────────────────
  function mediaPlayPause() {
    const p = MediaService.currentPlayer
    if (!p) return
    if (MediaService.isPlaying) p.pause()
    else p.play()
  }
  function mediaNext() {
    const p = MediaService.currentPlayer
    if (p && MediaService.canGoNext) p.next()
  }
  function mediaPrevious() {
    const p = MediaService.currentPlayer
    if (p && MediaService.canGoPrevious) p.previous()
  }
  function dismissNotification() {
    root.activeNotification = null
    notificationClearTimer.stop()
  }

  // ── IPC handler ──────────────────────────────────────────
  IpcHandler {
    target: "plugin:ns-dynamic-island"

    function peek(): void {
      root.peek()
    }

    function hide(): void {
      root.forceShown = false
      root.activeNotification = null
      peekTimer.stop()
      notificationClearTimer.stop()
    }

    function toggle(): void {
      root.forceShown = !root.forceShown
      if (root.forceShown) peekTimer.restart()
    }
  }

  // ── Multi-monitor floating island windows ────────────────
  Variants {
    model: Quickshell.screens.filter(s => root.disabledScreens.indexOf(s.name) === -1)

    delegate: Island {
      required property var modelData
      screen: modelData
      main: root
    }
  }

  Component.onCompleted: {
    Logger.i("ns-dynamic-island", "initialized on",
      CompositorService.isNiri ? "niri"
        : (CompositorService.isHyprland ? "hyprland" : "other"))
  }
}
