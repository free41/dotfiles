-- ============================================================================
-- PLUGINS (lazy.nvim)
-- ============================================================================

require("lazy").setup({

  -- ==========================================================================
  -- Color Scheme: Everforest
  -- ==========================================================================
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_disable_italic_comment = 0
      vim.g.everforest_better_performance = 1
      vim.g.everforest_transparent_background = 2

      vim.cmd.colorscheme("everforest")

      -- Everforest Dark Hard palette
      local c = {
        comment = "#859289",
        grey0   = "#7a8478",
        aqua    = "#83c092",
        fg      = "#d3c6aa",
        blue    = "#7fbbb3",
        green   = "#a7c080",
        red     = "#e67e80",
      }

      vim.api.nvim_set_hl(0, "Comment",      { fg = c.comment, italic = true })
      vim.api.nvim_set_hl(0, "LineNr",       { fg = c.grey0 })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.aqua, bold = true })
      vim.api.nvim_set_hl(0, "MatchParen",   { fg = c.fg, bg = c.blue, bold = true })

      -- Neo-tree git status
      vim.api.nvim_set_hl(0, "NeoTreeGitAdded",     { fg = c.green })
      vim.api.nvim_set_hl(0, "NeoTreeGitModified",  { fg = c.blue })
      vim.api.nvim_set_hl(0, "NeoTreeGitDeleted",   { fg = c.red })
      vim.api.nvim_set_hl(0, "NeoTreeGitConflict",  { fg = c.red, bold = true })
      vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = c.grey0 })
    end,
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
    version = "*",
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
      { "<leader>s", ":Telescope lsp_workspace_symbols<CR>",      desc = "Workspace symbols" },
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
  -- Completion
  -- ==========================================================================
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = {
        preset    = "enter",
        ["<C-u>"] = { "scroll_documentation_up",   "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
        providers = {
          lsp = {
            -- Float kwargs (label ends with '=') to the top of the list
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                if item.label:match("=$") then
                  item.score_offset = (item.score_offset or 0) + 10
                end
              end
              return items
            end,
          },
        },
      },
    },
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
        theme = "everforest",
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

  -- ==========================================================================
  -- Claude Code
  -- ==========================================================================
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },

}, {
  ui = { border = "rounded" },
})
