// qmllint disable unqualified
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: environmentSelector
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: root.height / 15
    Layout.maximumHeight: root.height / 15
    color: "transparent"

    Layout.leftMargin: 0

    implicitHeight: root.font.pointSize
    implicitWidth: parent.width / 2

    property alias currentIndex: environmentPicker.currentIndex

    Rectangle {
        id: environmentContainer
        anchors.horizontalCenter: parent.horizontalCenter
        height: root.font.pointSize * 3
        width: parent.width
        color: "transparent"

        MouseArea {
            id: environmentTrigger
            anchors.fill: parent
            hoverEnabled: true
            onClicked: environmentMenu.visible ? environmentMenu.close() : environmentMenu.open()
        }

        Text {
            id: environmentDisplayText
            anchors.centerIn: parent
            text: "Environment (" + environmentPicker.currentText + ")"
            color: config.EnvironmentButtonTextColor
            font {
                pointSize: root.font.pointSize * 0.9
                family: root.font.family
            }
            verticalAlignment: Text.AlignVCenter

            Behavior on color {
                ColorAnimation {
                    duration: root.animationDuration
                    easing.type: root.animationEasing
                }
            }
        }

        states: [
            State {
                name: "sessionPressed"
                when: environmentTrigger.pressed
                PropertyChanges {
                    environmentDisplayText.color: Qt.darker(config.HoverEnvironmentButtonTextColor, 1.2)
                }
            },
            State {
                name: "sessionHovered"
                when: environmentTrigger.containsMouse && !environmentTrigger.pressed
                PropertyChanges {
                    environmentDisplayText.color: Qt.lighter(config.HoverEnvironmentButtonTextColor, 1.15)
                }
            }
        ]
    }

    ComboBox {
        id: environmentPicker
        visible: false
        model: sessionModel
        currentIndex: model.lastIndex
        textRole: "name"

        popup: Popup {
            id: environmentMenu
            implicitHeight: menuContent.implicitHeight
            width: environmentSelector.width
            y: environmentContainer.height - 1
            x: -environmentMenu.width / 2 + environmentDisplayText.width / 2
            padding: 10

            onOpened: {
                if (environmentPicker.currentIndex >= 0)
                    menuContent.positionViewAtIndex(environmentPicker.currentIndex, ListView.Contain);
            }

            background: Rectangle {
                radius: 12
                color: config.DropdownBackgroundColor
                layer.enabled: true
            }

            contentItem: ListView {
                id: menuContent
                implicitHeight: contentHeight + 20
                clip: true
                model: sessionModel
                currentIndex: environmentPicker.currentIndex

                delegate: Rectangle {
                    x: 10
                    width: menuContent.width - 20
                    height: delegateText.implicitHeight + 12
                    color: index === environmentPicker.currentIndex ? config.DropdownSelectedBackgroundColor : "transparent"
                    radius: 4

                    Text {
                        id: delegateText
                        anchors.centerIn: parent
                        text: name
                        font {
                            pointSize: root.font.pointSize * 0.8
                            family: root.font.family
                            weight: Font.Normal
                        }
                        color: config.DropdownTextColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            environmentPicker.currentIndex = index;
                            environmentMenu.close();
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
                    duration: root.animationDuration
                    easing.type: root.animationEasing
                }
            }
            exit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: root.animationDuration
                    easing.type: root.animationEasing
                }
            }
        }
    }
}
