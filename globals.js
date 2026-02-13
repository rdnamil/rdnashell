.pragma library

.import "utils.js" as Utils

var Settings = {
	debug: false,
	barIsTop: true
};

var Controls = {
	padding: 12,
	spacing: 4,
	radius: 8,
	iconSize: 16
};

var Font = {
	sans: "Adwaita Sans",
	mono: "JetBrainsMono Nerd Font"
}

var Colours = Utils.parseJsonFromFile("./theme/catppuccin.json")
