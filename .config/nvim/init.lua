local api = vim.api
local g = vim.g
local opt = vim.opt
local BUFFER = vim.bo
local GLOBAL = vim.o
local WINDOW = vim.wo

local function set_all(option, scope, value)
	scope[option] = value
end

api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })

require('plugins')
require('config.colors')
require('key_bindings')
diagnostics = require('diag')
vim.cmd[[
  autocmd CursorMoved * :lua diagnostics.echo_diagnostic()
]]


local options = {
  {option='loaded', scope=g, value=1},
  {option='mapleader', scope=g, value=" "},
  {option='maplocalleader', scope=g, value = " "},
  {option='loaded_netrwPlugin', scope=g, value=1},
  {option='indentLine_fileTypeExclude', scope=g, value = {'dashboard'}},
  --tabs,spacing & formatting
	{option='tabstop', scope=GLOBAL, value=2},
	{option='shiftwidth', scope=GLOBAL, value=2},
	{option='expandtab', scope=GLOBAL, value=true},
	{option='smartcase', scope=GLOBAL, value=true},
	{option='shiftround', scope=GLOBAL, value=true},
	{option='ignorecase', scope=GLOBAL, value=true},
  -- display options
	{option='number', scope=GLOBAL, value=true},
	{option='hlsearch', scope=GLOBAL, value=true},
	{option='timeoutlen', scope=GLOBAL, value=300}, -- Time in milliseconds to wait for mapped seq to complete.
	{option='updatetime', scope=GLOBAL, value=250}, -- Decrease update time
	{option='cursorline', scope=GLOBAL, value=true},
	{option='signcolumn', scope=GLOBAL, value='yes'},
	{option='breakindent', scope=GLOBAL, value=true},
	{option='termguicolors', scope=GLOBAL, value=true},
	{option='relativenumber', scope=GLOBAL, value=true},
	{option='guicursor', scope=GLOBAL, value="n-v:block,i-c-ci-ve:ver25,r-cr:hor20,o:hor50,i:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"},

  -- undo, history, etc
	{option='mouse', scope=GLOBAL, value='a'},
	{option='undofile', scope=GLOBAL, value=true},
	{option='undodir', scope=GLOBAL, value=vim.fn.stdpath('config') .. '/undodir'},

  -- misc
	{option='clipboard', scope=GLOBAL, value='unnamedplus'},
}
for _, args in pairs(options) do
	set_all(args.option, args.scope, args.value)
end

-- highlight selection on yank
vim.cmd [[
    augroup YankHighlight
        autocmd!
        autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    augroup end
]]

vim.cmd[[colorscheme dracula]]
require('aerial').setup({
  backends = { "lsp", "treesitter", "markdown" },
  show_guides = true,
  border = "double",
  filter_kind = {
    "Array",
    "Boolean",
    "Class",
    "Constant",
    "Constructor",
    "Enum",
    "EnumMember",
    "Event",
    "Field",
    "File",
    "Function",
    "Interface",
    "Key",
    "Method",
    "Module",
    "Namespace",
    "Null",
    "Number",
    "Object",
    "Operator",
    "Package",
    "Property",
    "String",
    "Struct",
    "TypeParameter",
    "Variable",
  },
  icons = {
    Array = "",
    Boolean = "⊨",
    Class = "",
    Constant = "",
    Constructor = "",
    Key = "",
    Function = "",
    Method = "ƒ",
    Namespace = "",
    Null = "NULL",
    Number = "#",
    Object = "⦿",
    Property = "",
    TypeParameter = "𝙏",
    Variable = "",
    Enum = "ℰ",
    Package = "",
    EnumMember = "",
    File = "",
    Module = "",
    Field = "",
    Interface = "ﰮ",
    String = "𝓐",
    Struct = "𝓢",
    Event = "",
    Operator = "+",
  },
  guides = {
    mid_item = "├ ",
    last_item = "└ ",
    nested_top = "│ ",
    whitespace = "  ",
  },
  attach_mode = "global",
  close_automatic_events = {"switch_buffer"},
    float = {
    relative = "editor",
    override = function(conf)
      local padding = 1
      conf.anchor = 'NE'
      conf.row = padding
      conf.col = vim.api.nvim_win_get_width(0) - padding
      return conf
    end,
  },
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<cr>", { buffer = bufnr, desc = "Jump backwards in Aerial" })
    vim.keymap.set("n", "}", "<cmd>AerialNext<cr>", { buffer = bufnr, desc = "Jump forwards in Aerial" })
    -- Jump up the tree with '[[' or ']]'
    vim.keymap.set("n", "[[", "<cmd>AerialPrevUp<cr>", { buffer = bufnr, desc = "Jump up and backwards in Aerial" })
    vim.keymap.set("n", "]]", "<cmd>AerialNextUp<cr>", { buffer = bufnr, desc = "Jump up and forwards in Aerial" })
  end,
  })
vim.api.nvim_exec(
[[
    au! WinLeave *.rs AerialCloseAll
]], false)
