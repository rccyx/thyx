import QtQuick 2.15

Row {
    id: root

    property real scaleFactor: 1
    property var themeData

    signal actionRequested(string actionName)

    spacing: themeData.layout.powerSpacing * scaleFactor

    PowerAction {
        themeData: root.themeData
        scaleFactor: root.scaleFactor
        iconSource: root.themeData.copy.shutdownIcon
        label: root.themeData.copy.shutdownLabel
        actionName: root.themeData.copy.shutdownAction

        onActivated: function(actionName) {
            root.actionRequested(actionName)
        }
    }

    PowerAction {
        themeData: root.themeData
        scaleFactor: root.scaleFactor
        iconSource: root.themeData.copy.restartIcon
        label: root.themeData.copy.restartLabel
        actionName: root.themeData.copy.restartAction

        onActivated: function(actionName) {
            root.actionRequested(actionName)
        }
    }

    PowerAction {
        themeData: root.themeData
        scaleFactor: root.scaleFactor
        iconSource: root.themeData.copy.sleepIcon
        label: root.themeData.copy.sleepLabel
        actionName: root.themeData.copy.sleepAction

        onActivated: function(actionName) {
            root.actionRequested(actionName)
        }
    }
}
