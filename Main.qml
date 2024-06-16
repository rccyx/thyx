import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0 as SDDM

Rectangle {
    id: root

    width: Screen.width
    height: Screen.height
    color: "#020707"

    property string backgroundSource: "../../../wl.jpg"
    property string environmentLabel: "Hyprland"
    property date currentDate: new Date()
    property real uiScale: Math.max(0.72, Math.min(width / 1920, height / 1080))
    property color accent: "#13b8b5"
    property color accentHot: "#1fd7d2"
    property color textStrong: "#ecffff"
    property color textSoft: "#bdeeed"

    function login() {
        if (usernameInput.text.length === 0) {
            usernameInput.forceActiveFocus()
            return
        }

        sddm.login(usernameInput.text, passwordInput.text, 0)
    }

    function powerOff() {
        sddm.powerOff()
    }

    function restart() {
        sddm.reboot()
    }

    function sleep() {
        sddm.suspend()
    }

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
        source: root.backgroundSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#001816"
        opacity: 0.28
    }

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#78000000"
            }

            GradientStop {
                position: 0.34
                color: "#18000000"
            }

            GradientStop {
                position: 0.62
                color: "#24000000"
            }

            GradientStop {
                position: 1.0
                color: "#8a000000"
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.18
    }

    Column {
        id: clockBlock

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.135
        spacing: 10 * root.uiScale

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.currentDate, "dddd, MMMM d")
            color: root.textSoft
            font.family: "Inter"
            font.pixelSize: 31 * root.uiScale
            font.weight: Font.Medium
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.currentDate, "HH:mm")
            color: root.textStrong
            font.family: "Inter"
            font.pixelSize: 112 * root.uiScale
            font.weight: Font.Black
        }
    }

    Column {
        id: loginBlock

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.46
        width: 390 * root.uiScale
        spacing: 18 * root.uiScale

        TextField {
            id: usernameInput

            width: parent.width
            height: 38 * root.uiScale
            color: root.textStrong
            placeholderText: "Username"
            placeholderTextColor: Qt.rgba(0.82, 1.0, 1.0, 0.72)
            selectedTextColor: "#001414"
            selectionColor: root.accentHot
            font.family: "Inter"
            font.pixelSize: 15 * root.uiScale
            font.weight: Font.DemiBold
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 24 * root.uiScale
            rightPadding: 24 * root.uiScale
            selectByMouse: true

            background: Rectangle {
                radius: height / 2
                color: usernameInput.activeFocus
                    ? Qt.rgba(0.05, 0.70, 0.68, 0.28)
                    : Qt.rgba(0.04, 0.52, 0.50, usernameInput.hovered ? 0.26 : 0.18)
                border.width: usernameInput.activeFocus ? 1 : 0
                border.color: Qt.rgba(0.72, 1.0, 1.0, 0.42)
            }

            Keys.onReturnPressed: passwordInput.forceActiveFocus()
            Keys.onEnterPressed: passwordInput.forceActiveFocus()
        }

        TextField {
            id: passwordInput

            width: parent.width
            height: 38 * root.uiScale
            color: root.textStrong
            placeholderText: "Password"
            placeholderTextColor: Qt.rgba(0.82, 1.0, 1.0, 0.72)
            selectedTextColor: "#001414"
            selectionColor: root.accentHot
            font.family: "Inter"
            font.pixelSize: 15 * root.uiScale
            font.weight: Font.DemiBold
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 24 * root.uiScale
            rightPadding: 24 * root.uiScale
            echoMode: TextInput.Password
            passwordCharacter: "•"
            selectByMouse: true

            background: Rectangle {
                radius: height / 2
                color: passwordInput.activeFocus
                    ? Qt.rgba(0.05, 0.70, 0.68, 0.28)
                    : Qt.rgba(0.04, 0.52, 0.50, passwordInput.hovered ? 0.26 : 0.18)
                border.width: passwordInput.activeFocus ? 1 : 0
                border.color: Qt.rgba(0.72, 1.0, 1.0, 0.42)
            }

            Keys.onReturnPressed: root.login()
            Keys.onEnterPressed: root.login()
        }

        Text {
            id: errorText

            anchors.horizontalCenter: parent.horizontalCenter
            visible: text.length > 0
            text: ""
            color: "#ffd1d1"
            font.family: "Inter"
            font.pixelSize: 13 * root.uiScale
            font.weight: Font.Medium
        }

        Rectangle {
            id: loginButton

            width: parent.width
            height: 39 * root.uiScale
            radius: height / 2
            color: loginArea.pressed
                ? "#0d918e"
                : loginArea.containsMouse ? root.accentHot : root.accent

            Text {
                anchors.centerIn: parent
                text: "Login"
                color: "#001413"
                font.family: "Inter"
                font.pixelSize: 15 * root.uiScale
                font.weight: Font.Bold
            }

            MouseArea {
                id: loginArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.login()
                }
            }
        }
    }

    Row {
        id: powerBlock

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.79
        spacing: 70 * root.uiScale

        Item {
            width: 88 * root.uiScale
            height: 78 * root.uiScale
            opacity: shutdownArea.containsMouse ? 1.0 : 0.82

            Column {
                anchors.centerIn: parent
                spacing: 10 * root.uiScale

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "icons/shutdown.svg"
                    width: 34 * root.uiScale
                    height: 34 * root.uiScale
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: 0.96
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Shutdown"
                    color: root.textSoft
                    font.family: "Inter"
                    font.pixelSize: 14 * root.uiScale
                    font.weight: Font.Medium
                }
            }

            MouseArea {
                id: shutdownArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.powerOff()
                }
            }
        }

        Item {
            width: 88 * root.uiScale
            height: 78 * root.uiScale
            opacity: restartArea.containsMouse ? 1.0 : 0.82

            Column {
                anchors.centerIn: parent
                spacing: 10 * root.uiScale

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "icons/restart.svg"
                    width: 34 * root.uiScale
                    height: 34 * root.uiScale
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: 0.96
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Restart"
                    color: root.textSoft
                    font.family: "Inter"
                    font.pixelSize: 14 * root.uiScale
                    font.weight: Font.Medium
                }
            }

            MouseArea {
                id: restartArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.restart()
                }
            }
        }

        Item {
            width: 88 * root.uiScale
            height: 78 * root.uiScale
            opacity: sleepArea.containsMouse ? 1.0 : 0.82

            Column {
                anchors.centerIn: parent
                spacing: 10 * root.uiScale

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "icons/sleep.svg"
                    width: 34 * root.uiScale
                    height: 34 * root.uiScale
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: 0.96
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Sleep"
                    color: root.textSoft
                    font.family: "Inter"
                    font.pixelSize: 14 * root.uiScale
                    font.weight: Font.Medium
                }
            }

            MouseArea {
                id: sleepArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.sleep()
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.93
        text: "Environment (" + root.environmentLabel + ")"
        color: root.textSoft
        opacity: 0.92
        font.family: "Inter"
        font.pixelSize: 15 * root.uiScale
        font.weight: Font.Medium
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            passwordInput.text = ""
            errorText.text = "Login failed"
            passwordInput.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        usernameInput.forceActiveFocus()
    }
}