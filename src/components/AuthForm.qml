import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0 as SDDM

import "../ui" as UI

Column {
    id: authForm
    spacing: 4

    property var rootItem: null
    property var config: ({})
    property var sddmApi: null
    readonly property var cfg: config || ({})
    readonly property int basePointSize: UI.ThemePrimitives.rootPointSize(rootItem, 13)
    readonly property string baseFontFamily: UI.ThemePrimitives.rootFontFamily(rootItem, UI.ThemePrimitives.fontFamily(cfg, ""))
    readonly property bool canLogin: String(usernameInput.text || "").length > 0 && String(passwordInput.text || "").length > 0

    function normalizedUser() {
        const raw = String(usernameInput.text || "");
        return (cfg.AllowUppercaseLettersInUsernames == "false") ? raw.toLowerCase() : raw;
    }

    function loginWithPassword() {
        if (!canLogin)
            return;
        if (!sddmApi)
            return;

        sddmApi.login(normalizedUser(), String(passwordInput.text || ""), environmentPicker.currentIndex);
    }

    function loginWithFingerprint() {
        if (!sddmApi)
            return;
        if (!(cfg.AutoFingerprintOnLoad == "true" || cfg.AutoFingerprintOnLoad === true))
            return;

        sddmApi.login(normalizedUser(), "", environmentPicker.currentIndex);
    }

    SDDM.TextConstants {
        id: authConstants
    }

    FieldControl {
        id: usernameField
        rootItem: authForm.rootItem
        config: authForm.cfg
        backgroundColor: authForm.cfg.LoginFieldBackgroundColor
        textColor: authForm.cfg.LoginFieldTextColor
        placeholder: authConstants.userName
        input: usernameInput
    }

    FieldControl {
        id: passwordField
        rootItem: authForm.rootItem
        config: authForm.cfg
        backgroundColor: authForm.cfg.PasswordFieldBackgroundColor
        textColor: authForm.cfg.PasswordFieldTextColor
        placeholder: authConstants.password
        input: passwordInput
    }

    Rectangle {
        id: loginControl
        implicitHeight: authForm.basePointSize * 9
        implicitWidth: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        Rectangle {
            id: authButton
            width: parent.width
            implicitHeight: authForm.basePointSize * 3
            anchors.centerIn: parent
            radius: 24
            color: authForm.cfg.LoginButtonBackgroundColor
            focus: true

            MouseArea {
                id: authClickArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: authForm.loginWithPassword()
            }

            Text {
                anchors.centerIn: parent
                text: authConstants.login
                color: authForm.cfg.LoginButtonTextColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                font {
                    pointSize: authForm.basePointSize
                    family: authForm.baseFontFamily
                    weight: Font.Bold
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: UI.ThemePrimitives.animationDuration(authForm.cfg)
                    easing.type: UI.ThemePrimitives.animationEasing(authForm.cfg)
                }
            }

            states: [
                State {
                    name: "buttonPressed"
                    when: authClickArea.pressed
                    PropertyChanges {
                        authButton.color: Qt.darker(authForm.cfg.HoverLoginButtonBackgroundColor, 1.2)
                    }
                },
                State {
                    name: "buttonHovered"
                    when: authClickArea.containsMouse && !authClickArea.pressed
                    PropertyChanges {
                        authButton.color: authForm.cfg.HoverLoginButtonBackgroundColor
                    }
                }
            ]

            Keys.onReturnPressed: authForm.loginWithPassword()
            Keys.onEnterPressed: authForm.loginWithPassword()
        }
    }

    Rectangle {
        id: environmentSelector
        implicitHeight: authForm.basePointSize
        implicitWidth: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        Rectangle {
            id: environmentContainer
            anchors.horizontalCenter: parent.horizontalCenter
            height: authForm.basePointSize * 3
            width: parent.width
            color: "transparent"

            MouseArea {
                id: environmentTrigger
                anchors.fill: parent
                hoverEnabled: true
                onClicked: environmentMenu.visible ? environmentMenu.close() : environmentMenu.open()
            }

            Text {
                id: environmentDisplayText
                anchors.centerIn: parent
                text: "Environment (" + environmentPicker.currentText + ")"
                color: authForm.cfg.EnvironmentButtonTextColor
                verticalAlignment: Text.AlignVCenter

                font {
                    pointSize: authForm.basePointSize * 0.9
                    family: authForm.baseFontFamily
                }

                Behavior on color {
                    ColorAnimation {
                        duration: UI.ThemePrimitives.animationDuration(authForm.cfg)
                        easing.type: UI.ThemePrimitives.animationEasing(authForm.cfg)
                    }
                }
            }

            states: [
                State {
                    name: "sessionPressed"
                    when: environmentTrigger.pressed
                    PropertyChanges {
                        environmentDisplayText.color: Qt.darker(authForm.cfg.HoverEnvironmentButtonTextColor, 1.2)
                    }
                },
                State {
                    name: "sessionHovered"
                    when: environmentTrigger.containsMouse && !environmentTrigger.pressed
                    PropertyChanges {
                        environmentDisplayText.color: Qt.lighter(authForm.cfg.HoverEnvironmentButtonTextColor, 1.15)
                    }
                },
                State {
                    name: "sessionFocused"
                    when: environmentContainer.activeFocus
                    PropertyChanges {
                        environmentDisplayText.color: authForm.cfg.HoverEnvironmentButtonTextColor
                    }
                }
            ]

            Keys.onPressed: function (event) {
                if ((event.key == Qt.Key_Left || event.key == Qt.Key_Right) && !environmentMenu.visible)
                    environmentMenu.open();
            }
        }

        ComboBox {
            id: environmentPicker
            visible: false
            model: sessionModel
            currentIndex: model.lastIndex
            textRole: "name"

            popup: Popup {
                id: environmentMenu
                implicitHeight: menuContent.implicitHeight
                width: environmentSelector.width
                y: environmentContainer.height - 1
                x: -environmentMenu.width / 2 + environmentDisplayText.width / 2
                padding: 10

                background: Rectangle {
                    radius: 12
                    color: authForm.cfg.DropdownBackgroundColor
                    layer.enabled: true
                }

                contentItem: ListView {
                    id: menuContent
                    implicitHeight: contentHeight + 20
                    clip: true
                    model: environmentPicker.popup.visible ? environmentPicker.delegateModel : null
                    currentIndex: environmentPicker.highlightedIndex

                    delegate: Rectangle {
                        width: menuContent.width - 20
                        height: delegateText.implicitHeight + 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: menuContent.currentIndex === index ? authForm.cfg.DropdownSelectedBackgroundColor : "transparent"
                        radius: 4

                        Text {
                            id: delegateText
                            anchors.centerIn: parent
                            text: name
                            color: authForm.cfg.DropdownTextColor
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                            font {
                                pointSize: authForm.basePointSize * 0.8
                                family: authForm.baseFontFamily
                                weight: Font.Normal
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                environmentPicker.currentIndex = index;
                                environmentMenu.close();
                            }
                        }
                    }

                    ScrollIndicator.vertical: ScrollIndicator {}
                }

                enter: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 200
                    }
                }
                exit: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 150
                    }
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: false
        onTriggered: authForm.loginWithFingerprint()
    }

    Connections {
        target: passwordInput
        function onAccepted() {
            authForm.loginWithPassword();
        }
    }

    Connections {
        target: usernameInput
        function onAccepted() {
            if (!passwordInput.text || passwordInput.text.length === 0)
                passwordInput.forceActiveFocus();
            else
                authForm.loginWithPassword();
        }
    }

    ComboBox {
        id: userPicker
        visible: false
        model: userModel
        currentIndex: model.lastIndex
        textRole: "name"
        onActivated: usernameInput.text = currentText
    }

    TextInput {
        id: usernameInput
        parent: usernameField.inputParent
        anchors.centerIn: parent
        width: parent.width - 16
        height: parent.height
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        z: 1
        text: userPicker.currentText
        color: authForm.cfg.LoginFieldTextColor
        selectByMouse: true
        renderType: Text.QtRendering
        KeyNavigation.down: passwordInput
        onFocusChanged: if (focus)
            selectAll()

        font {
            bold: true
            pointSize: authForm.basePointSize
            family: authForm.baseFontFamily
            capitalization: authForm.cfg.AllowUppercaseLettersInUsernames == "false" ? Font.AllLowercase : Font.MixedCase
        }
    }

    TextInput {
        id: passwordInput
        parent: passwordField.inputParent
        anchors.centerIn: parent
        width: parent.width - 16
        height: parent.height
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        color: authForm.cfg.PasswordFieldTextColor
        focus: true
        selectByMouse: true
        renderType: Text.QtRendering
        echoMode: TextInput.Password
        passwordCharacter: "•"
        passwordMaskDelay: undefined
        KeyNavigation.down: authButton

        font {
            pointSize: authForm.basePointSize
            family: authForm.baseFontFamily
            weight: Font.Bold
        }
    }

    component FieldControl: Rectangle {
        id: fieldControl
        implicitHeight: UI.ThemePrimitives.rootPointSize(rootItem, 13) * 4.5
        implicitWidth: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        property var rootItem: null
        property var config: ({})
        property color backgroundColor: "transparent"
        property color textColor: "#ffffff"
        property string placeholder: ""
        property Item input
        readonly property int fieldHeight: UI.ThemePrimitives.rootPointSize(rootItem, 13) * 3
        property alias inputParent: inputFrame

        Rectangle {
            id: inputFrame
            anchors.centerIn: parent
            width: parent.width
            height: fieldControl.fieldHeight
            radius: 24
            color: UI.ThemePrimitives.translucentColor(fieldControl.backgroundColor, 0.25)
            border.width: 0
            border.color: "transparent"

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8
                samples: 16
                color: Qt.rgba(0, 0, 0, 0.15)
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                visible: fieldControl.input && fieldControl.input.text === ""

                Text {
                    anchors.centerIn: parent
                    text: fieldControl.placeholder
                    color: fieldControl.config.PlaceholderTextColor
                    font: fieldControl.input ? fieldControl.input.font : authForm.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: UI.ThemePrimitives.animationDuration(fieldControl.config)
                    easing.type: UI.ThemePrimitives.animationEasing(fieldControl.config)
                }
            }

            states: [
                State {
                    name: "inputFocused"
                    when: fieldControl.input && fieldControl.input.activeFocus
                    PropertyChanges {
                        inputFrame.border.color: "#8ab4f8"
                    }
                }
            ]
        }
    }
}
