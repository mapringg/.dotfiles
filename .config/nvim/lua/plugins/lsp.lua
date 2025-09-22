return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      stylelint_lsp = {
        filetypes = { "html", "css", "less", "scss" },
        settings = {},
      },
    },
  },
}
