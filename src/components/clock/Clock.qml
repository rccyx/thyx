import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../ui"

Rectangle {
    id: temporalDisplay
    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
    Layout.preferredHeight: (rootItem ? rootItem.height : (parent ? parent.height : 0)) * UiTokens.clock_height_ratio
    color: "transparent"

    property var rootItem: null
    property var config: ({})

    Layout.leftMargin: 0
    implicitWidth: parent ? parent.width * UiTokens.field_width_ratio : 0

    Column {
        id: timeDisplayContainer
        anchors.centerIn: parent
        spacing: UiTokens.spacing_xs

        DateLabel {
            id: currentDate
            rootItem: temporalDisplay.rootItem
            config: temporalDisplay.config
        }

        TimeLabel {
            id: currentTime
            rootItem: temporalDisplay.rootItem
            config: temporalDisplay.config
        }
    }

    QtObject {
        id: timeUpdater
        property var refreshTimer: Timer {
            interval: 1000
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: timeUpdater.refreshTimeDisplay()
        }

        function refreshTimeDisplay() {
            currentDate.refreshDisplay();
            currentTime.refreshDisplay();
        }
    }

    Component.onCompleted: timeUpdater.refreshTimeDisplay()
}
