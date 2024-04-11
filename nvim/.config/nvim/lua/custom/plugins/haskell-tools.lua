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
