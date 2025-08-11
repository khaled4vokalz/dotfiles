local wezterm = require("wezterm")

return {
	font_size = 14,
	font = wezterm.font_with_fallback({
		{ family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
		{ family = "JetBrainsMono Nerd Font Mono", weight = "Bold" },
		{ family = "JetBrainsMono Nerd Font Mono", style = "Italic" },
		{ family = "JetBrainsMono Nerd Font Mono", weight = "Bold", style = "Italic" },
	}),
}
