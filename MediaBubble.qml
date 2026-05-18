import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property real progress:
      main.mediaLength > 0
        ? Math.max(0, Math.min(1, main.mediaPosition / main.mediaLength))
        : 0

  RowLayout {
    anchors.fill: parent
    spacing: 8

    // ── Album art (or music icon fallback) ────────────────
    Item {
      Layout.preferredWidth: Math.max(18, parent.height - 8)
      Layout.preferredHeight: Math.max(18, parent.height - 8)
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.fill: parent
        radius: Math.max(4, width / 5)
        color: Qt.alpha(Color.mSurfaceVariant, 0.85)
        clip: true

        Image {
          anchors.fill: parent
          source: main.mediaArtUrl
          fillMode: Image.PreserveAspectCrop
          visible: main.mediaArtUrl.length > 0 && status === Image.Ready
          asynchronous: true
          cache: true
          sourceSize.width: width * 2
          sourceSize.height: height * 2
        }

        NIcon {
          anchors.centerIn: parent
          icon: "music"
          pointSize: Style.fontSizeS
          color: Color.mPrimary
          visible: main.mediaArtUrl.length === 0
        }
      }
    }

    // ── Text + progress ───────────────────────────────────
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      // Title (marquees when overflowing, otherwise elides)
      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: titleText.implicitHeight
        clip: true

        NText {
          id: titleText
          // When expanded with progress, sit a touch above center; otherwise center.
          y: (parent.height - implicitHeight) / 2
          text: main.mediaTitle
          color: Color.mOnSurface
          pointSize: Style.fontSizeS
          font.weight: Font.Medium
          elide: Text.ElideRight
          width: parent.width

          readonly property bool overflows: implicitWidth > width

          // Subtle horizontal marquee when text overflows and we're expanded.
          SequentialAnimation on x {
            running: titleText.overflows && root.expanded
            loops: Animation.Infinite
            PauseAnimation { duration: 1200 }
            NumberAnimation {
              from: 0
              to: -Math.max(0, titleText.implicitWidth - titleText.width) - 12
              duration: Math.max(1500, titleText.implicitWidth * 18)
              easing.type: Easing.InOutQuad
            }
            PauseAnimation { duration: 800 }
            NumberAnimation { to: 0; duration: 400; easing.type: Easing.OutQuad }
          }
        }
      }

      NText {
        Layout.fillWidth: true
        visible: root.expanded && main.mediaArtist.length > 0
        text: main.mediaArtist
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
      }

      // Progress bar (expanded only)
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 2
        Layout.topMargin: 3
        visible: root.expanded && main.mediaLength > 0
        color: Qt.alpha(Color.mOutline, 0.35)
        radius: 1

        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: parent.width * root.progress
          color: Color.mPrimary
          radius: 1

          Behavior on width {
            NumberAnimation { duration: 350; easing.type: Easing.Linear }
          }
        }
      }
    }

    // ── Transport controls (expanded only) ────────────────
    RowLayout {
      visible: root.expanded
      Layout.alignment: Qt.AlignVCenter
      spacing: 2

      NIconButton {
        icon: "media-prev"
        enabled: main.mediaCanPrev
        onClicked: main.mediaPrevious()
      }
      NIconButton {
        icon: main.mediaIsPlaying ? "media-pause" : "media-play"
        onClicked: main.mediaPlayPause()
      }
      NIconButton {
        icon: "media-next"
        enabled: main.mediaCanNext
        onClicked: main.mediaNext()
      }
    }
  }
}
