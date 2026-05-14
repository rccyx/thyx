pragma Singleton
import QtQuick 2.15

QtObject {

    readonly property int spacing_xs: 6
    readonly property int spacing_sm: 10
    readonly property int spacing_md: 14
    readonly property int spacing_lg: 20

    readonly property int radius: 10

    readonly property int motion_fast: 90
    readonly property int motion_normal: 170
    readonly property int motion_slow: 280

    readonly property int easing_standard: Easing.OutQuart
    readonly property int easing_bounce: Easing.OutBack
    readonly property int easing_smooth: Easing.OutCubic
}
