-- world module – fly, noclip, walk/jump, fullbright, nofog
local World = {
    fly = false,
    noclip = false,
    walkSpeed = 16,
    jumpPower = 50,
    flySpeed = 50,
    fullBright = false,
    noFog = false,
    bodyVelocity = nil,
    bodyGyro = nil
}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local userInput = game:GetService("UserInputService")

-- apply walkspeed and jump
local function applyMovement()
    local char = localPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = World.walkSpeed; hum.JumpPower = World.jumpPower end
end

-- fly logic
local function updateFly()
    local char = localPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if World.fly then
        if not World.bodyVelocity then
            World.bodyVelocity = Instance.new("BodyVelocity")
            World.bodyVelocity.MaxForce = Vector3.new(1,1,1) * 10000
            World.bodyVelocity.Parent = root
            World.bodyGyro = Instance.new("BodyGyro")
            World.bodyGyro.MaxTorque = Vector3.new(1,1,1) * 10000
            World.bodyGyro.Parent = root
        end

        local moveDir = Vector3.new(0,0,0)
        if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0,0,-1) end
        if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0,0,1) end
        if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1,0,0) end
        if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1,0,0) end
        if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir + Vector3.new(0,-1,0) end

        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit * World.flySpeed else moveDir = Vector3.new(0,0,0) end

        local camCF = workspace.CurrentCamera.CFrame
        local vel = (camCF.LookVector * -moveDir.Z) + (camCF.RightVector * moveDir.X) + (camCF.UpVector * moveDir.Y)
        World.bodyVelocity.Velocity = vel
        if vel.Magnitude > 0.1 then
            World.bodyGyro.CFrame = CFrame.new(root.Position, root.Position + vel.Unit * 10)
        end
    else
        if World.bodyVelocity then World.bodyVelocity:Destroy(); World.bodyVelocity = nil end
        if World.bodyGyro then World.bodyGyro:Destroy(); World.bodyGyro = nil end
    end
end

-- noclip
local function updateNoclip()
    local char = localPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = not World.noclip end
    end
end

-- fullbright
local function updateBright()
    if World.fullBright then
        lighting.Brightness = 2
        lighting.ClockTime = 12
        lighting.Ambient = Color3.fromRGB(255,255,255)
    else
        lighting.Brightness = 1
        lighting.ClockTime = 14
        lighting.Ambient = Color3.fromRGB(127,127,127)
    end
end

-- no fog
local function updateFog()
    if World.noFog then lighting.FogEnd = 100000 else lighting.FogEnd = 1000 end
end

-- main loop
local connection
local function onCharacterAdded()
    task.wait(0.5)
    applyMovement()
    updateNoclip()
    updateFly()
end

function World:start()
    self:stop()
    localPlayer.CharacterAdded:Connect(onCharacterAdded)
    connection = runService.Heartbeat:Connect(function()
        applyMovement()
        updateNoclip()
        updateFly()
        updateBright()
        updateFog()
    end)
end

function World:stop()
    if connection then connection:Disconnect(); connection = nil end
    if World.bodyVelocity then World.bodyVelocity:Destroy(); World.bodyVelocity = nil end
    if World.bodyGyro then World.bodyGyro:Destroy(); World.bodyGyro = nil end
    local char = localPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
    end
end

-- teleport to mouse
function World:teleportToMouse()
    local char = localPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local mouse = localPlayer:GetMouse()
    if mouse then root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0)) end
end

-- setters
function World:setFly(v) self.fly = v end
function World:setNoclip(v) self.noclip = v end
function World:setWalkspeed(v) self.walkSpeed = v end
function World:setJumpPower(v) self.jumpPower = v end
function World:setFlySpeed(v) self.flySpeed = v end
function World:setFullBright(v) self.fullBright = v end
function World:setNoFog(v) self.noFog = v end

-- save / load
function World:getSettings()
    return {fly = self.fly, noclip = self.noclip, walkSpeed = self.walkSpeed, jumpPower = self.jumpPower, flySpeed = self.flySpeed, fullBright = self.fullBright, noFog = self.noFog}
end
function World:applySettings(data)
    if not data then return end
    self.fly = data.fly or false
    self.noclip = data.noclip or false
    self.walkSpeed = data.walkSpeed or 16
    self.jumpPower = data.jumpPower or 50
    self.flySpeed = data.flySpeed or 50
    self.fullBright = data.fullBright or false
    self.noFog = data.noFog or false
end

onCharacterAdded()
World:start()
return World