// qmllint disable unqualified

import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0 as SDDM
import "../components/buttons"
import "../ui"

RowLayout {
    id: systemButtons
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: root.height * UiTokens.system_buttons_height_ratio
    Layout.maximumHeight: root.height * UiTokens.system_buttons_height_ratio

    Layout.leftMargin: 0

    spacing: root.font.pointSize * UiTokens.system_buttons_gap_em

    SDDM.TextConstants {
        id: textConstants
    }

    property var shutdown: [textConstants.shutdown, sddm.canPowerOff]
    property var restart: ["Restart", sddm.canReboot]
    property var sleep: ["Sleep", sddm.canSuspend]

    Repeater {
        model: [systemButtons.shutdown, systemButtons.restart, systemButtons.sleep]

        SystemButton {
            text: modelData[0]
            idx: index
            visible: true
        }
    }
}
