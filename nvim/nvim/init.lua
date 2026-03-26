-- ============================================================================
-- NEOVIM CONFIGURATION
-- ============================================================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader before plugins (lazy.nvim requirement)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load config modules
require("options")
require("plugins")
require("keymaps")  -- after plugins so plugin keymaps are available
require("lsp")      -- native LSP: ty + ruff (no plugins needed)
