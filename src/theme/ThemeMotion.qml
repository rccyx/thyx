import QtQuick 2.15

QtObject {
    property QtObject config: ThemeConfig {}

    property real actionIdleOpacity: config.numberValue("motion.actionIdleOpacity")
    property real actionHoverOpacity: config.numberValue("motion.actionHoverOpacity")
    property real actionIdleScale: config.numberValue("motion.actionIdleScale")
    property real actionHoverScale: config.numberValue("motion.actionHoverScale")
    property real actionPressedScale: config.numberValue("motion.actionPressedScale")
    property real actionAnimationMs: config.numberValue("motion.actionAnimationMs")
}
