return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      graphql = {},
      stylelint_lsp = {
        filetypes = { "html", "css", "less", "scss" },
        settings = {},
      },
    },
  },
}
