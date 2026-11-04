local builtin = require('telescope.builtin')
local map = vim.keymap.set

-- Telescope navigation maps (buffer-local)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach-keymaps', { clear = true }),
  callback = function(event)
    local buf = event.buf
    local opts = { buffer = buf, silent = true }
    map('n', 'grr', builtin.lsp_references, vim.tbl_extend('force', opts, { desc = 'Goto References' }))
    map('n', 'gri', builtin.lsp_implementations, vim.tbl_extend('force', opts, { desc = 'Goto Implementation' }))
    map('n', 'grd', builtin.lsp_definitions, vim.tbl_extend('force', opts, { desc = 'Goto Definition' }))
    map('n', 'gO', builtin.lsp_document_symbols, vim.tbl_extend('force', opts, { desc = 'Document Symbols' }))
    map('n', 'gW', builtin.lsp_dynamic_workspace_symbols, vim.tbl_extend('force', opts, { desc = 'Workspace Symbols' }))
    map('n', 'grt', builtin.lsp_type_definitions, vim.tbl_extend('force', opts, { desc = 'Goto Type Definition' }))
  end,
})

-- document highlighting + inlay hints on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end
    if client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end
    if client:supports_method('textDocument/inlayHint', event.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    end
  end,
})

-- bashls/basedpyright/yamlls/clangd are registered natively by
-- vim.languages.*.enable; nixd/nil_ls/lua_ls customizations and the
-- jdtls/R.nvim self-managed attach logic now live in lsp/full.nix and
-- lsp/default.nix via vim.lsp.servers, so there's nothing left to hand-roll
-- here.
