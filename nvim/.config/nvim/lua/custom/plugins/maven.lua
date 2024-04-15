return {
  'eatgrass/maven.nvim',
  cmd = { 'Maven', 'MavenExec' },
  dependencies = 'nvim-lua/plenary.nvim',
  config = function()
    require('maven').setup {
      executable = './mvnw',
    }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
