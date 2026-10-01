import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: bar

  anchors { top: true; left: true; right: true }
  margins { top: 3; left: 0; right: 0}
  implicitHeight: 40
  color: "transparent"

  Poller {
    id: clock
    command: "date +%H:%M"
    interval: 5000
  }

  Poller {
    id:vol 
    command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf\"%d\",$2*100}'"
    interval: 1000
  }

  Poller {
    id:bat 
    command: "cat /sys/class/power_supply/BAT0/capacity"
    interval: 60000
  }

  Poller {
    id: net 
    command: "nmcli -t -f NAME connection show --active | head -n1"
    interval: 5000
  }

  RowLayout {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: 14
    spacing: 8

    Workspaces {}
  }

  RowLayout {
    id: centerGroup
    anchors.centerIn: parent
    spacing: 8

    Pill { icon: ""; label: clock.value}
  }


  RowLayout {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.rightMargin: 14
    spacing: 8

    Pill { icon: ""; label: vol.value + "%"; iconColor: "#ffffff"}
    Pill { icon: ""; label: bat.value + "%"; iconColor: "#ffffff"}
    Pill { icon: ""; label: net.value; iconColor: "#ffffff"}

  }
  AppLauncher {}
}
