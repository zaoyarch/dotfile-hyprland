import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
  id: launcherWindow

  anchors { bottom: true; left: true; right: true }
  implicitHeight: 420
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.exclusiveZone: 0
  WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  property bool isOpen: false
  property int selectedIndex: 0

  property var filteredApps: {
    const query = searchInput.text.trim().toLowerCase()
    const apps = DesktopEntries.applications.values || []

    if (query === "") {
      return apps.slice().sort((a, b) => a.name.localeCompare(b.name))
    }

    return apps.filter(app =>
      app.name && app.name.toLowerCase().includes(query)
    ).sort((a, b) => a.name.localeCompare(b.name))
  }

  onFilteredAppsChanged: selectedIndex = 0

  IpcHandler {
    target: "launcher"
    function toggle(): void { isOpen ? closeLauncher() : openLauncher() }
    function open(): void { openLauncher() }
    function close(): void { closeLauncher() }
  }

  mask: Region {
    item: isOpen ? fullArea : triggerArea
  }

  Item {
    id: fullArea
    anchors.fill: parent
    MouseArea {
      anchors.fill: parent
      onClicked: closeLauncher()
    }
  }

  MouseArea {
      id: triggerArea
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      width: 640
      height: 8
      hoverEnabled: true
      onEntered: openLauncher()
  }

  Rectangle {
    id: container
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 12
    width: 640
    height: 380
    radius: 20
    color: "#1e1e2e"
    border.color: "#313244"
    border.width: 1

    transform: Translate {
      y: isOpen ? 0 : container.height + 30
      Behavior on y {
        NumberAnimation {
          duration: 220
          easing.type: Easing.OutCubic
        }
      }
    }

    HoverHandler {
      enabled: isOpen
      onHoveredChanged: {
        if (!hovered) closeTimer.restart()
        else closeTimer.stop()
      }
    }

    Timer {
      id: closeTimer
      interval: 280
      onTriggered: closeLauncher()
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 18
      spacing: 14

      TextField {
        id: searchInput
        Layout.fillWidth: true
        Layout.preferredHeight: 42
        placeholderText: "Find..."
        placeholderTextColor: "#6c7086"
        color: "#cdd6f4"
        font.pixelSize: 15
        font.family: "Inter"
        leftPadding: 14
        rightPadding: 14

        background: Rectangle {
          color: "#181825"
          radius: 12
          border.color: searchInput.activeFocus ? "#89b4fa" : "#313244"
          border.width: 1
        }

        Keys.onPressed: (event) => {
          if (event.key === Qt.Key_Escape) {
            closeLauncher()
            event.accepted = true
          }
          else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            launchSelected()
            event.accepted = true
          }
          else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
            if (filteredApps.length > 0)
              selectedIndex = Math.min(selectedIndex + 1, filteredApps.length - 1)
            event.accepted = true
          }
          else if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
            if (filteredApps.length > 0)
              selectedIndex = Math.max(selectedIndex - 1, 0)
            event.accepted = true
          }
        }
      }

      GridView {
        id: grid
        Layout.fillWidth: true
        Layout.fillHeight: true
        cellWidth: 118
        cellHeight: 118
        clip: true
        model: filteredApps
        currentIndex: selectedIndex

        onCurrentIndexChanged: {
          if (currentIndex >= 0)
            positionViewAtIndex(currentIndex, GridView.Contain)
        }

        delegate: Rectangle {
          width: grid.cellWidth - 12
          height: grid.cellHeight - 12
          radius: 14
          color: {
            if (grid.currentIndex === index) return "#45475a"
            if (itemMouse.containsMouse) return "#313244"
            return "transparent"
          }
          border.color: grid.currentIndex === index ? "#89b4fa" : "transparent"
          border.width: grid.currentIndex === index ? 2 : 0

          Behavior on color { ColorAnimation { duration: 120 } }

          required property var modelData
          required property int index

          ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            IconImage {
              Layout.alignment: Qt.AlignHCenter
              source: modelData.icon
                      ? Quickshell.iconPath(modelData.icon, true)
                      : Quickshell.iconPath("application-x-executable", true)
              implicitWidth: 48
              implicitHeight: 48
            }

            Text {
              Layout.alignment: Qt.AlignHCenter
              Layout.maximumWidth: 96
              text: modelData.name || ""
              color: "#cdd6f4"
              font.pixelSize: 13
              font.weight: Font.Medium
              elide: Text.ElideRight
              horizontalAlignment: Text.AlignHCenter
            }
          }

          MouseArea {
            id: itemMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              modelData.execute()
              closeLauncher()
            }
            onEntered: selectedIndex = index
          }
        }
      }
    }
  }

  function openLauncher() {
    isOpen = true
    selectedIndex = 0
    searchInput.forceActiveFocus()
  }

  function closeLauncher() {
    isOpen = false
    searchInput.text = ""
    selectedIndex = 0
  }

  function launchSelected() {
    if (filteredApps.length > 0 && selectedIndex >= 0 && selectedIndex < filteredApps.length) {
      filteredApps[selectedIndex].execute()
      closeLauncher()
    }
  }
}
