return {
  'jim-fx/sudoku.nvim',
  cmd = 'Sudoku',
  config = function()
    require('sudoku').setup {
      -- configuration ...
    }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
