import QtQuick 2.15

Item {
    id: root

    property var themeData

    Image {
        anchors.fill: parent
        source: root.themeData.copy.backgroundSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
    }

    Rectangle {
        anchors.fill: parent
        color: root.themeData.palette.tint
        opacity: root.themeData.palette.tintOpacity
    }

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop { position: root.themeData.palette.gradientTopPosition; color: root.themeData.palette.gradientTop }
            GradientStop { position: root.themeData.palette.gradientUpperPosition; color: root.themeData.palette.gradientUpper }
            GradientStop { position: root.themeData.palette.gradientLowerPosition; color: root.themeData.palette.gradientLower }
            GradientStop { position: root.themeData.palette.gradientBottomPosition; color: root.themeData.palette.gradientBottom }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.themeData.palette.shade
        opacity: root.themeData.palette.shadeOpacity
    }
}
