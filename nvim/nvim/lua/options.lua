-- ============================================================================
-- OPTIONS
-- ============================================================================

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.showcmd = true
opt.wildmenu = true
opt.showmatch = true
opt.laststatus = 2
opt.timeoutlen = 300
opt.signcolumn = "yes"    -- always show sign column (prevents layout shift)
opt.scrolloff = 5         -- keep 5 lines visible above/below cursor

-- True color (always available in Neovim)
opt.termguicolors = true
opt.background = "dark"

-- Search
opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Indentation
opt.autoindent = true
opt.smartindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- Files
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.autoread = true
opt.backspace = "indent,eol,start"

-- Spell
opt.spelllang = "en_us"
opt.spellfile = vim.fn.expand("~/.config/nvim/spell/en.utf-8.add")

-- Clipboard
opt.clipboard = "unnamedplus"

-- Backup
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Mouse
opt.mouse = "a"

-- Performance
opt.updatetime = 500

-- Split behavior
opt.splitright = true
opt.splitbelow = true

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

local autocmd = vim.api.nvim_create_autocmd

-- Auto-reload files changed outside neovim
autocmd({ "FocusGained", "BufEnter" }, { command = "checktime" })
autocmd("CursorHold", { command = "checktime" })

-- Markdown: wrap at 80 chars + spell
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.spell = true
    vim.opt_local.formatoptions:append("t")
  end,
})

-- Spell check for text-like files
autocmd("FileType", {
  pattern = { "text", "gitcommit", "rst", "yml", "yaml" },
  callback = function()
    vim.opt_local.spell = true
  end,
})
