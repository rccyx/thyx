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

    function doLogin() {
        const userName = String(usernameField.text || "");

        if (userName.length === 0)
            return;

        const password = String(passwordField.text || "");
        sddm.login(userName, password, environmentIndex);
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
                    duration: root.animationDuration
                    easing.type: root.animationEasing
                }
            }
        ]
    }
}
