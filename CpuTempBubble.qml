import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property int tempC: main.cpuTempC
  readonly property int cpuPct: main.cpuLoadPct
  readonly property bool hot: tempC >= main.cpuTempCritical

  RowLayout {
    anchors.fill: parent
    spacing: 6

    Item {
      Layout.preferredWidth: Math.max(18, parent.height - 8)
      Layout.preferredHeight: Math.max(18, parent.height - 8)
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.alpha(root.hot ? Color.mError : Color.mTertiary, 0.18)
        border.color: Qt.alpha(Color.mError, root.hot ? 0.85 : 0)
        border.width: root.hot ? 1 : 0

        SequentialAnimation on opacity {
          running: root.hot
          loops: Animation.Infinite
          NumberAnimation { to: 0.6; duration: 800; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
        }
      }

      NIcon {
        anchors.centerIn: parent
        icon: root.hot ? "cpu" : "cpu"
        pointSize: Style.fontSizeS
        color: root.hot ? Color.mError : Color.mTertiary
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: root.tempC > 0 ? root.tempC + "°C" : (root.cpuPct + "%")
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded
        text: root.hot
          ? "Thermal warning"
          : ("CPU " + root.cpuPct + "%" + (main.ramEnabled ? (" · RAM " + main.ramUsedPct + "%") : ""))
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }
    }

    // Sparkline
    Sparkline {
      visible: root.expanded
      Layout.alignment: Qt.AlignVCenter
      Layout.preferredWidth: 50
      Layout.preferredHeight: 14
      samples: main.cpuHistory
      stroke: root.hot ? Color.mError : Color.mTertiary
      fill: Qt.alpha(root.hot ? Color.mError : Color.mTertiary, 0.22)
      minVal: 0; maxVal: 100
    }
  }
}
