import QtQuick 2.15

Column {
    id: root

    property date currentDate
    property real scaleFactor: 1
    property var themeData

    spacing: themeData.layout.clockSpacing * scaleFactor

    Text {
        width: parent.width
        text: Qt.formatDate(root.currentDate, root.themeData.copy.dateFormat)
        color: root.themeData.palette.textSoft
        horizontalAlignment: Text.AlignHCenter

        font.family: root.themeData.copy.fontFamily
        font.pixelSize: root.themeData.layout.dateSize * root.scaleFactor
        font.weight: Font.Medium
    }

    Text {
        width: parent.width
        text: Qt.formatTime(root.currentDate, root.themeData.copy.timeFormat)
        color: root.themeData.palette.textStrong
        horizontalAlignment: Text.AlignHCenter

        font.family: root.themeData.copy.fontFamily
        font.pixelSize: root.themeData.layout.timeSize * root.scaleFactor
        font.weight: Font.Black
    }
}
