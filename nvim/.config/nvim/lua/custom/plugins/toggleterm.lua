return {
  -- amongst your other plugins
  'akinsho/toggleterm.nvim',
  config = function()
    require('toggleterm').setup {
      open_mapping = [[<c-\>]],
      --direction = 'float',
      --float_opts = {
      --  border = 'curved',
      --  width = 80,
      --  height = 20,
      --  title_pos = 'center',
      --},
    }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
