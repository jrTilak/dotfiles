return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- VS Code–style side-by-side diff
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit Status" },
    },
    config = function()
      require("neogit").setup({
        -- General behavior
        disable_signs = false,
        disable_hint = false,
        disable_context_highlighting = false,
        disable_commit_confirmation = false,
        auto_refresh = true,

        -- Use Diffview for real split diffs
        integrations = {
          diffview = true,
        },

        -- UI polish
        kind = "tab", -- open Neogit in a tab (change to "split" if you prefer)
        commit_editor = {
          kind = "tab",
        },

        -- Section visibility (VS Code–like)
        sections = {
          untracked = { folded = false },
          unstaged = { folded = false },
          staged = { folded = false },
          stashes = { folded = true },
          unpulled = { folded = true },
          unmerged = { folded = false },
          recent = { folded = true },
        },
      })
    end,
  },
}
