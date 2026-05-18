import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root
  property var pluginApi: null

  readonly property var cfg: pluginApi?.pluginSettings || ({})
  readonly property var def: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  // ── Edit-state mirrors of every setting ─────────────────
  // Core
  property bool   editEnabled:            cfg.enabled ?? def.enabled ?? true
  property bool   editOverlayEnabled:     cfg.overlayEnabled ?? def.overlayEnabled ?? true
  property bool   editOverlayInteractive: cfg.overlayInteractive ?? def.overlayInteractive ?? false
  property string editPosition:           cfg.position || def.position || "top"
  property int    editMargin:             cfg.marginPx ?? def.marginPx ?? 6
  property int    editHorizontalOffset:   cfg.horizontalOffset ?? def.horizontalOffset ?? 0
  property int    editCompactWidth:       cfg.compactWidth ?? def.compactWidth ?? 180
  property int    editExpandedWidth:      cfg.expandedWidth ?? def.expandedWidth ?? 440
  property int    editHeight:             cfg.height ?? def.height ?? 36
  property int    editCornerRadius:       cfg.cornerRadius ?? def.cornerRadius ?? 18
  property int    editHideDelay:          cfg.hideDelaySec ?? def.hideDelaySec ?? 4
  property bool   editHoverToExpand:      cfg.hoverToExpand ?? def.hoverToExpand ?? true
  property bool   editDualBubble:         cfg.dualBubble ?? def.dualBubble ?? true
  property var    editDisabledScreens:    (cfg.disabledScreens ? cfg.disabledScreens.slice() : (def.disabledScreens ? def.disabledScreens.slice() : []))

  // Theme / accessibility
  property string editThemePreset:        cfg.themePreset || def.themePreset || "system"
  property bool   editHighContrast:       cfg.highContrast ?? def.highContrast ?? false
  property bool   editLargeText:          cfg.largeText ?? def.largeText ?? false
  property real   editBackdropOpacity:    cfg.backdropOpacity ?? def.backdropOpacity ?? 0.94
  property bool   editFakeBlur:           cfg.fakeBlur ?? def.fakeBlur ?? true

  // Visual polish
  property bool   editSpringExpand:       cfg.springExpand ?? def.springExpand ?? true
  property bool   editCriticalGlow:       cfg.criticalGlow ?? def.criticalGlow ?? true
  property bool   editTimeOfDayTint:      cfg.timeOfDayTint ?? def.timeOfDayTint ?? true
  property bool   editDynamicMediaAccent: cfg.dynamicMediaAccent ?? def.dynamicMediaAccent ?? true
  property bool   editSmoothMediaPosition:cfg.smoothMediaPosition ?? def.smoothMediaPosition ?? true
  property bool   editIconMicroAnimations:cfg.iconMicroAnimations ?? def.iconMicroAnimations ?? true

  // Interaction
  property bool   editSwipeGestures:      cfg.swipeGestures ?? def.swipeGestures ?? true
  property bool   editScrubMedia:         cfg.scrubMedia ?? def.scrubMedia ?? true
  property bool   editContextMenu:        cfg.contextMenu ?? def.contextMenu ?? true

  // Media
  property bool   editAutoShowMedia:      cfg.autoShowOnMedia ?? def.autoShowOnMedia ?? true

  // Notifications
  property bool   editAutoShowNotification:    cfg.autoShowOnNotification ?? def.autoShowOnNotification ?? true
  property int    editNotificationDuration:    cfg.notificationDurationSec ?? def.notificationDurationSec ?? 5
  property bool   editStackNotifications:      cfg.stackNotifications ?? def.stackNotifications ?? true
  property bool   editShowNotificationActions: cfg.showNotificationActions ?? def.showNotificationActions ?? true
  property bool   editDnd:                     cfg.dndEnabled ?? def.dndEnabled ?? false
  property bool   editDndPausesMediaAutoShow:  cfg.dndPausesMediaAutoShow ?? def.dndPausesMediaAutoShow ?? false
  property string editMutedAppsCsv:            (cfg.notificationMutedApps || def.notificationMutedApps || []).join(", ")
  property string editPinnedAppsCsv:           (cfg.notificationPinnedApps || def.notificationPinnedApps || []).join(", ")

  // Recording
  property bool   editDetectRecording:    cfg.detectScreenRecording ?? def.detectScreenRecording ?? true
  property int    editRecordingPoll:      cfg.recordingPollSec ?? def.recordingPollSec ?? 3

  // Idle
  property bool   editIdleClock:          cfg.idleShowClock ?? def.idleShowClock ?? true
  property bool   editIdleShowSeconds:    cfg.idleShowSeconds ?? def.idleShowSeconds ?? false
  property bool   editIdleUse24h:         cfg.idleUse24h ?? def.idleUse24h ?? true
  property bool   editIdleWeather:        cfg.idleShowWeather ?? def.idleShowWeather ?? false
  property string editWeatherLocation:    cfg.weatherLocation || def.weatherLocation || ""
  property string editWeatherUnits:       cfg.weatherUnits || def.weatherUnits || "metric"
  property bool   editWeatherCacheEnabled:cfg.weatherCacheEnabled ?? def.weatherCacheEnabled ?? true

  // Battery
  property bool   editBatteryEnabled:     cfg.batteryEnabled ?? def.batteryEnabled ?? true
  property int    editBatteryLowThreshold:cfg.batteryLowThreshold ?? def.batteryLowThreshold ?? 20
  property int    editBatteryPollSec:     cfg.batteryPollSec ?? def.batteryPollSec ?? 30
  property bool   editBatteryShowOnChange:cfg.batteryShowOnChange ?? def.batteryShowOnChange ?? true

  // OSD
  property bool   editOsdEnabled:         cfg.osdEnabled ?? def.osdEnabled ?? true
  property int    editOsdDurationSec:     cfg.osdDurationSec ?? def.osdDurationSec ?? 2

  // Pomodoro
  property bool   editPomodoroEnabled:    cfg.pomodoroEnabled ?? def.pomodoroEnabled ?? true
  property int    editPomodoroWorkMin:    cfg.pomodoroWorkMin ?? def.pomodoroWorkMin ?? 25
  property int    editPomodoroShortBreakMin:cfg.pomodoroShortBreakMin ?? def.pomodoroShortBreakMin ?? 5
  property int    editPomodoroLongBreakMin:cfg.pomodoroLongBreakMin ?? def.pomodoroLongBreakMin ?? 15
  property int    editPomodoroLongBreakEvery:cfg.pomodoroLongBreakEvery ?? def.pomodoroLongBreakEvery ?? 4
  property bool   editPomodoroAutoDnd:    cfg.pomodoroAutoDnd ?? def.pomodoroAutoDnd ?? false

  // Generic timer
  property bool   editTimerEnabled:       cfg.timerEnabled ?? def.timerEnabled ?? true

  // Privacy
  property bool   editPrivacyEnabled:     cfg.privacyIndicatorEnabled ?? def.privacyIndicatorEnabled ?? true
  property int    editPrivacyPollSec:     cfg.privacyPollSec ?? def.privacyPollSec ?? 4

  // Network
  property bool   editNetworkEnabled:     cfg.networkEnabled ?? def.networkEnabled ?? true
  property int    editNetworkPollSec:     cfg.networkPollSec ?? def.networkPollSec ?? 8

  // Bluetooth
  property bool   editBluetoothEnabled:   cfg.bluetoothEnabled ?? def.bluetoothEnabled ?? true

  // Keyboard
  property bool   editKeyboardLayoutEnabled: cfg.keyboardLayoutEnabled ?? def.keyboardLayoutEnabled ?? true

  // Workspace
  property bool   editWorkspaceEnabled:   cfg.workspaceEnabled ?? def.workspaceEnabled ?? true

  // Clipboard / Screenshot
  property bool   editClipboardEnabled:   cfg.clipboardEnabled ?? def.clipboardEnabled ?? false
  property bool   editClipboardAutoWatch: cfg.clipboardAutoWatch ?? def.clipboardAutoWatch ?? false
  property bool   editClipboardPrivacy:   cfg.clipboardPrivacy ?? def.clipboardPrivacy ?? true
  property bool   editScreenshotEnabled:  cfg.screenshotEnabled ?? def.screenshotEnabled ?? true
  property string editScreenshotDir:      cfg.screenshotDir || def.screenshotDir || ""

  // Calendar
  property bool   editCalendarEnabled:    cfg.calendarEnabled ?? def.calendarEnabled ?? false

  // Download
  property bool   editDownloadEnabled:    cfg.downloadEnabled ?? def.downloadEnabled ?? true

  // CPU
  property bool   editCpuEnabled:         cfg.cpuEnabled ?? def.cpuEnabled ?? false
  property int    editCpuPollSec:         cfg.cpuPollSec ?? def.cpuPollSec ?? 5
  property int    editCpuTempCritical:    cfg.cpuTempCritical ?? def.cpuTempCritical ?? 85

  // Bar widget
  property bool   editBarShowClock:         cfg.barShowClock ?? def.barShowClock ?? true
  property bool   editBarShowWeather:       cfg.barShowWeather ?? def.barShowWeather ?? true
  property bool   editBarShowActiveWindow:  cfg.barShowActiveWindow ?? def.barShowActiveWindow ?? true
  property bool   editBarShowMedia:         cfg.barShowMedia ?? def.barShowMedia ?? true
  property bool   editBarShowNotifications: cfg.barShowNotifications ?? def.barShowNotifications ?? true
  property bool   editBarShowRecording:     cfg.barShowRecording ?? def.barShowRecording ?? true
  property bool   editBarShowBattery:       cfg.barShowBattery ?? def.barShowBattery ?? true
  property bool   editBarShowPomodoro:      cfg.barShowPomodoro ?? def.barShowPomodoro ?? true
  property bool   editBarShowPrivacy:       cfg.barShowPrivacy ?? def.barShowPrivacy ?? true
  property string editBarClickAction:       cfg.barClickAction || def.barClickAction || "panel"
  property int    editActiveWindowMaxChars: cfg.activeWindowMaxChars ?? def.activeWindowMaxChars ?? 28
  property int    editMediaTitleMaxChars:   cfg.mediaTitleMaxChars ?? def.mediaTitleMaxChars ?? 22
  property bool   editGlassEffect:          cfg.glassEffect ?? def.glassEffect ?? true
  property bool   editBarHoverLift:         cfg.barHoverLift ?? def.barHoverLift ?? true
  property bool   editBarClickRipple:       cfg.barClickRipple ?? def.barClickRipple ?? true
  property bool   editBarDynamicAccent:     cfg.barDynamicAccent ?? def.barDynamicAccent ?? true

  // Auto-polling
  property bool   editKeyboardLayoutAutoPoll: cfg.keyboardLayoutAutoPoll ?? def.keyboardLayoutAutoPoll ?? true
  property int    editKeyboardLayoutPollSec:  cfg.keyboardLayoutPollSec ?? def.keyboardLayoutPollSec ?? 2
  property bool   editWorkspaceAutoPoll:      cfg.workspaceAutoPoll ?? def.workspaceAutoPoll ?? true
  property int    editWorkspacePollSec:       cfg.workspacePollSec ?? def.workspacePollSec ?? 2
  property bool   editVolumeAutoPoll:         cfg.volumeAutoPoll ?? def.volumeAutoPoll ?? true
  property int    editVolumePollMs:           cfg.volumePollMs ?? def.volumePollMs ?? 800
  property bool   editBrightnessAutoPoll:     cfg.brightnessAutoPoll ?? def.brightnessAutoPoll ?? true
  property int    editBrightnessPollMs:       cfg.brightnessPollMs ?? def.brightnessPollMs ?? 1200
  property bool   editScreenshotAutoWatch:    cfg.screenshotAutoWatch ?? def.screenshotAutoWatch ?? true
  property int    editScreenshotPollSec:      cfg.screenshotPollSec ?? def.screenshotPollSec ?? 3

  // Sounds
  property bool   editNotificationSound:     cfg.notificationSound ?? def.notificationSound ?? false
  property string editNotificationSoundPath: cfg.notificationSoundPath || def.notificationSoundPath || ""

  // Effects
  property bool   editEffectsRipple:            cfg.effectsRipple ?? def.effectsRipple ?? true
  property bool   editEffectsHoverLift:         cfg.effectsHoverLift ?? def.effectsHoverLift ?? true
  property bool   editEffectsTrackFlash:        cfg.effectsTrackFlash ?? def.effectsTrackFlash ?? true
  property bool   editEffectsAudioBars:         cfg.effectsAudioBars ?? def.effectsAudioBars ?? true
  property bool   editEffectsConfetti:          cfg.effectsConfetti ?? def.effectsConfetti ?? true
  property bool   editEffectsNotificationSlide: cfg.effectsNotificationSlide ?? def.effectsNotificationSlide ?? true
  property bool   editEffectsWeatherParticles:  cfg.effectsWeatherParticles ?? def.effectsWeatherParticles ?? true
  property bool   editReducedMotion:            cfg.reducedMotion ?? def.reducedMotion ?? false
  property bool   editRealBlur:                 cfg.realBlur ?? def.realBlur ?? false
  property real   editRealBlurRadius:           cfg.realBlurRadius ?? def.realBlurRadius ?? 18

  // Interaction additions
  property bool   editScrollAdjustsVolume: cfg.scrollAdjustsVolume ?? def.scrollAdjustsVolume ?? true
  property int    editScrollVolumeStep:    cfg.scrollVolumeStep ?? def.scrollVolumeStep ?? 5

  // Auto-DND on fullscreen
  property bool   editAutoDndOnFullscreen: cfg.autoDndOnFullscreen ?? def.autoDndOnFullscreen ?? false
  property int    editFullscreenPollSec:   cfg.fullscreenPollSec ?? def.fullscreenPollSec ?? 4

  // Disk
  property bool   editDiskEnabled:       cfg.diskEnabled ?? def.diskEnabled ?? false
  property int    editDiskWarnThreshold: cfg.diskWarnThreshold ?? def.diskWarnThreshold ?? 90
  property int    editDiskPollSec:       cfg.diskPollSec ?? def.diskPollSec ?? 60
  property string editDiskMount:         cfg.diskMount || def.diskMount || "/"

  // Network speed
  property bool   editNetSpeedEnabled: cfg.netSpeedEnabled ?? def.netSpeedEnabled ?? false
  property int    editNetSpeedPollSec: cfg.netSpeedPollSec ?? def.netSpeedPollSec ?? 2

  // RAM
  property bool   editRamEnabled:       cfg.ramEnabled ?? def.ramEnabled ?? false
  property int    editRamWarnThreshold: cfg.ramWarnThreshold ?? def.ramWarnThreshold ?? 85

  // Pomodoro stats
  property bool   editPomodoroStatsEnabled: cfg.pomodoroStatsEnabled ?? def.pomodoroStatsEnabled ?? true

  // Idle countdown
  property bool   editIdleNextEventCountdown: cfg.idleNextEventCountdown ?? def.idleNextEventCountdown ?? true

  spacing: Style.marginL

  // ════════ Master ════════
  NToggle {
    Layout.fillWidth: true
    label: "Enable island"
    description: "Master switch. When disabled, the island is never shown."
    checked: root.editEnabled
    onToggled: checked => root.editEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Floating overlay ════════
  NLabel {
    label: "Floating overlay"
    description: "The pill is rendered on a wlr-layer-shell window above your bar."
  }
  NToggle {
    Layout.fillWidth: true
    label: "Show floating overlay"
    description: "When off, only the bar widget is used (no layer-shell window)."
    checked: root.editOverlayEnabled
    onToggled: checked => root.editOverlayEnabled = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Overlay accepts clicks"
    description: "Off by default — the pill is visible but every click passes through to your bar/browser. Turn on only if you want to click the pill directly AND your compositor honors our input-region mask correctly. If toggling this on makes your bar unclickable, turn it back off."
    visible: root.editOverlayEnabled
    checked: root.editOverlayInteractive
    onToggled: checked => root.editOverlayInteractive = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Layout ════════
  NLabel { label: "Layout" }

  NLabel { label: "Position" }
  NComboBox {
    Layout.fillWidth: true
    model: [
      { key: "top",    name: "Top of screen" },
      { key: "bottom", name: "Bottom of screen" }
    ]
    currentKey: root.editPosition
    onSelected: key => root.editPosition = key
  }

  NLabel { label: "Margin from edge (px): " + root.editMargin }
  NSlider {
    Layout.fillWidth: true
    from: 0; to: 80; stepSize: 1
    value: root.editMargin
    onValueChanged: root.editMargin = value
  }

  NLabel { label: "Horizontal offset (px): " + root.editHorizontalOffset }
  NSlider {
    Layout.fillWidth: true
    from: -400; to: 400; stepSize: 2
    value: root.editHorizontalOffset
    onValueChanged: root.editHorizontalOffset = value
  }

  NLabel { label: "Compact width (px): " + root.editCompactWidth }
  NSlider {
    Layout.fillWidth: true
    from: 120; to: 320; stepSize: 4
    value: root.editCompactWidth
    onValueChanged: root.editCompactWidth = value
  }

  NLabel { label: "Expanded width (px): " + root.editExpandedWidth }
  NSlider {
    Layout.fillWidth: true
    from: 240; to: 720; stepSize: 4
    value: root.editExpandedWidth
    onValueChanged: root.editExpandedWidth = value
  }

  NLabel { label: "Height (px): " + root.editHeight }
  NSlider {
    Layout.fillWidth: true
    from: 24; to: 64; stepSize: 1
    value: root.editHeight
    onValueChanged: root.editHeight = value
  }

  NLabel { label: "Corner radius (px): " + root.editCornerRadius }
  NSlider {
    Layout.fillWidth: true
    from: 0; to: 40; stepSize: 1
    value: root.editCornerRadius
    onValueChanged: root.editCornerRadius = value
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Theme & accessibility ════════
  NLabel { label: "Theme & accessibility" }

  NLabel { label: "Theme preset" }
  NComboBox {
    Layout.fillWidth: true
    model: [
      { key: "system",         name: "Match system" },
      { key: "dark",           name: "Dark" },
      { key: "light",          name: "Light" },
      { key: "amoled",         name: "AMOLED black" },
      { key: "matchWallpaper", name: "Match wallpaper" }
    ]
    currentKey: root.editThemePreset
    onSelected: key => root.editThemePreset = key
  }

  NToggle {
    Layout.fillWidth: true
    label: "High-contrast outlines"
    checked: root.editHighContrast
    onToggled: checked => root.editHighContrast = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Large text"
    description: "Increases text size for accessibility."
    checked: root.editLargeText
    onToggled: checked => root.editLargeText = checked
  }
  NLabel { label: "Backdrop opacity: " + root.editBackdropOpacity.toFixed(2) }
  NSlider {
    Layout.fillWidth: true
    from: 0.5; to: 1.0; stepSize: 0.01
    value: root.editBackdropOpacity
    onValueChanged: root.editBackdropOpacity = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Soft backdrop (faux blur)"
    description: "Layered translucent rectangles to soften the pill edge."
    checked: root.editFakeBlur
    onToggled: checked => root.editFakeBlur = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Visual polish ════════
  NLabel { label: "Visual polish" }

  NToggle {
    Layout.fillWidth: true
    label: "Spring expand"
    description: "Bouncier animation when the pill expands."
    checked: root.editSpringExpand
    onToggled: checked => root.editSpringExpand = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Critical glow"
    description: "Soft animated halo around the pill on urgent events."
    checked: root.editCriticalGlow
    onToggled: checked => root.editCriticalGlow = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Time-of-day tint on idle"
    description: "Subtle warm/cool overlay based on the hour."
    checked: root.editTimeOfDayTint
    onToggled: checked => root.editTimeOfDayTint = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Dynamic media accent"
    description: "Color the album art ring from the currently playing track."
    checked: root.editDynamicMediaAccent
    onToggled: checked => root.editDynamicMediaAccent = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Smooth media progress"
    description: "Interpolate position between MPRIS updates."
    checked: root.editSmoothMediaPosition
    onToggled: checked => root.editSmoothMediaPosition = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Icon micro-animations"
    description: "Subtle pulse/scale on key glyphs."
    checked: root.editIconMicroAnimations
    onToggled: checked => root.editIconMicroAnimations = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Interaction ════════
  NLabel { label: "Interaction" }

  NToggle {
    Layout.fillWidth: true
    label: "Expand on hover"
    checked: root.editHoverToExpand
    onToggled: checked => root.editHoverToExpand = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Show paired bubbles"
    description: "When on, multiple active bubbles share the pill side-by-side."
    checked: root.editDualBubble
    onToggled: checked => root.editDualBubble = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Swipe gestures"
    description: "Click-drag horizontally to skip media / cycle notifications."
    checked: root.editSwipeGestures
    onToggled: checked => root.editSwipeGestures = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Scrub media progress"
    description: "Click or drag the progress bar to seek."
    checked: root.editScrubMedia
    onToggled: checked => root.editScrubMedia = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Right-click context menu"
    checked: root.editContextMenu
    onToggled: checked => root.editContextMenu = checked
  }
  NLabel { label: "Auto-hide delay (s): " + root.editHideDelay }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 20; stepSize: 1
    value: root.editHideDelay
    onValueChanged: root.editHideDelay = value
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Media ════════
  NLabel { label: "Media" }
  NToggle {
    Layout.fillWidth: true
    label: "Auto-show on media change"
    checked: root.editAutoShowMedia
    onToggled: checked => root.editAutoShowMedia = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Notifications ════════
  NLabel { label: "Notifications" }
  NToggle {
    Layout.fillWidth: true
    label: "Auto-show on new notification"
    checked: root.editAutoShowNotification
    onToggled: checked => root.editAutoShowNotification = checked
  }
  NLabel { label: "Notification peek duration (s): " + root.editNotificationDuration }
  NSlider {
    Layout.fillWidth: true
    from: 2; to: 15; stepSize: 1
    value: root.editNotificationDuration
    onValueChanged: root.editNotificationDuration = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Stack notifications"
    description: "Show a count badge and cycle controls when more than one is pending."
    checked: root.editStackNotifications
    onToggled: checked => root.editStackNotifications = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Show notification actions"
    description: "Display inline action buttons when the notification provides them."
    checked: root.editShowNotificationActions
    onToggled: checked => root.editShowNotificationActions = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Do Not Disturb"
    description: "Suppress notification bubbles. Idle shows a moon glyph."
    checked: root.editDnd
    onToggled: checked => root.editDnd = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "DND also pauses media auto-show"
    visible: root.editDnd
    checked: root.editDndPausesMediaAutoShow
    onToggled: checked => root.editDndPausesMediaAutoShow = checked
  }
  NTextInput {
    Layout.fillWidth: true
    label: "Muted apps"
    description: "Comma-separated list of app names to silently drop notifications from."
    placeholderText: "e.g. Discord, Slack"
    text: root.editMutedAppsCsv
    onEditingFinished: root.editMutedAppsCsv = text
  }
  NTextInput {
    Layout.fillWidth: true
    label: "Pinned apps"
    description: "Notifications from these apps won't auto-dismiss until you do."
    placeholderText: "e.g. KeePassXC"
    text: root.editPinnedAppsCsv
    onEditingFinished: root.editPinnedAppsCsv = text
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Screen recording ════════
  NLabel { label: "Screen recording" }
  NToggle {
    Layout.fillWidth: true
    label: "Show recording indicator"
    description: "Polls for gpu-screen-recorder, wf-recorder, OBS, kooha."
    checked: root.editDetectRecording
    onToggled: checked => root.editDetectRecording = checked
  }
  NLabel { label: "Recording poll interval (s): " + root.editRecordingPoll }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 15; stepSize: 1
    value: root.editRecordingPoll
    onValueChanged: root.editRecordingPoll = value
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Idle (clock + weather) ════════
  NLabel { label: "Idle" }
  NToggle {
    Layout.fillWidth: true
    label: "Show clock when idle"
    checked: root.editIdleClock
    onToggled: checked => root.editIdleClock = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Use 24-hour clock"
    visible: root.editIdleClock
    checked: root.editIdleUse24h
    onToggled: checked => root.editIdleUse24h = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Show seconds"
    visible: root.editIdleClock
    checked: root.editIdleShowSeconds
    onToggled: checked => root.editIdleShowSeconds = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Show weather when idle"
    description: "Fetched from wttr.in every 30 minutes."
    checked: root.editIdleWeather
    onToggled: checked => root.editIdleWeather = checked
  }
  NTextInput {
    Layout.fillWidth: true
    label: "Weather location"
    description: "Leave empty for wttr.in auto-detection by IP."
    placeholderText: "e.g. London, 10001, or empty"
    text: root.editWeatherLocation
    onEditingFinished: root.editWeatherLocation = text
    visible: root.editIdleWeather
  }
  NLabel { label: "Weather units"; visible: root.editIdleWeather }
  NComboBox {
    Layout.fillWidth: true
    visible: root.editIdleWeather
    model: [
      { key: "metric",   name: "Metric (°C)" },
      { key: "imperial", name: "Imperial (°F)" }
    ]
    currentKey: root.editWeatherUnits
    onSelected: key => root.editWeatherUnits = key
  }
  NToggle {
    Layout.fillWidth: true
    label: "Cache weather to disk"
    description: "Remembers the last reading across sessions."
    visible: root.editIdleWeather
    checked: root.editWeatherCacheEnabled
    onToggled: checked => root.editWeatherCacheEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Battery ════════
  NLabel { label: "Battery" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable battery bubble"
    checked: root.editBatteryEnabled
    onToggled: checked => root.editBatteryEnabled = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Peek on state change"
    visible: root.editBatteryEnabled
    checked: root.editBatteryShowOnChange
    onToggled: checked => root.editBatteryShowOnChange = checked
  }
  NLabel {
    label: "Low battery threshold (%): " + root.editBatteryLowThreshold
    visible: root.editBatteryEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 5; to: 50; stepSize: 1
    visible: root.editBatteryEnabled
    value: root.editBatteryLowThreshold
    onValueChanged: root.editBatteryLowThreshold = value
  }
  NLabel {
    label: "Poll interval (s): " + root.editBatteryPollSec
    visible: root.editBatteryEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 5; to: 120; stepSize: 5
    visible: root.editBatteryEnabled
    value: root.editBatteryPollSec
    onValueChanged: root.editBatteryPollSec = value
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Volume/Brightness OSD ════════
  NLabel { label: "Volume / Brightness OSD" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable OSD"
    description: "Bind your hotkeys to plugin:ns-dynamic-island showVolume / showBrightness."
    checked: root.editOsdEnabled
    onToggled: checked => root.editOsdEnabled = checked
  }
  NLabel {
    label: "OSD duration (s): " + root.editOsdDurationSec
    visible: root.editOsdEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 8; stepSize: 1
    visible: root.editOsdEnabled
    value: root.editOsdDurationSec
    onValueChanged: root.editOsdDurationSec = value
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Pomodoro ════════
  NLabel { label: "Pomodoro" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable pomodoro"
    description: "Start/stop via plugin:ns-dynamic-island pomodoroToggle."
    checked: root.editPomodoroEnabled
    onToggled: checked => root.editPomodoroEnabled = checked
  }
  NLabel {
    label: "Work duration (min): " + root.editPomodoroWorkMin
    visible: root.editPomodoroEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 5; to: 90; stepSize: 1
    visible: root.editPomodoroEnabled
    value: root.editPomodoroWorkMin
    onValueChanged: root.editPomodoroWorkMin = value
  }
  NLabel {
    label: "Short break (min): " + root.editPomodoroShortBreakMin
    visible: root.editPomodoroEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 30; stepSize: 1
    visible: root.editPomodoroEnabled
    value: root.editPomodoroShortBreakMin
    onValueChanged: root.editPomodoroShortBreakMin = value
  }
  NLabel {
    label: "Long break (min): " + root.editPomodoroLongBreakMin
    visible: root.editPomodoroEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 5; to: 60; stepSize: 1
    visible: root.editPomodoroEnabled
    value: root.editPomodoroLongBreakMin
    onValueChanged: root.editPomodoroLongBreakMin = value
  }
  NLabel {
    label: "Long break every N cycles: " + root.editPomodoroLongBreakEvery
    visible: root.editPomodoroEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 2; to: 10; stepSize: 1
    visible: root.editPomodoroEnabled
    value: root.editPomodoroLongBreakEvery
    onValueChanged: root.editPomodoroLongBreakEvery = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Enable DND during focus phase"
    visible: root.editPomodoroEnabled
    checked: root.editPomodoroAutoDnd
    onToggled: checked => root.editPomodoroAutoDnd = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Timer ════════
  NLabel { label: "Generic timer" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable timer bubble"
    description: "Use plugin:ns-dynamic-island timerStart <seconds> <label>."
    checked: root.editTimerEnabled
    onToggled: checked => root.editTimerEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Privacy ════════
  NLabel { label: "Privacy indicators" }
  NToggle {
    Layout.fillWidth: true
    label: "Show mic / camera in-use dot"
    description: "Red dot when mic is recording, amber dot when camera is in use."
    checked: root.editPrivacyEnabled
    onToggled: checked => root.editPrivacyEnabled = checked
  }
  NLabel {
    label: "Poll interval (s): " + root.editPrivacyPollSec
    visible: root.editPrivacyEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 2; to: 30; stepSize: 1
    visible: root.editPrivacyEnabled
    value: root.editPrivacyPollSec
    onValueChanged: root.editPrivacyPollSec = value
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Network ════════
  NLabel { label: "Network" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable network bubble"
    description: "Peeks on connect / disconnect / SSID change. Uses nmcli if available."
    checked: root.editNetworkEnabled
    onToggled: checked => root.editNetworkEnabled = checked
  }
  NLabel {
    label: "Poll interval (s): " + root.editNetworkPollSec
    visible: root.editNetworkEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 3; to: 60; stepSize: 1
    visible: root.editNetworkEnabled
    value: root.editNetworkPollSec
    onValueChanged: root.editNetworkPollSec = value
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Bluetooth ════════
  NLabel { label: "Bluetooth" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable Bluetooth bubble"
    description: "IPC-driven: plugin:ns-dynamic-island bluetooth connected \"Headphones\"."
    checked: root.editBluetoothEnabled
    onToggled: checked => root.editBluetoothEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Keyboard layout ════════
  NLabel { label: "Keyboard layout" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable layout-switch peek"
    description: "IPC-driven: plugin:ns-dynamic-island keyboardLayout us."
    checked: root.editKeyboardLayoutEnabled
    onToggled: checked => root.editKeyboardLayoutEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Workspace ════════
  NLabel { label: "Workspace indicator" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable workspace peek"
    description: "IPC-driven: plugin:ns-dynamic-island workspace 3 Coding."
    checked: root.editWorkspaceEnabled
    onToggled: checked => root.editWorkspaceEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Clipboard / Screenshot ════════
  NLabel { label: "Clipboard & screenshots" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable clipboard peek"
    description: "Show a brief preview of what was copied."
    checked: root.editClipboardEnabled
    onToggled: checked => root.editClipboardEnabled = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Auto-watch clipboard (wl-paste)"
    description: "Background-watch the Wayland clipboard. Off by default for privacy."
    visible: root.editClipboardEnabled
    checked: root.editClipboardAutoWatch
    onToggled: checked => root.editClipboardAutoWatch = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Privacy preview"
    description: "Truncate preview to 24 chars; hide sensitive contents."
    visible: root.editClipboardEnabled
    checked: root.editClipboardPrivacy
    onToggled: checked => root.editClipboardPrivacy = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Enable screenshot peek"
    description: "Show a thumbnail when a screenshot is taken (IPC-driven)."
    checked: root.editScreenshotEnabled
    onToggled: checked => root.editScreenshotEnabled = checked
  }
  NTextInput {
    Layout.fillWidth: true
    label: "Screenshot directory"
    description: "Optional. Hint for tooling that watches a specific folder."
    placeholderText: "$HOME/Pictures/Screenshots"
    visible: root.editScreenshotEnabled
    text: root.editScreenshotDir
    onEditingFinished: root.editScreenshotDir = text
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Calendar ════════
  NLabel { label: "Calendar peek" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable calendar bubble"
    description: "Shows the next event on hover when idle. Feed via plugin:ns-dynamic-island calendar."
    checked: root.editCalendarEnabled
    onToggled: checked => root.editCalendarEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Downloads ════════
  NLabel { label: "Downloads" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable download bubble"
    description: "Use downloadStart / downloadUpdate / downloadFinish over IPC."
    checked: root.editDownloadEnabled
    onToggled: checked => root.editDownloadEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ CPU / temp ════════
  NLabel { label: "CPU & thermal" }
  NToggle {
    Layout.fillWidth: true
    label: "Enable CPU/temp bubble"
    description: "Peeks when temperature crosses the critical threshold."
    checked: root.editCpuEnabled
    onToggled: checked => root.editCpuEnabled = checked
  }
  NLabel {
    label: "Poll interval (s): " + root.editCpuPollSec
    visible: root.editCpuEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 2; to: 60; stepSize: 1
    visible: root.editCpuEnabled
    value: root.editCpuPollSec
    onValueChanged: root.editCpuPollSec = value
  }
  NLabel {
    label: "Critical temp (°C): " + root.editCpuTempCritical
    visible: root.editCpuEnabled
  }
  NSlider {
    Layout.fillWidth: true
    from: 60; to: 110; stepSize: 1
    visible: root.editCpuEnabled
    value: root.editCpuTempCritical
    onValueChanged: root.editCpuTempCritical = value
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Effects ════════
  NLabel {
    label: "Effects"
    description: "Extra visual flair. Toggle off if you prefer a quieter pill."
  }
  NToggle {
    Layout.fillWidth: true
    label: "Click ripple"
    description: "Material-style ripple at the click point."
    checked: root.editEffectsRipple
    onToggled: checked => root.editEffectsRipple = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Hover lift"
    description: "Subtle scale-up when hovered."
    checked: root.editEffectsHoverLift
    onToggled: checked => root.editEffectsHoverLift = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Track-change flash"
    description: "Brief flip + white flash on the album art when the track changes."
    checked: root.editEffectsTrackFlash
    onToggled: checked => root.editEffectsTrackFlash = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Media audio bars"
    description: "Animated bars in the media bubble while playing."
    checked: root.editEffectsAudioBars
    onToggled: checked => root.editEffectsAudioBars = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Confetti burst"
    description: "Celebrate pomodoro breaks and finished downloads with emoji confetti."
    checked: root.editEffectsConfetti
    onToggled: checked => root.editEffectsConfetti = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Notification slide-in"
    checked: root.editEffectsNotificationSlide
    onToggled: checked => root.editEffectsNotificationSlide = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Weather particles"
    description: "Rain / snow flakes drift over the idle pill in matching weather."
    checked: root.editEffectsWeatherParticles
    onToggled: checked => root.editEffectsWeatherParticles = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Real Gaussian blur"
    description: "Uses Qt6 MultiEffect. Falls back to faux-blur if unavailable. Heavier on GPU."
    checked: root.editRealBlur
    onToggled: checked => root.editRealBlur = checked
  }
  NLabel { label: "Blur radius: " + Math.round(root.editRealBlurRadius); visible: root.editRealBlur }
  NSlider {
    Layout.fillWidth: true
    from: 4; to: 48; stepSize: 1
    visible: root.editRealBlur
    value: root.editRealBlurRadius
    onValueChanged: root.editRealBlurRadius = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Reduced motion"
    description: "Disables most animations for accessibility / focus."
    checked: root.editReducedMotion
    onToggled: checked => root.editReducedMotion = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Disk / RAM / Net throughput ════════
  NLabel { label: "System monitors" }
  NToggle {
    Layout.fillWidth: true
    label: "Disk usage warning bubble"
    description: "Peeks when the watched mount crosses the warning threshold."
    checked: root.editDiskEnabled
    onToggled: checked => root.editDiskEnabled = checked
  }
  NTextInput {
    Layout.fillWidth: true
    label: "Watched mount"
    placeholderText: "/"
    visible: root.editDiskEnabled
    text: root.editDiskMount
    onEditingFinished: root.editDiskMount = text
  }
  NLabel { label: "Disk warn threshold (%): " + root.editDiskWarnThreshold; visible: root.editDiskEnabled }
  NSlider {
    Layout.fillWidth: true
    from: 70; to: 99; stepSize: 1
    visible: root.editDiskEnabled
    value: root.editDiskWarnThreshold
    onValueChanged: root.editDiskWarnThreshold = value
  }
  NLabel { label: "Disk poll (s): " + root.editDiskPollSec; visible: root.editDiskEnabled }
  NSlider {
    Layout.fillWidth: true
    from: 15; to: 600; stepSize: 5
    visible: root.editDiskEnabled
    value: root.editDiskPollSec
    onValueChanged: root.editDiskPollSec = value
  }

  NToggle {
    Layout.fillWidth: true
    label: "Network throughput"
    description: "Shows ↓/↑ KB/s in the network bubble."
    checked: root.editNetSpeedEnabled
    onToggled: checked => root.editNetSpeedEnabled = checked
  }
  NLabel { label: "Network speed poll (s): " + root.editNetSpeedPollSec; visible: root.editNetSpeedEnabled }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 10; stepSize: 1
    visible: root.editNetSpeedEnabled
    value: root.editNetSpeedPollSec
    onValueChanged: root.editNetSpeedPollSec = value
  }

  NToggle {
    Layout.fillWidth: true
    label: "Show RAM in CPU bubble"
    checked: root.editRamEnabled
    onToggled: checked => root.editRamEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Quality-of-life ════════
  NLabel { label: "Quality of life" }
  NToggle {
    Layout.fillWidth: true
    label: "Scroll wheel adjusts volume"
    description: "Hover the pill and scroll to nudge the system volume."
    checked: root.editScrollAdjustsVolume
    onToggled: checked => root.editScrollAdjustsVolume = checked
  }
  NLabel { label: "Volume scroll step (%): " + root.editScrollVolumeStep; visible: root.editScrollAdjustsVolume }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 20; stepSize: 1
    visible: root.editScrollAdjustsVolume
    value: root.editScrollVolumeStep
    onValueChanged: root.editScrollVolumeStep = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Auto-DND when an app is fullscreen"
    description: "Niri / Hyprland only. Checks active window state."
    checked: root.editAutoDndOnFullscreen
    onToggled: checked => root.editAutoDndOnFullscreen = checked
  }
  NLabel { label: "Fullscreen poll (s): " + root.editFullscreenPollSec; visible: root.editAutoDndOnFullscreen }
  NSlider {
    Layout.fillWidth: true
    from: 2; to: 15; stepSize: 1
    visible: root.editAutoDndOnFullscreen
    value: root.editFullscreenPollSec
    onValueChanged: root.editFullscreenPollSec = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Pomodoro daily stats"
    description: "Tracks completed cycles + focus minutes, resets at midnight."
    checked: root.editPomodoroStatsEnabled
    onToggled: checked => root.editPomodoroStatsEnabled = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Idle next-event countdown"
    description: "Inline countdown when a calendar event is within 30 minutes."
    checked: root.editIdleNextEventCountdown
    onToggled: checked => root.editIdleNextEventCountdown = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Automation / auto-poll ════════
  NLabel {
    label: "Automation"
    description: "Background pollers so features work without you binding IPC manually."
  }
  NToggle {
    Layout.fillWidth: true
    label: "Auto-OSD on volume change"
    description: "Polls wpctl/pactl. Default sink only."
    checked: root.editVolumeAutoPoll
    onToggled: checked => root.editVolumeAutoPoll = checked
  }
  NLabel { label: "Volume poll interval (ms): " + root.editVolumePollMs; visible: root.editVolumeAutoPoll }
  NSlider {
    Layout.fillWidth: true
    from: 300; to: 3000; stepSize: 100
    visible: root.editVolumeAutoPoll
    value: root.editVolumePollMs
    onValueChanged: root.editVolumePollMs = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Auto-OSD on brightness change"
    description: "Polls brightnessctl or /sys/class/backlight."
    checked: root.editBrightnessAutoPoll
    onToggled: checked => root.editBrightnessAutoPoll = checked
  }
  NLabel { label: "Brightness poll interval (ms): " + root.editBrightnessPollMs; visible: root.editBrightnessAutoPoll }
  NSlider {
    Layout.fillWidth: true
    from: 400; to: 4000; stepSize: 100
    visible: root.editBrightnessAutoPoll
    value: root.editBrightnessPollMs
    onValueChanged: root.editBrightnessPollMs = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Auto-detect workspace switches"
    description: "Polls niri / hyprctl."
    checked: root.editWorkspaceAutoPoll
    onToggled: checked => root.editWorkspaceAutoPoll = checked
  }
  NLabel { label: "Workspace poll (s): " + root.editWorkspacePollSec; visible: root.editWorkspaceAutoPoll }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 10; stepSize: 1
    visible: root.editWorkspaceAutoPoll
    value: root.editWorkspacePollSec
    onValueChanged: root.editWorkspacePollSec = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Auto-detect keyboard layout switches"
    description: "Polls niri / hyprctl / setxkbmap."
    checked: root.editKeyboardLayoutAutoPoll
    onToggled: checked => root.editKeyboardLayoutAutoPoll = checked
  }
  NLabel { label: "Keyboard layout poll (s): " + root.editKeyboardLayoutPollSec; visible: root.editKeyboardLayoutAutoPoll }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 10; stepSize: 1
    visible: root.editKeyboardLayoutAutoPoll
    value: root.editKeyboardLayoutPollSec
    onValueChanged: root.editKeyboardLayoutPollSec = value
  }
  NToggle {
    Layout.fillWidth: true
    label: "Watch screenshot directory for new files"
    checked: root.editScreenshotAutoWatch
    onToggled: checked => root.editScreenshotAutoWatch = checked
  }
  NLabel { label: "Screenshot poll (s): " + root.editScreenshotPollSec; visible: root.editScreenshotAutoWatch }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 30; stepSize: 1
    visible: root.editScreenshotAutoWatch
    value: root.editScreenshotPollSec
    onValueChanged: root.editScreenshotPollSec = value
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Sounds ════════
  NLabel { label: "Sounds" }
  NToggle {
    Layout.fillWidth: true
    label: "Play sound on notification"
    description: "Uses paplay / pw-play / aplay. Falls back to the freedesktop message sound."
    checked: root.editNotificationSound
    onToggled: checked => root.editNotificationSound = checked
  }
  NTextInput {
    Layout.fillWidth: true
    label: "Sound file"
    description: "Path to .ogg/.wav. Leave empty for freedesktop default."
    placeholderText: "/usr/share/sounds/freedesktop/stereo/message.oga"
    text: root.editNotificationSoundPath
    onEditingFinished: root.editNotificationSoundPath = text
    visible: root.editNotificationSound
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Bar widget ════════
  NLabel {
    label: "Bar widget"
    description: "Toggle each piece of state shown in the inline bar capsule. All visible at once."
  }
  NToggle {
    Layout.fillWidth: true
    label: "Active window title"
    checked: root.editBarShowActiveWindow
    onToggled: checked => root.editBarShowActiveWindow = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Current media"
    checked: root.editBarShowMedia
    onToggled: checked => root.editBarShowMedia = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Recording timer"
    checked: root.editBarShowRecording
    onToggled: checked => root.editBarShowRecording = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Pending notifications"
    checked: root.editBarShowNotifications
    onToggled: checked => root.editBarShowNotifications = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Pomodoro countdown"
    checked: root.editBarShowPomodoro
    onToggled: checked => root.editBarShowPomodoro = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Privacy dots (mic / camera in use)"
    checked: root.editBarShowPrivacy
    onToggled: checked => root.editBarShowPrivacy = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Battery (when low or charging)"
    checked: root.editBarShowBattery
    onToggled: checked => root.editBarShowBattery = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Clock"
    checked: root.editBarShowClock
    onToggled: checked => root.editBarShowClock = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Weather"
    checked: root.editBarShowWeather
    onToggled: checked => root.editBarShowWeather = checked
  }
  NLabel { label: "Active window title max chars: " + root.editActiveWindowMaxChars }
  NSlider {
    Layout.fillWidth: true
    from: 8; to: 80; stepSize: 1
    value: root.editActiveWindowMaxChars
    onValueChanged: root.editActiveWindowMaxChars = value
  }
  NLabel { label: "Media title max chars: " + root.editMediaTitleMaxChars }
  NSlider {
    Layout.fillWidth: true
    from: 8; to: 60; stepSize: 1
    value: root.editMediaTitleMaxChars
    onValueChanged: root.editMediaTitleMaxChars = value
  }
  NLabel { label: "Left click action" }
  NComboBox {
    Layout.fillWidth: true
    model: [
      { key: "panel",  name: "Open detail panel (recommended)" },
      { key: "peek",   name: "Peek floating island" },
      { key: "toggle", name: "Toggle floating island" }
    ]
    currentKey: root.editBarClickAction
    onSelected: key => root.editBarClickAction = key
  }

  NLabel {
    label: "Bar widget visual effects"
    description: "Glass-morphism styling on the capsule."
  }
  NToggle {
    Layout.fillWidth: true
    label: "Glass effect"
    description: "Translucent capsule + top-edge highlight + drop shadow."
    checked: root.editGlassEffect
    onToggled: checked => root.editGlassEffect = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Hover lift"
    description: "Subtle scale-up when the cursor is over the widget."
    checked: root.editBarHoverLift
    onToggled: checked => root.editBarHoverLift = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Click ripple"
    description: "Material-style ripple emitted from the click point."
    checked: root.editBarClickRipple
    onToggled: checked => root.editBarClickRipple = checked
  }
  NToggle {
    Layout.fillWidth: true
    label: "Dynamic accent line"
    description: "Bottom edge tints to match what's most prominent (media / recording / urgency)."
    checked: root.editBarDynamicAccent
    onToggled: checked => root.editBarDynamicAccent = checked
  }

  NDivider { Layout.fillWidth: true }

  // ════════ Monitors ════════
  NLabel {
    label: "Monitors"
    description: "Uncheck a monitor to hide the island on that screen."
  }
  Repeater {
    model: Quickshell.screens
    NToggle {
      Layout.fillWidth: true
      label: modelData.name
      checked: root.editDisabledScreens.indexOf(modelData.name) === -1
      onToggled: function (isChecked) {
        const arr = root.editDisabledScreens.slice()
        const idx = arr.indexOf(modelData.name)
        if (isChecked) { if (idx !== -1) arr.splice(idx, 1) }
        else { if (idx === -1) arr.push(modelData.name) }
        root.editDisabledScreens = arr
      }
    }
  }

  function parseCsv(s) {
    if (!s || s.length === 0) return []
    return s.split(",").map(x => x.trim()).filter(x => x.length > 0)
  }

  function saveSettings() {
    if (!pluginApi) return
    const s = pluginApi.pluginSettings

    // Core
    s.enabled = root.editEnabled
    s.overlayEnabled = root.editOverlayEnabled
    s.overlayInteractive = root.editOverlayInteractive
    s.position = root.editPosition
    s.marginPx = root.editMargin
    s.horizontalOffset = root.editHorizontalOffset
    s.compactWidth = root.editCompactWidth
    s.expandedWidth = root.editExpandedWidth
    s.height = root.editHeight
    s.cornerRadius = root.editCornerRadius
    s.hideDelaySec = root.editHideDelay
    s.hoverToExpand = root.editHoverToExpand
    s.dualBubble = root.editDualBubble
    s.disabledScreens = root.editDisabledScreens

    // Theme / a11y
    s.themePreset = root.editThemePreset
    s.highContrast = root.editHighContrast
    s.largeText = root.editLargeText
    s.backdropOpacity = root.editBackdropOpacity
    s.fakeBlur = root.editFakeBlur

    // Polish
    s.springExpand = root.editSpringExpand
    s.criticalGlow = root.editCriticalGlow
    s.timeOfDayTint = root.editTimeOfDayTint
    s.dynamicMediaAccent = root.editDynamicMediaAccent
    s.smoothMediaPosition = root.editSmoothMediaPosition
    s.iconMicroAnimations = root.editIconMicroAnimations

    // Interaction
    s.swipeGestures = root.editSwipeGestures
    s.scrubMedia = root.editScrubMedia
    s.contextMenu = root.editContextMenu

    // Media
    s.autoShowOnMedia = root.editAutoShowMedia

    // Notifications
    s.autoShowOnNotification = root.editAutoShowNotification
    s.notificationDurationSec = root.editNotificationDuration
    s.stackNotifications = root.editStackNotifications
    s.showNotificationActions = root.editShowNotificationActions
    s.dndEnabled = root.editDnd
    s.dndPausesMediaAutoShow = root.editDndPausesMediaAutoShow
    s.notificationMutedApps = root.parseCsv(root.editMutedAppsCsv)
    s.notificationPinnedApps = root.parseCsv(root.editPinnedAppsCsv)

    // Recording
    s.detectScreenRecording = root.editDetectRecording
    s.recordingPollSec = root.editRecordingPoll

    // Idle
    s.idleShowClock = root.editIdleClock
    s.idleShowSeconds = root.editIdleShowSeconds
    s.idleUse24h = root.editIdleUse24h
    s.idleShowWeather = root.editIdleWeather
    s.weatherLocation = root.editWeatherLocation
    s.weatherUnits = root.editWeatherUnits
    s.weatherCacheEnabled = root.editWeatherCacheEnabled

    // Battery
    s.batteryEnabled = root.editBatteryEnabled
    s.batteryLowThreshold = root.editBatteryLowThreshold
    s.batteryPollSec = root.editBatteryPollSec
    s.batteryShowOnChange = root.editBatteryShowOnChange

    // OSD
    s.osdEnabled = root.editOsdEnabled
    s.osdDurationSec = root.editOsdDurationSec

    // Pomodoro
    s.pomodoroEnabled = root.editPomodoroEnabled
    s.pomodoroWorkMin = root.editPomodoroWorkMin
    s.pomodoroShortBreakMin = root.editPomodoroShortBreakMin
    s.pomodoroLongBreakMin = root.editPomodoroLongBreakMin
    s.pomodoroLongBreakEvery = root.editPomodoroLongBreakEvery
    s.pomodoroAutoDnd = root.editPomodoroAutoDnd

    // Timer
    s.timerEnabled = root.editTimerEnabled

    // Privacy
    s.privacyIndicatorEnabled = root.editPrivacyEnabled
    s.privacyPollSec = root.editPrivacyPollSec

    // Network
    s.networkEnabled = root.editNetworkEnabled
    s.networkPollSec = root.editNetworkPollSec

    // Bluetooth
    s.bluetoothEnabled = root.editBluetoothEnabled

    // Keyboard
    s.keyboardLayoutEnabled = root.editKeyboardLayoutEnabled

    // Workspace
    s.workspaceEnabled = root.editWorkspaceEnabled

    // Clipboard / Screenshot
    s.clipboardEnabled = root.editClipboardEnabled
    s.clipboardAutoWatch = root.editClipboardAutoWatch
    s.clipboardPrivacy = root.editClipboardPrivacy
    s.screenshotEnabled = root.editScreenshotEnabled
    s.screenshotDir = root.editScreenshotDir

    // Calendar
    s.calendarEnabled = root.editCalendarEnabled

    // Downloads
    s.downloadEnabled = root.editDownloadEnabled

    // CPU
    s.cpuEnabled = root.editCpuEnabled
    s.cpuPollSec = root.editCpuPollSec
    s.cpuTempCritical = root.editCpuTempCritical

    // Bar widget
    s.barShowClock = root.editBarShowClock
    s.barShowWeather = root.editBarShowWeather
    s.barShowActiveWindow = root.editBarShowActiveWindow
    s.barShowMedia = root.editBarShowMedia
    s.barShowNotifications = root.editBarShowNotifications
    s.barShowRecording = root.editBarShowRecording
    s.barShowBattery = root.editBarShowBattery
    s.barShowPomodoro = root.editBarShowPomodoro
    s.barShowPrivacy = root.editBarShowPrivacy
    s.barClickAction = root.editBarClickAction
    s.activeWindowMaxChars = root.editActiveWindowMaxChars
    s.mediaTitleMaxChars = root.editMediaTitleMaxChars
    s.glassEffect = root.editGlassEffect
    s.barHoverLift = root.editBarHoverLift
    s.barClickRipple = root.editBarClickRipple
    s.barDynamicAccent = root.editBarDynamicAccent

    // Automation
    s.keyboardLayoutAutoPoll = root.editKeyboardLayoutAutoPoll
    s.keyboardLayoutPollSec = root.editKeyboardLayoutPollSec
    s.workspaceAutoPoll = root.editWorkspaceAutoPoll
    s.workspacePollSec = root.editWorkspacePollSec
    s.volumeAutoPoll = root.editVolumeAutoPoll
    s.volumePollMs = root.editVolumePollMs
    s.brightnessAutoPoll = root.editBrightnessAutoPoll
    s.brightnessPollMs = root.editBrightnessPollMs
    s.screenshotAutoWatch = root.editScreenshotAutoWatch
    s.screenshotPollSec = root.editScreenshotPollSec

    // Sounds
    s.notificationSound = root.editNotificationSound
    s.notificationSoundPath = root.editNotificationSoundPath

    // Effects
    s.effectsRipple = root.editEffectsRipple
    s.effectsHoverLift = root.editEffectsHoverLift
    s.effectsTrackFlash = root.editEffectsTrackFlash
    s.effectsAudioBars = root.editEffectsAudioBars
    s.effectsConfetti = root.editEffectsConfetti
    s.effectsNotificationSlide = root.editEffectsNotificationSlide
    s.effectsWeatherParticles = root.editEffectsWeatherParticles
    s.reducedMotion = root.editReducedMotion
    s.realBlur = root.editRealBlur
    s.realBlurRadius = root.editRealBlurRadius

    // Interaction extras
    s.scrollAdjustsVolume = root.editScrollAdjustsVolume
    s.scrollVolumeStep = root.editScrollVolumeStep
    s.autoDndOnFullscreen = root.editAutoDndOnFullscreen
    s.fullscreenPollSec = root.editFullscreenPollSec

    // Disk / Net / RAM
    s.diskEnabled = root.editDiskEnabled
    s.diskWarnThreshold = root.editDiskWarnThreshold
    s.diskPollSec = root.editDiskPollSec
    s.diskMount = root.editDiskMount
    s.netSpeedEnabled = root.editNetSpeedEnabled
    s.netSpeedPollSec = root.editNetSpeedPollSec
    s.ramEnabled = root.editRamEnabled
    s.ramWarnThreshold = root.editRamWarnThreshold

    // Pomodoro stats / idle countdown
    s.pomodoroStatsEnabled = root.editPomodoroStatsEnabled
    s.idleNextEventCountdown = root.editIdleNextEventCountdown

    pluginApi.saveSettings()
  }
}
