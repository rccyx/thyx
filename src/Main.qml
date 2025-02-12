import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "components"
import "ui" as UI

Pane {
    id: root
    height: Screen.height
    width: Screen.width
    padding: 0

    readonly property var cfg: (typeof config !== "undefined" && config) ? config : ({})
    readonly property string formPos: String(cfg.FormPosition || "center")
    readonly property var sddmApi: (typeof sddm !== "undefined" && sddm) ? sddm : null

    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    palette.window: "transparent"
    palette.buttonText: cfg.HoverSystemButtonsIconsColor || "#ffffff"

    font {
        family: UI.ThemePrimitives.fontFamily(root.cfg, font.family)
        pointSize: UI.ThemePrimitives.fontPointSize(root.cfg, root.height, 13)
        weight: Font.Medium
    }

    focus: true

    Item {
        anchors.fill: parent

        VisualFrame {
            config: root.cfg
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

            DateTime {
                rootItem: root
                config: root.cfg
            }

            Item {
                Layout.preferredHeight: root.font.pointSize
            }

            AuthForm {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                rootItem: root
                config: root.cfg
                sddmApi: root.sddmApi
            }

            SystemActions {
                Layout.alignment: Qt.AlignHCenter
                rootItem: root
                config: root.cfg
                sddmApi: root.sddmApi
            }

            Item {
                Layout.preferredHeight: root.font.pointSize * 0.5
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: parent.forceActiveFocus()
        }
    }
}
