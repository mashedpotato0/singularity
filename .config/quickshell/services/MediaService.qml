pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// media mpris service
QtObject {
    id: root

    readonly property var allPlayers: Mpris.players ? Mpris.players.values : []
    property var selectedPlayer: null

    readonly property var activePlayer: {
        if (selectedPlayer && allPlayers.indexOf(selectedPlayer) !== -1) {
            return selectedPlayer;
        }
        for (let i = 0; i < allPlayers.length; i++) {
            if (allPlayers[i].playbackState === MprisPlaybackState.Playing) {
                return allPlayers[i];
            }
        }
        return allPlayers.length > 0 ? allPlayers[0] : null;
    }

    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: activePlayer ? (activePlayer.playbackState === MprisPlaybackState.Playing) : false
    readonly property string trackTitle: (activePlayer && activePlayer.trackTitle) ? activePlayer.trackTitle : "No Media Playing"
    readonly property string trackArtist: (activePlayer && activePlayer.trackArtist) ? activePlayer.trackArtist : ""
    readonly property string trackAlbum: (activePlayer && activePlayer.trackAlbum) ? activePlayer.trackAlbum : ""
    readonly property string trackArtUrl: (activePlayer && activePlayer.trackArtUrl) ? activePlayer.trackArtUrl : ""
    readonly property string playerName: activePlayer ? (activePlayer.identity || activePlayer.desktopEntry || "Media") : ""

    property real currentPosition: (activePlayer && activePlayer.position) ? activePlayer.position : 0.0

    readonly property real position: currentPosition
    readonly property real length: activePlayer ? (activePlayer.length || 0.0) : 0.0
    readonly property real progress: (length > 0) ? Math.max(0.0, Math.min(1.0, currentPosition / length)) : 0.0

    // position tick timer
    property var posTimer: Timer {
        interval: 250
        running: root.isPlaying && root.hasPlayer
        repeat: true
        onTriggered: {
            if (root.activePlayer && root.length > 0) {
                let p = root.activePlayer.position || 0.0;
                if (Math.abs(p - root.currentPosition) > 2.0) {
                    root.currentPosition = p;
                } else {
                    root.currentPosition = Math.min(root.length, root.currentPosition + 0.25);
                }
            }
        }
    }

    onActivePlayerChanged: {
        currentPosition = activePlayer ? (activePlayer.position || 0.0) : 0.0;
    }

    onIsPlayingChanged: {
        if (activePlayer) {
            currentPosition = activePlayer.position || 0.0;
        }
    }

    onTrackTitleChanged: {
        if (activePlayer) {
            currentPosition = activePlayer.position || 0.0;
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds <= 0 || isNaN(seconds)) return "00:00";
        let totalSec = Math.floor(seconds);
        let mins = Math.floor(totalSec / 60);
        let secs = totalSec % 60;
        return (mins < 10 ? "0" + mins : mins) + ":" + (secs < 10 ? "0" + secs : secs);
    }

    readonly property string positionStr: formatTime(position)
    readonly property string lengthStr: formatTime(length)

    function playPause() {
        if (activePlayer) {
            if (activePlayer.canTogglePlaying) {
                activePlayer.togglePlaying();
            } else if (activePlayer.playbackState === MprisPlaybackState.Playing) {
                activePlayer.pause();
            } else {
                activePlayer.play();
            }
        }
    }

    function next() {
        if (activePlayer && activePlayer.canGoNext) activePlayer.next();
    }

    function previous() {
        if (activePlayer && activePlayer.canGoPrevious) activePlayer.previous();
    }

    function stop() {
        if (activePlayer) activePlayer.stop();
    }

    function seekTo(progressRatio) {
        if (activePlayer && activePlayer.canSeek && length > 0) {
            let target = progressRatio * length;
            let offset = target - currentPosition;
            currentPosition = target;
            activePlayer.seek(offset);
        }
    }
}
