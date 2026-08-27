-- anti module – anti‑fling, anti‑afk (virtualuser), anti‑kick
local Anti = {
    fling = true,
    afk = true,
    kick = true,
    afkTimer = 0
}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local runService = game:GetService("RunService")

-- setup virtualuser for anti‑afk
local virtualUser = nil
if _G.ExecutorInfo.canVirtualUser then
    pcall(function()
        virtualUser = game:GetService("VirtualUser")
        virtualUser:CaptureController()
    end)
end

-- anti‑fling
local function checkFling()
    if not Anti.fling then return end
    local char = localPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    if root.Velocity.Magnitude > 1000 then
        root.Velocity = Vector3.new(0,0,0)
        root.CFrame = CFrame.new(root.Position + Vector3.new(0,5,0))
        hum.Sit = false
    end
end

-- anti‑afk – uses virtualuser if available, falls back to wiggle
local function checkAFK()
    if not Anti.afk then return end
    Anti.afkTimer = Anti.afkTimer + 1
    if Anti.afkTimer >= 30 then
        Anti.afkTimer = 0
        if virtualUser then
            pcall(function()
                virtualUser:ClickButton2(Vector2.new(math.random(0,100), math.random(0,100)))
            end)
        else
            -- fallback: tiny wiggle
            local char = localPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    local old = hum.WalkSpeed
                    hum.WalkSpeed = 0.1
                    task.wait(0.1)
                    hum.WalkSpeed = old
                end
            end
        end
    end
end

-- anti‑kick (hook metatable)
local function setupAntiKick()
    if not Anti.kick then return end
    if not _G.ExecutorInfo.canGetRawMetatable or not _G.ExecutorInfo.canGetNameCallMethod then return end
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        mt.__namecall = function(self, ...)
            if getnamecallmethod() == "Kick" then
                warn("[skeet.dev] blocked a kick attempt")
                return nil
            end
            return old(self, ...)
        end
    end
    -- also hook teleport
    local ts = game:GetService("TeleportService")
    local oldTeleport = ts.Teleport
    ts.Teleport = function(...)
        warn("[skeet.dev] blocked a teleport/kick attempt")
        return nil
    end
end

-- main loop
local connection
function Anti:start()
    self:stop()
    setupAntiKick()
    connection = runService.Heartbeat:Connect(function()
        checkFling()
        checkAFK()
    end)
end

function Anti:stop()
    if connection then connection:Disconnect(); connection = nil end
end

-- setters
function Anti:setFling(v) self.fling = v end
function Anti:setAFK(v) self.afk = v end
function Anti:setKick(v) self.kick = v end

Anti:start()

-- save / load
function Anti:getSettings()
    return {fling = self.fling, afk = self.afk, kick = self.kick}
end
function Anti:applySettings(data)
    if not data then return end
    self.fling = data.fling or true
    self.afk = data.afk or true
    self.kick = data.kick or true
end

return Anti