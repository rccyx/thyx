// qmllint disable unqualified

import QtQuick 2.15
import "../../ui"

Rectangle {
    id: authField
    implicitHeight: root.font.pointSize * UiTokens.field_frame_height_em
    implicitWidth: parent.width * UiTokens.field_width_ratio
    anchors.horizontalCenter: parent.horizontalCenter
    color: "transparent"

    property alias input: textInput
    property string placeholderText: ""
    property string initialText: ""
    property int echoMode: TextInput.Normal
    property bool initialFocus: false
    property Item nextDown

    UiFieldFrame {
        id: inputFrame
        anchors.centerIn: parent
        width: parent.width
        basePointSize: root.font.pointSize
        fillColor: config.InputFieldBackgroundColor

        TextInput {
            id: textInput
            anchors.fill: parent
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

            Text {
                anchors.centerIn: parent
                text: authField.placeholderText
                color: config.PlaceholderTextColor
                font: textInput.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: textInput.text === ""
            }
        }
    }
}
