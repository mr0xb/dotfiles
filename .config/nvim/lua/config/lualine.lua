local M = {}

function M.setup()
    local lualine = require 'lualine'

    local conf = {
      options = {
        icons_enabled = true,
        theme = 'dracula-nvim',
      },
      sections = {
        lualine_x = {"aerial"},
      }
    }
    lualine.setup(conf)
end
return M
