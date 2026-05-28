local player = game.Players.LocalPlayer
local lobbyGui = player:WaitForChild("PlayerGui"):WaitForChild("Lobby")
local menuGui = player.PlayerGui:WaitForChild("Menu")

game.Loaded:Connect(function()
    if not menuGui.Enabled then
        menuGui.Enabled = true
    end
end)