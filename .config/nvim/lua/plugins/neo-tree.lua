return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = false,
          always_show_by_pattern = {
            ".env*",
          },
        },
      },
    },
  },
}
