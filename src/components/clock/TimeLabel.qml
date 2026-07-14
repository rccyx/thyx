import QtQuick 2.15

Text {
    id: timeDisplay
    anchors.horizontalCenter: parent.horizontalCenter

    property var rootItem: null
    property var config: ({})
    readonly property var cfg: config || ({})
    readonly property int basePt: (rootItem && rootItem.font && rootItem.font.pointSize) ? rootItem.font.pointSize : 13
    readonly property string baseFamily: (rootItem && rootItem.font && rootItem.font.family) ? rootItem.font.family : (cfg.Font && cfg.Font !== "" ? cfg.Font : timeDisplay.font.family)

    font {
        pointSize: basePt * 9
        weight: Font.Bold
        family: baseFamily
    }

    color: cfg.TimeTextColor || "#ffffff"
    renderType: Text.QtRendering
    horizontalAlignment: Text.AlignHCenter

    readonly property var systemLocale: Qt.locale()

    function refreshDisplay() {
        const rawFormat = typeof cfg.HourFormat === "undefined" ? "" : String(cfg.HourFormat);
        const timeFormat = rawFormat === "long" ? Locale.LongFormat : (rawFormat !== "" ? rawFormat : Locale.ShortFormat);
        text = new Date().toLocaleTimeString(systemLocale, timeFormat);
    }

    Component.onCompleted: refreshDisplay()
}
