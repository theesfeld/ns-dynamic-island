import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property real liveProgress:
      main.mediaLength > 0
        ? Math.max(0, Math.min(1,
            (main.smoothMediaPosition ? main.smoothedMediaPosition : main.mediaPosition) / main.mediaLength))
        : 0
  readonly property color accent: main.mediaAccent

  function mmss(s) {
    if (s <= 0 || isNaN(s)) return "0:00"
    const m = Math.floor(s / 60)
    const r = Math.floor(s) % 60
    return m + ":" + (r < 10 ? "0" : "") + r
  }

  RowLayout {
    anchors.fill: parent
    spacing: 8

    // Album art with track-change flash + flip
    Item {
      id: artHolder
      Layout.preferredWidth: Math.max(18, parent.height - 8)
      Layout.preferredHeight: Math.max(18, parent.height - 8)
      Layout.alignment: Qt.AlignVCenter

      property real flipAngle: 0

      transform: Rotation {
        origin.x: artHolder.width / 2
        origin.y: artHolder.height / 2
        axis { x: 0; y: 1; z: 0 }
        angle: artHolder.flipAngle
      }

      Connections {
        target: main
        function onTrackChanged() {
          if (!main.effectsTrackFlash) return
          flipAnim.restart()
          flashAnim.restart()
        }
      }
      SequentialAnimation {
        id: flipAnim
        NumberAnimation { target: artHolder; property: "flipAngle"; from: 0; to: 90;  duration: 220; easing.type: Easing.InQuad }
        NumberAnimation { target: artHolder; property: "flipAngle"; from: -90; to: 0;  duration: 220; easing.type: Easing.OutQuad }
      }
      SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: flashOverlay; property: "opacity"; from: 0; to: 0.75; duration: 100 }
        NumberAnimation { target: flashOverlay; property: "opacity"; to: 0; duration: 400; easing.type: Easing.OutQuad }
      }

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

        // Track-change flash overlay
        Rectangle {
          id: flashOverlay
          anchors.fill: parent
          radius: parent.radius
          color: "#FFFFFF"
          opacity: 0
        }

        // Subtle dynamic-accent ring
        Rectangle {
          anchors.fill: parent
          radius: parent.radius
          color: "transparent"
          border.color: Qt.alpha(root.accent, 0.55)
          border.width: 1
          visible: main.dynamicMediaAccent
        }

        NIcon {
          anchors.centerIn: parent
          icon: "music"
          pointSize: Style.fontSizeS
          color: root.accent
          visible: main.mediaArtUrl.length === 0
        }
      }
    }

    // Audio level bars — visible when expanded AND playing
    AudioBars {
      visible: main.effectsAudioBars && root.expanded && main.mediaIsPlaying
      Layout.alignment: Qt.AlignVCenter
      Layout.preferredWidth: 14
      tint: root.accent
      playing: main.mediaIsPlaying
      barCount: 4
      maxHeight: 12
    }

    // Text + progress
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: titleText.implicitHeight
        clip: true

        NText {
          id: titleText
          y: (parent.height - implicitHeight) / 2
          text: main.mediaTitle
          color: Color.mOnSurface
          pointSize: Style.fontSizeS * main.textScale
          font.weight: Font.Medium
          elide: Text.ElideRight
          width: parent.width

          readonly property bool overflows: implicitWidth > width

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

      RowLayout {
        Layout.fillWidth: true
        visible: root.expanded && main.mediaArtist.length > 0
        spacing: 6

        NText {
          Layout.fillWidth: true
          text: main.mediaArtist
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeXS * main.textScale
          elide: Text.ElideRight
        }
        NText {
          visible: main.mediaLength > 0
          text: root.mmss(main.smoothMediaPosition ? main.smoothedMediaPosition : main.mediaPosition)
              + " / " + root.mmss(main.mediaLength)
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeXS * main.textScale
          font.family: "monospace"
        }
      }

      // Scrubbable progress bar
      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 6
        Layout.topMargin: 3
        visible: root.expanded && main.mediaLength > 0

        Rectangle {
          id: progressTrack
          anchors.fill: parent
          anchors.topMargin: 2
          anchors.bottomMargin: 2
          color: Qt.alpha(Color.mOutline, 0.35)
          radius: 1

          Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * root.liveProgress
            color: root.accent
            radius: 1
            Behavior on width {
              NumberAnimation { duration: 350; easing.type: Easing.Linear }
            }
          }
        }

        MouseArea {
          anchors.fill: parent
          enabled: main.scrubMedia && main.mediaLength > 0
          hoverEnabled: true
          cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
          onClicked: (mouse) => main.mediaSeek(mouse.x / width)
          onPositionChanged: (mouse) => {
            if (pressed) main.mediaSeek(mouse.x / width)
          }
        }
      }
    }

    // Transport controls
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
      // Player switcher (when multiple MPRIS players are running)
      NIconButton {
        visible: main.availablePlayers && main.availablePlayers.length > 1
        icon: "swap"
        property int cursor: 0
        onClicked: {
          cursor = (cursor + 1) % main.availablePlayers.length
          main.switchToPlayer(cursor)
        }
      }
    }
  }
}
