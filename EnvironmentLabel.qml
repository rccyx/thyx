import QtQuick 2.15

Text {
    id: root

    property real scaleFactor: 1
    property var themeData

    text: "Environment (" + themeData.copy.environmentLabel + ")"
    color: themeData.palette.textSoft
    opacity: 0.92

    font.family: themeData.copy.fontFamily
    font.pixelSize: themeData.layout.environmentSize * scaleFactor
    font.weight: Font.Medium
}
