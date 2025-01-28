import QtQuick 2.15

QtObject {
    property string backgroundSource: "../../../../../wl.jpg"
    property string environmentLabel: "Hyprland"
    property string environmentTemplate: "Environment (%1)"
    property string fontFamily: "Inter"
    property string dateFormat: "dddd, MMMM d"
    property string timeFormat: "HH:mm"
    property string usernamePlaceholder: "Username"
    property string passwordPlaceholder: "Password"
    property string passwordCharacter: "•"
    property string loginLabel: "Login"
    property string loginFailedMessage: "Login failed"
    property string shutdownLabel: "Shutdown"
    property string restartLabel: "Restart"
    property string sleepLabel: "Sleep"
    property string shutdownIcon: "../assets/icons/shutdown.svg"
    property string restartIcon: "../assets/icons/restart.svg"
    property string sleepIcon: "../assets/icons/sleep.svg"
    property string shutdownAction: "shutdown"
    property string restartAction: "restart"
    property string sleepAction: "sleep"

    function environmentText() {
        return environmentTemplate.replace("%1", environmentLabel)
    }
}
