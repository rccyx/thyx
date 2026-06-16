// qmllint disable unqualified
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import SddmComponents 2.0 as SDDM

import "components/clock"
import "components/inputs"
import "components/buttons"
import "layouts"
import "effects"
import "ui"

Pane {
    id: root
    height: Screen.height
    width: Screen.width
    padding: 0

    readonly property var cfg: (typeof config !== "undefined" && config) ? config : ({})
    readonly property string formPos: String(cfg.FormPosition || "center")
    readonly property var sddmApi: (typeof sddm !== "undefined" && sddm) ? sddm : null
    readonly property color startupColor: (cfg.StartupBackgroundColor && cfg.StartupBackgroundColor !== "") ? cfg.StartupBackgroundColor : "#000000"

    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    palette.buttonText: cfg.HoverSystemButtonsIconsColor || "#ffffff"

    background: Rectangle {
        color: root.startupColor
    }

    font {
        family: cfg.Font || font.family
        pointSize: (cfg.FontSize !== "" && typeof cfg.FontSize !== "undefined") ? parseInt(cfg.FontSize) : (parseInt(height / 80) || 13)
        weight: Font.Medium
    }

    focus: true

    Item {
        id: fxVisual
        anchors.fill: parent

        Background {
            id: bg
            config: root.cfg
            fallbackColor: root.startupColor
        }

        BlurEffect {
            id: blurOverlay
            sourceItem: bg.imageItem
            config: root.cfg
        }

        Rectangle {
            id: formBackground
            anchors.fill: form
            anchors.centerIn: form
            z: 0.9
            color: root.cfg.FormBackgroundColor || "transparent"
            visible: false
            opacity: 1
        }

        ColumnLayout {
            id: form
            z: 1

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            y: parent.height * 0.003

            width: parent.width / 2.5

            x: {
                if (root.formPos === "left")
                    return 0;
                if (root.formPos === "right")
                    return parent.width - width;
                return (parent.width - width) / 2;
            }

            SDDM.TextConstants {
                id: textConstants
            }

            Clock {
                rootItem: root
                config: root.cfg
            }

            Item {
                Layout.preferredHeight: root.font.pointSize * 1
            }

            Column {
                id: inputContainer
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: -1
                Layout.leftMargin: 0
                Layout.fillWidth: true
                spacing: UiTokens.spacing_xs

                UsernameInput {
                    id: usernameInput
                    nextDown: passwordInput.password
                }

                PasswordField {
                    id: passwordInput
                    nextDown: loginButton.authenticateBtn
                }

                LoginButton {
                    id: loginButton
                    usernameField: usernameInput.username
                    passwordField: passwordInput.password
                    environmentIndex: environmentButton.currentIndex
                }

                Connections {
                    target: root.sddmApi
                    function onLoginSucceeded() {
                    }
                    function onLoginFailed() {
                    }
                }
            }

            SystemButtonsLayout {}

            Item {
                Layout.preferredHeight: root.font.pointSize * 0.5
            }

            EnvironmentButton {
                id: environmentButton
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: parent.forceActiveFocus()
        }
    }
}
