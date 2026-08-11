// qmllint disable unqualified

import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../ui"

Rectangle {
    id: powerControl
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    color: "transparent"

    property int idx: 0
    property string text: ""

    implicitWidth: iconSize
    implicitHeight: iconSize + labelText.implicitHeight + UiTokens.spacing_sm

    readonly property int iconSize: root.font.pointSize * UiTokens.icon_button_size_em

    function activate() {
        if (powerControl.idx === 0)
            sddm.powerOff();
        else if (powerControl.idx === 1)
            sddm.reboot();
        else if (powerControl.idx === 2)
            sddm.suspend();
    }

    Column {
        anchors.centerIn: parent
        spacing: UiTokens.spacing_sm

        UiIconButton {
            id: iconButton
            width: powerControl.iconSize
            height: powerControl.iconSize
            anchors.horizontalCenter: parent.horizontalCenter
            defaultIconColor: config.SystemButtonsIconsColor
            hoverIconColor: config.HoverSystemButtonsIconsColor
            pressedIconColor: Qt.darker(config.HoverSystemButtonsIconsColor, 1.2)
            motionDuration: root.animationDuration
            motionEasing: root.animationEasing

            iconSource: {
                switch (powerControl.idx) {
                case 0:
                    return Qt.resolvedUrl("../../../icons/shutdown.svg");
                case 1:
                    return Qt.resolvedUrl("../../../icons/restart.svg");
                case 2:
                    return Qt.resolvedUrl("../../../icons/sleep.svg");
                default:
                    return Qt.resolvedUrl("../../../icons/shutdown.svg");
                }
            }

            onClicked: powerControl.activate()
        }

        Text {
            id: labelText
            anchors.horizontalCenter: parent.horizontalCenter
            text: powerControl.text || ""
            font {
                pointSize: root.font.pointSize * UiTokens.text_md
                family: root.font.family
                weight: Font.Normal
            }
            color: config.SystemButtonsIconsColor
            horizontalAlignment: Text.AlignHCenter
            width: powerControl.iconSize + 20
            wrapMode: Text.WordWrap

            Behavior on color {
                ColorAnimation {
                    duration: root.animationDuration
                    easing.type: root.animationEasing
                }
            }

            states: [
                State {
                    name: "labelHovered"
                    when: iconButton.hovered
                    PropertyChanges {
                        labelText.color: config.HoverSystemButtonsIconsColor
                    }
                },
                State {
                    name: "labelPressed"
                    when: iconButton.pressed
                    PropertyChanges {
                        labelText.color: Qt.darker(config.HoverSystemButtonsIconsColor, 1.2)
                    }
                }
            ]
        }
    }

    Keys.onReturnPressed: powerControl.activate()
    Keys.onEnterPressed: powerControl.activate()
}
