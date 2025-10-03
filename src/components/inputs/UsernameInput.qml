// qmllint disable unqualified

import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0 as SDDM

Rectangle {
    id: userInputContainer
    implicitHeight: root.font.pointSize * 4.5
    implicitWidth: parent.width / 2
    anchors.horizontalCenter: parent.horizontalCenter
    color: "transparent"

    property alias username: userInput
    property Item nextDown
    signal accepted(string username)

    SDDM.TextConstants {
        id: loginConstants
    }

    Rectangle {
        id: inputFrame
        anchors.centerIn: parent
        width: parent.width
        height: root.font.pointSize * 3
        radius: 24
        color: Qt.rgba(parseInt(config.LoginFieldBackgroundColor.slice(1, 3), 16) / 255, parseInt(config.LoginFieldBackgroundColor.slice(3, 5), 16) / 255, parseInt(config.LoginFieldBackgroundColor.slice(5, 7), 16) / 255, 0.25)
        border.width: 0
        border.color: "transparent"

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.15)
        }

        TextInput {
            id: userInput
            anchors.centerIn: parent
            width: parent.width - 16
            height: parent.height
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            z: 1

            text: userPicker.currentText

            font {
                bold: true
                pointSize: root.font.pointSize
                family: root.font.family
                capitalization: config.AllowUppercaseLettersInUsernames == "false" ? Font.AllLowercase : Font.MixedCase
            }
            color: config.LoginFieldTextColor
            selectByMouse: true
            renderType: Text.QtRendering
            onFocusChanged: if (focus)
                selectAll()
            onAccepted: userInputContainer.accepted(userInput.text)

            KeyNavigation.down: userInputContainer.nextDown

            Rectangle {
                id: userPlaceholder
                anchors.fill: parent
                color: "transparent"
                visible: userInput.text === ""

                Text {
                    anchors.centerIn: parent
                    text: loginConstants.userName
                    color: config.PlaceholderTextColor
                    font: userInput.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Behavior on border.color {
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
                name: "userInputFocused"
                when: userInput.activeFocus
                PropertyChanges {
                    inputFrame.border.color: "#8ab4f8"
                }
                PropertyChanges {
                    userInput.color: config.LoginFieldTextColor
                }
            }
        ]
    }

    ComboBox {
        id: userPicker
        visible: false
        model: userModel
        currentIndex: model.lastIndex
        textRole: "name"
        onActivated: userInput.text = currentText

        popup: Popup {
            id: userMenu
            visible: false  // Disable dropdown completely
            implicitHeight: 0
            width: 0
            y: inputFrame.height - userInput.height / 3
            x: 0
            padding: 10

            background: Rectangle {
                radius: 12
                color: config.DropdownBackgroundColor
                border.width: 1
                border.color: config.DropdownBorderColor
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 4
                    radius: 12
                    samples: 24
                    color: Qt.rgba(0, 0, 0, 0.3)
                }
            }

            contentItem: ListView {
                id: userListContent
                implicitHeight: contentHeight + 20
                clip: true
                model: userPicker.popup.visible ? userPicker.delegateModel : null
                currentIndex: userPicker.highlightedIndex

                delegate: Rectangle {
                    width: ListView.view.width - 20
                    height: delegateUserText.implicitHeight + 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: ListView.view.currentIndex === index ? config.DropdownSelectedBackgroundColor : "transparent"
                    radius: 8
                    border.width: ListView.view.currentIndex === index ? 1 : 0
                    border.color: config.DropdownSelectedBorderColor

                    Text {
                        id: delegateUserText
                        anchors.centerIn: parent
                        text: name
                        font {
                            pointSize: root.font.pointSize * 0.9
                            capitalization: Font.AllLowercase
                            family: root.font.family
                            weight: Font.Medium
                        }
                        color: ListView.view.currentIndex === index ? config.DropdownSelectedTextColor : config.DropdownTextColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            userPicker.currentIndex = index;
                            userInput.text = userPicker.currentText;
                            userMenu.close();
                        }
                    }
                }

                ScrollIndicator.vertical: ScrollIndicator {}
            }

            enter: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 80
                }
            }
        }
    }
}
