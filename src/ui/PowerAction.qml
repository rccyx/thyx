import QtQuick 2.15

Item {
    id: root

    property var themeData
    property real scaleFactor: 1
    property string iconSource: ""
    property string label: ""
    property string actionName: ""

    signal activated(string actionName)

    width: themeData.layout.actionWidth * scaleFactor
    height: themeData.layout.actionHeight * scaleFactor
    opacity: themeData.actionOpacity(actionArea.containsMouse)
    scale: themeData.actionScale(actionArea.pressed, actionArea.containsMouse)

    Behavior on opacity {
        NumberAnimation { duration: root.themeData.motion.actionAnimationMs }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.themeData.motion.actionAnimationMs
            easing.type: Easing.OutCubic
        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: root.themeData.layout.powerContentSpacing * root.scaleFactor

        Image {
            x: (parent.width - width) / 2
            source: root.iconSource
            width: root.themeData.layout.actionIconSize * root.scaleFactor
            height: root.themeData.layout.actionIconSize * root.scaleFactor
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.themeData.palette.actionIconOpacity
        }

        Text {
            property int scaledPixelSize: root.themeData.pixelSize(root.themeData.layout.actionLabelSize, root.scaleFactor)

            width: parent.width
            text: root.label
            color: root.themeData.palette.textSoft
            horizontalAlignment: Text.AlignHCenter

            font.family: root.themeData.copy.fontFamily
            font.pixelSize: scaledPixelSize
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: actionArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.activated(root.actionName)
    }
}
