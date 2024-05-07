import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import SddmComponents 2.0 as SDDM

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#0a0a0a"

    property string backgroundSource: "wallpapers/sd.jpg"
    property var config: ({})
    property date currentDate: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentDate = new Date()
        }
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: backgroundSource
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.45
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: 480
        spacing: 28

        Text {
            text: "OSYX"
            color: "#ffffff"
            font.pixelSize: 78
            font.weight: Font.Bold
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Sign in"
            color: "#e0e0e0"
            font.pixelSize: 22
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 400
            height: 54
            color: "#1f1f2b"
            radius: 10
            border.width: 1
            border.color: usernameInput.activeFocus ? "#60a5fa" : "#ffffff18"

            TextInput {
                id: usernameInput
                anchors.fill: parent
                anchors.margins: 14
                color: "#ffffff"
                font.pixelSize: 17
                placeholderText: "Username"
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 400
            height: 54
            color: "#1f1f2b"
            radius: 10
            border.width: 1
            border.color: passwordInput.activeFocus ? "#60a5fa" : "#ffffff18"

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.margins: 14
                color: "#ffffff"
                font.pixelSize: 17
                echoMode: TextInput.Password
                placeholderText: "Password"
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 400
            height: 58
            color: signInArea.pressed ? "#1d4ed8" : signInArea.containsMouse ? "#3b82f6" : "#2563eb"
            radius: 30

            Text {
                text: "Sign in"
                color: "#ffffff"
                font.pixelSize: 18
                font.weight: Font.Medium
                anchors.centerIn: parent
            }

            MouseArea {
                id: signInArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    sddm.login(usernameInput.text, passwordInput.text, 0)
                }
            }
        }

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 48

            Text {
                text: "⏻"
                color: "#aaaaaa"
                font.pixelSize: 38
            }
            Text {
                text: "↺"
                color: "#aaaaaa"
                font.pixelSize: 38
            }
            Text {
                text: "⏾"
                color: "#aaaaaa"
                font.pixelSize: 38
            }
        }

        Text {
            text: Qt.formatTime(root.currentDate, "HH:mm")
            color: "#f0f0f0"
            font.pixelSize: 64
            font.weight: Font.Light
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: Qt.formatDate(root.currentDate, "MMMM d, yyyy")
            color: "#888888"
            font.pixelSize: 17
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
