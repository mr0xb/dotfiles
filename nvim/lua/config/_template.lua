local M = {}

function M.setup()
	local {PLUGIN} = require({PLUGIN})
	local conf = {
    conf = {

    }
	}
  {PLUGIN}.setup(conf)
end
return M
