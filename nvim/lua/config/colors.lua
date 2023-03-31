local g = vim.g
local colors = require('dracula').colors()

vim.cmd[[colorscheme dracula]]

g.rainbow_guifgs = {
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
}
g.rainbow_active = 1 
--vim.highlight.create('Beacon', {guibg=colors.green, guifg=colors.bg}, false)
vim.api.nvim_set_hl(0, 'Beacon', {bg=colors.green, fg=colors.bg})
