import QtQuick 2.15
import QtMultimedia
import Qt5Compat.GraphicalEffects

Item {
    id: visualFrame
    anchors.fill: parent

    property var config: ({})
    property url resolvedUrl: (config.Background && config.Background !== "") ? Qt.resolvedUrl("../../" + config.Background) : ""
    property bool isVideo: false
    readonly property real blurAmount: {
        const value = (config.Blur === "" ? 0.4 : Number(config.Blur));
        if (isNaN(value))
            return 0.4;
        if (value < 0)
            return 0;
        if (value > 1)
            return 1;
        return value;
    }

    function setSource() {
        const urlObject = visualFrame.resolvedUrl;
        const source = urlObject ? urlObject.toString() : "";

        if (!source || source === "") {
            videoOutput.visible = false;
            backgroundImage.visible = true;
            backgroundImage.source = "";
            if (player.playbackState !== MediaPlayer.StoppedState)
                player.stop();
            player.source = "";
            return;
        }

        const extension = source.split(".").pop().toLowerCase();
        visualFrame.isVideo = ["avi", "mp4", "mov", "mkv", "m4v", "webm"].indexOf(extension) !== -1;

        if (visualFrame.isVideo) {
            videoOutput.visible = true;
            backgroundImage.visible = false;
            player.playbackRate = 1.0;
            player.source = urlObject;
            player.play();
            return;
        }

        if (player.playbackState !== MediaPlayer.StoppedState)
            player.stop();
        player.source = "";
        videoOutput.visible = false;
        backgroundImage.visible = true;
        backgroundImage.source = urlObject;
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        asynchronous: true
        cache: true
        clip: true
        mipmap: true
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        fillMode: Image.PreserveAspectCrop
        visible: !videoOutput.visible
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        visible: false
        fillMode: VideoOutput.PreserveAspectCrop
    }

    MediaPlayer {
        id: player
        videoOutput: videoOutput
        autoPlay: true
        loops: -1
    }

    FastBlur {
        anchors.fill: parent
        z: 0.5
        source: backgroundImage
        radius: visualFrame.blurAmount * 64
        transparentBorder: true
        visible: visualFrame.blurAmount > 0
    }

    onResolvedUrlChanged: setSource()
    Component.onCompleted: setSource()
}
