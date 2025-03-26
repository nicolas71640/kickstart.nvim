-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    -- NOTE: To display the files tree
    'nvim-tree/nvim-tree.lua',
    lazy = true,
    opts = {
      sort = {
        sorter = 'case_sensitive',
      },
    },
    config = function()
      require('nvim-tree').setup {
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        filters = {
          dotfiles = false,
          custom = { '.git' }, -- Hide .git folder
        },
      }

      local api = require 'nvim-tree.api'
      local is_half = false

      function ToggleNvimTreeSize()
        local normal_width = 30 -- Taille standard
        local half_width = math.floor(vim.o.columns / 2) -- La moitié de la fenêtre

        if is_half then
          api.tree.open { find_file = true, focus = true } -- S'assurer que NvimTree est ouvert
          api.tree.resize { width = normal_width } -- Agrandir à la moitié de l'écran
          --    api.tree.resize(normal_width) -- Revenir à la taille normale
          is_half = false
        else
          api.tree.open { find_file = true, focus = true } -- S'assurer que NvimTree est ouvert
          api.tree.resize { width = half_width } -- Agrandir à la moitié de l'écran
          is_half = true
        end
      end

      vim.keymap.set('n', '<leader>dr', ToggleNvimTreeSize, { noremap = true, silent = true, desc = '[d]rawer [r]esize' })
      vim.keymap.set('n', '<C-t>', api.tree.toggle, { desc = 'Toggle [D]rawer (tree)' })
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
      vim.api.nvim_set_keymap('n', '<leader>dg', ':diffget<CR>', { desc = '[d]iff [g]et' })
      vim.api.nvim_set_keymap('n', '<leader>dp', ':diffput<CR>', { desc = '[d]iff [p]et' })

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
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    init = function()
      require('lualine').setup()
    end,
  },
  -- For view in hexadecimal
  {
    'RaafatTurki/hex.nvim',
    init = function()
      require('hex').setup()
    end,
  },
  -- Project manager
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup {
        detection_methods = { 'pattern' }, -- Use patterns to detect project roots
        patterns = { '.git', 'Makefile', 'package.json', 'pyproject.toml' }, -- Root files to detect
      }

      require('telescope').load_extension 'projects'

      vim.keymap.set('n', '<leader>sp', '<cmd>Telescope projects<CR>', { desc = '[S]earch for [P]rojects' })
    end,
  },
  {
    'andythigpen/nvim-coverage',
    opts = {
      lcov_file = 'build_pc/coverage_lcov.total',
    },
    requires = 'nvim-lua/plenary.nvim',
    -- Optional: needed for PHP when using the cobertura parser
    rocks = { 'lua-xmlreader' },
    config = function()
      local lcov_file = 'build_pc/coverage_lcov.total'
      require('coverage').setup {
        vim.keymap.set('n', '<leader>cl', '<cmd>CoverageLoadLcov ' .. lcov_file .. '<CR><cmd>CoverageShow <CR>', { desc = '[C]overage [l]cov ' }),
      }
    end,
  },
  {
    'sindrets/diffview.nvim',
  },
  -- To have icons in the dropdown menu of autocompletion
  {
    'onsails/lspkind.nvim',
  },

  {
    'tpope/vim-obsession',
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    'folke/zen-mode.nvim',
    setup = {
      vim.api.nvim_set_keymap('n', '<leader>z', ':ZenMode<CR>', { noremap = true, silent = true }),
    },
    opts = {

      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      plugins = {
        -- disable some global vim options (vim.o...)
        -- comment the lines to not apply the options
        options = {
          enabled = true,
          ruler = false, -- disables the ruler text in the cmd line area
          showcmd = false, -- disables the command in the last line of the screen
          -- you may turn on/off statusline in zen mode by setting 'laststatus'
          -- statusline will be shown only if 'laststatus' == 3
          laststatus = 0, -- turn off the statusline in zen mode
        },
        twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
        gitsigns = { enabled = false }, -- disables git signs
        tmux = { enabled = true }, -- disables the tmux statusline
      },
    },
  },

  {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',

      -- see below for full list of optional dependencies 👇
    },
    opts = {
      workspaces = {
        {
          name = 'personal',
          path = '~/Documents/Notes/',
        },
      },
    },
  },

  --  {
  --    'rmagatti/auto-session',
  --    config = function()
  --      require('auto-session').setup {
  --        log_level = 'error',
  --        auto_session_enable_last_session = true,
  --        auto_session_enabled = true,
  --        auto_save_enabled = true,
  --        auto_restore_enabled = true,
  --        pre_save_cmds = { 'NvimTreeClose' }, -- Close nvim-tree before saving
  --      }
  --
  --      local function open_nvim_tree()
  --        require('nvim-tree.api').tree.open()
  --      end
  --
  --      vim.api.nvim_create_autocmd('VimEnter', {
  --        callback = function()
  --          if vim.fn.argc() == 0 then
  --            open_nvim_tree()
  --          end
  --        end,
  --      })
  --    end,
  --  },
  --
  {
    'ThePrimeagen/vim-be-good',
    cmd = 'VimBeGood',
  },
}
