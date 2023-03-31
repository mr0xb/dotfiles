local M = {}

function M.setup()
	local winshift = require("winshift")
	local conf = {
    conf = {
      highlight_moving_win = true, --hl window when being moved
      focused_hl_group = "Visual", -- hl group for moving window
      moving_win_options = {
        wrap = false,
        cursorline = false,
        cusorcolumn = false,
        colorcolumn = "",
      }
       
    }
	}
  winshift.setup(conf)
end
return M
