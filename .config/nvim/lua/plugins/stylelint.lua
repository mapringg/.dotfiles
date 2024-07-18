return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      stylelint_lsp = {
        settings = {
          stylelintplus = {
            autoFixOnSave = true,
          },
        },
        filetypes = { "css", "scss" },
      },
    },
  },
}
