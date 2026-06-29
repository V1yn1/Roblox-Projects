local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local guns = ServerStorage:WaitForChild("guns")
local gunStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("defaultGunsStats"))


game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait()
    for _,v in pairs(guns:GetChildren()) do
        if v:IsA("Tool") then
            local clone = v:Clone()
            clone.Parent = player.Backpack
        end
    end
end)

gunStats.LoadTypes()
