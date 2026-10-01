import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root

  property string icon: ""
  property string label: ""
  property color iconColor: "#ffffff"
  property int maxLabelWidth: 400

  implicitWidth: row.implicitWidth + 22
  implicitHeight: 33
  radius: height / 2
  color: "#000000"

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 7

    Text {
      text: root.icon
      color: root.iconColor
      font.family: "Jetbrains Nerd font"
      font.pixelSize: 16
    }

    Text {
      text: root.label
      color:"#ffffff"
      font.family: "Jetbrains Nerd Font"
      font.pixelSize: 16
      elide:Text.ElideRight
      Layout.maximumWidth: root.maxLabelWidth
      visible: root.label !== ""
    }
  }
}
