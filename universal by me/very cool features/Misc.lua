-- misc – rejoin, hop, copy coords, unlock fps
local Misc = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local teleport = game:GetService("TeleportService")

function Misc:rejoin(lib)
    if lib and lib:Rejoin then lib:Rejoin() else teleport:Teleport(game.PlaceId, localPlayer) end
end

function Misc:hop()
    teleport:Teleport(game.PlaceId)
end

function Misc:copyCoordinates(lib)
    local char = localPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if lib and lib:Copy then lib:Copy(tostring(root.Position)) end
end

function Misc:unlockFPS(lib)
    if lib and lib:UnlockFps then lib:UnlockFps(300) end
end

return Misc