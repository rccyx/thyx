// qmllint disable unqualified

import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../misc"

Rectangle {
    id: powerControl
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    color: "transparent"

    property int idx: 0
    property string text: ""

    implicitWidth: iconSize
    implicitHeight: iconSize + labelText.implicitHeight + 8

    readonly property int iconSize: root.font.pointSize * 4.5

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
        spacing: 8

        AnimatedIconButton {
            id: iconButton
            width: powerControl.iconSize
            height: powerControl.iconSize
            anchors.horizontalCenter: parent.horizontalCenter

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
                pointSize: root.font.pointSize * 0.9
                family: root.font.family
                weight: Font.Normal
            }
            color: config.SystemButtonsIconsColor
            horizontalAlignment: Text.AlignHCenter
            width: powerControl.iconSize + 20
            wrapMode: Text.WordWrap

            Behavior on color {
                ColorAnimation {
                    duration: config.AnimationDuration || 80
                    easing.type: {
                        switch (config.AnimationEasing) {
                        case "OutCubic":
                            return Easing.OutCubic;
                        case "OutBack":
                            return Easing.OutBack;
                        case "OutQuart":
                        default:
                            return Easing.OutQuart;
                        }
                    }
                }
            }

            states: [
                State {
                    name: "labelHovered"
                    when: iconButton.isHovered
                    PropertyChanges {
                        labelText.color: config.HoverSystemButtonsIconsColor
                    }
                },
                State {
                    name: "labelPressed"
                    when: iconButton.isPressed
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
