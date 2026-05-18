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

  property bool editEnabled: cfg.enabled ?? def.enabled ?? true
  property string editPosition: cfg.position || def.position || "top"
  property int editMargin: cfg.marginPx ?? def.marginPx ?? 6
  property int editHorizontalOffset: cfg.horizontalOffset ?? def.horizontalOffset ?? 0
  property int editCompactWidth: cfg.compactWidth ?? def.compactWidth ?? 180
  property int editExpandedWidth: cfg.expandedWidth ?? def.expandedWidth ?? 440
  property int editHeight: cfg.height ?? def.height ?? 36
  property int editCornerRadius: cfg.cornerRadius ?? def.cornerRadius ?? 18
  property int editHideDelay: cfg.hideDelaySec ?? def.hideDelaySec ?? 4
  property bool editHoverToExpand: cfg.hoverToExpand ?? def.hoverToExpand ?? true
  property bool editAutoShowMedia: cfg.autoShowOnMedia ?? def.autoShowOnMedia ?? true
  property bool editAutoShowNotification: cfg.autoShowOnNotification ?? def.autoShowOnNotification ?? true
  property int editNotificationDuration: cfg.notificationDurationSec ?? def.notificationDurationSec ?? 5
  property bool editDetectRecording: cfg.detectScreenRecording ?? def.detectScreenRecording ?? true
  property int editRecordingPoll: cfg.recordingPollSec ?? def.recordingPollSec ?? 3
  property bool editIdleClock: cfg.idleShowClock ?? def.idleShowClock ?? true
  property bool editIdleWeather: cfg.idleShowWeather ?? def.idleShowWeather ?? false
  property string editWeatherLocation: cfg.weatherLocation || def.weatherLocation || ""
  property string editWeatherUnits: cfg.weatherUnits || def.weatherUnits || "metric"
  property bool editDualBubble: cfg.dualBubble ?? def.dualBubble ?? true
  property var editDisabledScreens: (cfg.disabledScreens ? cfg.disabledScreens.slice() : (def.disabledScreens ? def.disabledScreens.slice() : []))

  spacing: Style.marginL

  NToggle {
    Layout.fillWidth: true
    label: "Enable island"
    description: "Master switch. When disabled, the island is never shown."
    checked: root.editEnabled
    onToggled: checked => root.editEnabled = checked
  }

  NDivider { Layout.fillWidth: true }

  // ── Layout ─────────────────────────────────────────────
  NLabel { label: "Position" }
  NComboBox {
    Layout.fillWidth: true
    model: [
      { key: "top", name: "Top of screen" },
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

  // ── Behavior ───────────────────────────────────────────
  NToggle {
    Layout.fillWidth: true
    label: "Expand on hover"
    checked: root.editHoverToExpand
    onToggled: checked => root.editHoverToExpand = checked
  }

  NToggle {
    Layout.fillWidth: true
    label: "Show both bubbles simultaneously"
    description: "When on, media + notification (or media + recording) can appear side by side."
    checked: root.editDualBubble
    onToggled: checked => root.editDualBubble = checked
  }

  NLabel { label: "Auto-hide delay (s): " + root.editHideDelay }
  NSlider {
    Layout.fillWidth: true
    from: 1; to: 20; stepSize: 1
    value: root.editHideDelay
    onValueChanged: root.editHideDelay = value
  }

  NDivider { Layout.fillWidth: true }

  // ── Media ──────────────────────────────────────────────
  NToggle {
    Layout.fillWidth: true
    label: "Auto-show on media change"
    checked: root.editAutoShowMedia
    onToggled: checked => root.editAutoShowMedia = checked
  }

  // ── Notifications ──────────────────────────────────────
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

  // ── Screen recording ───────────────────────────────────
  NToggle {
    Layout.fillWidth: true
    label: "Show recording indicator"
    description: "Polls for gpu-screen-recorder / wf-recorder / obs processes."
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

  // ── Idle state ─────────────────────────────────────────
  NToggle {
    Layout.fillWidth: true
    label: "Show clock when idle"
    checked: root.editIdleClock
    onToggled: checked => root.editIdleClock = checked
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

  NLabel {
    label: "Weather units"
    visible: root.editIdleWeather
  }
  NComboBox {
    Layout.fillWidth: true
    visible: root.editIdleWeather
    model: [
      { key: "metric", name: "Metric (°C)" },
      { key: "imperial", name: "Imperial (°F)" }
    ]
    currentKey: root.editWeatherUnits
    onSelected: key => root.editWeatherUnits = key
  }

  NDivider { Layout.fillWidth: true }

  // ── Monitors ───────────────────────────────────────────
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

  function saveSettings() {
    if (!pluginApi) return
    const s = pluginApi.pluginSettings
    s.enabled = root.editEnabled
    s.position = root.editPosition
    s.marginPx = root.editMargin
    s.horizontalOffset = root.editHorizontalOffset
    s.compactWidth = root.editCompactWidth
    s.expandedWidth = root.editExpandedWidth
    s.height = root.editHeight
    s.cornerRadius = root.editCornerRadius
    s.hideDelaySec = root.editHideDelay
    s.hoverToExpand = root.editHoverToExpand
    s.autoShowOnMedia = root.editAutoShowMedia
    s.autoShowOnNotification = root.editAutoShowNotification
    s.notificationDurationSec = root.editNotificationDuration
    s.detectScreenRecording = root.editDetectRecording
    s.recordingPollSec = root.editRecordingPoll
    s.idleShowClock = root.editIdleClock
    s.idleShowWeather = root.editIdleWeather
    s.weatherLocation = root.editWeatherLocation
    s.weatherUnits = root.editWeatherUnits
    s.dualBubble = root.editDualBubble
    s.disabledScreens = root.editDisabledScreens
    pluginApi.saveSettings()
  }
}
