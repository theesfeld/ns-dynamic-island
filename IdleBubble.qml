import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  property string clockText: ""

  function formatNow() {
    const fmt = main.idleUse24h
      ? (main.idleShowSeconds ? "HH:mm:ss" : "HH:mm")
      : (main.idleShowSeconds ? "h:mm:ss AP" : "h:mm AP")
    return Qt.formatTime(new Date(), fmt)
  }

  Timer {
    interval: main.idleShowSeconds ? 1000 : 15000
    running: main.idleShowClock
    repeat: true
    triggeredOnStart: true
    onTriggered: root.clockText = root.formatNow()
  }

  function weatherParticleMode(condition) {
    const c = (condition || "").toLowerCase()
    if (c.indexOf("snow") !== -1 || c.indexOf("sleet") !== -1) return "snow"
    if (c.indexOf("rain") !== -1 || c.indexOf("drizzle") !== -1 || c.indexOf("shower") !== -1) return "rain"
    return "none"
  }

  function weatherIconFor(condition) {
    const c = (condition || "").toLowerCase()
    if (c.indexOf("thunder") !== -1) return "weather-storm"
    if (c.indexOf("snow") !== -1 || c.indexOf("sleet") !== -1) return "weather-snow"
    if (c.indexOf("rain") !== -1 || c.indexOf("drizzle") !== -1 || c.indexOf("shower") !== -1) return "weather-rain"
    if (c.indexOf("fog") !== -1 || c.indexOf("mist") !== -1 || c.indexOf("haze") !== -1) return "weather-fog"
    if (c.indexOf("cloud") !== -1 || c.indexOf("overcast") !== -1) return "weather-cloud"
    if (c.indexOf("clear") !== -1 && new Date().getHours() >= 20) return "weather-moon"
    return "weather-sun"
  }

  // Weather particles overlay
  WeatherParticles {
    anchors.fill: parent
    visible: main.effectsWeatherParticles && main.idleShowWeather
    mode: visible ? root.weatherParticleMode(main.weatherCondition) : "none"
  }

  RowLayout {
    anchors.centerIn: parent
    spacing: 8

    NText {
      visible: main.idleShowClock
      text: root.clockText
      color: main.themeOnSurface
      pointSize: Style.fontSizeS * main.textScale
      font.weight: Font.Medium
    }

    // Calendar countdown ("in 5m") shown when next event is soon
    NText {
      visible: main.calendarEnabled && main.idleNextEventCountdown
        && main.calendarMinutesUntil >= 0 && main.calendarMinutesUntil <= 30
      text: "· " + main.calendarNextTitle + " in "
        + (main.calendarMinutesUntil <= 0 ? "now"
           : main.calendarMinutesUntil < 60 ? (main.calendarMinutesUntil + "m")
           : (Math.floor(main.calendarMinutesUntil / 60) + "h"))
      color: Color.mPrimary
      pointSize: Style.fontSizeXS * main.textScale
      font.weight: Font.Medium
    }

    Rectangle {
      visible: main.idleShowClock && main.idleShowWeather && main.weatherTemp.length > 0
      Layout.preferredWidth: 3
      Layout.preferredHeight: 3
      Layout.alignment: Qt.AlignVCenter
      radius: 1.5
      color: Qt.alpha(main.themeOutline, 0.6)
    }

    RowLayout {
      visible: main.idleShowWeather && main.weatherTemp.length > 0
      spacing: 4

      NIcon {
        icon: root.weatherIconFor(main.weatherCondition)
        pointSize: Style.fontSizeS
        color: main.weatherStale ? Color.mOnSurfaceVariant : Color.mOnSurfaceVariant
        opacity: main.weatherStale ? 0.55 : 1.0
      }
      NText {
        text: main.weatherTemp + (main.weatherStale ? " (stale)" : "")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS * main.textScale
      }
    }

    // DND glyph appears alongside clock when DND is active
    NIcon {
      visible: main.dndEnabled
      icon: "moon"
      pointSize: Style.fontSizeXS
      color: Color.mTertiary
    }
  }
}
