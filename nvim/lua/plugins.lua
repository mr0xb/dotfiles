local M = {}

function M.setup()
  -- Indicate first time installation
  local packer_bootstrap = false
  -- packer.nvim configuration
	--
  local conf = {
    display = {
      open_fn = function()
        return require("packer.util").float { border = "rounded" }
      end,
    },
  }

  -- Check if packer.nvim is installed
  -- Run PackerCompile if there are changes in this file
  local function packer_init()
    local fn = vim.fn
    local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
      packer_bootstrap = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
      }
      vim.cmd [[packadd packer.nvim]]
    end
    vim.cmd "autocmd BufWritePost plugins.lua source <afile> | PackerCompile"
  end
  -- Plugins
  local function plugins(use)
    use { "wbthomason/packer.nvim" }
    -- rainbow brackets
    use { 'frazrepo/vim-rainbow' }
    use { "p00f/nvim-ts-rainbow" }
    use { "tpope/vim-surround" }
    use { "danilamihailov/beacon.nvim" }
    use {
        'VonHeikemen/lsp-zero.nvim',
          requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
          }
  	    }

    use {
        'nvim-treesitter/nvim-treesitter',
          run = function()
            require('nvim-treesitter.install').update({ with_sync = true })
          end,
          config = function()
            require('config.nvim-treesitter').setup()
          end,
        }
    use {
        'stevearc/aerial.nvim',
    }
    use {
        'sindrets/winshift.nvim',
          config = function()
            require('config.winshift').setup()
          end,
        }
    -- Better icons
    use {
        "kyazdani42/nvim-web-devicons",
          module = "nvim-web-devicons",
          config = function()
            require("nvim-web-devicons").setup { default = true }
          end,
        }
    -- dracula-vim
    use {
        'Mofiqul/dracula.nvim',
          config = function()
            require('config.dracula-vim').setup()
          end,
        }
    -- nvim-tree
    use {
        'kyazdani42/nvim-tree.lua',
          config = function()
              require('config.nvim-tree').setup()
          end,
        }

    -- lua-line
    use {
        'nvim-lualine/lualine.nvim',
          config = function()
            require("config.lualine").setup()
          end,
        }

    -- WhichKey
    use {
      "folke/which-key.nvim",
      config = function()
        require("config.whichkey").setup()
      end,
    }

    --dashboard-nvim
    use {
      'glepnir/dashboard-nvim',
      config = function()
        require("config.dashboard")
      end,
    }
    -- Bootstrap Neovim
    if packer_bootstrap then
      print "Restart Neovim required after installation!"
      require("packer").sync()
    end
  end

  packer_init()

  local packer = require "packer"
  packer.init(conf)
  packer.startup(plugins)
  local lsp = require('lsp-zero')
  lsp.preset('recommended')
  lsp.nvim_workspace()
  lsp.setup{
    on_attach = require("aerial").on_attach,
  }
end

return M.setup()
