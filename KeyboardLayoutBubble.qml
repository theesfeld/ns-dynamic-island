import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property string layout: main.keyboardLayout

  RowLayout {
    anchors.centerIn: parent
    spacing: 6

    NIcon {
      icon: "keyboard"
      pointSize: Style.fontSizeS
      color: Color.mPrimary
    }
    NText {
      text: root.layout.length > 0 ? root.layout.toUpperCase() : "—"
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      font.weight: Font.Bold
      font.family: "monospace"
    }
  }
}
