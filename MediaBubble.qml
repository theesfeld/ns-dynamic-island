import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property real progress: main.mediaLength > 0 ? main.mediaPosition / main.mediaLength : 0

  RowLayout {
    anchors.fill: parent
    spacing: 8

    // Album art (or music icon fallback)
    Item {
      Layout.preferredWidth: parent.height - 8
      Layout.preferredHeight: parent.height - 8
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.fill: parent
        radius: width / 4
        color: Qt.alpha(Color.mSurfaceVariant, 0.8)
        clip: true

        Image {
          anchors.fill: parent
          source: main.mediaArtUrl
          fillMode: Image.PreserveAspectCrop
          visible: main.mediaArtUrl.length > 0
          asynchronous: true
          cache: true
        }

        NIcon {
          anchors.centerIn: parent
          icon: "music"
          visible: main.mediaArtUrl.length === 0
          color: Color.mPrimary
        }
      }
    }

    // Text block (title + artist or marquee title)
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: main.mediaTitle
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
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
        Layout.topMargin: 2
        visible: root.expanded && main.mediaLength > 0
        color: Qt.alpha(Color.mOutline, 0.35)
        radius: 1

        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          width: parent.width * Math.max(0, Math.min(1, root.progress))
          color: Color.mPrimary
          radius: 1

          Behavior on width {
            NumberAnimation { duration: 400; easing.type: Easing.Linear }
          }
        }
      }
    }

    // Transport controls (expanded only)
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
