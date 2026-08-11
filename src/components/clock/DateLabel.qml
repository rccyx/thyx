import QtQuick 2.15
import "../../ui"

Text {
    id: dateDisplay
    anchors.horizontalCenter: parent.horizontalCenter

    property var rootItem: null
    property var config: ({})
    readonly property var cfg: config
    readonly property int basePt: (rootItem && rootItem.font && rootItem.font.pointSize) ? rootItem.font.pointSize : 13
    readonly property string baseFamily: (rootItem && rootItem.font && rootItem.font.family) ? rootItem.font.family : (cfg.Font && cfg.Font !== "" ? cfg.Font : dateDisplay.font.family)

    color: cfg.DateTextColor

    font {
        pointSize: basePt * UiTokens.text_date
        weight: Font.Medium
        family: baseFamily
    }

    renderType: Text.QtRendering
    horizontalAlignment: Text.AlignHCenter

    readonly property var systemLocale: Qt.locale()

    function refreshDisplay() {
        const rawFormat = typeof cfg.DateFormat === "undefined" ? "" : String(cfg.DateFormat);
        const dateFormat = rawFormat === "long" ? Locale.LongFormat : (rawFormat !== "" ? rawFormat : Locale.ShortFormat);
        text = new Date().toLocaleDateString(systemLocale, dateFormat);
    }

    Component.onCompleted: refreshDisplay()
}
