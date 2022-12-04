-- require("nvim-tree").setup({
--     disable_netrw = true,
--     hijack_netrw = true,
--     sort_by = "case_sensitive",
--     view = {
--         adaptive_size = true,
--         mappings = {
--         list = {
--             { key = "u", action = "dir_up" },
--         },
--         },
--     },
--     renderer = {
--         group_empty = true,
--     },
--     filters = {
--         dotfiles = false,
--     },
-- })
local M = {}

function M.setup()
    local ntree = require 'nvim-tree'

    local conf = {
        disable_netrw = true,
        hijack_netrw = true,
        sort_by = "case_sensitive",
        view = {
            adaptive_size = true,
            mappings = {
            list = {
                { key = "u", action = "dir_up" },
            },
            },
        },
        renderer = {
            group_empty = true,
        },
        filters = {
            dotfiles = false,
        },
    }
    ntree.setup(conf)
end
return M