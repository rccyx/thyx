import QtQuick 2.15

QtObject {
    property QtObject config: ThemeConfig {}

    property color base: config.colorValue("palette.base")
    property color accent: config.colorValue("palette.accent")
    property color accentHot: config.colorValue("palette.accentHot")
    property color accentPressed: config.colorValue("palette.accentPressed")
    property color buttonText: config.colorValue("palette.buttonText")
    property color textStrong: config.colorValue("palette.textStrong")
    property color textSoft: config.colorValue("palette.textSoft")
    property color textError: config.colorValue("palette.textError")
    property color placeholder: config.colorValue("palette.placeholder")
    property color inputIdle: config.colorValue("palette.inputIdle")
    property color inputHover: config.colorValue("palette.inputHover")
    property color inputFocus: config.colorValue("palette.inputFocus")
    property color inputBorder: config.colorValue("palette.inputBorder")
    property color tint: config.colorValue("palette.tint")
    property real tintOpacity: config.numberValue("palette.tintOpacity")
    property color shade: config.colorValue("palette.shade")
    property real shadeOpacity: config.numberValue("palette.shadeOpacity")
    property real actionIconOpacity: config.numberValue("palette.actionIconOpacity")
    property real environmentOpacity: config.numberValue("palette.environmentOpacity")
    property real gradientTopPosition: config.numberValue("palette.gradientTopPosition")
    property color gradientTop: config.colorValue("palette.gradientTop")
    property real gradientUpperPosition: config.numberValue("palette.gradientUpperPosition")
    property color gradientUpper: config.colorValue("palette.gradientUpper")
    property real gradientLowerPosition: config.numberValue("palette.gradientLowerPosition")
    property color gradientLower: config.colorValue("palette.gradientLower")
    property real gradientBottomPosition: config.numberValue("palette.gradientBottomPosition")
    property color gradientBottom: config.colorValue("palette.gradientBottom")
}
