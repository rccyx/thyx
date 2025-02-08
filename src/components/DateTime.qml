import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../ui" as UI

Rectangle {
    id: temporalDisplay
    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
    Layout.preferredHeight: (rootItem ? rootItem.height : (parent ? parent.height : 0)) / 4
    implicitWidth: parent ? parent.width / 2 : 0
    color: "transparent"

    property var rootItem: null
    property var config: ({})
    readonly property var cfg: config || ({})
    readonly property int basePointSize: UI.ThemePrimitives.rootPointSize(rootItem, 13)
    readonly property string baseFontFamily: UI.ThemePrimitives.rootFontFamily(rootItem, UI.ThemePrimitives.fontFamily(cfg, ""))
    readonly property var systemLocale: Qt.locale()

    function refreshDisplay() {
        const today = new Date();
        const dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        const hourFormat = (typeof cfg.HourFormat === "undefined") ? "" : cfg.HourFormat;
        const timeFormat = (hourFormat == "long") ? Locale.LongFormat : (hourFormat !== "" ? hourFormat : Locale.ShortFormat);
        currentDate.text = dayNames[today.getDay()] + ", " + monthNames[today.getMonth()] + " " + today.getDate();
        currentTime.text = today.toLocaleTimeString(systemLocale, timeFormat);
    }

    Column {
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: currentDate
            anchors.horizontalCenter: parent.horizontalCenter
            color: temporalDisplay.cfg.DateTextColor || "#ffffff"
            renderType: Text.QtRendering
            horizontalAlignment: Text.AlignHCenter

            font {
                pointSize: temporalDisplay.basePointSize * 2
                weight: Font.Medium
                family: temporalDisplay.baseFontFamily
            }
        }

        Text {
            id: currentTime
            anchors.horizontalCenter: parent.horizontalCenter
            color: temporalDisplay.cfg.TimeTextColor || "#ffffff"
            renderType: Text.QtRendering
            horizontalAlignment: Text.AlignHCenter

            font {
                pointSize: temporalDisplay.basePointSize * 9
                weight: Font.Bold
                family: temporalDisplay.baseFontFamily
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: temporalDisplay.refreshDisplay()
    }

    Component.onCompleted: temporalDisplay.refreshDisplay()
}
