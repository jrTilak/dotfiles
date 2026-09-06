-- Omarchy-specific: Disable Snacks' animated scrolling for immediate movement.
return {
	"folke/snacks.nvim",
	opts = {
		scroll = {
			enabled = false, -- Disable scrolling animations
		},
	},
}
