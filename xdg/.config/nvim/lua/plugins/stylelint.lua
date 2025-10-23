return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylelint-lsp",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        stylelint_lsp = {},
      },
    },
  },
}
