return {
  'luc-tielen/telescope_hoogle',
  ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  dependencies = {
    { 'nvim-telescope/telescope.nvim' },
  },
  config = function()
    local ok, telescope = pcall(require, 'telescope')
    if ok then
      telescope.load_extension 'hoogle'
    end
  end,
}
