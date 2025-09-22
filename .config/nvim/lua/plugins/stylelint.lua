local supported = {
  "scss",
  "less",
  "css",
  "sass",
}

local M = {}

--- Checks if a stylelint config can be found for the given context
---@param ctx ConformCtx
function M.has_config(ctx)
  vim.fn.system({ "stylelint", "--print-config", ctx.filename })
  return vim.v.shell_error == 0
end

M.has_config = LazyVim.memoize(M.has_config)

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        stylelint_lsp = {
          filetypes = supported,
        },
      },
    },
  },

  -- mason
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "stylelint" } },
  },

  -- conform
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "stylelint")
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.stylelint = {
        condition = function(_, ctx)
          return M.has_config(ctx)
        end,
      }
    end,
  },

  -- none-ls support
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.stylelint)
    end,
  },
}
