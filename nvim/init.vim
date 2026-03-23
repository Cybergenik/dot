syntax on

" Wild stuff, ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*

" Clipboard default
set clipboard+=unnamedplus

set noerrorbells
set backspace=indent,eol,start
set nohlsearch
set hidden
set nu
set norelativenumber
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set smartcase
set noswapfile
set wrap
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set scrolloff=8
set signcolumn=yes
set textwidth=80

" Neovide
if exists("g:neovide")
    " set guifont=*:h4
    " let g:neovide_scale_factor = 1.0
endif

"plugins here:
call plug#begin('~/.config/nvim/plugged')

"Auto Complete:
Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'master', 'do': ':TSUpdate'}

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' } "OMG they finally released v0.1!
Plug 'tweekmonster/gofmt.vim'
Plug 'tpope/vim-fugitive'
Plug 'paretje/vim-man'
" Plug 'lyuts/vim-rtags'
Plug 'mbbill/undotree'
Plug 'gruvbox-community/gruvbox'
Plug 'tpope/vim-projectionist'

" File manipulation (tree view)
Plug 'nvim-tree/nvim-web-devicons' " optional
Plug 'nvim-tree/nvim-tree.lua'

" Shell runners
Plug 'nvim-neotest/nvim-nio'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'tpope/vim-dispatch'
Plug 'timonv/vim-cargo'

Plug 'rust-lang/rust.vim'

" LSP Support
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lua'

"  Snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'rafamadriz/friendly-snippets'

Plug 'VonHeikemen/lsp-zero.nvim'

" Markdown, RUN: call mkdp#util#install()
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug', 'md', 'mdx']}

" Status bar:
Plug 'nvim-lualine/lualine.nvim'
" Icons in status bar
Plug 'kyazdani42/nvim-web-devicons'

" Debugger
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'leoluz/nvim-dap-go'

call plug#end()

lua require("nvim-tree-setup")

lua require("dapui").setup()
lua require("dap-go").setup()

colorscheme gruvbox

" highlight Normal guibg=none

" NeoSnippets:
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
	set conceallevel=2
endif

lua << EOF
require('lualine').setup {
    options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = { left = '|', right = '|'},
        section_separators = { left = '|', right = '|'},
    }
}

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.extend_lspconfig({
    sign_text = true,
    capabilities = require('cmp_nvim_lsp').default_capabilities()
})
local cmp = require('cmp')

cmp.setup({
sources = {
  {name = 'nvim_lsp'},
},
mapping = cmp.mapping.preset.insert({}),
})

require('mason').setup({})
require('mason-lspconfig').setup({
    -- Replace the language servers listed here 
    -- with the ones you want to install
    ensure_installed = {
      'rust_analyzer',
      'elixirls',
      'cmake',
      'gopls',
      'eslint'
    },
    handlers = {
      function(server_name)
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        require('lspconfig')[server_name].setup({
            capabilities = capabilities,
        })
      end,
    },
})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = false,
    float = true,
})

require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust", "javascript", "typescript", "python", "go", "vim", "haskell" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = { enable = true },
  textobjects = { enable = true },
}

require('telescope').setup { 
    defaults = {
        file_ignore_patterns = { "vendor", "changelog", "changes"},
    }
}

EOF

if executable('rg')
    let g:rg_derive_root='true'
endif

let mapleader = " "

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

"" deoplete
"let g:deoplete#enable_at_startup = 0
"
"" neosnippet
"let g:neosnippet#enable_completed_snippet = 1

let g:vim_be_good_log_file = 1
let g:vim_apm_log = 1
let loaded_matchparen = 1

" rust
let g:rust_clip_command = 'xclip -selection clipboard'

" Markdown:
" set to 1, nvim will open the preview window after entering the markdown buffer
" default: 0
let g:mkdp_auto_start = 0

" set to 1, the nvim will auto close current preview window when change
" from markdown buffer to another buffer
" default: 1
let g:mkdp_auto_close = 1

" set to 1, the vim will refresh markdown when save the buffer or
" leave from insert mode, default 0 is auto refresh markdown as you edit or
" move the cursor
" default: 0
let g:mkdp_refresh_slow = 1

