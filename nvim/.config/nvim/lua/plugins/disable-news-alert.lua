-- Omarchy-specific: Keep the preconfigured editor quiet by disabling LazyVim
-- and Neovim news notifications.
return {
	"LazyVim/LazyVim",
	opts = {
		news = {
			lazyvim = false,
			neovim = false,
		},
	},
}
