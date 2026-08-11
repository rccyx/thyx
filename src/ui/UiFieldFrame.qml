import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Rectangle {
    id: fieldFrame

    default property alias content: contentHost.data

    implicitHeight: basePointSize * UiTokens.control_height_em
    height: implicitHeight
    radius: UiTokens.radius_pill
    color: fillColor

    property int basePointSize: 13
    property color fillColor: "transparent"
    property int horizontalPadding: UiTokens.spacing_sm

    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: UiTokens.shadow_y
        radius: UiTokens.shadow_radius
        samples: UiTokens.shadow_samples
        color: Qt.rgba(0, 0, 0, UiTokens.shadow_opacity)
    }

    Item {
        id: contentHost
        anchors.fill: parent
        anchors.leftMargin: fieldFrame.horizontalPadding
        anchors.rightMargin: fieldFrame.horizontalPadding
    }
}
