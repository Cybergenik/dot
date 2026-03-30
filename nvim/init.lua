-- Set leaders before lazy loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Misc globals
vim.g.rg_derive_root = "true"
vim.g.vim_be_good_log_file = 1
vim.g.vim_apm_log = 1
vim.g.loaded_matchparen = 1
vim.g.rust_clip_command = "xclip -selection clipboard"
vim.g.nvim_man_default_target = "horizontal"

-- Neovide
if vim.g.neovide then
end

-- Vim options
vim.opt.wildignore:append({ "*.pyc", "*_build/*", "**/coverage/*", "**/node_modules/*", "**/android/*", "**/ios/*", "**/.git/*" })
vim.opt.clipboard:append("unnamedplus")
vim.opt.errorbells = false
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.hlsearch = false
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.smartcase = true
vim.opt.swapfile = false
vim.opt.wrap = true
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.textwidth = 80
vim.opt.conceallevel = 2
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
vim.opt.shortmess:append("c")
vim.opt.termguicolors = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- Colorscheme
vim.cmd.colorscheme("retrobox")
vim.cmd("highlight Normal guibg=none")

-- LSP keymaps
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>gd", "<cmd>tab split | lua vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "<leader>gq", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>y", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)

-- Tree view
vim.keymap.set("n", "<leader>F", "<cmd>NvimTreeFindFile<CR>")

-- Terminal
vim.keymap.set("n", "<leader>b", "<cmd>vertical Spawn<CR>")

-- Tabbing
vim.keymap.set("n", "<leader>t", "<cmd>tabnew<CR>")
vim.keymap.set("n", "<S-Tab>", "<cmd>tabprev<CR>")
vim.keymap.set("n", "<Tab>", "<cmd>tabnext<CR>")

-- Window commands
vim.keymap.set("n", "<leader>n", "<C-w>n")
vim.keymap.set("n", "<leader>q", "<C-w>q")

vim.keymap.set("n", "<leader>l", "<C-w>l")
vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>k", "<C-w>k")

vim.keymap.set("n", "<leader>L", "<C-w>L")
vim.keymap.set("n", "<leader>H", "<C-w>H")
vim.keymap.set("n", "<leader>J", "<C-w>J")
vim.keymap.set("n", "<leader>K", "<C-w>K")

-- Resize
vim.keymap.set("n", "<leader>(", "<cmd>resize +5<CR>")
vim.keymap.set("n", "<leader>)", "<cmd>resize -5<CR>")
vim.keymap.set("n", "<leader>+", "<cmd>vertical resize +5<CR>")
vim.keymap.set("n", "<leader>-", "<cmd>vertical resize -5<CR>")
