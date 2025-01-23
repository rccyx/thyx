import QtQuick 2.15

QtObject {
    id: root

    property QtObject config: ThemeConfig {}
    property QtObject copy: ThemeCopy { config: root.config }
    property QtObject layout: ThemeLayout { config: root.config }
    property QtObject motion: ThemeMotion { config: root.config }
    property QtObject palette: ThemePalette { config: root.config }

    function scaleFor(width, height) {
        return Math.max(layout.minScale, Math.min(width / layout.designWidth, height / layout.designHeight))
    }

    function pixelSize(size, scale) {
        return Math.round(size * scale)
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
