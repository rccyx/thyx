import QtQuick 2.15

Item {
    id: root

    property date currentDate
    property real scaleFactor: 1
    property var themeData
    property alias loginForm: credentialsForm

    signal actionRequested(string actionName)
    signal loginRequested(string username, string password)

    BackgroundLayer {
        anchors.fill: parent
        themeData: root.themeData
    }

    ClockBlock {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * root.themeData.layout.clockY
        width: root.width
        currentDate: root.currentDate
        scaleFactor: root.scaleFactor
        themeData: root.themeData
    }

    LoginForm {
        id: credentialsForm

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * root.themeData.layout.loginY
        scaleFactor: root.scaleFactor
        themeData: root.themeData

        onLoginRequested: function(username, password) {
            root.loginRequested(username, password)
        }
    }

    PowerBar {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * root.themeData.layout.powerY
        scaleFactor: root.scaleFactor
        themeData: root.themeData

        onActionRequested: function(actionName) {
            root.actionRequested(actionName)
        }
    }

    EnvironmentLabel {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * root.themeData.layout.environmentY
        scaleFactor: root.scaleFactor
        themeData: root.themeData
    }
}
