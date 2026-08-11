import QtQuick 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent
    z: 0.5

    property Item sourceItem
    property var config: ({})

    property real blurAmount: {
        var v = (config.Blur === "" ? 0.4 : Number(config.Blur));
        if (isNaN(v))
            v = 0.4;
        if (v < 0)
            v = 0;
        if (v > 1)
            v = 1;
        return v;
    }

    visible: !!sourceItem && blurAmount > 0

    FastBlur {
        id: blur
        anchors.fill: parent
        source: root.sourceItem
        radius: root.blurAmount * 64
        transparentBorder: true
    }
}
