import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property var notif: main.activeNotification

  // urgency: 0 = low, 1 = normal, 2 = critical
  readonly property int urgency: notif ? (notif.urgency | 0) : 1
  readonly property color accent:
      urgency === 2 ? Color.mError
    : urgency === 0 ? Color.mOnSurfaceVariant
    : Color.mTertiary

  RowLayout {
    anchors.fill: parent
    spacing: 8
    visible: root.notif !== null

    // ── App icon / image bubble ──────────────────────────
    Item {
      Layout.preferredWidth: Math.max(18, parent.height - 8)
      Layout.preferredHeight: Math.max(18, parent.height - 8)
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.alpha(root.accent, 0.22)
        border.color: Qt.alpha(root.accent, root.urgency === 2 ? 0.85 : 0.0)
        border.width: root.urgency === 2 ? 1 : 0
        clip: true

        Image {
          anchors.fill: parent
          source: root.notif && root.notif.image ? root.notif.image : ""
          fillMode: Image.PreserveAspectCrop
          visible: root.notif && root.notif.image && root.notif.image.length > 0
            && status === Image.Ready
          asynchronous: true
          sourceSize.width: width * 2
          sourceSize.height: height * 2
        }

        NIcon {
          anchors.centerIn: parent
          icon: root.urgency === 2 ? "alert" : "bell"
          pointSize: Style.fontSizeS
          color: root.accent
          visible: !root.notif || !root.notif.image || root.notif.image.length === 0
        }
      }
    }

    // ── Text block ───────────────────────────────────────
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: root.notif
          ? (root.notif.summary && root.notif.summary.length > 0
              ? root.notif.summary
              : (root.notif.appName || ""))
          : ""
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
      }

      NText {
        Layout.fillWidth: true
        visible: root.expanded && root.notif && root.notif.body && root.notif.body.length > 0
        text: root.notif ? root.notif.body : ""
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
        maximumLineCount: 2
        wrapMode: Text.WordWrap
      }
    }

    // ── Urgency pip (critical only) ──────────────────────
    Rectangle {
      visible: root.urgency === 2
      Layout.preferredWidth: 6
      Layout.preferredHeight: 6
      Layout.alignment: Qt.AlignVCenter
      radius: 3
      color: Color.mError

      SequentialAnimation on opacity {
        running: root.urgency === 2
        loops: Animation.Infinite
        NumberAnimation { to: 0.4; duration: 700; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
      }
    }
  }
}
