-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'
vim.opt.cursorcolumn = true
vim.opt.colorcolumn = '80'

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See :help 'list'
--  and :help 'listchars'
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Editor options
vim.opt.syntax = 'on' -- Turn on syntax highlighting
vim.opt.autoindent = true -- Copy indent from current line for next new line
vim.opt.smartindent = true
vim.opt.expandtab = true -- In insert mode space out the tab
vim.opt.shiftwidth = 4 -- Number of spaces for each step of (auto)indent
vim.opt.tabstop = 4 -- Number of spaces a <Tab> is
vim.opt.encoding = 'utf-8' -- Character encoding in vim
vim.opt.fileencoding = 'utf-8' -- Character encoding for file in buff
vim.opt.ruler = true -- Line and column number of cursor
vim.opt.title = true -- Show window title
vim.opt.hidden = true -- Hide buffer when abandoned
vim.opt.ttimeoutlen = 0 -- Time in ms key code or mapped key to complete
vim.opt.wildmenu = true -- Command-line completion operatis in an enhanced mode
vim.opt.showcmd = true -- Show (partial) command in last line of screen.
vim.opt.showmatch = true -- When bracket insert, briefly jump to matching one
vim.opt.termguicolors = true
vim.opt.hlsearch = true

if vim.fn.has 'win32' == 1 then
  vim.opt.shell = vim.fn.executable 'pwsh' and 'pwsh' or 'powershell'
  vim.opt.shellcmdflag =
    '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
  vim.opt.shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
  vim.opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
  vim.opt.shellquote = ''
  vim.opt.shellxquote = ''
elseif vim.fn.has 'mac' == 1 then
  vim.opt.shell = '/bin/zsh'
  vim.opt.shellcmdflag = '-c'
  vim.opt.shellredir = ''
  vim.opt.shellpipe = '2>&1 | tee %s >/dev/null; exit ${PIPESTATUS[0]}'
  vim.opt.shellquote = '\\'
  vim.opt.shellxquote = ''
elseif vim.fn.has 'bsd' == 1 then
  vim.opt.shell = '/usr/local/bin/zsh'
else
  vim.opt.shell = '/usr/bin/zsh'
end

-- vim: ts=2 sts=2 sw=2 et
