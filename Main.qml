import QtQuick 2.15
import QtQuick.Window 2.15
import SddmComponents 2.0 as SDDM

Rectangle {
    id: root

    width: Screen.width
    height: Screen.height
    color: theme.palette.base

    property date currentDate: new Date()
    property real uiScale: theme.scaleFor(width, height)

    Theme {
        id: theme
    }

    SessionController {
        id: sessionController

        greeter: sddm
        loginForm: greeterScreen.loginForm
        themeData: theme
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: root.currentDate = new Date()
    }

    GreeterScreen {
        id: greeterScreen

        anchors.fill: parent
        currentDate: root.currentDate
        scaleFactor: root.uiScale
        themeData: theme

        onLoginRequested: function(username, password) {
            sessionController.login(username, password)
        }

        onActionRequested: function(actionName) {
            sessionController.runPowerAction(actionName)
        }
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            sessionController.handleLoginFailed()
        }
    }

    Component.onCompleted: greeterScreen.loginForm.focusUsername()
}
