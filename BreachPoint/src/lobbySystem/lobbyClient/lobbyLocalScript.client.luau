local player = game.Players.LocalPlayer
local updateUi = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("UpdateUI")

local menuGui = player.PlayerGui:WaitForChild("Menu")
local menuButtons = menuGui:WaitForChild("MainMenu"):WaitForChild("MenuButtons")
local playButton = menuButtons:WaitForChild("Play TextButton")

local lobbyGui = player:WaitForChild("PlayerGui"):WaitForChild("Lobby")
local lobbyFrame = lobbyGui:WaitForChild("LobbyGui")
local returnButton = lobbyFrame:WaitForChild("Return TextButton")
local createButton = lobbyFrame:WaitForChild("Create TextButton")
local lobbyList = lobbyFrame:WaitForChild("ServersList ScrollingFrame")
local exampleButton = lobbyList:WaitForChild("Example")

local createLobbyUi = lobbyGui:WaitForChild("CreateLobby")
-- menu configuration

if not menuGui.Enabled then
    menuGui.Enabled = true
end

playButton.MouseButton1Click:Connect(function()
    lobbyGui.Enabled = true
    menuGui.Enabled = false
    lobbyFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
    lobbyFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quad", 0.5)
end)


-- lobbygui configuration
local function loadLobbies()
    local lobbies = updateUi:Invoke()
    for i,v in pairs(lobbies) do 
        local newLobby
        if lobbyList:FindFirstChild(i) then
            newLobby = lobbyList:FindFirstChild(i)
        else
           newLobby = exampleButton:Clone()
        end
        newLobby.Name = i
        newLobby.MapName.Text = v.map.name
        newLobby["MapPhoto ImageLabel"].Image = v.map.imageId
        newLobby.PlayerAmount.Text = #v.players
        newLobby.Parent = lobbyList
        newLobby.Visible = true
    end

end

lobbyGui:GetPropertyChangedSignal("Enabled"):Connect(function()
    if lobbyGui.Enabled then
        loadLobbies()
    end
end)

returnButton.MouseButton1Click:Connect(function()
    lobbyFrame:TweenPosition(UDim2.new(0.5, 0, -0.5, 0), "In", "Quad", 0.5, true, function()
        lobbyGui.Enabled = false
        menuGui.Enabled = true
    end)
end)

createButton.MouseButton1Click:Connect(function()
    if createLobbyUi.Visible then
        createLobbyUi.Visible = false
    else
        createLobbyUi.Visible = true
    end
end)