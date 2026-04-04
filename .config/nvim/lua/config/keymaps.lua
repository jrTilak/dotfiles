-- Toggle Markdown preview in floating window
vim.keymap.set("n", "<leader>mt", ":Glow<CR>", { desc = "Markdown Terminal Preview" })

-- Insert mode: delete word backward (no clipboard)
vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word backward", noremap = true, silent = true })
vim.keymap.set("i", "<C-H>", "<C-w>", { desc = "Delete word backward", noremap = true, silent = true })

-- Normal mode: delete word backward (no clipboard) + drop into Insert mode
vim.keymap.set("n", "<C-BS>", '"_dbi', { desc = "Delete word backward + insert", noremap = true, silent = true })
vim.keymap.set("n", "<C-H>", '"_dbi', { desc = "Delete word backward + insert", noremap = true, silent = true })

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
