import QtQuick 2.15

Column {
    id: root

    property real scaleFactor: 1
    property var themeData

    signal loginRequested(string username, string password)

    width: themeData.layout.inputWidth * scaleFactor
    spacing: themeData.layout.loginSpacing * scaleFactor

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

        themeData: root.themeData
        scaleFactor: root.scaleFactor
        placeholderText: root.themeData.copy.usernamePlaceholder

        onAccepted: passwordInput.forceActiveFocus()
    }

    CredentialField {
        id: passwordInput

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

        width: parent.width
        visible: text.length > 0
        text: ""
        color: root.themeData.palette.textError
        horizontalAlignment: Text.AlignHCenter

        font.family: root.themeData.copy.fontFamily
        font.pixelSize: scaledPixelSize
        font.weight: Font.Medium
    }

    LoginButton {
        themeData: root.themeData
        scaleFactor: root.scaleFactor

        onActivated: root.loginRequested(usernameInput.text, passwordInput.text)
    }
}
