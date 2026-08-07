local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerClass = require(ReplicatedStorage.Shared.Classes.Player)
local PlayerDataStore = require(ReplicatedStorage.Shared.Model.PlayerDataStore)
local PlayerRepository = require(ReplicatedStorage.Shared.Repository.PlayerRepository)

Players.PlayerAdded:Connect(function(player)
    local NewPlayer = PlayerClass.New()
    NewPlayer.Name = player.Name
    PlayerRepository.Players[player.UserId] = NewPlayer
    PlayerDataStore:LoadPlayerData(player)
end)

Players.PlayerRemoving:Connect(function(player)
    PlayerDataStore:SavePlayerData(player)
    PlayerRepository.Players[player.UserId] = nil
end)

