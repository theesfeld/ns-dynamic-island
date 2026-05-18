import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property bool expanded: main.expanded
  readonly property string preview: main.clipboardPreview
  readonly property string kind: main.clipboardKind   // "text" | "image" | "file"

  RowLayout {
    anchors.fill: parent
    spacing: 8

    Item {
      Layout.preferredWidth: Math.max(18, parent.height - 8)
      Layout.preferredHeight: Math.max(18, parent.height - 8)
      Layout.alignment: Qt.AlignVCenter

      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.alpha(Color.mPrimary, 0.18)
      }
      NIcon {
        anchors.centerIn: parent
        icon: root.kind === "image" ? "image" : root.kind === "file" ? "file" : "clipboard"
        pointSize: Style.fontSizeS
        color: Color.mPrimary
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      NText {
        Layout.fillWidth: true
        text: "Copied"
        color: Color.mOnSurface
        pointSize: Style.fontSizeS
        font.weight: Font.Medium
      }
      NText {
        Layout.fillWidth: true
        visible: root.expanded && root.preview.length > 0
        text: root.preview
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        elide: Text.ElideRight
        maximumLineCount: 1
      }
    }
  }
}
