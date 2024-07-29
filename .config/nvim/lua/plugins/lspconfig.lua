return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    servers = {
      emmet_language_server = {},
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
