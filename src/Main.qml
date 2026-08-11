// qmllint disable unqualified
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "components/clock"
import "components/inputs"
import "components/buttons"
import "layouts"
import "layouts/effects"
import "ui"

Pane {
    id: root
    height: Screen.height
    width: Screen.width
    padding: 0

    readonly property var cfg: (typeof config !== "undefined" && config) ? config : ({})
    readonly property string formPos: String(cfg.FormPosition || "center")
    readonly property int animationDuration: {
        const value = Number(cfg.AnimationDuration);

        if (isNaN(value) || value < 0)
            return 80;

        return Math.round(value);
    }
    readonly property int animationEasing: {
        switch (String(cfg.AnimationEasing || "OutQuart")) {
        case "OutCubic":
            return Easing.OutCubic;
        case "OutBack":
            return Easing.OutBack;
        case "OutQuart":
        default:
            return Easing.OutQuart;
        }
    }

    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    background: Rectangle {
        color: "#000000"
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
            fallbackColor: "#000000"
        }

        BlurEffect {
            id: blurOverlay
            sourceItem: bg.imageItem
            config: root.cfg
        }

        ColumnLayout {
            id: form
            z: 1

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            y: parent.height * 0.003

            width: parent.width * UiTokens.form_width_ratio

            x: {
                if (root.formPos === "left")
                    return 0;
                if (root.formPos === "right")
                    return parent.width - width;
                return (parent.width - width) / 2;
            }

            Clock {
                rootItem: root
                config: root.cfg
            }

            Item {
                Layout.preferredHeight: root.font.pointSize
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
                    nextDown: passwordInput.input
                }

                PasswordField {
                    id: passwordInput
                    nextDown: loginButton.authenticateBtn
                }

                LoginButton {
                    id: loginButton
                    usernameField: usernameInput.input
                    passwordField: passwordInput.input
                    environmentIndex: environmentButton.currentIndex
                }
            }

            SystemButtonsLayout {}

            Item {
                Layout.preferredHeight: root.font.pointSize * UiTokens.field_width_ratio
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
