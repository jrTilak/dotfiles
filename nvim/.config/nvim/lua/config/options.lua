-- Omarchy-specific: Load remote clipboard support before lazy.nvim starts.
-- The remaining settings are regular LazyVim user options.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = true
vim.g.autoformat = true
