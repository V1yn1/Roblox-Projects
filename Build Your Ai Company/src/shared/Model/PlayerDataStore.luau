local PlayerDataStore = {}
local PlayerRepository = require(game:GetService("ReplicatedStorage").Shared.Repository.PlayerRepository)

function PlayerDataStore:SavePlayerData(player)
    local PlayerData = PlayerRepository.Players[player.UserId]
    if PlayerData then
        -- Save player data to DataStore
        local Success, ErrorMessage = pcall(function()
            local dataStore = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore")
            dataStore:SetAsync(player.UserId, PlayerData)
        end)

        if not Success then
            warn("Failed to save player data for " .. player.Name .. ": " .. ErrorMessage)
        end 
    end
end

function PlayerDataStore:LoadPlayerData(player)
    local Success, PlayerData = pcall(function()
        local DataStore = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore")
        return DataStore:GetAsync(player.UserId)
    end)

    if Success and PlayerData then
        PlayerRepository.Players[player.UserId] = PlayerData
    else
        warn("Failed to load player data for " .. player.Name)
    end
end

return PlayerDataStore