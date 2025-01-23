import QtQuick 2.15

QtObject {
    property QtObject config: ThemeConfig {}

    property string backgroundSource: config.value("copy.backgroundSource")
    property string environmentLabel: config.value("copy.environmentLabel")
    property string environmentTemplate: config.value("copy.environmentTemplate")
    property string fontFamily: config.value("copy.fontFamily")
    property string dateFormat: config.value("copy.dateFormat")
    property string timeFormat: config.value("copy.timeFormat")
    property string usernamePlaceholder: config.value("copy.usernamePlaceholder")
    property string passwordPlaceholder: config.value("copy.passwordPlaceholder")
    property string passwordCharacter: config.value("copy.passwordCharacter")
    property string loginLabel: config.value("copy.loginLabel")
    property string loginFailedMessage: config.value("copy.loginFailedMessage")
    property string shutdownLabel: config.value("copy.shutdownLabel")
    property string restartLabel: config.value("copy.restartLabel")
    property string sleepLabel: config.value("copy.sleepLabel")
    property string shutdownIcon: config.value("copy.shutdownIcon")
    property string restartIcon: config.value("copy.restartIcon")
    property string sleepIcon: config.value("copy.sleepIcon")
    property string shutdownAction: config.value("copy.shutdownAction")
    property string restartAction: config.value("copy.restartAction")
    property string sleepAction: config.value("copy.sleepAction")

    function environmentText() {
        return environmentTemplate.replace("%1", environmentLabel)
    }
}
