import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property var notif: main.activeNotification

  readonly property int urgency: notif ? (notif.urgency | 0) : 1
  readonly property color accent:
      urgency === 2 ? Color.mError
    : urgency === 0 ? Color.mOnSurfaceVariant
    : Color.mTertiary

  readonly property int queueCount: main.notificationQueueCount

  RowLayout {
    anchors.fill: parent
    spacing: 8
    visible: root.notif !== null

    // App icon
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
          cache: true
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

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      RowLayout {
        Layout.fillWidth: true
        spacing: 6

        NText {
          Layout.fillWidth: true
          text: root.notif
            ? (root.notif.summary && root.notif.summary.length > 0
                ? root.notif.summary
                : (root.notif.appName || ""))
            : ""
          color: Color.mOnSurface
          pointSize: Style.fontSizeS * main.textScale
          font.weight: Font.Medium
          elide: Text.ElideRight
          verticalAlignment: Text.AlignVCenter
        }

        // Pin glyph
        NIcon {
          visible: root.notif && root.notif.pinned
          icon: "pin"
          pointSize: Style.fontSizeXS
          color: Color.mTertiary
        }

        // Queue count badge: shown when there's more than one popup
        Rectangle {
          visible: main.stackNotifications && root.queueCount > 1
          radius: 8
          height: 16
          width: Math.max(18, queueLabel.implicitWidth + 8)
          color: Qt.alpha(root.accent, 0.18)
          border.color: Qt.alpha(root.accent, 0.65)
          border.width: 1
          NText {
            id: queueLabel
            anchors.centerIn: parent
            text: root.queueCount.toString()
            color: root.accent
            pointSize: Style.fontSizeXS
            font.weight: Font.Bold
          }
        }
      }

      NText {
        Layout.fillWidth: true
        visible: root.expanded && root.notif && root.notif.body && root.notif.body.length > 0
        text: root.notif ? root.notif.body : ""
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS * main.textScale
        elide: Text.ElideRight
        maximumLineCount: 2
        wrapMode: Text.WordWrap
      }

      // Action buttons row (action pairs come as [id, label, id, label, ...])
      RowLayout {
        Layout.fillWidth: true
        visible: root.expanded
              && main.showNotificationActions
              && root.notif && root.notif.actions
              && root.notif.actions.length >= 2
        spacing: 4

        Repeater {
          model: {
            if (!root.notif || !root.notif.actions) return []
            const a = root.notif.actions
            const pairs = []
            for (let i = 0; i + 1 < a.length; i += 2) {
              if (a[i] === "default") continue
              pairs.push({ id: a[i], label: a[i + 1] || a[i] })
            }
            return pairs.slice(0, 3)
          }
          delegate: Rectangle {
            radius: 6
            color: actionArea.containsMouse ? Qt.alpha(root.accent, 0.28) : Qt.alpha(root.accent, 0.16)
            border.color: Qt.alpha(root.accent, 0.5)
            border.width: 1
            implicitWidth: actionText.implicitWidth + 12
            implicitHeight: 18
            Layout.preferredHeight: 18

            NText {
              id: actionText
              anchors.centerIn: parent
              text: modelData.label
              color: root.accent
              pointSize: Style.fontSizeXS
              font.weight: Font.Medium
            }
            MouseArea {
              id: actionArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: main.invokeNotificationAction(modelData.id)
            }
          }
        }
      }
    }

    // Cycle / dismiss controls
    RowLayout {
      visible: root.expanded
      Layout.alignment: Qt.AlignVCenter
      spacing: 2

      NIconButton {
        visible: main.stackNotifications && root.queueCount > 1
        icon: "chevron-up"
        onClicked: main.cycleNotification(-1)
      }
      NIconButton {
        visible: main.stackNotifications && root.queueCount > 1
        icon: "chevron-down"
        onClicked: main.cycleNotification(1)
      }
      NIconButton {
        icon: "close"
        onClicked: main.dismissNotification()
      }
    }

    // Critical urgency pulsing pip
    Rectangle {
      visible: root.urgency === 2 && !root.expanded
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
