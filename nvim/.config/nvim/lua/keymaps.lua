-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- General
vim.keymap.set('n', '<leader>ww', ':w<CR>', { desc = 'Save current file' }) -- save
vim.keymap.set('n', '<leader>wq', ':wq<CR>', { desc = 'Save current file and quit nvim' }) -- save and quit
vim.keymap.set('n', '<leader>qq', ':q!<CR>', { desc = 'Quit without saving' }) -- quit without saving
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Buffer Next' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Buffer Previous' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Buffer Delete' })

-- Shortcuts
vim.keymap.set('i', '<C-F>', '<Esc>gUiw`]a', { desc = 'Uppercase typed word' })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See :help lua-guide-autocommands

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Define an autocmd group named "set_jenkins_groovy"
vim.cmd [[augroup set_jenkins_groovy]]
vim.cmd [[au!]]

-- Attach autocmd for BufNewFile, BufRead events on specific file patterns
vim.cmd [[au BufNewFile,BufRead *.jenkinsfile,*.Jenkinsfile,Jenkinsfile,jenkinsfile setf groovy]]

-- End the autocmd group
vim.cmd [[augroup END]]

-- Trouble
vim.keymap.set('n', '<leader>xx', function()
  require('trouble').toggle()
end, { desc = 'Trouble Toggle' })
vim.keymap.set('n', '<leader>xw', function()
  require('trouble').toggle 'workspace_diagnostics'
end, { desc = 'Trouble Worspace Diagnostics' })
vim.keymap.set('n', '<leader>xd', function()
  require('trouble').toggle 'document_diagnostics'
end, { desc = 'Trouble Document Diagnostics' })
vim.keymap.set('n', '<leader>xq', function()
  require('trouble').toggle 'quickfix'
end, { desc = 'Trouble QuickFix' })
vim.keymap.set('n', '<leader>xl', function()
  require('trouble').toggle 'loclist'
end, { desc = 'Trouble LocList' })
vim.keymap.set('n', 'gR', function()
  require('trouble').toggle 'lsp_references'
end, { desc = 'Trouble LSP References' })

-- Todo Comments
vim.keymap.set('n', ']t', function()
  require('todo-comments').jump_next()
end, { desc = 'Next todo comment' })

vim.keymap.set('n', '[t', function()
  require('todo-comments').jump_prev()
end, { desc = 'Previous todo comment' })

-- LazyGit
vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>', { desc = 'Lazy Git' })

-- vim: ts=2 sts=2 sw=2 et
