import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0 as SDDM

Rectangle {
    id: root

    width: Screen.width
    height: Screen.height
    color: theme.base

    property date currentDate: new Date()
    property real uiScale: theme.scaleFor(width, height)

    Theme {
        id: theme
    }

    function login() {
        if (usernameInput.text.length === 0) {
            usernameInput.forceActiveFocus()
            return
        }

        errorText.text = ""
        sddm.login(usernameInput.text, passwordInput.text, 0)
    }

    function runPowerAction(action) {
        switch (action) {
        case "shutdown":
            sddm.powerOff()
            break
        case "restart":
            sddm.reboot()
            break
        case "sleep":
            sddm.suspend()
            break
        }
    }

    component CredentialField: TextField {
        id: field

        property var themeData
        property real scaleFactor: 1

        width: themeData.inputWidth * scaleFactor
        height: themeData.inputHeight * scaleFactor
        color: themeData.textStrong
        placeholderTextColor: themeData.placeholder
        selectedTextColor: themeData.buttonText
        selectionColor: themeData.accentHot
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        leftPadding: themeData.inputPadding * scaleFactor
        rightPadding: themeData.inputPadding * scaleFactor
        selectByMouse: true
        hoverEnabled: true

        font.family: themeData.fontFamily
        font.pixelSize: themeData.inputSize * scaleFactor
        font.weight: Font.DemiBold

        background: Rectangle {
            radius: height / 2
            color: themeData.inputFill(field.activeFocus, field.hovered)
            border.width: field.activeFocus ? 1 : 0
            border.color: themeData.inputBorder
        }
    }

    component LoginButton: Rectangle {
        id: button

        property var themeData
        property real scaleFactor: 1

        signal activated()

        width: themeData.inputWidth * scaleFactor
        height: themeData.loginHeight * scaleFactor
        radius: height / 2
        color: themeData.loginFill(buttonArea.pressed, buttonArea.containsMouse)

        Text {
            anchors.centerIn: parent
            text: themeData.loginLabel
            color: themeData.buttonText

            font.family: themeData.fontFamily
            font.pixelSize: themeData.loginSize * scaleFactor
            font.weight: Font.Bold
        }

        MouseArea {
            id: buttonArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                button.activated()
            }
        }
    }

    component PowerAction: Item {
        
        id: action

        property var themeData
        property real scaleFactor: 1
        property string iconSource: ""
        property string label: ""
        property string actionName: ""

        signal activated(string actionName)

        width: themeData.actionWidth * scaleFactor
        height: themeData.actionHeight * scaleFactor
        opacity: themeData.actionOpacity(actionArea.containsMouse)
        scale: themeData.actionScale(actionArea.pressed, actionArea.containsMouse)

        Behavior on opacity {
            NumberAnimation {
                duration: themeData.actionAnimationMs
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: themeData.actionAnimationMs
                easing.type: Easing.OutCubic
            }
        }

        Column {
            anchors.centerIn: parent
            width: parent.width
            spacing: themeData.powerContentSpacing * scaleFactor

            Image {
                x: (parent.width - width) / 2
                source: action.iconSource
                width: themeData.actionIconSize * scaleFactor
                height: themeData.actionIconSize * scaleFactor
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.96
            }

            Text {
                width: parent.width
                text: action.label
                color: themeData.textSoft
                horizontalAlignment: Text.AlignHCenter

                font.family: themeData.fontFamily
                font.pixelSize: themeData.actionLabelSize * scaleFactor
                font.weight: Font.Medium
            }
        }

        MouseArea {
            id: actionArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                action.activated(action.actionName)
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
        source: theme.backgroundSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
    }

    Rectangle {
        anchors.fill: parent
        color: theme.tint
        opacity: theme.tintOpacity
    }

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: theme.gradientTop
            }

            GradientStop {
                position: 0.34
                color: theme.gradientUpper
            }

            GradientStop {
                position: 0.62
                color: theme.gradientLower
            }

            GradientStop {
                position: 1.0
                color: theme.gradientBottom
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: theme.shade
        opacity: theme.shadeOpacity
    }

    Column {
        id: clockBlock

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * theme.clockY
        width: root.width
        spacing: theme.clockSpacing * root.uiScale

        Text {
            width: parent.width
            text: Qt.formatDate(root.currentDate, theme.dateFormat)
            color: theme.textSoft
            horizontalAlignment: Text.AlignHCenter

            font.family: theme.fontFamily
            font.pixelSize: theme.dateSize * root.uiScale
            font.weight: Font.Medium
        }

        Text {
            width: parent.width
            text: Qt.formatTime(root.currentDate, theme.timeFormat)
            color: theme.textStrong
            horizontalAlignment: Text.AlignHCenter

            font.family: theme.fontFamily
            font.pixelSize: theme.timeSize * root.uiScale
            font.weight: Font.Black
        }
    }

    Column {
        id: loginBlock

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * theme.loginY
        width: theme.inputWidth * root.uiScale
        spacing: theme.loginSpacing * root.uiScale

        CredentialField {
            id: usernameInput

            themeData: theme
            scaleFactor: root.uiScale
            placeholderText: theme.usernamePlaceholder

            onAccepted: {
                passwordInput.forceActiveFocus()
            }
        }

        CredentialField {
            id: passwordInput

            themeData: theme
            scaleFactor: root.uiScale
            placeholderText: theme.passwordPlaceholder
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
            color: theme.textError
            horizontalAlignment: Text.AlignHCenter

            font.family: theme.fontFamily
            font.pixelSize: theme.errorSize * root.uiScale
            font.weight: Font.Medium
        }

        LoginButton {
            themeData: theme
            scaleFactor: root.uiScale

            onActivated: {
                root.login()
            }
        }
    }

    Row {
        id: powerBlock

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * theme.powerY
        spacing: theme.powerSpacing * root.uiScale

        Repeater {
            model: [
                {
                    icon: theme.shutdownIcon,
                    label: theme.shutdownLabel,
                    action: "shutdown"
                },
                {
                    icon: theme.restartIcon,
                    label: theme.restartLabel,
                    action: "restart"
                },
                {
                    icon: theme.sleepIcon,
                    label: theme.sleepLabel,
                    action: "sleep"
                }
            ]

            PowerAction {
                themeData: theme
                scaleFactor: root.uiScale
                iconSource: modelData.icon
                label: modelData.label
                actionName: modelData.action

                onActivated: function(actionName) {
                    root.runPowerAction(actionName)
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * theme.environmentY
        text: "Environment (" + theme.environmentLabel + ")"
        color: theme.textSoft
        opacity: 0.92

        font.family: theme.fontFamily
        font.pixelSize: theme.environmentSize * root.uiScale
        font.weight: Font.Medium
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            passwordInput.text = ""
            errorText.text = theme.loginFailedMessage
            passwordInput.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        usernameInput.forceActiveFocus()
    }
}
