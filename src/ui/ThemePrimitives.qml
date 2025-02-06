pragma Singleton

import QtQuick 2.15

QtObject {
    function animationDuration(config) {
        return config.AnimationDuration || 80;
    }

    function animationEasing(config) {
        switch (config.AnimationEasing) {
        case "OutCubic":
            return Easing.OutCubic;
        case "OutBack":
            return Easing.OutBack;
        case "OutQuart":
        default:
            return Easing.OutQuart;
        }
    }

    function fontFamily(config, fallback) {
        return config.Font || fallback;
    }

    function fontPointSize(config, height, fallback) {
        if (config.FontSize !== "" && typeof config.FontSize !== "undefined")
            return parseInt(config.FontSize);
        return parseInt(height / 80) || fallback;
    }

    function rootFontFamily(rootItem, fallback) {
        if (rootItem && rootItem.font && rootItem.font.family)
            return rootItem.font.family;
        return fallback;
    }

    function rootPointSize(rootItem, fallback) {
        if (rootItem && rootItem.font && rootItem.font.pointSize)
            return rootItem.font.pointSize;
        return fallback;
    }

    function translucentColor(colorValue, alpha) {
        const text = String(colorValue || "#000000");
        return Qt.rgba(parseInt(text.slice(1, 3), 16) / 255, parseInt(text.slice(3, 5), 16) / 255, parseInt(text.slice(5, 7), 16) / 255, alpha);
    }
}
