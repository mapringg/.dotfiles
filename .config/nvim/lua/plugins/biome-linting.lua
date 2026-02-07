local function biome_fix_all(bufnr, client)
  local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
  params.context = {
    only = { "source.fixAll.biome" },
    diagnostics = {},
  }

  local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
  if not results then
    return
  end

  for _, result in pairs(results) do
    for _, action in ipairs(result.result or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      elseif action.command then
        client:exec_cmd(action.command)
      end
    end
  end
end

local function biome_organize_imports(bufnr, client)
  local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
  params.context = {
    only = { "source.organizeImports.biome" },
    diagnostics = {},
  }

  local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
  if not results then
    return
  end

  for _, result in pairs(results) do
    for _, action in ipairs(result.result or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      elseif action.command then
        client:exec_cmd(action.command)
      end
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "biome" then
            return
          end

          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function(event)
              biome_organize_imports(event.buf, client)
              vim.cmd("redraw")
              biome_fix_all(event.buf, client)
              vim.cmd("redraw")
            end,
          })
        end,
      })
    end,
  },
}
