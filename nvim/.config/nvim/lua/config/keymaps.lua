-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.
-- Add any additional keymaps here
--

-- jk to exit insert mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode", noremap = true, silent = true })
