import Quickshell
import Quickshell.Hyprland
import QtQuick 
import QtQuick.Layouts

Rectangle {
  implicitWidth: row.implicitWidth + 22
  implicitHeight : 33
  radius: height / 2
  color: "#040e0d"

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 8

    Text {
      text: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : "?"
      color: "#ffffff"
      font.family: "Jetbrains Nerd Font"
      font.pixelSize: 16
      font.bold: true
    }

    Repeater {
      model: Hyprland.workspaces

      Rectangle {
        implicitWidth: modelData.active ? 11 : 6
        implicitHeight: implicitWidth
        radius: width / 2
        color: modelData.active ? "transparent" : "#1d3631"
        border.width: modelData.active ? 2 : 0
        border.color: "#ffffff"

        Behavior on implicitWidth {
          NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
      }
    }
  }
}
