import QtQuick 2.15

Text {
    id: dateDisplay
    anchors.horizontalCenter: parent.horizontalCenter

    property var rootItem: null
    property var config: ({})
    readonly property var cfg: config || ({})
    readonly property int basePt: (rootItem && rootItem.font && rootItem.font.pointSize) ? rootItem.font.pointSize : 13
    readonly property string baseFamily: (rootItem && rootItem.font && rootItem.font.family) ? rootItem.font.family : (cfg.Font && cfg.Font !== "" ? cfg.Font : dateDisplay.font.family)

    color: cfg.DateTextColor || "#ffffff"

    font {
        pointSize: basePt * 2
        weight: Font.Medium
        family: baseFamily
    }

    renderType: Text.QtRendering
    horizontalAlignment: Text.AlignHCenter

    function refreshDisplay() {
        const today = new Date();
        const dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        const dayName = dayNames[today.getDay()];
        const monthName = monthNames[today.getMonth()];
        const dayNumber = today.getDate();
        text = dayName + ", " + monthName + " " + dayNumber;
    }

    Component.onCompleted: refreshDisplay()
}
