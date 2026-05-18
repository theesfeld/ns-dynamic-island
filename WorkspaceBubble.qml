import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
  id: root
  required property var main

  readonly property string ws: main.workspaceName
  readonly property string wsLabel: main.workspaceLabel

  RowLayout {
    anchors.centerIn: parent
    spacing: 6

    NIcon {
      icon: "workspace"
      pointSize: Style.fontSizeS
      color: Color.mPrimary
    }
    NText {
      text: root.wsLabel.length > 0 ? root.wsLabel : root.ws
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
      font.weight: Font.Medium
      elide: Text.ElideRight
    }
  }
}
