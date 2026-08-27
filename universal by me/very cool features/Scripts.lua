-- scripts – load and execute custom scripts
local Scripts = {}

function Scripts:execute(url)
    if url and url ~= "" then
        pcall(function()
            loadstring(game:HttpGet(url))()
        end)
    end
end

function Scripts:loadInfiniteYield()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
end

return Scripts