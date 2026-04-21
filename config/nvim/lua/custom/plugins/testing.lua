return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-neotest/neotest-python',
      'fredrikaverpil/neotest-golang',
    },
    keys = {
      { '<leader>tn', function() require('neotest').run.run() end, desc = '[T]est nearest' },
      { '<leader>tf', function() require('neotest').run.run(vim.fn.expand '%') end, desc = '[T]est current [F]ile' },
      { '<leader>td', function() require('neotest').run.run { strategy = 'dap' } end, desc = '[T]est with [D]ebugger' },
      { '<leader>ts', function() require('neotest').summary.toggle() end, desc = '[T]est [S]ummary' },
      { '<leader>to', function() require('neotest').output.open { enter = true, auto_close = true } end, desc = '[T]est [O]utput' },
    },
    config = function()
      local python = require 'custom.python'

      require('neotest').setup {
        adapters = {
          require('neotest-python') {
            dap = { justMyCode = false },
            python = python.project_python,
            runner = 'pytest',
          },
          require('neotest-golang') {
            dap_mode = 'dap-go',
            go_test_args = { '-v', '-race', '-count=1' },
          },
        },
      }
    end,
  },
}
