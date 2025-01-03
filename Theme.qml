import QtQuick 2.15

QtObject {
    id: theme

    property string backgroundSource: "../../../wl.jpg"
    property string environmentLabel: "Hyprland"
    property string fontFamily: "Inter"

    property string dateFormat: "dddd, MMMM d"
    property string timeFormat: "HH:mm"

    property string usernamePlaceholder: "Username"
    property string passwordPlaceholder: "Password"
    property string loginLabel: "Login"
    property string loginFailedMessage: "Login failed"

    property string shutdownLabel: "Shutdown"
    property string restartLabel: "Restart"
    property string sleepLabel: "Sleep"

    property string shutdownIcon: "icons/shutdown.svg"
    property string restartIcon: "icons/restart.svg"
    property string sleepIcon: "icons/sleep.svg"

    property real designWidth: 1920
    property real designHeight: 1080
    property real minScale: 0.72

    property real clockY: 0.135
    property real loginY: 0.46
    property real powerY: 0.79
    property real environmentY: 0.93

    property real clockSpacing: 10
    property real loginSpacing: 18
    property real powerSpacing: 70
    property real powerContentSpacing: 10

    property real inputWidth: 390
    property real inputHeight: 38
    property real inputPadding: 24
    property real loginHeight: 39

    property real actionWidth: 88
    property real actionHeight: 78
    property real actionIconSize: 34

    property real dateSize: 31
    property real timeSize: 112
    property real inputSize: 15
    property real loginSize: 15
    property real errorSize: 13
    property real actionLabelSize: 14
    property real environmentSize: 15

    property color base: "#020707"
    property color accent: "#13b8b5"
    property color accentHot: "#1fd7d2"
    property color accentPressed: "#0d918e"

    property color buttonText: "#001413"
    property color textStrong: "#ecffff"
    property color textSoft: "#bdeeed"
    property color textError: "#ffd1d1"
    property color placeholder: Qt.rgba(0.82, 1.0, 1.0, 0.72)

    property color inputIdle: Qt.rgba(0.04, 0.52, 0.50, 0.18)
    property color inputHover: Qt.rgba(0.04, 0.52, 0.50, 0.26)
    property color inputFocus: Qt.rgba(0.05, 0.70, 0.68, 0.28)
    property color inputBorder: Qt.rgba(0.72, 1.0, 1.0, 0.42)

    property color tint: "#001816"
    property real tintOpacity: 0.28
    property color shade: "#000000"
    property real shadeOpacity: 0.18

    property color gradientTop: Qt.rgba(0.0, 0.0, 0.0, 0.47)
    property color gradientUpper: Qt.rgba(0.0, 0.0, 0.0, 0.09)
    property color gradientLower: Qt.rgba(0.0, 0.0, 0.0, 0.14)
    property color gradientBottom: Qt.rgba(0.0, 0.0, 0.0, 0.54)

    property real actionIdleOpacity: 0.82
    property real actionHoverOpacity: 1.0
    property real actionIdleScale: 1.0
    property real actionHoverScale: 1.04
    property real actionPressedScale: 0.96
    property real actionAnimationMs: 120

    function scaleFor(width, height) {
        return Math.max(minScale, Math.min(width / designWidth, height / designHeight))
    }

    function inputFill(hasFocus, isHovered) {
        if (hasFocus) {
            return inputFocus
        }

        return isHovered ? inputHover : inputIdle
    }

    function loginFill(isPressed, isHovered) {
        if (isPressed) {
            return accentPressed
        }

        return isHovered ? accentHot : accent
    }

    function actionOpacity(isHovered) {
        return isHovered ? actionHoverOpacity : actionIdleOpacity
    }

    function actionScale(isPressed, isHovered) {
        if (isPressed) {
            return actionPressedScale
        }

        return isHovered ? actionHoverScale : actionIdleScale
    }
}
