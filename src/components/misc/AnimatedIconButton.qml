// qmllint disable unqualified

import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: animatedIconButton
    color: "transparent"

    property string iconSource: ""
    property color defaultIconColor: config.SystemButtonsIconsColor
    property color hoverIconColor: config.HoverSystemButtonsIconsColor
    property color pressedIconColor: Qt.darker(config.HoverSystemButtonsIconsColor, 1.2)
    property real iconScale: 0.7
    property bool circular: true
    property alias mouseArea: clickHandler

    signal clicked
    signal pressed
    signal released

    property bool isHovered: clickHandler.containsMouse && !clickHandler.pressed
    property bool isPressed: clickHandler.pressed

    radius: circular ? Math.min(width, height) / 2 : 0

    MouseArea {
        id: clickHandler
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: animatedIconButton.clicked()
        onPressed: animatedIconButton.pressed()
        onReleased: animatedIconButton.released()
    }

    Image {
        id: iconImage
        anchors.centerIn: parent
        width: parent.width * animatedIconButton.iconScale
        height: parent.height * animatedIconButton.iconScale
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        source: animatedIconButton.iconSource
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
        mipmap: true

        ColorOverlay {
            id: iconColorOverlay
            anchors.fill: parent
            source: parent
            color: animatedIconButton.defaultIconColor

            Behavior on color {
                ColorAnimation {
                    duration: root.animationDuration
                    easing.type: root.animationEasing
                }
            }
        }
    }

    states: [
        State {
            name: "pressed"
            when: animatedIconButton.isPressed
            PropertyChanges {
                iconColorOverlay.color: animatedIconButton.pressedIconColor
            }
        },
        State {
            name: "hovered"
            when: animatedIconButton.isHovered
            PropertyChanges {
                iconColorOverlay.color: animatedIconButton.hoverIconColor
            }
        }
    ]

    Keys.onReturnPressed: animatedIconButton.clicked()
    Keys.onEnterPressed: animatedIconButton.clicked()
}
