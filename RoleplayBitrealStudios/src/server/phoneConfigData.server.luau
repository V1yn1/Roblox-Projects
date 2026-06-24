local DataStoreService = game:GetService("DataStoreService")
local phoneData = DataStoreService:GetDataStore("phonedata")
local salvarConfigPhone = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("SalvarConfigPhone")
local carregarConfigPhone = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("CarregarConfigPhone")
game.Players.PlayerAdded:Connect(function(player)
    pcall(function()
        return phoneData:GetAsync(player.UserId)
    end)
end)

salvarConfigPhone.OnServerEvent:Connect(function(player,keybind,wallpaper,notificacoes)
    local data = {
        keybind = keybind,
        wallpaper = wallpaper,
        notificacoes = notificacoes
    }
    phoneData:SetAsync(player.UserId,data)
end)