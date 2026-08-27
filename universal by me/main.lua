-- load ui from git
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Snxdfer/back-ups-for-libs/refs/heads/main/xsxLibrary.lua"))()
library.rank = "skeet.dev user"

-- create watermark
local watermark = library:Watermark("skeet.dev | v" .. library.version .. " | " .. library:GetUsername() .. " | rank: " .. library.rank)
local fpsDisplay = watermark:AddWatermark("fps: " .. library.fps)

-- fps counter
coroutine.wrap(function()
    while wait(0.75) do
        fpsDisplay:Text("fps: " .. library.fps)
    end
end)()

local notifications = library:InitNotifications()

-- full compatability test (checks everything we use)
_G.ExecutorInfo = {
    canHttpGet = pcall(function() return game:HttpGet end) and true or false,
    canWriteFile = pcall(function() writefile("skeet_test.txt", "test"); return true end) or false,
    canReadFile = pcall(function() readfile("skeet_test.txt"); return true end) or false,
    canMakeFolder = pcall(function() makefolder("skeet_test_folder"); return true end) or false,
    canIsFolder = pcall(function() isfolder("skeet_test_folder"); return true end) or false,
    canListFiles = pcall(function() listfiles("skeet_test_folder"); return true end) or false,
    canDeleteFile = pcall(function() delfile("skeet_test.txt"); return true end) or false,
    canSetClipboard = pcall(function() setclipboard("skeet_test"); return true end) or false,
    canGetClipboard = pcall(function() getclipboard(); return true end) or false,
    canDraw = pcall(function() return Drawing end) and true or false,
    canMoveMouse = pcall(function() mousemoverel(0, 0); return true end) or false,
    canMoveMouseAbs = pcall(function() mousemoveabs(0, 0); return true end) or false,
    canGetRawMetatable = pcall(function() return getrawmetatable end) and true or false,
    canSetRawMetatable = pcall(function() return setrawmetatable end) and true or false,
    canGetNameCallMethod = pcall(function() return getnamecallmethod end) and true or false,
    canNewCClosure = pcall(function() return newcclosure end) and true or false,
    canSynRequest = pcall(function() return syn and syn.request end) or false,
    canHttpRequest = pcall(function() return http_request end) or false,
    canVirtualUser = pcall(function() local vu = game:GetService("VirtualUser"); vu:CaptureController(); return true end) and true or false,
}

-- clean up test files
pcall(delfile, "skeet_test.txt")
pcall(delfile, "skeet_test_folder/skeet_test.txt")
pcall(delfile, "skeet_test_folder")

-- show warnings if something's missing
local missingStuff = {}
if not _G.ExecutorInfo.canHttpGet then table.insert(missingStuff, "HTTP GET - can't load modules") end
if not _G.ExecutorInfo.canDraw then table.insert(missingStuff, "Drawing API - ESP & FOV circles disabled") end
if not _G.ExecutorInfo.canMoveMouse then table.insert(missingStuff, "mouse control - use CFrame aim instead") end
if not _G.ExecutorInfo.canWriteFile then table.insert(missingStuff, "file system - configs use clipboard fallback") end
if not _G.ExecutorInfo.canSetClipboard then table.insert(missingStuff, "clipboard - can't copy configs or coords") end
if not _G.ExecutorInfo.canGetRawMetatable then table.insert(missingStuff, "metatable hooks - anti-kick may not work") end
if not _G.ExecutorInfo.canVirtualUser then table.insert(missingStuff, "VirtualUser - anti-afk will use wiggle fallback") end

if #missingStuff > 0 then
    notifications:Notify("WARNING: your executor is missing:", 3, "alert")
    for i, msg in ipairs(missingStuff) do
        task.wait(0.4)
        notifications:Notify("- " .. msg, 4, "alert")
    end
    notifications:Notify("some features may not work as expected", 3, "alert")
else
    notifications:Notify("full compatibility - all features should work", 2, "success")
end

-- create ui window
library.title = "skeet.dev"
library:Introduction()
local mainWindow = library:Init()

-- load gui
local BASE_URL = "https://raw.githubusercontent.com/fatality-win/hm/main/"
local guiBuilder = loadstring(game:HttpGet(BASE_URL .. "gui.lua"))()
local tabs = guiBuilder(library, mainWindow, notifications)

-- wait for game and player
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

if not localPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    localPlayer = Players.LocalPlayer
end

if not localPlayer.Character then
    localPlayer.CharacterAdded:Wait()
end

task.wait(0.5)

-- load feature modules
_G.Modules = {}

local function loadModule(path)
    local success, module = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    if not success then
        warn("[skeet.dev] failed to load " .. path .. ": " .. tostring(module))
        notifications:Notify("failed to load: " .. path, 3, "error")
        return nil
    end
    return module
end

_G.Modules.Combat = loadModule("Features/Combat.lua")
_G.Modules.ESP = loadModule("Features/ESP.lua")
_G.Modules.World = loadModule("Features/World.lua")
_G.Modules.Anti = loadModule("Features/Anti.lua")
_G.Modules.Misc = loadModule("Features/Misc.lua")
_G.Modules.Scripts = loadModule("Features/Scripts.lua")
_G.Modules.Config = loadModule("Features/Config.lua")

notifications:Notify("skeet.dev Loaded", 3, "success")

-- love yall btw