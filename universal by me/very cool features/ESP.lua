-- esp module – boxes, names, health, tracers, etc.
local ESP = {
    enabled = false,
    visuals = {boxes = true, corner = false, names = true, health = true, tracers = false, skeleton = false, headDot = true, distance = true},
    color = "#00FF00",
    maxDistance = 400,
    drawings = {}
}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

-- helpers
local function hexToRGB(hex)
    hex = hex:gsub("#","")
    return Color3.fromRGB(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
end

local function createDrawing(kind)
    if not _G.ExecutorInfo.canDraw then return nil end
    local d = Drawing.new(kind)
    d.Visible = false
    return d
end

local function getColor() return hexToRGB(ESP.color) end

-- main update loop
local function updateESP()
    if not ESP.enabled then return end
    for _, d in pairs(ESP.drawings) do pcall(function() d:Remove() end) end
    ESP.drawings = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local dist = (camera.CFrame.Position - root.Position).Magnitude
        if dist > ESP.maxDistance then continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end

        local size = (char:GetExtentsSize().Magnitude / 2) * (camera.FieldOfView / 70) / dist * 500
        local center = Vector2.new(screenPos.X, screenPos.Y)
        local color = getColor()
        local healthPercent = hum.Health / hum.MaxHealth

        -- boxes
        if ESP.visuals.boxes then
            if ESP.visuals.corner then
                local lines = {createDrawing("Line"), createDrawing("Line"), createDrawing("Line"), createDrawing("Line")}
                lines[1].From = center + Vector2.new(-size, -size); lines[1].To = center + Vector2.new(-size/3, -size)
                lines[2].From = center + Vector2.new(size, -size); lines[2].To = center + Vector2.new(size/3, -size)
                lines[3].From = center + Vector2.new(-size, size); lines[3].To = center + Vector2.new(-size/3, size)
                lines[4].From = center + Vector2.new(size, size); lines[4].To = center + Vector2.new(size/3, size)
                for _, l in ipairs(lines) do l.Thickness = 2; l.Color = color; l.Visible = true; table.insert(ESP.drawings, l) end
            else
                local box = createDrawing("Quad")
                box.PointA = center + Vector2.new(-size, -size)
                box.PointB = center + Vector2.new(size, -size)
                box.PointC = center + Vector2.new(size, size)
                box.PointD = center + Vector2.new(-size, size)
                box.Thickness = 2; box.Color = color; box.Filled = false; box.Visible = true
                table.insert(ESP.drawings, box)
            end
        end

        -- health bar
        if ESP.visuals.health then
            local bar = createDrawing("Line")
            bar.From = center + Vector2.new(-size - 8, -size)
            bar.To = center + Vector2.new(-size - 8, -size + (size * 2 * healthPercent))
            bar.Thickness = 4
            bar.Color = Color3.fromRGB(255 - (255 * healthPercent), 255 * healthPercent, 0)
            bar.Visible = true
            table.insert(ESP.drawings, bar)
        end

        -- name
        if ESP.visuals.names then
            local txt = createDrawing("Text")
            txt.Text = player.Name
            txt.Position = center + Vector2.new(0, -size - 20)
            txt.Size = 14
            txt.Color = color
            txt.Center = true
            txt.Visible = true
            table.insert(ESP.drawings, txt)
        end

        -- distance
        if ESP.visuals.distance then
            local txt = createDrawing("Text")
            txt.Text = math.floor(dist) .. "m"
            txt.Position = center + Vector2.new(0, size + 5)
            txt.Size = 12
            txt.Color = Color3.fromRGB(255,255,255)
            txt.Center = true
            txt.Visible = true
            table.insert(ESP.drawings, txt)
        end

        -- head dot
        if ESP.visuals.headDot then
            local head = char:FindFirstChild("Head")
            if head then
                local hp, on = camera:WorldToViewportPoint(head.Position)
                if on then
                    local dot = createDrawing("Circle")
                    dot.Position = Vector2.new(hp.X, hp.Y)
                    dot.Radius = 4
                    dot.Color = color
                    dot.Filled = true
                    dot.Visible = true
                    table.insert(ESP.drawings, dot)
                end
            end
        end

        -- tracers
        if ESP.visuals.tracers then
            local line = createDrawing("Line")
            local screenSize = camera.ViewportSize
            line.From = Vector2.new(screenSize.X / 2, screenSize.Y)
            line.To = center
            line.Thickness = 1.5
            line.Color = color
            line.Visible = true
            table.insert(ESP.drawings, line)
        end

        -- skeleton (basic)
        if ESP.visuals.skeleton then
            local joints = {"Head","UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg"}
            local lastPos = nil
            for _, name in ipairs(joints) do
                local part = char:FindFirstChild(name)
                if part then
                    local p, on = camera:WorldToViewportPoint(part.Position)
                    if on and lastPos then
                        local line = createDrawing("Line")
                        line.From = lastPos
                        line.To = Vector2.new(p.X, p.Y)
                        line.Thickness = 1.5
                        line.Color = color
                        line.Visible = true
                        table.insert(ESP.drawings, line)
                    end
                    if p then lastPos = Vector2.new(p.X, p.Y) end
                end
            end
        end
    end
end

-- start / stop
local connection
function ESP:start() self:stop(); connection = runService.RenderStepped:Connect(updateESP) end
function ESP:stop()
    if connection then connection:Disconnect(); connection = nil end
    for _, d in pairs(self.drawings) do pcall(function() d:Remove() end) end
    self.drawings = {}
end

-- setters
function ESP:setEnabled(v) self.enabled = v; if v then self:start() else self:stop() end end
function ESP:setBoxes(v) self.visuals.boxes = v end
function ESP:setCornerBox(v) self.visuals.corner = v end
function ESP:setNames(v) self.visuals.names = v end
function ESP:setHealth(v) self.visuals.health = v end
function ESP:setTracers(v) self.visuals.tracers = v end
function ESP:setSkeleton(v) self.visuals.skeleton = v end
function ESP:setHeadDot(v) self.visuals.headDot = v end
function ESP:setDistance(v) self.visuals.distance = v end
function ESP:setColor(v) self.color = v end
function ESP:setDistanceLimit(v) self.maxDistance = v end

-- save / load
function ESP:getSettings()
    return {enabled = self.enabled, visuals = self.visuals, color = self.color, maxDistance = self.maxDistance}
end
function ESP:applySettings(data)
    if not data then return end
    self.enabled = data.enabled or false
    self.visuals = data.visuals or {boxes = true, corner = false, names = true, health = true, tracers = false, skeleton = false, headDot = true, distance = true}
    self.color = data.color or "#00FF00"
    self.maxDistance = data.maxDistance or 400
    if self.enabled then self:start() else self:stop() end
end

return ESP