return {
  'mfussenegger/nvim-lint',
  optional = true,
  opts = {
    linters_by_ft = {
      cmake = { 'cmakelint' },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
