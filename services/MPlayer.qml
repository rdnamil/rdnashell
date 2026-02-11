/*---------------------------
--- MPlayer.qml by andrel ---
---------------------------*/

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton { id: root
	readonly property MprisPlayer player: {
		const players = Mpris.players.values;

		if (players.length > 0) {
			const spotify = players.find(p => p.identity.toLowerCase() === "spotify");

			// prefer spotify if playing
			if (spotify && spotiy.isPlaying) return spotify;

			// return first player in list that's playing
			else if (players.some(p => p.isPlaying)) return players.find(p => p.isPlaying);

			// prefer spotify if nothing playing
			else if (spotify) return spotify;

			// return first player in list
			else return players[0];
		} else return null;
	}
	readonly property FrameAnimation frameAnim: frameAnim
	readonly property ColorQuantizer colorQuant: ColorQuantizer {
		source: root.artUrl
		depth: 8
		rescaleSize: 64;
	}
	readonly property color accent: {
		// get avg hue and val
		let avgHue = 0; let avgVal = 0;

		root.colorQuant.colors.forEach(c => {
			avgHue += c.hsvHue;
			avgVal += c.hsvValue;
		});

		avgHue /= root.colorQuant.colors.length
		avgVal /= root.colorQuant.colors.length

		const colours = Array.from(root.colorQuant.colors)
		// filter out colours that don't meet min req
		.filter(c => (c.hsvSaturation > 0.5 && c.hsvValue > 0.1))
		// sort based on hue furthest from avg & highest sat/val
		.sort((a, b) => {
			//scoring weights
			const h = 0.5;
			const s = 0.25;
			const v = 1 -h -s; // DON'T MODIFY THIS LINE

			function getDiff(h) {
				const diff = Math.abs(h -avgHue);
				return Math.min(diff, 1-diff) *2;
			}

			function getScore(c) { return h *getDiff(c.hsvHue) +s *c.hsvSaturation +v *c.hsvValue; }

			return getScore(b) -getScore(a);
		});

		if (colours.length > 0) return colours[0];
		else if (avgHue < 0) return Qt.hsva(-1, 1.0, Math.max(Math.min(avgVal, 0.6), 0.3), 1.0);
		else return Qt.hsva(avgHue, 0.5, 0.5, 1.0);
	}
	readonly property color complementary: Qt.hsva((accent.hsvHue +0.5) %1, 0.75, 0.75, 1.0)

	property bool active
	property string title
	property string artist
	property url artUrl

	function updateTrack() {
		const t = player.trackTitle;
		root.title = t;
	}
	function updateArtist() {
		const a = player.trackArtist;
		root.artist = a;
	}
	function updateArtUrl() {
		const a = player.trackArtUrl;
		root.artUrl = a;
	}

	function loopState() {
		const states = [MprisLoopState.None, MprisLoopState.Playlist, MprisLoopState.Track];

		return states[(states.findIndex(s => s === root.player.loopState) +1) %states.length];
	}

	onPlayerChanged: {
		if (!root.player) grace.restart();
		else {
			root.updateTrack();
			root.updateArtist();
			root.updateArtUrl();
		}
	}

	// period where track props can be updated
	Timer { id: hold; interval: 500; }

	// period before player is inactive
	Timer { id: grace
		interval: 1000
		onTriggered: root.active = false;
	}

	Connections {
		target: player

		function onTrackTitleChanged() { if (player.trackTitle) {
			// prevent player going inactive
			root.active = true;
			grace.stop();
			hold.restart();

			root.updateTrack();
		} else grace.restart(); }

		function onTrackArtistChanged() { if (hold.running) { root.updateArtist(); }}

		function onTrackArtUrlChanged() { if (hold.running) { root.updateArtUrl(); }}
	}

	// update the active player's position while playing
	FrameAnimation { id: frameAnim
		running: root.player?.playbackState == MprisPlaybackState.Playing
		onTriggered: player.positionChanged();
	}

	Component.onCompleted: { if (frameAnim.running) {
		root.active = true;
		root.updateTrack();
		root.updateArtist();
		root.updateArtUrl();
	}}
}
