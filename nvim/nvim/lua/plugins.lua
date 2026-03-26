-- ============================================================================
-- PLUGINS (lazy.nvim)
-- ============================================================================

require("lazy").setup({

  -- ==========================================================================
  -- Color Scheme: Nord
  -- ==========================================================================
  -- See all options: https://github.com/shaunsingh/nord.nvim#configuration
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Set before calling nord.set()
      vim.g.nord_contrast = true              -- darker bg on non-focused windows
      vim.g.nord_borders = true               -- visible borders between splits
      vim.g.nord_italic = false               -- disable italics
      vim.g.nord_bold = true
      vim.g.nord_uniform_diff_background = true
      vim.g.nord_enable_sidebar_background = true
      vim.g.nord_cursorline_transparent = false

      require("nord").set()

      -- Fine-tune specific highlights after loading.
      -- Nord palette:
      --   nord0=#2E3440  nord1=#3B4252  nord2=#434C5E  nord3=#4C566A
      --   nord4=#D8DEE9  nord5=#E5E9F0  nord6=#ECEFF4
      --   nord7=#8FBCBB  nord8=#88C0D0  nord9=#81A1C1  nord10=#5E81AC
      --   nord11=#BF616A nord12=#D08770 nord13=#EBCB8B
      --   nord14=#A3BE8C nord15=#B48EAD
      vim.api.nvim_set_hl(0, "Comment",      { fg = "#616E88", italic = true })
      vim.api.nvim_set_hl(0, "LineNr",       { fg = "#4C566A" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#88C0D0", bold = true })
      vim.api.nvim_set_hl(0, "MatchParen",   { fg = "#ECEFF4", bg = "#5E81AC", bold = true })
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
