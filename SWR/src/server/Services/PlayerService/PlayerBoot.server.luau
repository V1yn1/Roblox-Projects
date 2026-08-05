local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerClass = require(ReplicatedStorage.Shared.Classes.PlayerClass.PlayerClass)

game.Players.PlayerAdded:Connect(function(player)
    local playerInstance = PlayerClass:New()
    playerInstance.PlayerName = player.Name
    print(playerInstance)
end)