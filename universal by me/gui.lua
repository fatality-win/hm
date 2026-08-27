-- build the ui tabs
return function(library, window, notifications)
    -- create tabs
    local combatTab = window:NewTab("Combat")
    local espTab = window:NewTab("ESP")
    local worldTab = window:NewTab("World")
    local antiTab = window:NewTab("Anti")
    local miscTab = window:NewTab("Misc")
    local scriptsTab = window:NewTab("Scripts")
    local configTab = window:NewTab("Config")

    -- combat tab
    combatTab:NewSection("Aimbot")
    combatTab:NewToggle("Enable Aimbot", false, function(v) _G.Modules.Combat:setEnabled(v) end):AddKeybind(Enum.KeyCode.RightControl)

    combatTab:NewSection("Checks")
    combatTab:NewToggle("Dead Check", true, function(v) _G.Modules.Combat:setDeadCheck(v) end)
    combatTab:NewToggle("Wall Check", true, function(v) _G.Modules.Combat:setWallCheck(v) end)
    combatTab:NewToggle("Team Check", true, function(v) _G.Modules.Combat:setTeamCheck(v) end)

    combatTab:NewSection("Aiming")
    combatTab:NewSelector("Aim Type", "Mouse", {"CFrame", "Mouse"}, function(v) _G.Modules.Combat:setAimType(v) end)
    combatTab:NewSelector("Target Part", "Head", {"Head","Chest","HumanoidRootPart","LeftLeg","RightLeg"}, function(v) _G.Modules.Combat:setAimPart(v) end)
    combatTab:NewSlider("Smoothness", "", true, "%", {min=0,max=1,default=0.3,decimals=2}, function(v) _G.Modules.Combat:setSmoothness(v) end)
    combatTab:NewSlider("Prediction", "", true, "", {min=0,max=0.5,default=0.15,decimals=3}, function(v) _G.Modules.Combat:setPrediction(v) end)

    combatTab:NewSection("FOV Circle")
    combatTab:NewSlider("FOV Radius", "", true, "°", {min=1,max=1000,default=60}, function(v) _G.Modules.Combat:setFOV(v) end)
    combatTab:NewToggle("Show FOV", true, function(v) _G.Modules.Combat:showFOV(v) end)
    combatTab:NewToggle("Filled FOV", false, function(v) _G.Modules.Combat:fillFOV(v) end)
    combatTab:NewSlider("Filled Transparency", "", true, "%", {min=0,max=1,default=0.5,decimals=2}, function(v) _G.Modules.Combat:setFOVTransparency(v) end)

    -- esp tab
    espTab:NewSection("Player ESP")
    espTab:NewToggle("Enable ESP", false, function(v) _G.Modules.ESP:setEnabled(v) end):AddKeybind(Enum.KeyCode.RightShift)
    espTab:NewToggle("Boxes", true, function(v) _G.Modules.ESP:setBoxes(v) end)
    espTab:NewToggle("Corner Boxes", false, function(v) _G.Modules.ESP:setCornerBox(v) end)
    espTab:NewToggle("Names", true, function(v) _G.Modules.ESP:setNames(v) end)
    espTab:NewToggle("Health Bars", true, function(v) _G.Modules.ESP:setHealth(v) end)
    espTab:NewToggle("Tracers", false, function(v) _G.Modules.ESP:setTracers(v) end)
    espTab:NewToggle("Skeleton", false, function(v) _G.Modules.ESP:setSkeleton(v) end)
    espTab:NewToggle("Head Dot", true, function(v) _G.Modules.ESP:setHeadDot(v) end)
    espTab:NewToggle("Distance", true, function(v) _G.Modules.ESP:setDistance(v) end)

    espTab:NewSection("Visuals")
    espTab:NewTextbox("Hex Color (e.g. #FF0000)", "#00FF00", "1", "all", "medium", true, false, function(v) _G.Modules.ESP:setColor(v) end)
    espTab:NewSlider("Max Render Distance", "", true, "m", {min=50,max=1000,default=400}, function(v) _G.Modules.ESP:setDistanceLimit(v) end)

    -- world tab
    worldTab:NewSection("Movement")
    worldTab:NewToggle("Fly", false, function(v) _G.Modules.World:setFly(v) end):AddKeybind(Enum.KeyCode.F)
    worldTab:NewToggle("Noclip", false, function(v) _G.Modules.World:setNoclip(v) end):AddKeybind(Enum.KeyCode.N)
    worldTab:NewSlider("Walk Speed", "", true, "", {min=16,max=500,default=16}, function(v) _G.Modules.World:setWalkspeed(v) end)
    worldTab:NewSlider("Jump Power", "", true, "", {min=50,max=500,default=50}, function(v) _G.Modules.World:setJumpPower(v) end)
    worldTab:NewSlider("Fly Speed", "", true, "", {min=10,max=300,default=50}, function(v) _G.Modules.World:setFlySpeed(v) end)
    worldTab:NewButton("Teleport to Mouse", function() _G.Modules.World:teleportToMouse() end)

    worldTab:NewSection("Visuals")
    worldTab:NewToggle("Full Bright", false, function(v) _G.Modules.World:setFullBright(v) end)
    worldTab:NewToggle("No Fog", false, function(v) _G.Modules.World:setNoFog(v) end)

    -- anti tab
    antiTab:NewSection("Protections")
    antiTab:NewToggle("Anti-Fling", true, function(v) _G.Modules.Anti:setFling(v) end)
    antiTab:NewToggle("Anti-AFK", true, function(v) _G.Modules.Anti:setAFK(v) end)
    antiTab:NewToggle("Anti-Kick", true, function(v) _G.Modules.Anti:setKick(v) end)

    -- misc tab
    miscTab:NewSection("Utilities")
    miscTab:NewButton("Rejoin Server", function() _G.Modules.Misc:rejoin(library) end)
    miscTab:NewButton("Hop to Another Server", function() _G.Modules.Misc:hop() end)
    miscTab:NewButton("Copy Coordinates", function() _G.Modules.Misc:copyCoordinates(library) end)
    miscTab:NewButton("Unlock FPS (300)", function() _G.Modules.Misc:unlockFPS(library) end)

    -- scripts tab (external executor)
    scriptsTab:NewSection("Load Custom Scripts")
    scriptsTab:NewTextbox("Script URL (raw)", "https://pastebin.com/raw/...", "1", "all", "medium", true, false, function(v) _G._pendingScriptURL = v end)
    scriptsTab:NewButton("Execute URL", function() if _G._pendingScriptURL then _G.Modules.Scripts:execute(_G._pendingScriptURL) end end)

    scriptsTab:NewSection("Quick Scripts")
    scriptsTab:NewButton("Load Infinite Yield", function() _G.Modules.Scripts:loadInfiniteYield() end)

    -- config tab (save/load profiles)
    configTab:NewSection("Profile Manager")
    configTab:NewTextbox("Profile Name", "MyProfile", "1", "all", "small", true, false, function(v) _G._profileName = v end)

    configTab:NewButton("Save Profile", function()
        local name = _G._profileName or "profile_" .. os.time()
        _G.Modules.Config:save(name, library)
        notifications:Notify("saved '" .. name .. "'", 2, "success")
    end)

    configTab:NewButton("Load Profile", function()
        local name = _G._profileName
        if name and name ~= "" then
            _G.Modules.Config:loadByName(name)
            notifications:Notify("loaded '" .. name .. "'", 2, "success")
        else
            notifications:Notify("enter a profile name first", 2, "alert")
        end
    end)

    configTab:NewButton("Delete Profile", function()
        local name = _G._profileName
        if name and name ~= "" then
            _G.Modules.Config:delete(name)
            notifications:Notify("deleted '" .. name .. "'", 2, "alert")
        else
            notifications:Notify("enter a profile name first", 2, "alert")
        end
    end)

    configTab:NewButton("Reset All Settings", function()
        _G.Modules.Config:reset()
        notifications:Notify("all settings reset to default", 2, "alert")
    end)

    configTab:NewButton("List All Profiles", function()
        local list = _G.Modules.Config:list()
        if #list == 0 then
            notifications:Notify("no saved profiles found", 2, "information")
        else
            notifications:Notify("profiles: " .. table.concat(list, ", "), 4, "information")
        end
    end)

    -- fallback for executors without file system
    configTab:NewLabel("if your executor lacks file support, paste JSON below and click load", "center")
    configTab:NewTextbox("Paste JSON here", "", "1", "all", "medium", true, false, function(v) _G._jsonPaste = v end)
    configTab:NewButton("Load from JSON (clipboard paste)", function()
        if _G._jsonPaste and _G._jsonPaste ~= "" then
            local ok = _G.Modules.Config:loadFromString(_G._jsonPaste)
            if ok then notifications:Notify("json config loaded!", 2, "success") else notifications:Notify("invalid json", 2, "error") end
        else
            notifications:Notify("paste some json first", 2, "alert")
        end
    end)

    return {combatTab, espTab, worldTab, antiTab, miscTab, scriptsTab, configTab}
end