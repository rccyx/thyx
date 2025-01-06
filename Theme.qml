import QtQuick 2.15

QtObject {
    id: root

    property QtObject copy: ThemeCopy {}
    property QtObject layout: ThemeLayout {}
    property QtObject motion: ThemeMotion {}
    property QtObject palette: ThemePalette {}

    function scaleFor(width, height) {
        return Math.max(layout.minScale, Math.min(width / layout.designWidth, height / layout.designHeight))
    }

    function inputFill(hasFocus, isHovered) {
        if (hasFocus) return palette.inputFocus

        return isHovered ? palette.inputHover : palette.inputIdle
    }

    function loginFill(isPressed, isHovered) {
        if (isPressed) return palette.accentPressed

        return isHovered ? palette.accentHot : palette.accent
    }

    function actionOpacity(isHovered) {
        return isHovered ? motion.actionHoverOpacity : motion.actionIdleOpacity
    }

    function actionScale(isPressed, isHovered) {
        if (isPressed) return motion.actionPressedScale

        return isHovered ? motion.actionHoverScale : motion.actionIdleScale
    }
}
