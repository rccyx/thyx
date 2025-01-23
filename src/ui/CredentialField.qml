import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: root

    property var themeData
    property real scaleFactor: 1
    property int scaledPixelSize: themeData.pixelSize(themeData.layout.inputSize, scaleFactor)

    width: themeData.layout.inputWidth * scaleFactor
    height: themeData.layout.inputHeight * scaleFactor
    color: themeData.palette.textStrong
    placeholderTextColor: themeData.palette.placeholder
    selectedTextColor: themeData.palette.buttonText
    selectionColor: themeData.palette.accentHot
    horizontalAlignment: TextInput.AlignHCenter
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: themeData.layout.inputPadding * scaleFactor
    rightPadding: themeData.layout.inputPadding * scaleFactor
    selectByMouse: true
    hoverEnabled: true

    font.family: themeData.copy.fontFamily
    font.pixelSize: scaledPixelSize
    font.weight: Font.DemiBold

    background: Rectangle {
        radius: height / 2
        color: root.themeData.inputFill(root.activeFocus, root.hovered)
        border.width: root.activeFocus ? root.themeData.layout.inputBorderFocusWidth : 0
        border.color: root.themeData.palette.inputBorder
    }
}
