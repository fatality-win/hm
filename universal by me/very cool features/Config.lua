-- config – save/load profiles to files or clipboard
local Config = {}
local CONFIG_FOLDER = "skeet_profiles/"

-- helpers
local function ensureFolder()
    if _G.ExecutorInfo.canMakeFolder and _G.ExecutorInfo.canIsFolder then
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    end
end

local function getPath(name)
    local clean = name:gsub("[^%w_%-%s]", "")
    return CONFIG_FOLDER .. clean .. ".json"
end

local function gatherAll()
    return {
        version = 1,
        timestamp = os.time(),
        combat = _G.Modules.Combat:getSettings(),
        esp = _G.Modules.ESP:getSettings(),
        world = _G.Modules.World:getSettings(),
        anti = _G.Modules.Anti:getSettings()
    }
end

local function applyAll(data)
    if not data then return end
    if _G.Modules.Combat then _G.Modules.Combat:applySettings(data.combat) end
    if _G.Modules.ESP then _G.Modules.ESP:applySettings(data.esp) end
    if _G.Modules.World then _G.Modules.World:applySettings(data.world) end
    if _G.Modules.Anti then _G.Modules.Anti:applySettings(data.anti) end
end

-- save (file or clipboard)
function Config:save(name, lib)
    name = name or "Unnamed"
    local json = game:GetService("HttpService"):JSONEncode(gatherAll())

    if _G.ExecutorInfo.canWriteFile and _G.ExecutorInfo.canMakeFolder then
        ensureFolder()
        local ok, err = pcall(function() writefile(getPath(name), json) end)
        if ok then
            if lib and lib:Copy then lib:Copy(json) end
            return true
        end
    end

    -- fallback to clipboard
    if lib and lib:Copy then
        lib:Copy(json)
        return false -- file failed but clipboard worked
    end
    return false
end

-- load by name (file)
function Config:loadByName(name)
    if not name or name == "" then return false end
    if _G.ExecutorInfo.canReadFile then
        local ok, content = pcall(readfile, getPath(name))
        if ok and content then
            local data = game:GetService("HttpService"):JSONDecode(content)
            applyAll(data)
            return true
        end
    end
    return false
end

-- load from json string (for clipboard)
function Config:loadFromString(jsonString)
    if not jsonString or jsonString == "" then return false end
    local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(jsonString) end)
    if ok and data then
        applyAll(data)
        return true
    end
    return false
end

-- delete
function Config:delete(name)
    if not name or name == "" then return false end
    if _G.ExecutorInfo.canDeleteFile then
        pcall(delfile, getPath(name))
        return true
    end
    return false
end

-- list
function Config:list()
    local files = {}
    if _G.ExecutorInfo.canListFiles and _G.ExecutorInfo.canIsFolder then
        if isfolder(CONFIG_FOLDER) then
            for _, file in ipairs(listfiles(CONFIG_FOLDER)) do
                local name = file:match("([^/]+)%.json$")
                if name then table.insert(files, name) end
            end
        end
    end
    return files
end

-- reset
function Config:reset()
    applyAll({})
end

return Config