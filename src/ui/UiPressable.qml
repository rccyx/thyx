import QtQuick 2.15

Item {
    id: pressable

    readonly property bool hovered: hitTarget.containsMouse && !hitTarget.pressed
    readonly property bool pressed: hitTarget.pressed
    property alias mouseArea: hitTarget

    signal clicked
    signal pressStarted
    signal released

    MouseArea {
        id: hitTarget
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: pressable.clicked()
        onPressed: pressable.pressStarted()
        onReleased: pressable.released()
    }

    Keys.onReturnPressed: pressable.clicked()
    Keys.onEnterPressed: pressable.clicked()
}
