local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local guns = ServerStorage:WaitForChild("guns")
local gunStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("defaultGunsStats"))

gunStats.LoadTypes()

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait()
    gunStats.GiveGun(player,"M4A1")
    gunStats.GiveGun(player,"Glock 22")
end)

