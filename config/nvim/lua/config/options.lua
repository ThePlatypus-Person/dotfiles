-- OPTIONS
local set = vim.opt
set.termguicolors = true

set.number = true
set.relativenumber = true
set.cursorline = true
set.shiftwidth = 4

-- Folding
set.foldmethod = "indent"
set.foldenable = true
set.foldlevel = 99

-- search settings
set.ignorecase = true
set.smartcase = true

-- appearance
set.termguicolors = true
set.background = "dark"
set.signcolumn = "yes"

-- cursor line
set.cursorline = true

-- 80th column
set.colorcolumn = "80"

-- clipboard
set.clipboard:append("unnamedplus")

-- backspace
set.backspace = "indent,eol,start"

-- keep cursor at least 8 rows from top/bot
set.scrolloff = 8

-- incremental search
set.hlsearch = true
set.incsearch = true

-- No Linewrap
set.wrap = false

-- undo dir settings
set.swapfile = false
set.backup = false
set.undodir = os.getenv("HOME") .. "/.vim/undodir"
set.undofile = true

-- faster cursor hold
set.updatetime = 50
