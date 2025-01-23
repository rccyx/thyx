import QtQuick 2.15

Row {
    id: root

    property real scaleFactor: 1
    property var themeData
    property var actionModel: [
        {
            icon: themeData.copy.shutdownIcon,
            label: themeData.copy.shutdownLabel,
            action: themeData.copy.shutdownAction
        },
        {
            icon: themeData.copy.restartIcon,
            label: themeData.copy.restartLabel,
            action: themeData.copy.restartAction
        },
        {
            icon: themeData.copy.sleepIcon,
            label: themeData.copy.sleepLabel,
            action: themeData.copy.sleepAction
        }
    ]

    signal actionRequested(string actionName)

    spacing: themeData.layout.powerSpacing * scaleFactor

    Repeater {
        model: root.actionModel

        PowerAction {
            themeData: root.themeData
            scaleFactor: root.scaleFactor
            iconSource: modelData.icon
            label: modelData.label
            actionName: modelData.action

            onActivated: function(actionName) {
                root.actionRequested(actionName)
            }
        }
    }
}
