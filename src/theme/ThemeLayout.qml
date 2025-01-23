import QtQuick 2.15

QtObject {
    property QtObject config: ThemeConfig {}

    property real designWidth: config.numberValue("layout.designWidth")
    property real designHeight: config.numberValue("layout.designHeight")
    property real minScale: config.numberValue("layout.minScale")
    property real clockY: config.numberValue("layout.clockY")
    property real loginY: config.numberValue("layout.loginY")
    property real powerY: config.numberValue("layout.powerY")
    property real environmentY: config.numberValue("layout.environmentY")
    property real clockSpacing: config.numberValue("layout.clockSpacing")
    property real loginSpacing: config.numberValue("layout.loginSpacing")
    property real powerSpacing: config.numberValue("layout.powerSpacing")
    property real powerContentSpacing: config.numberValue("layout.powerContentSpacing")
    property real inputWidth: config.numberValue("layout.inputWidth")
    property real inputHeight: config.numberValue("layout.inputHeight")
    property real inputPadding: config.numberValue("layout.inputPadding")
    property real inputBorderFocusWidth: config.numberValue("layout.inputBorderFocusWidth")
    property real loginHeight: config.numberValue("layout.loginHeight")
    property real actionWidth: config.numberValue("layout.actionWidth")
    property real actionHeight: config.numberValue("layout.actionHeight")
    property real actionIconSize: config.numberValue("layout.actionIconSize")
    property real dateSize: config.numberValue("layout.dateSize")
    property real timeSize: config.numberValue("layout.timeSize")
    property real inputSize: config.numberValue("layout.inputSize")
    property real loginSize: config.numberValue("layout.loginSize")
    property real errorSize: config.numberValue("layout.errorSize")
    property real actionLabelSize: config.numberValue("layout.actionLabelSize")
    property real environmentSize: config.numberValue("layout.environmentSize")
}
