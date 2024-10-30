-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    -- NOTE: To display the files tree
    'nvim-tree/nvim-tree.lua',
    opts = {
      sort = {
        sorter = 'case_sensitive',
      },
    },
    config = function()
      require('nvim-tree').setup()

      local api = require 'nvim-tree.api'

      vim.keymap.set('n', '<C-d>', api.tree.toggle, { desc = 'Toggle [D]rawer (tree)' })
      vim.keymap.set('n', '<C-f>', api.tree.find_file, { desc = '[F]ocus on current file in tree' })
    end,
    dependencies = {
      -- To Have icons in the tree
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
  },

  --  NOTE: To have the :G command
  {
    'tpope/vim-fugitive',
    config = function()
      vim.api.nvim_set_keymap('n', '<leader>g', ':lua ToggleFugitive()<CR>', { noremap = true, silent = true })

      function ToggleFugitive()
        -- Check if there is a window with a Fugitive buffer
        local is_fugitive_open = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
          if bufname:match 'fugitive://' then
            is_fugitive_open = true
            vim.api.nvim_win_close(win, true) -- Close the Fugitive window
            break
          end
        end

        if not is_fugitive_open then
          vim.cmd 'G' -- Open Fugitive if it's not already open
        end
      end
    end,
  },

  --  NOTE: To have a nice terminal in nvim
  {
    'akinsho/toggleterm.nvim',
    config = function()
      require('toggleterm').setup {
        open_mapping = [[<c-\>]],
      }

      -- Open Toggle term with double spaces
      vim.keymap.set('n', '<leader><leader>', ':ToggleTerm size=15<cr>', { silent = true })

      -- LazyGit in ToggleTerm
      local Terminal = require('toggleterm.terminal').Terminal

      local lg_cmd = 'lazygit -w $PWD'
      if vim.v.servername ~= nil then
        lg_cmd = string.format('NVIM_SERVER=%s lazygit -ucf ~/.config/nvim/lazygit.toml -w $PWD', vim.v.servername)
      end

      vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"

      local lazygit = Terminal:new {
        cmd = lg_cmd,
        count = 5,
        direction = 'float',
        float_opts = {
          border = 'double',
          width = function()
            return vim.o.columns - 20
          end,
          height = function()
            return vim.o.lines - 20
          end,
        },
        -- function to run on opening the terminal
        on_open = function(term)
          vim.cmd 'startinsert!'
          vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
        end,
      }

      function Edit(fn, line_number)
        local edit_cmd = string.format(':e %s', fn)
        if line_number ~= nil then
          edit_cmd = string.format(':e +%d %s', line_number, fn)
        end
        vim.cmd(edit_cmd)
      end

      function Lazygit_toggle()
        lazygit:toggle()
      end

      vim.keymap.set('n', '<leader>lg', '<cmd>lua Lazygit_toggle()<CR>', { silent = true })
    end,
  },
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function()
      vim.g.barbar_auto_setup = false
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }

      map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
      map('n', '<A-;>', '<Cmd>BufferNext<CR>', opts)
      map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
      map('n', '<A-C>', '<Cmd>BufferCloseAllButCurrent<CR>', opts)
    end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },
  {
    'mhinz/vim-startify',
  },
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = 'make',
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
}
