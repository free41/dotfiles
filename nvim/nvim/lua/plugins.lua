-- ============================================================================
-- PLUGINS (lazy.nvim)
-- ============================================================================

-- Nord palette — single source of truth for all color references below
local c = {
  -- Polar Night
  nord0  = "#2E3440",
  nord1  = "#3B4252",
  nord2  = "#434C5E",
  nord3  = "#4C566A",
  -- Snow Storm
  nord4  = "#D8DEE9",
  nord5  = "#E5E9F0",
  nord6  = "#ECEFF4",
  -- Frost
  nord7  = "#8FBCBB",
  nord8  = "#88C0D0",
  nord9  = "#81A1C1",
  nord10 = "#5E81AC",
  -- Aurora
  nord11 = "#BF616A",  -- red
  nord12 = "#D08770",  -- orange
  nord13 = "#EBCB8B",  -- yellow
  nord14 = "#A3BE8C",  -- green
  nord15 = "#B48EAD",  -- purple
  -- Custom
  comment = "#616E88",
}

require("lazy").setup({

  -- ==========================================================================
  -- Color Scheme: Nord
  -- ==========================================================================
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = true
      vim.g.nord_italic = false
      vim.g.nord_bold = false
      vim.g.nord_uniform_diff_background = true
      vim.g.nord_enable_sidebar_background = true
      vim.g.nord_cursorline_transparent = false
      vim.g.nord_disable_background = true

      require("nord").set()

      vim.api.nvim_set_hl(0, "Comment",      { fg = c.comment, italic = true })
      vim.api.nvim_set_hl(0, "LineNr",       { fg = c.nord3 })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.nord8, bold = true })
      vim.api.nvim_set_hl(0, "MatchParen",   { fg = c.nord6, bg = c.nord10, bold = true })

      -- Neo-tree git status
      vim.api.nvim_set_hl(0, "NeoTreeGitAdded",     { fg = c.nord14 })
      vim.api.nvim_set_hl(0, "NeoTreeGitModified",  { fg = c.nord9 })
      vim.api.nvim_set_hl(0, "NeoTreeGitDeleted",   { fg = c.nord11 })
      vim.api.nvim_set_hl(0, "NeoTreeGitConflict",  { fg = c.nord11, bold = true })
      vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = c.nord3 })
    end,
  },

  -- ==========================================================================
  -- Markdown: visual heading backgrounds and code block shading
  -- ==========================================================================
  -- nord.nvim defines Headline1-6, CodeBlock, Dash, Quote automatically
  {
    "lukas-reineke/headlines.nvim",
    ft = { "markdown", "org", "norg" },
    opts = {
      markdown = {
        headline_highlights = {
          "Headline1", "Headline2", "Headline3",
          "Headline4", "Headline5", "Headline6",
        },
        codeblock_highlight = "CodeBlock",
        dash_highlight       = "Dash",
        quote_highlight      = "Quote",
      },
    },
  },

  -- ==========================================================================
  -- Navigation
  -- ==========================================================================

  -- Seamless vim/tmux pane navigation with Ctrl+hjkl
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft", "TmuxNavigateDown",
      "TmuxNavigateUp",   "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },

  -- File tree: replaces NERDTree. Same <leader>n toggle.
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>n", ":Neotree toggle<CR>", desc = "Toggle file tree" },
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { ".git", "__pycache__", "node_modules", ".egg-info" },
        },
        follow_current_file = { enabled = true },
      },
      window = { width = 30 },
    },
  },

  -- Code outline: replaces Tagbar. LSP-aware, no ctags needed. Same <leader>t.
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>t", ":AerialToggle right<CR>", desc = "Toggle code outline" },
    },
    opts = {
      autoscroll = "nearest",
      autojump = true,
      close_automatic_events = { "unfocus" },
      layout = { default_direction = "right" },
    },
  },

  -- ==========================================================================
  -- Fuzzy Finder: replaces fzf.vim. Same keybindings.
  -- ==========================================================================
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>f", ":Telescope find_files<CR>",                desc = "Find files" },
      { "<C-p>",     ":Telescope find_files<CR>",                desc = "Find files" },
      { "<leader>b", ":Telescope buffers<CR>",                   desc = "Buffers" },
      { "<leader>g", ":Telescope live_grep<CR>",                 desc = "Live grep" },
      { "<leader>/", ":Telescope current_buffer_fuzzy_find<CR>", desc = "Buffer search" },
      { "<leader>s", ":Telescope lsp_document_symbols<CR>",      desc = "Symbols" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_config = { width = 0.9, height = 0.6 },
          preview = { treesitter = false },
          file_ignore_patterns = { "^.git/", "__pycache__/", "node_modules/" },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case",
            "--follow", "--glob=!.git/*",
          },
        },
        pickers = {
          find_files = {
            find_command = {
              "git", "ls-files", "--cached", "--others", "--exclude-standard",
            },
            hidden = true,
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- ==========================================================================
  -- Editing
  -- ==========================================================================

  -- Commenting: replaces vim-commentary. Same gc / <C-_> bindings.
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
      local api = require("Comment.api")
      -- Ctrl+/ (terminals send Ctrl+_ for Ctrl+/)
      vim.keymap.set("n", "<C-_>", api.toggle.linewise.current,
        { noremap = true, silent = true })
      vim.keymap.set("v", "<C-_>",
        "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
        { noremap = true, silent = true })
    end,
  },

  -- Surround: replaces vim-surround. Same ys/cs/ds bindings.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- ==========================================================================
  -- Git
  -- ==========================================================================
  { "tpope/vim-fugitive", cmd = { "Git", "G" } },

  -- ==========================================================================
  -- Minimap: replaces minimap.vim. Pure Lua, no binary needed.
  -- ==========================================================================
  {
    "echasnovski/mini.map",
    version = "*",
    keys = {
      { "<leader>m", function() require("mini.map").toggle() end, desc = "Toggle minimap" },
    },
    config = function()
      local map = require("mini.map")
      map.setup({
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diagnostic(),
        },
        symbols = {
          encode = map.gen_encode_symbols.dot("4x2"),
        },
        window = {
          width = 10,
          winblend = 15,
        },
      })
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function() map.open() end,
      })
    end,
  },

  -- ==========================================================================
  -- Statusline
  -- ==========================================================================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "nord",
        component_separators = { left = "|", right = "|" },
        section_separators   = { left = "",  right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype", "encoding" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

}, {
  ui = { border = "rounded" },
})
