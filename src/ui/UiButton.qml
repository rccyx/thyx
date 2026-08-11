import QtQuick 2.15

Rectangle {
    id: button

    implicitHeight: basePointSize * UiTokens.control_height_em
    height: implicitHeight
    radius: UiTokens.radius_pill
    color: defaultColor

    property string text: ""
    property color defaultColor: "transparent"
    property color hoverColor: defaultColor
    property color pressedColor: hoverColor
    property color textColor: "#ffffff"
    property int basePointSize: 13
    property string fontFamily: ""
    property int fontWeight: Font.Bold
    property int motionDuration: 80
    property int motionEasing: Easing.OutQuart
    readonly property bool hovered: pressable.hovered
    readonly property bool pressed: pressable.pressed

    signal clicked

    UiPressable {
        id: pressable
        anchors.fill: parent
        onClicked: button.clicked()
    }

    Text {
        anchors.centerIn: parent
        text: button.text
        color: button.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            pointSize: button.basePointSize * UiTokens.text_lg
            family: button.fontFamily
            weight: button.fontWeight
        }
    }

    states: [
        State {
            name: "pressed"
            when: button.pressed
            PropertyChanges {
                button.color: button.pressedColor
            }
        },
        State {
            name: "hovered"
            when: button.hovered
            PropertyChanges {
                button.color: button.hoverColor
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"

            ColorAnimation {
                target: button
                property: "color"
                duration: button.motionDuration
                easing.type: button.motionEasing
            }
        }
    ]
}
