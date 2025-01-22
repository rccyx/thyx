import QtQuick 2.15

QtObject {
    id: root

    function colorValue(key) {
        return value(key)
    }

    function numberValue(key) {
        return Number(value(key))
    }

    function value(key) {
        if (typeof config === "undefined") return ""

        return config[key] || ""
    }
}
