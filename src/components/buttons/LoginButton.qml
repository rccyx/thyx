// qmllint disable unqualified

import QtQuick 2.15
import SddmComponents 2.0 as SDDM
import "../../ui"

Rectangle {
    id: authenticationControl
    implicitHeight: root.font.pointSize * UiTokens.login_area_height_em
    implicitWidth: parent.width * UiTokens.field_width_ratio
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

    UiButton {
        id: authBtn
        width: parent.width
        anchors.centerIn: parent
        text: loginConstants.login
        defaultColor: config.LoginButtonBackgroundColor
        hoverColor: config.HoverLoginButtonBackgroundColor
        pressedColor: Qt.darker(config.HoverLoginButtonBackgroundColor, 1.18)
        textColor: config.LoginButtonTextColor
        basePointSize: root.font.pointSize
        fontFamily: root.font.family
        motionDuration: root.animationDuration
        motionEasing: root.animationEasing

        onClicked: authenticationControl.doLogin()
    }
}
