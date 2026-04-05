return {
  {
    "ellisonleao/glow.nvim",
    ft = "markdown", -- load only for Markdown files
    config = function()
      require("glow").setup({
        style = "dark", -- match your dark theme
        width = 80, -- preview width
        height = 20, -- preview height
        border = "rounded", -- floating window border
        pager = false, -- use built-in floating window instead of external pager
      })
    end,
  },
}
