pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property int spacing_xs: 6
    readonly property int spacing_sm: 8
    readonly property int spacing_md: 12
    readonly property int spacing_lg: 20

    readonly property int radius_sm: 4
    readonly property int radius_md: 12
    readonly property int radius_pill: 24

    readonly property real text_sm: 0.8
    readonly property real text_md: 0.9
    readonly property real text_lg: 1
    readonly property real text_date: 2
    readonly property real text_time: 9

    readonly property real form_width_ratio: 0.4
    readonly property real field_width_ratio: 0.5
    readonly property real clock_height_ratio: 0.25
    readonly property real system_buttons_height_ratio: 0.125
    readonly property real environment_height_ratio: 0.0666666667

    readonly property real control_height_em: 3
    readonly property real field_frame_height_em: 4.5
    readonly property real login_area_height_em: 9
    readonly property real icon_button_size_em: 4.5
    readonly property real system_buttons_gap_em: 5

    readonly property real icon_scale: 0.7
    readonly property int shadow_y: 2
    readonly property int shadow_radius: 8
    readonly property int shadow_samples: 16
    readonly property real shadow_opacity: 0.15
}
