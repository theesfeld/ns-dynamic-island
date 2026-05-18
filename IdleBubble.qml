import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  property string clockText: Qt.formatTime(new Date(), "HH:mm")

  Timer {
    interval: 1000
    running: root.main.idleShowClock
    repeat: true
    triggeredOnStart: true
    onTriggered: root.clockText = Qt.formatTime(new Date(), "HH:mm")
  }

  // Map wttr.in weatherCondition keywords to a Noctalia icon name.
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

  RowLayout {
    anchors.centerIn: parent
    spacing: 8

    NText {
      visible: root.main.idleShowClock
      text: root.clockText
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      font.weight: Font.Medium
    }

    // Dot separator
    Rectangle {
      visible: root.main.idleShowClock && root.main.idleShowWeather && root.main.weatherTemp.length > 0
      Layout.preferredWidth: 3
      Layout.preferredHeight: 3
      Layout.alignment: Qt.AlignVCenter
      radius: 1.5
      color: Qt.alpha(Color.mOutline, 0.6)
    }

    RowLayout {
      visible: root.main.idleShowWeather && root.main.weatherTemp.length > 0
      spacing: 4

      NIcon {
        icon: root.weatherIconFor(root.main.weatherCondition)
        pointSize: Style.fontSizeS
        color: Color.mOnSurfaceVariant
      }

      NText {
        text: root.main.weatherTemp
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
      }
    }
  }
}
