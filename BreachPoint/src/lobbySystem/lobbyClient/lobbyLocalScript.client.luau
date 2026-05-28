local player = game.Players.LocalPlayer
local lobbyGui = player:WaitForChild("PlayerGui"):WaitForChild("Lobby")
local menuGui = player.PlayerGui:WaitForChild("Menu")
local menuButtons = menuGui:WaitForChild("MenuButtons")
local playButton = menuButtons:WaitForChild("Play TextButton")
if not menuGui.Enabled then
    menuGui.Enabled = true
end

playButton.MouseButton1Click:Connect(function()
    lobbyGui.Enabled = true
    menuGui.Enabled = false
    lobbyGui.Position = UDim2.new(0.5, 0, -0.5, 0)
    lobbyGui:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quad", 0.5)
end)