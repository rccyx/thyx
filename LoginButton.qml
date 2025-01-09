import QtQuick 2.15

Rectangle {
    id: root

    property var themeData
    property real scaleFactor: 1

    signal activated()

    width: themeData.layout.inputWidth * scaleFactor
    height: themeData.layout.loginHeight * scaleFactor
    radius: height / 2
    color: themeData.loginFill(buttonArea.pressed, buttonArea.containsMouse)

    Text {
        anchors.centerIn: parent
        text: root.themeData.copy.loginLabel
        color: root.themeData.palette.buttonText

        font.family: root.themeData.copy.fontFamily
        font.pixelSize: root.themeData.layout.loginSize * root.scaleFactor
        font.weight: Font.Bold
    }

    MouseArea {
        id: buttonArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.activated()
    }
}
