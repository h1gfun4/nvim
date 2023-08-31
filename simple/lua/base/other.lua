local opt = vim.opt
local g = vim.g

opt.splitright = true
opt.clipboard = 'unnamedplus'
opt.fixeol = false
opt.completeopt = 'menuone,noselect'
vim.cmd [[autocmd BufEnter * set fo-=c fo-=r fo-=o]]

