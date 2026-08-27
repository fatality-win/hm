-- combat module – aimbot, checks, fov circle
local Combat = {
    enabled = false,
    checks = {dead = true, wall = true, team = true},
    settings = {aimType = "Mouse", aimPart = "Head", smoothness = 0.3, prediction = 0.15},
    fov = {radius = 60, show = true, filled = false, transparency = 0.5},
    fovCircle = nil,
    connections = {}
}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")

-- draw or update the fov circle
local function updateFOVCircle()
    if Combat.fovCircle then Combat.fovCircle:Remove() end
    if not Combat.fov.show then return end
    if not _G.ExecutorInfo.canDraw then return end
    local circle = Drawing.new("Circle")
    circle.Thickness = 2
    circle.Color = Color3.fromRGB(255,255,255)
    circle.Filled = Combat.fov.filled
    circle.Transparency = Combat.fov.transparency
    circle.Radius = Combat.fov.radius
    circle.Visible = true
    Combat.fovCircle = circle
end

-- find the closest enemy
local function getClosestEnemy()
    local closest, shortest = nil, math.huge
    local mouse = localPlayer:GetMouse()
    local mousePos = mouse.Hit.Position
    local camPos = camera.CFrame.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then continue end
        if Combat.checks.dead and hum.Health <= 0 then continue end
        if Combat.checks.team and localPlayer.Team and player.Team == localPlayer.Team then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- wall check
        if Combat.checks.wall then
            local ray = Ray.new(camPos, (root.Position - camPos).Unit * 1000)
            local hit = workspace:FindPartOnRay(ray, localPlayer.Character)
            if hit and not hit:IsDescendantOf(char) then continue end
        end

        local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
        if dist < shortest and dist <= Combat.fov.radius then
            shortest = dist
            closest = player
        end
    end
    return closest
end

-- the actual aimbot loop
local function aimbotLoop()
    if not Combat.enabled then return end
    local target = getClosestEnemy()
    if not target then return end
    local char = target.Character
    local aimPart = char:FindFirstChild(Combat.settings.aimPart) or char:FindFirstChild("Head")
    if not aimPart then return end

    local vel = aimPart.Velocity or Vector3.new()
    local predictedPos = aimPart.Position + (vel * Combat.settings.prediction)

    if Combat.settings.aimType == "CFrame" then
        camera.CFrame = CFrame.new(camera.CFrame.Position, predictedPos)
    else
        local screenPos, onScreen = camera:WorldToViewportPoint(predictedPos)
        if onScreen and _G.ExecutorInfo.canMoveMouse then
            local mouse = localPlayer:GetMouse()
            local dx = (screenPos.X - mouse.X) * Combat.settings.smoothness
            local dy = (screenPos.Y - mouse.Y) * Combat.settings.smoothness
            mousemoverel(dx, dy)
        end
    end
end

-- start / stop
function Combat:start()
    self:stop()
    updateFOVCircle()
    self.connections.render = runService.RenderStepped:Connect(function()
        if Combat.fovCircle then
            local mouse = localPlayer:GetMouse()
            Combat.fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
        end
        aimbotLoop()
    end)
    self.connections.fovUpdate = runService.Heartbeat:Connect(function()
        if Combat.fovCircle then
            if Combat.fovCircle.Radius ~= Combat.fov.radius then Combat.fovCircle.Radius = Combat.fov.radius end
            Combat.fovCircle.Filled = Combat.fov.filled
            Combat.fovCircle.Transparency = Combat.fov.transparency
        end
    end)
end

function Combat:stop()
    for _, c in pairs(self.connections) do pcall(function() c:Disconnect() end) end
    self.connections = {}
    if self.fovCircle then self.fovCircle:Remove(); self.fovCircle = nil end
end

-- setters (gui calls these)
function Combat:setEnabled(v) self.enabled = v; if v then self:start() else self:stop() end end
function Combat:setDeadCheck(v) self.checks.dead = v end
function Combat:setWallCheck(v) self.checks.wall = v end
function Combat:setTeamCheck(v) self.checks.team = v end
function Combat:setAimType(v) self.settings.aimType = v end
function Combat:setAimPart(v) self.settings.aimPart = v end
function Combat:setSmoothness(v) self.settings.smoothness = v end
function Combat:setPrediction(v) self.settings.prediction = v end
function Combat:setFOV(v) self.fov.radius = v end
function Combat:showFOV(v) self.fov.show = v; updateFOVCircle() end
function Combat:fillFOV(v) self.fov.filled = v end
function Combat:setFOVTransparency(v) self.fov.transparency = v end

-- save / load for config
function Combat:getSettings()
    return {enabled = self.enabled, checks = self.checks, settings = self.settings, fov = self.fov}
end
function Combat:applySettings(data)
    if not data then return end
    self.enabled = data.enabled or false
    self.checks = data.checks or {dead = true, wall = true, team = true}
    self.settings = data.settings or {aimType = "Mouse", aimPart = "Head", smoothness = 0.3, prediction = 0.15}
    self.fov = data.fov or {radius = 60, show = true, filled = false, transparency = 0.5}
    if self.enabled then self:start() else self:stop() end
end

return Combat