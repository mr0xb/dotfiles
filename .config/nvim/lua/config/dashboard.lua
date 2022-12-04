local M = {}
local home = os.getenv('HOME')

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename 
    end
    pfile:close()
    return t
end


function M()
    catTable = scandir(vim.fn.stdpath('config') .. '/static/')
    math.random()
    math.randomseed(os.time()+math.random())
    math.random(); math.random(); math.random();
    file = vim.fn.stdpath('config') .. '/static/' .. catTable[math.random(#catTable)]
    local fheight = io.popen('cat '..file..' | wc -l')
    local fwidth = io.popen('awk "{print length}" '..file..' | sort -nr | head -1')
    local db = require 'dashboard'
    db.preview_command = 'cat | lolcat -F 0.3 -p 15'
    db.preview_file_path = file
    db.preview_file_height = tonumber(fheight:read("*a"))
    db.preview_file_width = tonumber(fwidth:read("*a"))
    db.header_pad = 0


end
return M()