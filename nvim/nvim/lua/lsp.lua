-- ============================================================================
-- LSP CONFIGURATION (Neovim 0.11+ native API)
-- Install servers via uv:
--   uv tool install ty
--   uv tool install ruff
-- ============================================================================

-- Neovim 0.11 unconditionally calls vim.treesitter.start() in hover floats.
-- Wrap it so a missing parser falls back to basic syntax instead of erroring.
local _ts_start = vim.treesitter.start
vim.treesitter.start = function(bufnr, lang)
  local ok = pcall(_ts_start, bufnr, lang)
  if not ok then
    pcall(function() vim.bo[bufnr].syntax = lang end)
  end
end

-- ty: type checking (https://docs.astral.sh/ty/editors/#neovim)
vim.lsp.config('ty', {
  cmd          = { 'ty', 'server' },
  filetypes    = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
})
vim.lsp.enable('ty')

-- ruff: linting + formatting (https://docs.astral.sh/ruff/editors/setup/#neovim)
vim.lsp.config('ruff', {
  cmd          = { 'ruff', 'server' },
  filetypes    = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
})
vim.lsp.enable('ruff')

-- pyright: completions only (ty owns diagnostics/hover, ruff owns lint)
vim.lsp.config('pyright', {
  cmd          = { 'pyright-langserver', '--stdio' },
  filetypes    = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
  settings = {
    pyright = {
      -- disable pyright's own diagnostics; ty handles those
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        diagnosticMode   = 'off',
        typeCheckingMode = 'off',
      },
    },
  },
})
vim.lsp.enable('pyright')

-- Disable ruff's hover so ty handles it (ty owns type info, ruff owns lint)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('ruff_no_hover', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end
    if client and client.name == 'pyright' then
      client.server_capabilities.hoverProvider              = false
      client.server_capabilities.diagnosticProvider         = false
      client.server_capabilities.referencesProvider         = false
      client.server_capabilities.definitionProvider         = false
      client.server_capabilities.typeDefinitionProvider     = false
      client.server_capabilities.implementationProvider     = false
      client.server_capabilities.renameProvider             = false
      -- Ensure '(' and ',' trigger kwarg completions
      local cp = client.server_capabilities.completionProvider
      if cp then
        cp.triggerCharacters = vim.list_extend(cp.triggerCharacters or {}, { '(', ',' })
      end
    end
  end,
})

-- Keybindings applied whenever any LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp_keymaps', { clear = true }),
  callback = function(ev)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = ev.buf, silent = true, desc = desc })
    end

    -- Navigation (matches old coc.nvim bindings)
    map('gd', vim.lsp.buf.definition,      'Go to definition')
    map('gy', vim.lsp.buf.type_definition,  'Go to type definition')
    map('gi', vim.lsp.buf.implementation,  'Go to implementation')
    map('gr', vim.lsp.buf.references,      'References')
    map('K',  vim.lsp.buf.hover,           'Hover docs')

    -- Diagnostics (matches old [g / ]g)
    map('[g', vim.diagnostic.goto_prev, 'Previous diagnostic')
    map(']g', vim.diagnostic.goto_next, 'Next diagnostic')

    -- Refactoring
    map('<leader>rn', vim.lsp.buf.rename,      'Rename symbol')
    map('<leader>qf', vim.lsp.buf.code_action, 'Code action / quickfix')

    -- Format with ruff
    map('<leader>F', function()
      vim.lsp.buf.format({ async = true })
    end, 'Format buffer')
  end,
})

-- Diagnostic display
vim.diagnostic.config({
  virtual_text     = { prefix = '●' },
  signs            = true,
  underline        = true,
  update_in_insert = false,
  float            = { border = 'rounded' },
})
