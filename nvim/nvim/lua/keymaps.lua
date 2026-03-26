-- ============================================================================
-- KEYMAPS
-- ============================================================================
-- Plugin-specific keymaps are defined inline in plugins.lua.
-- This file covers all non-plugin bindings.

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Buffer navigation
map("n", "<leader>h", ":bprevious<CR>", opts)
map("n", "<leader>l", ":bnext<CR>", opts)

-- Window navigation (in addition to Ctrl+hjkl via vim-tmux-navigator)
map("n", "<leader>j", "<C-w>j", opts)
map("n", "<leader>k", "<C-w>k", opts)

-- Quick save
map("n", "<leader>w", ":w<CR>", opts)

-- Reload file
map("n", "<leader>r", ":edit<CR>", opts)

-- Window management (mirrors tmux Prefix bindings)
map("n", "<C-w>s", ":split<CR>", opts)
map("n", "<C-w>v", ":vsplit<CR>", opts)
map("n", "<C-w>q", ":q<CR>", opts)
map("n", "<C-w>0", ":tabfirst<CR>", opts)
map("n", "<C-w>=", "<C-w>=", opts)
map("n", "<C-w>_", "<C-w>_", opts)

-- Clear search highlighting
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- Spell check shortcuts
map("n", "<leader>sp", ":setlocal spell!<CR>", opts)
map("n", "<leader>sn", "]s", opts)
map("n", "<leader>sb", "[s", opts)
map("n", "<leader>sa", "zg", opts)
map("n", "<leader>s?", "z=", opts)