" set to 1, the MarkdownPreview command can be use for all files,
" by default it can be use in markdown file
" default: 0
let g:mkdp_command_for_global = 0

" set to 1, preview server available to others in your network
" by default, the server listens on localhost (127.0.0.1)
" default: 0
let g:mkdp_open_to_the_world = 0

" use custom IP to open preview page
" useful when you work in remote vim and preview on local browser
" more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
" default empty
let g:mkdp_open_ip = ''

" specify browser to open preview page
" default: ''
let g:mkdp_browser = ''

" set to 1, echo preview page url in command line when open preview page
" default is 0
let g:mkdp_echo_preview_url = 1

" a custom vim function name to open preview page
" this function will receive url as param
" default is empty
let g:mkdp_browserfunc = ''

" options for markdown render
" mkit: markdown-it options for render
" katex: katex options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
" disable_sync_scroll: if disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
"   middle: mean the cursor position alway show at the middle of the preview page
"   top: mean the vim top viewport alway show at the top of the preview page
"   relative: mean the cursor position alway show at the relative positon of the preview page
" hide_yaml_meta: if hide yaml metadata, default is 1
" sequence_diagrams: js-sequence-diagrams options
" content_editable: if enable content editable for preview page, default: v:false
" disable_filename: if disable filename header for preview page, default: 0
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0
    \ }

" use a custom markdown style must be absolute path
" like '/Users/username/markdown.css' or expand('~/markdown.css')
let g:mkdp_markdown_css = ''

" use a custom highlight style must absolute path
" like '/Users/username/highlight.css' or expand('~/highlight.css')
let g:mkdp_highlight_css = ''

" use a custom port to start server or random for empty
let g:mkdp_port = ''

" preview page title
" ${name} will be replace with the file name
let g:mkdp_page_title = '「${name}」'

" recognized filetypes
" these filetypes will have MarkdownPreview... commands
let g:mkdp_filetypes = ['markdown', 'md', 'mdx']

let g:nvim_man_default_target = 'horizontal'

highlight Normal guibg=none

" Tree view 
nnoremap <leader>F :NvimTreeFindFile<Return>

" LSP 
nnoremap <leader>gr <cmd>tab split <bar> lua vim.lsp.buf.definition()<Return>
nnoremap <leader>gd <cmd>tab split <bar> lua vim.lsp.buf.definition()<Return>
nnoremap <leader>gq <cmd>lua vim.lsp.buf.format()<Return>
nnoremap <leader>y <cmd>lua vim.lsp.buf.code_action()<Return>
nnoremap <leader>r <cmd>lua vim.lsp.buf.rename()<Return>

" Term
nnoremap <leader>b :vertical Spawn<Return>

" Search
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>

" Debugger
nnoremap <leader>db <cmd>lua require('dap').toggle_breakpoint()<cr>
nnoremap <leader>dc <cmd>lua require('dap').continue()<cr>
nnoremap <leader>dr <cmd>lua require('dap').repl.open()<cr>
nnoremap <leader>dl <cmd>lua require('dap').run_last()<cr>
nnoremap <leader>dh <cmd>lua require('dap.ui.widget').hover()<cr>
nnoremap <leader>dp <cmd>lua require('dap.ui.widget').preview()<cr>

"Tabbing:
nmap <Leader>t :tabnew<Return>
nmap <S-Tab> :tabprev<Return>
nmap <Tab>   :tabnext<Return>

" Window commands
nmap <Leader>n <C-w>n
nmap <Leader>q <C-w>q

nmap <Leader>l <C-w>l
nmap <Leader>h <C-w>h
nmap <Leader>j <C-w>j
nmap <Leader>k <C-w>k

nmap <Leader><S-l> <C-w><S-l>
nmap <Leader><S-h> <C-w><S-h>
nmap <Leader><S-j> <C-w><S-j>
nmap <Leader><S-k> <C-w><S-k>

nnoremap <Leader>( :resize +5<CR>
nnoremap <Leader>) :resize -5<CR>
nnoremap <Leader>+ :vertical resize +5<CR>
nnoremap <Leader>- :vertical resize -5<CR>
