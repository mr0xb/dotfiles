local M = {}

function M.setup()
	local colors = require('dracula').colors()
	local sitter = require("nvim-treesitter.configs")
	local conf = {
		ensure_installed = "all",
		sync_install = false,
		ignore_install = {""},
		matchup = {
			enable = true,
			disable_virtual_text = true,
		},
		highlight = {
			enable = true,
			disable = {},
      additional_vim_regex_highlighting = true,
		},
		autopairs = {
			enable = true,
		},
		indent = {
			enable = true,
			--disable = {
				--"python",
				--"css"
				--}
				--
		},
		audotag = {
			enable = true,
			disable = {
				"xml",
				"markdown",
			},
		},
		rainbow = {
			enable = true,
			extended_mode = false,
			colors = {
			    colors.red,
			    colors.orange,
			    colors.yellow,
			    colors.green,
			    colors.purple,
			    colors.cyan,
			    colors.pink,
			    colors.bright_red,
			    colors.bright_green,
			    colors.bright_yellow,
			    colors.bright_blue,
			    colors.bright_magenta,
			    colors.bright_cyan
			},
		},
	}
	sitter.setup(conf)	
end

return M

