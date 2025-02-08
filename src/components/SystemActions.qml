import QtQuick 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0 as SDDM

import "../ui" as UI

RowLayout {
    id: systemActions
    Layout.preferredHeight: (rootItem ? rootItem.height : 0) / 8
    Layout.maximumHeight: (rootItem ? rootItem.height : 0) / 8
    spacing: basePointSize * 5

    property var rootItem: null
    property var config: ({})
    property var sddmApi: null
    readonly property var cfg: config || ({})
    readonly property int basePointSize: UI.ThemePrimitives.rootPointSize(rootItem, 13)
    readonly property string baseFontFamily: UI.ThemePrimitives.rootFontFamily(rootItem, UI.ThemePrimitives.fontFamily(cfg, ""))
    readonly property var shutdown: [textConstants.shutdown, sddmApi ? sddmApi.canPowerOff : false]
    readonly property var restart: ["Restart", sddmApi ? sddmApi.canReboot : false]
    readonly property var sleep: ["Sleep", sddmApi ? sddmApi.canSuspend : false]

    function triggerAction(index) {
        if (!sddmApi)
            return;
        if (index === 0)
            sddmApi.powerOff();
        else if (index === 1)
            sddmApi.reboot();
        else if (index === 2)
            sddmApi.suspend();
    }

    SDDM.TextConstants {
        id: textConstants
    }

    Repeater {
        model: [systemActions.shutdown, systemActions.restart, systemActions.sleep]

        Rectangle {
            id: powerControl
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            implicitWidth: iconSize
            implicitHeight: iconSize + labelText.implicitHeight + 8
            color: "transparent"

            readonly property int actionIndex: index
            readonly property int iconSize: systemActions.basePointSize * 4.5

            Column {
                anchors.centerIn: parent
                spacing: 8

                IconButton {
                    id: iconButton
                    width: powerControl.iconSize
                    height: powerControl.iconSize
                    anchors.horizontalCenter: parent.horizontalCenter
                    config: systemActions.cfg
                    iconSource: {
                        switch (powerControl.actionIndex) {
                        case 0:
                            return Qt.resolvedUrl("../../icons/shutdown.svg");
                        case 1:
                            return Qt.resolvedUrl("../../icons/restart.svg");
                        case 2:
                            return Qt.resolvedUrl("../../icons/sleep.svg");
                        default:
                            return Qt.resolvedUrl("../../icons/shutdown.svg");
                        }
                    }
                    onClicked: {
                        powerControl.forceActiveFocus();
                        systemActions.triggerAction(powerControl.actionIndex);
                    }
                }

                Text {
                    id: labelText
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData[0] || ""
                    color: systemActions.cfg.SystemButtonsIconsColor
                    horizontalAlignment: Text.AlignHCenter
                    width: powerControl.iconSize + 20
                    wrapMode: Text.WordWrap

                    font {
                        pointSize: systemActions.basePointSize * 0.9
                        family: systemActions.baseFontFamily
                        weight: Font.Normal
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: UI.ThemePrimitives.animationDuration(systemActions.cfg)
                            easing.type: UI.ThemePrimitives.animationEasing(systemActions.cfg)
                        }
                    }

                    states: [
                        State {
                            name: "labelHovered"
                            when: iconButton.isHovered
                            PropertyChanges {
                                labelText.color: systemActions.cfg.HoverSystemButtonsIconsColor
                            }
                        },
                        State {
                            name: "labelPressed"
                            when: iconButton.isPressed
                            PropertyChanges {
                                labelText.color: Qt.darker(systemActions.cfg.HoverSystemButtonsIconsColor, 1.2)
                            }
                        },
                        State {
                            name: "labelFocused"
                            when: iconButton.activeFocus
                            PropertyChanges {
                                labelText.color: systemActions.cfg.HoverSystemButtonsIconsColor
                            }
                        }
                    ]
                }
            }

            Keys.onReturnPressed: iconButton.clicked()
            Keys.onEnterPressed: iconButton.clicked()
            onActiveFocusChanged: if (activeFocus)
                iconButton.forceActiveFocus()
            focus: true
        }
    }

    component IconButton: Rectangle {
        id: iconButton
        color: "transparent"
        radius: Math.min(width, height) / 2
        focus: true

        property var config: ({})
        property string iconSource: ""
        property color defaultIconColor: config.SystemButtonsIconsColor
        property color hoverIconColor: config.HoverSystemButtonsIconsColor
        property color pressedIconColor: Qt.darker(config.HoverSystemButtonsIconsColor, 1.2)
        property real iconScale: 0.7
        readonly property bool isHovered: clickHandler.containsMouse && !clickHandler.pressed
        readonly property bool isPressed: clickHandler.pressed

        signal clicked
        signal pressed
        signal released

        MouseArea {
            id: clickHandler
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: iconButton.clicked()
            onPressed: iconButton.pressed()
            onReleased: iconButton.released()
        }

        Image {
            id: iconImage
            anchors.centerIn: parent
            width: parent.width * iconButton.iconScale
            height: parent.height * iconButton.iconScale
            sourceSize.width: width * 2
            sourceSize.height: height * 2
            source: iconButton.iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            antialiasing: true
            mipmap: true

            ColorOverlay {
                id: iconColorOverlay
                anchors.fill: parent
                source: parent
                color: iconButton.defaultIconColor

                Behavior on color {
                    ColorAnimation {
                        duration: UI.ThemePrimitives.animationDuration(iconButton.config)
                        easing.type: UI.ThemePrimitives.animationEasing(iconButton.config)
                    }
                }
            }
        }

        states: [
            State {
                name: "pressed"
                when: iconButton.isPressed
                PropertyChanges {
                    iconColorOverlay.color: iconButton.pressedIconColor
                }
            },
            State {
                name: "hovered"
                when: iconButton.isHovered
                PropertyChanges {
                    iconColorOverlay.color: iconButton.hoverIconColor
                }
            },
            State {
                name: "focused"
                when: iconButton.activeFocus
                PropertyChanges {
                    iconColorOverlay.color: iconButton.hoverIconColor
                }
            }
        ]

        Keys.onReturnPressed: clickHandler.clicked()
        Keys.onEnterPressed: clickHandler.clicked()
    }
}
