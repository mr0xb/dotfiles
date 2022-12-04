local keymap = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

-- Better escape using jk in insert and terminal mode
keymap("i", "jk", "<ESC>", default_opts)
keymap("t", "jk", "<C-\\><C-n>", default_opts)
-- Center search results
keymap("n", "n", "nzz", default_opts)
keymap("n", "N", "Nzz", default_opts)
-- Paste over currently selected text without yanking it
keymap("v", "p", '"_dP', default_opts)
-- Cancel search highlighting with ESC
keymap("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", default_opts)
-- Move selected line / block of text in visual mode
keymap("x", "K", ":move '<-2<CR>gv-gv", default_opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", default_opts)
-- Resizing panes
keymap("n", "<S-Left>", ":vertical resize +1<CR>", default_opts)
keymap("n", "<S-Right>", ":vertical resize -1<CR>", default_opts)
keymap("n", "<S-Up>", ":resize -1<CR>", default_opts)
keymap("n", "<S-Down>", ":resize +1<CR>", default_opts)
