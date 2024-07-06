-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Add border for diagnostics float
vim.diagnostic.config({
  float = {
    border = "rounded",
  },
})

-- Make the cmp menu transparent
vim.opt.pumblend = 0
