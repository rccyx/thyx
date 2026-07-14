// qmllint disable unqualified

import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0 as SDDM

AuthField {
    id: usernameField

    placeholderText: loginConstants.userName
    initialText: userPicker.currentText
    echoMode: TextInput.Normal

    SDDM.TextConstants {
        id: loginConstants
    }

    ComboBox {
        id: userPicker
        visible: false
        model: userModel
        currentIndex: model.lastIndex
        textRole: "name"
    }
}
