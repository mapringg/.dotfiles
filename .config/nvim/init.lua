-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.syntax = 'enable'
vim.opt.mouse = 'a'
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Filetype detection
vim.cmd('filetype plugin indent on')

-- Disable netrw (default file explorer) to avoid conflicts if plugins are added later
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Make background transparent
vim.cmd('highlight Normal guibg=NONE ctermbg=NONE')
vim.cmd('highlight NonText guibg=NONE ctermbg=NONE')
vim.cmd('highlight NormalNC guibg=NONE ctermbg=NONE')
vim.cmd('highlight EndOfBuffer guibg=NONE ctermbg=NONE')

-- Disable statusline for minimal look
vim.opt.laststatus = 0
