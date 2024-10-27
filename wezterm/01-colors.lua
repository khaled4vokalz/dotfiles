local color_assets = require("97-assets").colors

return {
	colors = {
		tab_bar = {
			active_tab = { bg_color = color_assets.lt_orange, fg_color = color_assets.lt_black },
			inactive_tab = { bg_color = color_assets.cool_gray, fg_color = color_assets.warm_white },
			inactive_tab_hover = {
				bg_color = color_assets.nut_gray,
				fg_color = color_assets.lt_gray,
				italic = true,
			},
		},
	},
}
