return {
  'mrcjkb/haskell-tools.nvim',
  dependencis = {
    'nvim-lua/plenary.nvim',
  },
  version = '^3', -- Recommended
  ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  init = function()
    vim.g.haskell_tools = {}
  end,
}

-- vim: ts=2 sts=2 sw=2 et
