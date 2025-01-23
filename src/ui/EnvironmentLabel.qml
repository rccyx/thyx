import QtQuick 2.15

Text {
    id: root

    property real scaleFactor: 1
    property var themeData
    property int scaledPixelSize: themeData.pixelSize(themeData.layout.environmentSize, scaleFactor)

    text: themeData.copy.environmentText()
    color: themeData.palette.textSoft
    opacity: themeData.palette.environmentOpacity

    font.family: themeData.copy.fontFamily
    font.pixelSize: scaledPixelSize
    font.weight: Font.Medium
}
