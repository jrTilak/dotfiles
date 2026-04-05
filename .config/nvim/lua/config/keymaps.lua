-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle Markdown preview in floating window
vim.keymap.set("n", "<leader>mt", ":Glow<CR>", { desc = "Markdown Terminal Preview" })

-- Ctrl + Backspace
vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word backward", noremap = true, silent = true })
vim.keymap.set("i", "<C-H>", "<C-w>", { desc = "Delete word backward", noremap = true, silent = true })

vim.keymap.set("n", "<C-BS>", '"_dbi', { desc = "Delete word backward + insert", noremap = true, silent = true })
vim.keymap.set("n", "<C-H>", '"_dbi', { desc = "Delete word backward + insert", noremap = true, silent = true })

-- Ctrl + Delete
vim.keymap.set("i", "<C-Delete>", "<C-o>dw", { desc = "Delete word forward", noremap = true, silent = true })
vim.keymap.set("n", "<C-Delete>", '"_dwe', { desc = "Delete word forward + insert", noremap = true, silent = true })

-- jk to exit insert mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode", noremap = true, silent = true })
