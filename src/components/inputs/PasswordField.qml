// qmllint disable unqualified

import QtQuick 2.15
import SddmComponents 2.0 as SDDM

AuthField {
    id: passwordField

    placeholderText: authConstants.password
    echoMode: TextInput.Password
    initialFocus: true

    input.passwordCharacter: "•"
    input.passwordMaskDelay: undefined

    SDDM.TextConstants {
        id: authConstants
    }
}
