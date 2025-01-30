import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    property real scaleFactor: 1
    property real gap: themeData.layout.loginSpacing * scaleFactor
    property var themeData

    signal loginRequested(string username, string password)

    width: themeData.layout.inputWidth * scaleFactor
    height: loginButton.y + loginButton.height

    function clearError() {
        errorText.text = ""
    }

    function focusUsername() {
        usernameInput.forceActiveFocus()
    }

    function handleLoginFailed() {
        passwordInput.text = ""
        errorText.text = themeData.copy.loginFailedMessage
        passwordInput.forceActiveFocus()
    }

    CredentialField {
        id: usernameInput

        x: 0
        y: 0
        themeData: root.themeData
        scaleFactor: root.scaleFactor
        placeholderText: root.themeData.copy.usernamePlaceholder

        onAccepted: passwordInput.forceActiveFocus()
    }

    CredentialField {
        id: passwordInput

        x: 0
        y: usernameInput.y + usernameInput.height + root.gap
        themeData: root.themeData
        scaleFactor: root.scaleFactor
        placeholderText: root.themeData.copy.passwordPlaceholder
        echoMode: TextInput.Password
        passwordCharacter: root.themeData.copy.passwordCharacter

        onAccepted: root.loginRequested(usernameInput.text, passwordInput.text)
    }

    Text {
        id: errorText

        property int scaledPixelSize: root.themeData.pixelSize(root.themeData.layout.errorSize, root.scaleFactor)

        x: 0
        y: passwordInput.y + passwordInput.height + root.gap
        width: parent.width
        height: visible ? implicitHeight : 0
        visible: text.length > 0
        text: ""
        color: root.themeData.palette.textError
        horizontalAlignment: Text.AlignHCenter

        font.family: root.themeData.copy.fontFamily
        font.pixelSize: scaledPixelSize
        font.weight: Font.Medium
    }

    LoginButton {
        id: loginButton

        x: 0
        y: errorText.visible
            ? errorText.y + errorText.height + root.gap
            : passwordInput.y + passwordInput.height + root.gap
        themeData: root.themeData
        scaleFactor: root.scaleFactor

        onActivated: root.loginRequested(usernameInput.text, passwordInput.text)
    }
}
