return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      custom_highlights = function()
        return {
          TelescopeNormal = { bg = "none" },
          TelescopeBorder = { bg = "none" },
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          -- for snacks picker (LazyVim default)
          SnacksPickerNormal = { bg = "none" },
          SnacksPickerBorder = { bg = "none" },
        }
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
