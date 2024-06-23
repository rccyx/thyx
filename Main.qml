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
    property string fontFamily: "Inter"

    property date currentDate: new Date()
    property real uiScale: Math.max(0.72, Math.min(width / 1920, height / 1080))
    property real inputWidth: 390 * uiScale
    property real inputHeight: 38 * uiScale
    property real inputPadding: 24 * uiScale
    property real actionWidth: 88 * uiScale
    property real actionHeight: 78 * uiScale

    property color accent: "#13b8b5"
    property color accentHot: "#1fd7d2"
    property color buttonText: "#001413"
    property color textStrong: "#ecffff"
    property color textSoft: "#bdeeed"
    property color textError: "#ffd1d1"
    property color inputIdle: Qt.rgba(0.04, 0.52, 0.50, 0.18)
    property color inputHover: Qt.rgba(0.04, 0.52, 0.50, 0.26)
    property color inputFocus: Qt.rgba(0.05, 0.70, 0.68, 0.28)
    property color inputBorder: Qt.rgba(0.72, 1.0, 1.0, 0.42)
    property color placeholder: Qt.rgba(0.82, 1.0, 1.0, 0.72)

    function inputFill(field) {
        if (field.activeFocus) {
            return inputFocus
        }

        return field.hovered ? inputHover : inputIdle
    }

    function login() {
        if (usernameInput.text.length === 0) {
            usernameInput.forceActiveFocus()
            return
        }

        errorText.text = ""
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

    component CredentialField: TextField {
        id: field

        width: root.inputWidth
        height: root.inputHeight
        color: root.textStrong
        placeholderTextColor: root.placeholder
        selectedTextColor: root.buttonText
        selectionColor: root.accentHot
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        leftPadding: root.inputPadding
        rightPadding: root.inputPadding
        selectByMouse: true
        hoverEnabled: true

        font.family: root.fontFamily
        font.pixelSize: 15 * root.uiScale
        font.weight: Font.DemiBold

        background: Rectangle {
            radius: height / 2
            color: root.inputFill(field)
            border.width: field.activeFocus ? 1 : 0
            border.color: root.inputBorder
        }
    }

    component PowerAction: Item {
        id: action

        property string iconSource: ""
        property string label: ""

        signal activated()

        width: root.actionWidth
        height: root.actionHeight
        opacity: actionArea.containsMouse ? 1.0 : 0.82
        scale: actionArea.pressed ? 0.96 : actionArea.containsMouse ? 1.04 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 10 * root.uiScale

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: action.iconSource
                width: 34 * root.uiScale
                height: 34 * root.uiScale
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.96
            }

            Text {
                width: action.width
                text: action.label
                color: root.textSoft
                horizontalAlignment: Text.AlignHCenter

                font.family: root.fontFamily
                font.pixelSize: 14 * root.uiScale
                font.weight: Font.Medium
            }
        }

        MouseArea {
            id: actionArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                action.activated()
            }
        }
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
        width: root.width
        spacing: 10 * root.uiScale

        Text {
            width: parent.width
            text: Qt.formatDate(root.currentDate, "dddd, MMMM d")
            color: root.textSoft
            horizontalAlignment: Text.AlignHCenter

            font.family: root.fontFamily
            font.pixelSize: 31 * root.uiScale
            font.weight: Font.Medium
        }

        Text {
            width: parent.width
            text: Qt.formatTime(root.currentDate, "HH:mm")
            color: root.textStrong
            horizontalAlignment: Text.AlignHCenter

            font.family: root.fontFamily
            font.pixelSize: 112 * root.uiScale
            font.weight: Font.Black
        }
    }

    Column {
        id: loginBlock

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.46
        width: root.inputWidth
        spacing: 18 * root.uiScale

        CredentialField {
            id: usernameInput

            placeholderText: "Username"

            onAccepted: {
                passwordInput.forceActiveFocus()
            }
        }

        CredentialField {
            id: passwordInput

            placeholderText: "Password"
            echoMode: TextInput.Password
            passwordCharacter: "•"

            onAccepted: {
                root.login()
            }
        }

        Text {
            id: errorText

            width: parent.width
            visible: text.length > 0
            text: ""
            color: root.textError
            horizontalAlignment: Text.AlignHCenter

            font.family: root.fontFamily
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
                color: root.buttonText

                font.family: root.fontFamily
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

        PowerAction {
            iconSource: "icons/shutdown.svg"
            label: "Shutdown"

            onActivated: {
                root.powerOff()
            }
        }

        PowerAction {
            iconSource: "icons/restart.svg"
            label: "Restart"

            onActivated: {
                root.restart()
            }
        }

        PowerAction {
            iconSource: "icons/sleep.svg"
            label: "Sleep"

            onActivated: {
                root.sleep()
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.93
        text: "Environment (" + root.environmentLabel + ")"
        color: root.textSoft
        opacity: 0.92

        font.family: root.fontFamily
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