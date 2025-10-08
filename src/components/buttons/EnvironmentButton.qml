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

    property string formAlignment: config.FormPosition
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
        }

        Rectangle {
            id: focusIndicator
            anchors.bottom: parent.bottom
            width: environmentDisplayText.implicitWidth
            height: environmentContainer.activeFocus ? 2 : 0
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter

            Behavior on height {
                NumberAnimation {
                    duration: config.AnimationDuration * 2 || 160
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
            },
            State {
                name: "sessionFocused"
                when: environmentContainer.activeFocus
                PropertyChanges {
                    environmentDisplayText.color: config.HoverEnvironmentButtonTextColor
                }
            }
        ]

        Keys.onPressed: function (event) {
            if ((event.key == Qt.Key_Left || event.key == Qt.Key_Right) && !environmentMenu.visible) {
                environmentMenu.open();
            }
        }
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

            background: Rectangle {
                radius: 12
                color: config.DropdownBackgroundColor
                layer.enabled: true
            }

            contentItem: ListView {
                id: menuContent
                implicitHeight: contentHeight + 20
                clip: true
                model: environmentPicker.popup.visible ? environmentPicker.delegateModel : null
                currentIndex: environmentPicker.highlightedIndex

                delegate: Rectangle {
                    width: menuContent.width - 20
                    height: delegateText.implicitHeight + 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: menuContent.currentIndex === index ? config.DropdownSelectedBackgroundColor : "transparent"
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
                    duration: 200
                }
            }
            exit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 150
                }
            }
        }
    }
}
