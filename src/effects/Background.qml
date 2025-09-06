import QtQuick 2.15
import QtMultimedia

Item {
    id: background
    anchors.fill: parent
    // cfg passed by main
    property var config: ({})
    property alias imageItem: backgroundImage

    property url resolvedUrl: (config.Background && config.Background !== "") ? Qt.resolvedUrl("../../" + config.Background) : ""
    property bool isVideo: false

    Item {
        id: backgroundContainer
        anchors.fill: parent

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
    }

    function setSource() {
        const urlObj = background.resolvedUrl;
        const src = urlObj ? urlObj.toString() : "";

        if (!src || src === "") {
            videoOutput.visible = false;
            backgroundImage.visible = true;
            backgroundImage.source = "";
            if (player.playbackState !== MediaPlayer.StoppedState)
                player.stop();
            player.source = "";
            return;
        }

        const ext = src.split(".").pop().toLowerCase();
        background.isVideo = ["avi", "mp4", "mov", "mkv", "m4v", "webm"].indexOf(ext) !== -1;

        if (background.isVideo) {
            videoOutput.visible = true;
            backgroundImage.visible = false;

            player.playbackRate = 1.0;
            player.source = urlObj; // keep as QUrl (Qt6)
            player.play();
        } else {
            if (player.playbackState !== MediaPlayer.StoppedState)
                player.stop();
            player.source = "";

            videoOutput.visible = false;
            backgroundImage.visible = true;
            backgroundImage.source = urlObj;
        }
    }

    onResolvedUrlChanged: setSource()
    Component.onCompleted: setSource()
}
