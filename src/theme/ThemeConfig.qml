import QtQuick 2.15

QtObject {
    id: root

    readonly property var defaults: ({
        "copy.backgroundSource": "../../../../../wl.jpg",
        "copy.environmentLabel": "Hyprland",
        "copy.environmentTemplate": "Environment (%1)",
        "copy.fontFamily": "Inter",
        "copy.dateFormat": "dddd, MMMM d",
        "copy.timeFormat": "HH:mm",
        "copy.usernamePlaceholder": "Username",
        "copy.passwordPlaceholder": "Password",
        "copy.passwordCharacter": "•",
        "copy.loginLabel": "Login",
        "copy.loginFailedMessage": "Login failed",
        "copy.shutdownLabel": "Shutdown",
        "copy.restartLabel": "Restart",
        "copy.sleepLabel": "Sleep",
        "copy.shutdownIcon": "../assets/icons/shutdown.svg",
        "copy.restartIcon": "../assets/icons/restart.svg",
        "copy.sleepIcon": "../assets/icons/sleep.svg",
        "copy.shutdownAction": "shutdown",
        "copy.restartAction": "restart",
        "copy.sleepAction": "sleep",

        "layout.designWidth": "1920",
        "layout.designHeight": "1080",
        "layout.minScale": "0.72",
        "layout.clockY": "0.135",
        "layout.loginY": "0.46",
        "layout.powerY": "0.79",
        "layout.environmentY": "0.93",
        "layout.clockSpacing": "10",
        "layout.loginSpacing": "18",
        "layout.powerSpacing": "70",
        "layout.powerContentSpacing": "10",
        "layout.inputWidth": "390",
        "layout.inputHeight": "38",
        "layout.inputPadding": "24",
        "layout.inputBorderFocusWidth": "1",
        "layout.loginHeight": "39",
        "layout.actionWidth": "88",
        "layout.actionHeight": "78",
        "layout.actionIconSize": "34",
        "layout.dateSize": "31",
        "layout.timeSize": "112",
        "layout.inputSize": "15",
        "layout.loginSize": "15",
        "layout.errorSize": "13",
        "layout.actionLabelSize": "14",
        "layout.environmentSize": "15",

        "motion.actionIdleOpacity": "0.82",
        "motion.actionHoverOpacity": "1.0",
        "motion.actionIdleScale": "1.0",
        "motion.actionHoverScale": "1.04",
        "motion.actionPressedScale": "0.96",
        "motion.actionAnimationMs": "120",

        "palette.base": "#020707",
        "palette.accent": "#13b8b5",
        "palette.accentHot": "#1fd7d2",
        "palette.accentPressed": "#0d918e",
        "palette.buttonText": "#001413",
        "palette.textStrong": "#ecffff",
        "palette.textSoft": "#bdeeed",
        "palette.textError": "#ffd1d1",
        "palette.placeholder": "#b8d1ffff",
        "palette.inputIdle": "#2e0a8580",
        "palette.inputHover": "#420a8580",
        "palette.inputFocus": "#470db3ad",
        "palette.inputBorder": "#6bb8ffff",
        "palette.tint": "#001816",
        "palette.tintOpacity": "0.28",
        "palette.shade": "#000000",
        "palette.shadeOpacity": "0.18",
        "palette.actionIconOpacity": "0.96",
        "palette.environmentOpacity": "0.92",
        "palette.gradientTopPosition": "0.0",
        "palette.gradientTop": "#78000000",
        "palette.gradientUpperPosition": "0.34",
        "palette.gradientUpper": "#17000000",
        "palette.gradientLowerPosition": "0.62",
        "palette.gradientLower": "#24000000",
        "palette.gradientBottomPosition": "1.0",
        "palette.gradientBottom": "#8a000000"
    })

    function colorValue(key) {
        return value(key)
    }

    function numberValue(key) {
        var parsed = Number(value(key))

        if (isNaN(parsed)) {
            return Number(defaults[key])
        }

        return parsed
    }

    function value(key) {
        var configured = ""

        try {
            if (typeof config !== "undefined") {
                configured = config[key]
            }
        } catch (error) {
            configured = ""
        }

        if (configured !== undefined && configured !== null && String(configured).length > 0) {
            return configured
        }

        return defaults[key]
    }
}