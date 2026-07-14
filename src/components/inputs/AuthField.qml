// qmllint disable unqualified

import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: authField
    implicitHeight: root.font.pointSize * 4.5
    implicitWidth: parent.width / 2
    anchors.horizontalCenter: parent.horizontalCenter
    color: "transparent"

    property alias input: textInput
    property string placeholderText: ""
    property string initialText: ""
    property int echoMode: TextInput.Normal
    property bool initialFocus: false
    property Item nextDown

    Rectangle {
        id: inputFrame
        anchors.centerIn: parent
        width: parent.width
        height: root.font.pointSize * 3
        radius: 24
        color: config.InputFieldBackgroundColor

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.15)
        }

        TextInput {
            id: textInput
            anchors.centerIn: parent
            width: parent.width - 16
            height: parent.height
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            z: 1

            text: authField.initialText
            echoMode: authField.echoMode
            focus: authField.initialFocus

            font {
                pointSize: root.font.pointSize
                family: root.font.family
                weight: Font.Bold
            }

            color: config.InputFieldTextColor
            selectByMouse: true
            renderType: Text.QtRendering
            KeyNavigation.down: authField.nextDown

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                visible: textInput.text === ""

                Text {
                    anchors.centerIn: parent
                    text: authField.placeholderText
                    color: config.PlaceholderTextColor
                    font: textInput.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
