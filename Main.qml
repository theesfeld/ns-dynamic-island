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

  // Core
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
  readonly property bool dualBubble: cfg.dualBubble ?? def.dualBubble ?? true
  readonly property var disabledScreens: cfg.disabledScreens || def.disabledScreens || []

  // Theme & accessibility
  readonly property string themePreset: cfg.themePreset || def.themePreset || "system"
  readonly property bool highContrast: cfg.highContrast ?? def.highContrast ?? false
  readonly property bool largeText: cfg.largeText ?? def.largeText ?? false
  readonly property real backdropOpacity: cfg.backdropOpacity ?? def.backdropOpacity ?? 0.94
  readonly property bool fakeBlur: cfg.fakeBlur ?? def.fakeBlur ?? true

  // Visual polish toggles
  readonly property bool springExpand: cfg.springExpand ?? def.springExpand ?? true
  readonly property bool criticalGlow: cfg.criticalGlow ?? def.criticalGlow ?? true
  readonly property bool timeOfDayTint: cfg.timeOfDayTint ?? def.timeOfDayTint ?? true
  readonly property bool dynamicMediaAccent: cfg.dynamicMediaAccent ?? def.dynamicMediaAccent ?? true
  readonly property bool smoothMediaPosition: cfg.smoothMediaPosition ?? def.smoothMediaPosition ?? true
  readonly property bool iconMicroAnimations: cfg.iconMicroAnimations ?? def.iconMicroAnimations ?? true

  // Interaction
  readonly property bool swipeGestures: cfg.swipeGestures ?? def.swipeGestures ?? true
  readonly property bool scrubMedia: cfg.scrubMedia ?? def.scrubMedia ?? true
  readonly property bool contextMenu: cfg.contextMenu ?? def.contextMenu ?? true

  // Media
  readonly property bool autoShowOnMedia: cfg.autoShowOnMedia ?? def.autoShowOnMedia ?? true

  // Notifications
  readonly property bool autoShowOnNotification: cfg.autoShowOnNotification ?? def.autoShowOnNotification ?? true
  readonly property int notificationDurationSec: cfg.notificationDurationSec ?? def.notificationDurationSec ?? 5
  readonly property bool stackNotifications: cfg.stackNotifications ?? def.stackNotifications ?? true
  readonly property bool showNotificationActions: cfg.showNotificationActions ?? def.showNotificationActions ?? true
  readonly property var notificationMutedApps: cfg.notificationMutedApps || def.notificationMutedApps || []
  readonly property var notificationPinnedApps: cfg.notificationPinnedApps || def.notificationPinnedApps || []
  readonly property bool dndEnabled: cfg.dndEnabled ?? def.dndEnabled ?? false
  readonly property bool dndPausesMediaAutoShow: cfg.dndPausesMediaAutoShow ?? def.dndPausesMediaAutoShow ?? false

  // Recording
  readonly property bool detectScreenRecording: cfg.detectScreenRecording ?? def.detectScreenRecording ?? true
  readonly property int recordingPollSec: cfg.recordingPollSec ?? def.recordingPollSec ?? 3

  // Idle
  readonly property bool idleShowClock: cfg.idleShowClock ?? def.idleShowClock ?? true
  readonly property bool idleShowWeather: cfg.idleShowWeather ?? def.idleShowWeather ?? false
  readonly property bool idleShowSeconds: cfg.idleShowSeconds ?? def.idleShowSeconds ?? false
  readonly property bool idleUse24h: cfg.idleUse24h ?? def.idleUse24h ?? true
  readonly property string weatherLocation: cfg.weatherLocation || def.weatherLocation || ""
  readonly property string weatherUnits: cfg.weatherUnits || def.weatherUnits || "metric"
  readonly property bool weatherCacheEnabled: cfg.weatherCacheEnabled ?? def.weatherCacheEnabled ?? true

  // Battery
  readonly property bool batteryEnabled: cfg.batteryEnabled ?? def.batteryEnabled ?? true
  readonly property int batteryLowThreshold: cfg.batteryLowThreshold ?? def.batteryLowThreshold ?? 20
  readonly property int batteryPollSec: cfg.batteryPollSec ?? def.batteryPollSec ?? 30
  readonly property bool batteryShowOnChange: cfg.batteryShowOnChange ?? def.batteryShowOnChange ?? true

  // OSD (volume / brightness)
  readonly property bool osdEnabled: cfg.osdEnabled ?? def.osdEnabled ?? true
  readonly property int osdDurationSec: cfg.osdDurationSec ?? def.osdDurationSec ?? 2

  // Pomodoro
  readonly property bool pomodoroEnabled: cfg.pomodoroEnabled ?? def.pomodoroEnabled ?? true
  readonly property int pomodoroWorkMin: cfg.pomodoroWorkMin ?? def.pomodoroWorkMin ?? 25
  readonly property int pomodoroShortBreakMin: cfg.pomodoroShortBreakMin ?? def.pomodoroShortBreakMin ?? 5
  readonly property int pomodoroLongBreakMin: cfg.pomodoroLongBreakMin ?? def.pomodoroLongBreakMin ?? 15
  readonly property int pomodoroLongBreakEvery: cfg.pomodoroLongBreakEvery ?? def.pomodoroLongBreakEvery ?? 4
  readonly property bool pomodoroAutoDnd: cfg.pomodoroAutoDnd ?? def.pomodoroAutoDnd ?? false

  // Timer (generic)
  readonly property bool timerEnabled: cfg.timerEnabled ?? def.timerEnabled ?? true

  // Privacy
  readonly property bool privacyIndicatorEnabled: cfg.privacyIndicatorEnabled ?? def.privacyIndicatorEnabled ?? true
  readonly property int privacyPollSec: cfg.privacyPollSec ?? def.privacyPollSec ?? 4

  // Network
  readonly property bool networkEnabled: cfg.networkEnabled ?? def.networkEnabled ?? true
  readonly property int networkPollSec: cfg.networkPollSec ?? def.networkPollSec ?? 8

  // Bluetooth
  readonly property bool bluetoothEnabled: cfg.bluetoothEnabled ?? def.bluetoothEnabled ?? true

  // Keyboard layout
  readonly property bool keyboardLayoutEnabled: cfg.keyboardLayoutEnabled ?? def.keyboardLayoutEnabled ?? true

  // Workspace indicator
  readonly property bool workspaceEnabled: cfg.workspaceEnabled ?? def.workspaceEnabled ?? true

  // Clipboard / Screenshot
  readonly property bool clipboardEnabled: cfg.clipboardEnabled ?? def.clipboardEnabled ?? false
  readonly property bool clipboardPrivacy: cfg.clipboardPrivacy ?? def.clipboardPrivacy ?? true
  readonly property bool screenshotEnabled: cfg.screenshotEnabled ?? def.screenshotEnabled ?? true
  readonly property string screenshotDir: cfg.screenshotDir || def.screenshotDir || ""

  // Calendar
  readonly property bool calendarEnabled: cfg.calendarEnabled ?? def.calendarEnabled ?? false

  // Download
  readonly property bool downloadEnabled: cfg.downloadEnabled ?? def.downloadEnabled ?? true

  // CPU / temp
  readonly property bool cpuEnabled: cfg.cpuEnabled ?? def.cpuEnabled ?? false
  readonly property int cpuPollSec: cfg.cpuPollSec ?? def.cpuPollSec ?? 5
  readonly property int cpuTempCritical: cfg.cpuTempCritical ?? def.cpuTempCritical ?? 85

  // ── Theme application ────────────────────────────────────
  readonly property color themeSurface: {
    if (themePreset === "amoled") return "#000000"
    if (themePreset === "light")  return Qt.lighter(Color.mSurface, 1.0)
    if (themePreset === "matchWallpaper" && Color.mSurface !== undefined) return Color.mSurface
    return Color.mSurface
  }
  readonly property color themeOnSurface: {
    if (themePreset === "amoled" || themePreset === "dark") return "#FFFFFF"
    if (themePreset === "light") return "#111111"
    return Color.mOnSurface
  }
  readonly property color themeOutline: {
    if (highContrast) return "#FFFFFF"
    return Color.mOutline
  }
  readonly property real textScale: largeText ? 1.18 : 1.0

  // ── Media (forwarded from MediaService) ──────────────────
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

  // Smoothed media position
  property real smoothedMediaPosition: mediaPosition
  Timer {
    id: smoothMediaTicker
    interval: 250
    repeat: true
    running: root.smoothMediaPosition && root.mediaIsPlaying && root.mediaActive
    onTriggered: {
      const next = root.smoothedMediaPosition + 0.25
      if (root.mediaLength > 0 && next > root.mediaLength) {
        root.smoothedMediaPosition = root.mediaLength
      } else {
        root.smoothedMediaPosition = next
      }
    }
  }
  Connections {
    target: MediaService
    function onCurrentPositionChanged() {
      const drift = Math.abs(MediaService.currentPosition - root.smoothedMediaPosition)
      if (drift > 1.0 || !root.smoothMediaPosition) {
        root.smoothedMediaPosition = MediaService.currentPosition
      }
    }
  }

  // Dynamic accent: deterministic hash of artist+title → hue
  readonly property color mediaAccent: {
    if (!dynamicMediaAccent) return Color.mPrimary
    const s = (mediaTitle + "|" + mediaArtist)
    if (s.length === 0) return Color.mPrimary
    let h = 0
    for (let i = 0; i < s.length; i++) h = ((h << 5) - h) + s.charCodeAt(i)
    const hue = Math.abs(h % 360) / 360.0
    return Qt.hsla(hue, 0.55, 0.55, 1.0)
  }

  function mediaSeek(fraction) {
    if (mediaLength <= 0) return
    const target = Math.max(0, Math.min(1, fraction)) * mediaLength
    const p = MediaService.currentPlayer
    if (!p) return
    if (typeof p.seek === "function") {
      p.seek(target)
    } else if (typeof p.setPosition === "function") {
      p.setPosition(target)
    }
    root.smoothedMediaPosition = target
  }

  // ── Notification peek (queue head + queue size) ──────────
  property var activeNotification: null
  readonly property bool notificationActive: activeNotification !== null
  readonly property int notificationQueueCount:
      NotificationService.popupModel ? NotificationService.popupModel.count : 0
  property int notificationCursor: 0 // for cycling through stack

  Connections {
    target: NotificationService.popupModel
    function onCountChanged() {
      if (!root.autoShowOnNotification) return
      if (root.dndEnabled) return
      if (NotificationService.popupModel.count === 0) {
        root.activeNotification = null
        return
      }
      const idx = root.stackNotifications
                    ? Math.max(0, Math.min(root.notificationCursor, NotificationService.popupModel.count - 1))
                    : 0
      const latest = NotificationService.popupModel.get(idx)
      if (!latest) return
      const appName = latest.appName || ""
      if (root.notificationMutedApps.indexOf(appName) !== -1) return
      root.activeNotification = {
        summary: latest.summary || "",
        body: latest.body || "",
        appName: appName,
        image: latest.cachedImage || latest.originalImage || "",
        urgency: latest.urgency !== undefined ? latest.urgency : 1,
        timestamp: latest.timestamp || Date.now(),
        actions: latest.actions || [],
        pinned: root.notificationPinnedApps.indexOf(appName) !== -1
      }
      notificationClearTimer.restart()
    }
  }

  function cycleNotification(delta) {
    if (!NotificationService.popupModel || NotificationService.popupModel.count === 0) return
    const count = NotificationService.popupModel.count
    root.notificationCursor = ((root.notificationCursor + delta) % count + count) % count
    const n = NotificationService.popupModel.get(root.notificationCursor)
    if (!n) return
    root.activeNotification = {
      summary: n.summary || "",
      body: n.body || "",
      appName: n.appName || "",
      image: n.cachedImage || n.originalImage || "",
      urgency: n.urgency !== undefined ? n.urgency : 1,
      timestamp: n.timestamp || Date.now(),
      actions: n.actions || [],
      pinned: root.notificationPinnedApps.indexOf(n.appName || "") !== -1
    }
    notificationClearTimer.restart()
  }

  Timer {
    id: notificationClearTimer
    interval: Math.max(1000, root.notificationDurationSec * 1000)
    repeat: false
    onTriggered: {
      if (root.activeNotification && root.activeNotification.pinned) return
      root.activeNotification = null
    }
  }

  // ── Screen recording detection ───────────────────────────
  property bool recordingActive: false
  property real recordingStartedAtMs: 0

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
      const wasActive = root.recordingActive
      const nowActive = (exitCode === 0)
      if (nowActive && !wasActive) root.recordingStartedAtMs = Date.now()
      if (!nowActive) root.recordingStartedAtMs = 0
      root.recordingActive = nowActive
      running = false
    }
  }

  // ── Weather (wttr.in, optional, with cache) ──────────────
  property string weatherTemp: ""
  property string weatherCondition: ""
  property string weatherCode: ""
  property bool weatherStale: false

  Timer {
    id: weatherTimer
    interval: 30 * 60 * 1000
    running: root.idleShowWeather
    repeat: true
    triggeredOnStart: true
    onTriggered: root.fetchWeather()
  }

  Component.onCompleted: {
    if (root.weatherCacheEnabled) weatherCacheLoad.running = true
    Logger.i("ns-dynamic-island", "initialized on",
      CompositorService.isNiri ? "niri"
        : (CompositorService.isHyprland ? "hyprland" : "other"))
  }

  Process {
    id: weatherCacheLoad
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
          root.weatherCode = j.code || ""
          root.weatherStale = true
        } catch (e) {}
      }
    }
    onExited: running = false
  }

  property string _weatherCachePayload: ""
  Process {
    id: weatherCacheSave
    running: false
    command: ["sh", "-c",
      "mkdir -p \"$HOME/.cache/ns-dynamic-island\" && " +
      "printf '%s' \"$1\" > \"$HOME/.cache/ns-dynamic-island/weather.json\"",
      "sh", root._weatherCachePayload]
    onExited: running = false
  }

  function fetchWeather() {
    const loc = encodeURIComponent(weatherLocation || "")
    const url = "https://wttr.in/" + loc + "?format=j1"
    const xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function () {
      if (xhr.readyState !== XMLHttpRequest.DONE) return
      if (xhr.status !== 200) {
        Logger.w("ns-dynamic-island", "Weather fetch failed:", xhr.status)
        root.weatherStale = root.weatherTemp.length > 0
        return
      }
      try {
        const data = JSON.parse(xhr.responseText)
        const cur = data && data.current_condition && data.current_condition[0]
        if (!cur) return
        root.weatherTemp = (weatherUnits === "imperial" ? cur.temp_F + "°F" : cur.temp_C + "°C")
        root.weatherCondition = (cur.weatherDesc && cur.weatherDesc[0] && cur.weatherDesc[0].value) || ""
        root.weatherCode = cur.weatherCode || ""
        root.weatherStale = false
        if (root.weatherCacheEnabled) {
          root._weatherCachePayload = JSON.stringify({
            temp: root.weatherTemp,
            condition: root.weatherCondition,
            code: root.weatherCode,
            ts: Date.now()
          })
          weatherCacheSave.running = true
        }
      } catch (e) {
        Logger.w("ns-dynamic-island", "Weather parse failed:", e)
        root.weatherStale = root.weatherTemp.length > 0
      }
    }
    xhr.open("GET", url)
    xhr.send()
  }

  // ── Battery ──────────────────────────────────────────────
  property int batteryLevel: -1
  property string batteryState: ""
  property int batteryPrevLevel: -1
  property string batteryPrevState: ""
  readonly property bool batteryPresent: batteryLevel >= 0
  readonly property bool batteryCritical: batteryPresent && batteryLevel <= 10 && batteryState !== "Charging"
  property bool batteryPeek: false
  readonly property bool batteryActive: batteryEnabled && batteryPresent
    && (batteryCritical || batteryPeek)

  Timer {
    id: batteryPoller
    interval: Math.max(5000, root.batteryPollSec * 1000)
    running: root.batteryEnabled
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!batteryProbe.running) batteryProbe.running = true
  }

  Process {
    id: batteryProbe
    running: false
    command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*/; do [ -d \"$b\" ] && cap=$(cat \"$b\"capacity 2>/dev/null) && st=$(cat \"$b\"status 2>/dev/null) && echo \"$cap|$st\" && break; done"]
    stdout: StdioCollector {
      onStreamFinished: {
        const line = (text || "").trim()
        if (line.length === 0) {
          root.batteryLevel = -1
          root.batteryState = ""
          return
        }
        const parts = line.split("|")
        const lvl = parseInt(parts[0])
        const st = (parts[1] || "").trim()
        if (isNaN(lvl)) { root.batteryLevel = -1; root.batteryState = ""; return }
        const stateChanged = st !== root.batteryPrevState && root.batteryPrevState.length > 0
        const crossedLow = st === "Discharging"
          && root.batteryPrevLevel > root.batteryLowThreshold
          && lvl <= root.batteryLowThreshold
        root.batteryLevel = lvl
        root.batteryState = st
        if (root.batteryShowOnChange && (stateChanged || crossedLow)) {
          root.batteryPeek = true
          batteryPeekTimer.restart()
        }
        root.batteryPrevLevel = lvl
        root.batteryPrevState = st
      }
    }
    onExited: running = false
  }

  Timer {
    id: batteryPeekTimer
    interval: Math.max(2000, root.hideDelaySec * 1000)
    repeat: false
    onTriggered: root.batteryPeek = false
  }

  // ── Privacy indicators ───────────────────────────────────
  property bool micInUse: false
  property bool camInUse: false

  Timer {
    id: privacyPoller
    interval: Math.max(2000, root.privacyPollSec * 1000)
    running: root.privacyIndicatorEnabled
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!privacyProbe.running) privacyProbe.running = true
  }

  Process {
    id: privacyProbe
    running: false
    command: ["sh", "-c", "m=0; c=0; if command -v pactl >/dev/null 2>&1; then n=$(pactl list source-outputs 2>/dev/null | grep -cE '^Source Output #' || echo 0); [ \"$n\" -gt 0 ] 2>/dev/null && m=1; fi; for d in /dev/video*; do [ -e \"$d\" ] && command -v fuser >/dev/null 2>&1 && fuser \"$d\" >/dev/null 2>&1 && c=1 && break; done; echo \"$m|$c\""]
    stdout: StdioCollector {
      onStreamFinished: {
        const line = (text || "").trim()
        if (line.length === 0) { root.micInUse = false; root.camInUse = false; return }
        const parts = line.split("|")
        root.micInUse = parts[0] === "1"
        root.camInUse = parts[1] === "1"
      }
    }
    onExited: running = false
  }

  // ── Network ──────────────────────────────────────────────
  property string netState: ""    // "wifi" | "ethernet" | "disconnected"
  property string netSsid: ""
  property bool netVpn: false
  property int netSignal: 0
  property string netPrevState: ""
  property string netPrevSsid: ""
  property bool netPeek: false
  readonly property bool networkActive: networkEnabled && netPeek

  Timer {
    id: networkPoller
    interval: Math.max(3000, root.networkPollSec * 1000)
    running: root.networkEnabled
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!networkProbe.running) networkProbe.running = true
  }

  Process {
    id: networkProbe
    running: false
    command: ["sh", "-c",
      "if command -v nmcli >/dev/null 2>&1; then " +
      "  conn=$(nmcli -t -f TYPE,STATE,CONNECTION dev status 2>/dev/null | awk -F: '$2==\"connected\"{print $1\"|\"$3; exit}'); " +
      "  if [ -z \"$conn\" ]; then echo \"disconnected||0||0\"; else " +
      "    t=$(echo \"$conn\" | cut -d'|' -f1); n=$(echo \"$conn\" | cut -d'|' -f2); " +
      "    sig=0; [ \"$t\" = \"wifi\" ] && sig=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1==\"*\"{print $2; exit}'); " +
      "    vpn=0; nmcli -t -f TYPE,STATE dev status 2>/dev/null | grep -q '^vpn:connected\\|^wireguard:connected\\|^tun:connected' && vpn=1; " +
      "    case \"$t\" in wifi) k=wifi;; ethernet|802-3-ethernet) k=ethernet;; *) k=$t;; esac; " +
      "    echo \"$k|$n|${sig:-0}|$vpn|0\"; " +
      "  fi; " +
      "else " +
      "  for i in /sys/class/net/*/operstate; do s=$(cat \"$i\" 2>/dev/null); [ \"$s\" = \"up\" ] && echo \"ethernet||0|0|0\" && exit 0; done; " +
      "  echo \"disconnected||0|0|0\"; " +
      "fi"]
    stdout: StdioCollector {
      onStreamFinished: {
        const line = (text || "").trim()
        if (line.length === 0) return
        const parts = line.split("|")
        const st = parts[0] || "disconnected"
        const ssid = parts[1] || ""
        const sig = parseInt(parts[2] || "0") || 0
        const vpn = (parts[3] || "0") === "1"
        const stateChanged = (st !== root.netPrevState && root.netPrevState.length > 0)
            || (ssid !== root.netPrevSsid && st === "wifi")
        root.netState = st
        root.netSsid = ssid
        root.netSignal = sig
        root.netVpn = vpn
        if (stateChanged) {
          root.netPeek = true
          netPeekTimer.restart()
        }
        root.netPrevState = st
        root.netPrevSsid = ssid
      }
    }
    onExited: running = false
  }

  Timer {
    id: netPeekTimer
    interval: Math.max(2000, root.hideDelaySec * 1000)
    repeat: false
    onTriggered: root.netPeek = false
  }

  // ── Bluetooth ────────────────────────────────────────────
  property string btEvent: ""
  property string btDevice: ""
  property bool btPeek: false
  readonly property bool bluetoothActive: bluetoothEnabled && btPeek

  Timer {
    id: btPeekTimer
    interval: Math.max(2000, root.hideDelaySec * 1000)
    repeat: false
    onTriggered: root.btPeek = false
  }

  function btShow(event, device) {
    if (!bluetoothEnabled) return
    btEvent = event || ""
    btDevice = device || ""
    btPeek = true
    btPeekTimer.restart()
  }

  // ── Keyboard layout ──────────────────────────────────────
  property string keyboardLayout: ""
  property bool keyboardPeek: false
  readonly property bool keyboardActive: keyboardLayoutEnabled && keyboardPeek

  Timer {
    id: kbPeekTimer
    interval: Math.max(1500, root.hideDelaySec * 1000)
    repeat: false
    onTriggered: root.keyboardPeek = false
  }

  function keyboardShow(layout) {
    if (!keyboardLayoutEnabled) return
    keyboardLayout = layout || ""
    keyboardPeek = true
    kbPeekTimer.restart()
  }

  // ── Workspace indicator ──────────────────────────────────
  property string workspaceName: ""
  property string workspaceLabel: ""
  property bool workspacePeek: false
  readonly property bool workspaceActive: workspaceEnabled && workspacePeek

  Timer {
    id: wsPeekTimer
    interval: Math.max(1200, root.hideDelaySec * 800)
    repeat: false
    onTriggered: root.workspacePeek = false
  }

  function workspaceShow(name, label) {
    if (!workspaceEnabled) return
    workspaceName = name || ""
    workspaceLabel = label || ""
    workspacePeek = true
    wsPeekTimer.restart()
  }

  // ── Clipboard ────────────────────────────────────────────
  property string clipboardPreview: ""
  property string clipboardKind: "text"
  property bool clipboardPeek: false
  readonly property bool clipboardActive: clipboardEnabled && clipboardPeek

  Timer {
    id: clipPeekTimer
    interval: Math.max(1500, root.hideDelaySec * 1000)
    repeat: false
    onTriggered: root.clipboardPeek = false
  }

  function clipboardShow(preview, kind) {
    if (!clipboardEnabled) return
    const p = (preview || "").toString()
    if (clipboardPrivacy && p.length > 24) {
      clipboardPreview = p.substring(0, 24) + "…"
    } else {
      clipboardPreview = p
    }
    clipboardKind = kind || "text"
    clipboardPeek = true
    clipPeekTimer.restart()
  }

  // Clipboard is IPC-driven by default. Auto-watch flag is preserved for
  // forward-compat with a future poller that uses a verified Quickshell API.
  readonly property bool clipboardAutoWatch: cfg.clipboardAutoWatch ?? def.clipboardAutoWatch ?? false

  // ── Screenshot ───────────────────────────────────────────
  property string screenshotPath: ""
  property bool screenshotPeek: false
  readonly property bool screenshotActive: screenshotEnabled && screenshotPeek

  Timer {
    id: shotPeekTimer
    interval: Math.max(2500, root.hideDelaySec * 1000)
    repeat: false
    onTriggered: root.screenshotPeek = false
  }

  function screenshotShow(path) {
    if (!screenshotEnabled) return
    screenshotPath = path || ""
    screenshotPeek = true
    shotPeekTimer.restart()
  }

  // ── OSD (volume / brightness) ────────────────────────────
  property bool osdActive: false
  property string osdKind: "volume"
  property int osdValue: 0
  property bool osdMuted: false

  Timer {
    id: osdTimer
    interval: Math.max(800, root.osdDurationSec * 1000)
    repeat: false
    onTriggered: root.osdActive = false
  }

  function showOsd(kind, value, muted) {
    if (!root.osdEnabled) return
    root.osdKind = kind === "brightness" ? "brightness" : "volume"
    root.osdValue = Math.max(0, Math.min(100, value | 0))
    root.osdMuted = !!muted
    root.osdActive = true
    osdTimer.restart()
  }

  // ── Pomodoro engine ──────────────────────────────────────
  property string pomodoroPhase: "idle"
  property bool pomodoroPaused: false
  property int pomodoroRemainingSec: 0
  property int pomodoroPhaseTotalSec: 0
  property int pomodoroCycleCount: 0
  readonly property bool pomodoroActive: pomodoroEnabled && pomodoroPhase !== "idle"

  Timer {
    id: pomodoroTicker
    interval: 1000
    repeat: true
    running: root.pomodoroActive && !root.pomodoroPaused
    onTriggered: {
      if (root.pomodoroRemainingSec > 0) root.pomodoroRemainingSec -= 1
      else root._pomodoroAdvance()
    }
  }

  function _pomodoroAdvance() {
    if (pomodoroPhase === "work") {
      const cycle = pomodoroCycleCount + 1
      pomodoroCycleCount = cycle
      const long = pomodoroLongBreakEvery > 0 && (cycle % pomodoroLongBreakEvery === 0)
      pomodoroPhase = long ? "longBreak" : "break"
      pomodoroPhaseTotalSec = (long ? pomodoroLongBreakMin : pomodoroShortBreakMin) * 60
      pomodoroRemainingSec = pomodoroPhaseTotalSec
    } else {
      pomodoroPhase = "work"
      pomodoroPhaseTotalSec = pomodoroWorkMin * 60
      pomodoroRemainingSec = pomodoroPhaseTotalSec
    }
    root.peek()
  }

  function pomodoroStart() {
    pomodoroCycleCount = 0
    pomodoroPhase = "work"
    pomodoroPaused = false
    pomodoroPhaseTotalSec = pomodoroWorkMin * 60
    pomodoroRemainingSec = pomodoroPhaseTotalSec
    root.peek()
  }
  function pomodoroPause()  { pomodoroPaused = true }
  function pomodoroResume() { pomodoroPaused = false }
  function pomodoroSkip()   { if (pomodoroActive) _pomodoroAdvance() }
  function pomodoroStop() {
    pomodoroPhase = "idle"
    pomodoroPaused = false
    pomodoroRemainingSec = 0
    pomodoroPhaseTotalSec = 0
    pomodoroCycleCount = 0
  }

  // ── Generic timer ────────────────────────────────────────
  property int timerRemainingSec: 0
  property int timerTotalSec: 0
  property string timerLabel: ""
  readonly property bool timerActive: timerEnabled && timerRemainingSec > 0

  Timer {
    id: timerTicker
    interval: 1000
    repeat: true
    running: root.timerActive
    onTriggered: {
      if (root.timerRemainingSec > 0) root.timerRemainingSec -= 1
      if (root.timerRemainingSec === 0) {
        const lbl = root.timerLabel
        root.timerLabel = ""
        root.timerTotalSec = 0
        root.peek()
        Logger.i("ns-dynamic-island", "timer finished:", lbl)
      }
    }
  }

  function timerStart(seconds, label) {
    timerTotalSec = Math.max(1, seconds | 0)
    timerRemainingSec = timerTotalSec
    timerLabel = label || ""
    root.peek()
  }
  function timerStop() {
    timerRemainingSec = 0
    timerTotalSec = 0
    timerLabel = ""
  }

  // ── Calendar (IPC fed) ───────────────────────────────────
  property string calendarNextTitle: ""
  property string calendarNextWhen: ""
  property string calendarNextColor: ""
  readonly property bool calendarActive: calendarEnabled && hovered && calendarNextTitle.length > 0

  // ── Download (IPC fed) ───────────────────────────────────
  property string downloadName: ""
  property real downloadProgress: 0
  property int downloadSpeedKb: 0
  property bool downloadShowing: false
  readonly property bool downloadActive: downloadEnabled && downloadShowing

  function downloadStart(name) {
    downloadName = name || "Download"
    downloadProgress = 0
    downloadSpeedKb = 0
    downloadShowing = true
  }
  function downloadUpdate(progress, speedKb) {
    if (!downloadShowing) downloadShowing = true
    downloadProgress = Math.max(0, Math.min(1, progress))
    downloadSpeedKb = Math.max(0, speedKb | 0)
  }
  function downloadFinish() {
    downloadProgress = 1
    downloadFinishTimer.restart()
  }
  Timer {
    id: downloadFinishTimer
    interval: 1500; repeat: false
    onTriggered: { root.downloadShowing = false; root.downloadName = ""; root.downloadProgress = 0; root.downloadSpeedKb = 0 }
  }

  // ── CPU temp / load ──────────────────────────────────────
  property int cpuTempC: 0
  property int cpuLoadPct: 0
  property bool cpuPeek: false
  readonly property bool cpuActive: cpuEnabled && (cpuPeek || cpuTempC >= cpuTempCritical)

  Timer {
    id: cpuPoller
    interval: Math.max(2000, root.cpuPollSec * 1000)
    running: root.cpuEnabled
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!cpuProbe.running) cpuProbe.running = true
  }

  Process {
    id: cpuProbe
    running: false
    command: ["sh", "-c",
      "t=0; for z in /sys/class/thermal/thermal_zone*/temp; do [ -e \"$z\" ] && v=$(cat \"$z\" 2>/dev/null); [ -n \"$v\" ] && [ \"$v\" -gt \"$t\" ] && t=$v; done; " +
      "tc=$((t/1000)); " +
      "load=$(awk '{print $1}' /proc/loadavg 2>/dev/null); " +
      "cores=$(nproc 2>/dev/null || echo 1); " +
      "pct=$(awk -v l=\"$load\" -v c=\"$cores\" 'BEGIN{printf \"%d\", (l/c)*100}'); " +
      "echo \"$tc|$pct\""]
    stdout: StdioCollector {
      onStreamFinished: {
        const line = (text || "").trim()
        if (line.length === 0) return
        const parts = line.split("|")
        const tc = parseInt(parts[0]) || 0
        const pct = parseInt(parts[1]) || 0
        const wasHot = root.cpuTempC >= root.cpuTempCritical
        root.cpuTempC = tc
        root.cpuLoadPct = pct
        if (tc >= root.cpuTempCritical && !wasHot) {
          root.cpuPeek = true
          cpuPeekTimer.restart()
        }
      }
    }
    onExited: running = false
  }
  Timer { id: cpuPeekTimer; interval: 5000; repeat: false; onTriggered: root.cpuPeek = false }

  // ── DND state (auto from Pomodoro if requested) ──────────
  readonly property bool dndActive: dndEnabled || (pomodoroAutoDnd && pomodoroPhase === "work")
  readonly property bool focusBubbleActive: dndActive && hovered

  // ── Force-show (IPC) ─────────────────────────────────────
  property bool forceShown: false

  // ── Visibility / expansion ───────────────────────────────
  readonly property bool anyBubbleActive:
      mediaActive
   || (notificationActive && !dndActive)
   || recordingActive
   || batteryActive
   || osdActive
   || pomodoroActive
   || timerActive
   || networkActive
   || bluetoothActive
   || keyboardActive
   || workspaceActive
   || clipboardActive
   || screenshotActive
   || downloadActive
   || cpuActive
   || focusBubbleActive

  readonly property bool idleVisible: idleShowClock || (idleShowWeather && weatherTemp.length > 0)
  readonly property bool shouldShow: enabled && (forceShown || anyBubbleActive || idleVisible)

  property bool hovered: false

  readonly property bool expanded: hovered
    || (mediaActive && !recordingActive)
    || (autoShowOnNotification && notificationActive)
    || osdActive
    || (batteryCritical && batteryActive)
    || pomodoroActive
    || timerActive
    || downloadActive
    || cpuActive

  // ── Media transport passthrough ──────────────────────────
  function mediaPlayPause() {
    const p = MediaService.currentPlayer
    if (!p) return
    if (MediaService.isPlaying) p.pause()
    else p.play()
  }
  function mediaNext()     { const p = MediaService.currentPlayer; if (p && MediaService.canGoNext) p.next() }
  function mediaPrevious() { const p = MediaService.currentPlayer; if (p && MediaService.canGoPrevious) p.previous() }
  function dismissNotification() {
    root.activeNotification = null
    notificationClearTimer.stop()
  }

  function invokeNotificationAction(actionId) {
    const p = NotificationService.popupModel
    if (!p || p.count === 0) return
    const n = p.get(Math.min(root.notificationCursor, p.count - 1))
    if (!n) return
    if (typeof n.invokeAction === "function") n.invokeAction(actionId)
    root.dismissNotification()
  }

  // ── Peek ─────────────────────────────────────────────────
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

  // ── IPC handler ──────────────────────────────────────────
  IpcHandler {
    target: "plugin:ns-dynamic-island"

    function peek(): void { root.peek() }
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

    function showVolume(value: int, muted: bool): void { root.showOsd("volume", value, muted) }
    function showBrightness(value: int): void { root.showOsd("brightness", value, false) }

    function pomodoroStart(): void  { root.pomodoroStart() }
    function pomodoroPause(): void  { root.pomodoroPause() }
    function pomodoroResume(): void { root.pomodoroResume() }
    function pomodoroSkip(): void   { root.pomodoroSkip() }
    function pomodoroStop(): void   { root.pomodoroStop() }
    function pomodoroToggle(): void { if (root.pomodoroActive) root.pomodoroStop(); else root.pomodoroStart() }

    function timerStart(seconds: int, label: string): void { root.timerStart(seconds, label) }
    function timerStop(): void { root.timerStop() }

    function bluetooth(event: string, device: string): void { root.btShow(event, device) }
    function keyboardLayout(name: string): void { root.keyboardShow(name) }
    function workspace(name: string, label: string): void { root.workspaceShow(name, label) }
    function clipboard(preview: string, kind: string): void { root.clipboardShow(preview, kind) }
    function screenshot(path: string): void { root.screenshotShow(path) }

    function calendar(title: string, when: string, color: string): void {
      root.calendarNextTitle = title || ""
      root.calendarNextWhen = when || ""
      root.calendarNextColor = color || ""
    }

    function downloadStart(name: string): void { root.downloadStart(name) }
    function downloadUpdate(progress: real, speedKb: int): void { root.downloadUpdate(progress, speedKb) }
    function downloadFinish(): void { root.downloadFinish() }

    function dnd(on: bool): void {
      if (root.pluginApi && root.pluginApi.pluginSettings) {
        root.pluginApi.pluginSettings.dndEnabled = !!on
        root.pluginApi.saveSettings()
      }
    }

    function nextNotification(): void { root.cycleNotification(1) }
    function prevNotification(): void { root.cycleNotification(-1) }
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
}
