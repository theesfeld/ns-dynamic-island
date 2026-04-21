import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  // Tick once per second for the clock
  property string clockText: Qt.formatTime(new Date(), "HH:mm")

  Timer {
    interval: 1000
    running: root.main.idleShowClock
    repeat: true
    triggeredOnStart: true
    onTriggered: root.clockText = Qt.formatTime(new Date(), "HH:mm")
  }

  RowLayout {
    anchors.centerIn: parent
    spacing: 10

    NText {
      visible: root.main.idleShowClock
      text: root.clockText
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      font.weight: Font.Medium
    }

    Rectangle {
      visible: root.main.idleShowClock && root.main.idleShowWeather && root.main.weatherTemp.length > 0
      Layout.preferredWidth: 1
      Layout.preferredHeight: 14
      color: Qt.alpha(Color.mOutline, 0.4)
    }

    RowLayout {
      visible: root.main.idleShowWeather && root.main.weatherTemp.length > 0
      spacing: 4

      NIcon {
        icon: "weather-sun"
        pointSize: Style.fontSizeXS
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
