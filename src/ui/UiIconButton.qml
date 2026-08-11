import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: iconButton

    color: "transparent"
    radius: circular ? Math.min(width, height) / 2 : 0

    property string iconSource: ""
    property color defaultIconColor: "#ffffff"
    property color hoverIconColor: defaultIconColor
    property color pressedIconColor: hoverIconColor
    property real iconScale: UiTokens.icon_scale
    property bool circular: true
    property int motionDuration: 80
    property int motionEasing: Easing.OutQuart
    property alias mouseArea: pressable.mouseArea
    readonly property bool hovered: pressable.hovered
    readonly property bool pressed: pressable.pressed

    signal clicked
    signal pressStarted
    signal released

    UiPressable {
        id: pressable
        anchors.fill: parent

        onClicked: iconButton.clicked()
        onPressStarted: iconButton.pressStarted()
        onReleased: iconButton.released()
    }

    Image {
        id: iconImage
        anchors.centerIn: parent
        width: parent.width * iconButton.iconScale
        height: parent.height * iconButton.iconScale
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        source: iconButton.iconSource
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
        mipmap: true

        ColorOverlay {
            id: iconColorOverlay
            anchors.fill: parent
            source: parent
            color: iconButton.defaultIconColor

            Behavior on color {
                ColorAnimation {
                    duration: iconButton.motionDuration
                    easing.type: iconButton.motionEasing
                }
            }
        }
    }

    states: [
        State {
            name: "pressed"
            when: iconButton.pressed
            PropertyChanges {
                iconColorOverlay.color: iconButton.pressedIconColor
            }
        },
        State {
            name: "hovered"
            when: iconButton.hovered
            PropertyChanges {
                iconColorOverlay.color: iconButton.hoverIconColor
            }
        }
    ]
}
