import QtQuick 2.15

QtObject {
    id: root

    property var greeter
    property var loginForm
    property var themeData

    function login(username, password) {
        if (username.length === 0) {
            loginForm.focusUsername()
            return
        }

        loginForm.clearError()
        greeter.login(username, password, 0)
    }

    function handleLoginFailed() {
        loginForm.handleLoginFailed()
    }

    function runPowerAction(actionName) {
        if (actionName === themeData.copy.shutdownAction) {
            greeter.powerOff()
            return
        }

        if (actionName === themeData.copy.restartAction) {
            greeter.reboot()
            return
        }

        if (actionName === themeData.copy.sleepAction) greeter.suspend()
    }
}
