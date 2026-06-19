// qmllint disable unqualified

import QtQuick 2.15
import SddmComponents 2.0 as SDDM

Rectangle {
    id: authenticationControl
    implicitHeight: root.font.pointSize * 9
    implicitWidth: parent.width / 2
    anchors.horizontalCenter: parent.horizontalCenter
    color: "transparent"

    SDDM.TextConstants {
        id: loginConstants
    }

    required property var usernameField
    required property var passwordField
    required property int environmentIndex

    property alias authenticateBtn: focusProxy

    readonly property int animationDuration: Number(config.AnimationDuration || 80)
    readonly property int animationEasing: {
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

    readonly property bool canLogin: {
        const u = String(usernameField.text || "");
        const p = String(passwordField.text || "");
        return u.length > 0 && p.length > 0;
    }

    function normalizedUser() {
        const raw = String(usernameField.text || "");
        return (config.AllowUppercaseLettersInUsernames == "false") ? raw.toLowerCase() : raw;
    }

    function doLogin() {
        if (!canLogin)
            return;

        const userName = normalizedUser();
        const pwd = String(passwordField.text || "");
        sddm.login(userName, pwd, environmentIndex);
    }

    Timer {
        id: fingerprintAutoStart
        interval: 500
        running: true
        repeat: false
        onTriggered: {
            if (config.AutoFingerprintOnLoad == "true" || config.AutoFingerprintOnLoad === true) {
                const userName = normalizedUser();
                sddm.login(userName, "", authenticationControl.environmentIndex);
            }
        }
    }

    Connections {
        target: authenticationControl.passwordField
        function onAccepted() {
            authenticationControl.doLogin();
        }
    }

    Connections {
        target: authenticationControl.usernameField
        function onAccepted() {
            if (!authenticationControl.passwordField.text || authenticationControl.passwordField.text.length === 0)
                authenticationControl.passwordField.forceActiveFocus();
            else
                authenticationControl.doLogin();
        }
    }

    Item {
        id: focusProxy
        width: 0
        height: 0
        visible: false
        focus: true

        Keys.onReturnPressed: authenticationControl.doLogin()
        Keys.onEnterPressed: authenticationControl.doLogin()
    }

    Rectangle {
        id: authBtn
        implicitHeight: root.font.pointSize * 3
        width: parent.width
        anchors.centerIn: parent
        radius: 24
        opacity: 1
        color: baseColor

        readonly property color baseColor: config.LoginButtonBackgroundColor
        readonly property color hoverColor: config.HoverLoginButtonBackgroundColor
        readonly property color pressedColor: Qt.darker(hoverColor, 1.18)

        MouseArea {
            id: authClickArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: authenticationControl.doLogin()
        }

        Text {
            id: authLabel
            anchors.centerIn: parent
            text: loginConstants.login
            font {
                pointSize: root.font.pointSize
                family: root.font.family
                weight: Font.Bold
            }
            color: config.LoginButtonTextColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        states: [
            State {
                name: "buttonPressed"
                when: authClickArea.pressed
                PropertyChanges {
                    authBtn.color: authBtn.pressedColor
                }
            },
            State {
                name: "buttonHovered"
                when: authClickArea.containsMouse && !authClickArea.pressed
                PropertyChanges {
                    authBtn.color: authBtn.hoverColor
                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "*"

                ColorAnimation {
                    target: authBtn
                    property: "color"
                    duration: authenticationControl.animationDuration
                    easing.type: authenticationControl.animationEasing
                }
            }
        ]
    }
}
