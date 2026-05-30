local player = game.Players.LocalPlayer
local updateUi = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("UpdateUI")
local maps = require(game.ReplicatedStorage.LobbyShared:WaitForChild("maps"))
local selectedMap,playerCount = nil,2

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
local playersCount = createLobbyUi:WaitForChild("PlayerCountText")
local plusButton = createLobbyUi:WaitForChild("+ TextButton")
local minusButton = createLobbyUi:WaitForChild("- TextButton")
local selectedMapText = createLobbyUi:WaitForChild("SelectedMapText")
local selectMapButton = createLobbyUi:WaitForChild("SelectMap TextButton")
local arrowIconUp = selectMapButton:WaitForChild("ArrowUp")
local arrowIconDown = selectMapButton:WaitForChild("ArrowDown")
local mapDropdown = createLobbyUi:WaitForChild("DropDown ScrollingFrame")
local mapDropdownExample = mapDropdown:WaitForChild("MapExample TextButton")
local createLobbyButton = createLobbyUi:WaitForChild("Create TextButton")

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
    local lobbies = updateUi:InvokeServer()
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

--create lobby gui configuration
createButton.MouseButton1Click:Connect(function()
   createLobbyUi.Visible = not createLobbyUi.Visible
end)

local function loadDropDownMaps()
    for i,v in pairs(maps) do
        if not mapDropdown:FindFirstChild(i) then
            local newMap = mapDropdownExample:Clone()
            newMap.Name = i
            newMap.MapName.Text = v.name
            newMap["MapPhoto ImageLabel"].Image = v.imageId
            newMap.Parent = mapDropdown
            newMap.Visible = true
            
            newMap.MouseButton1Click:Connect(function()
                selectedMapText.Text = "Selected Map: " .. v.name
                selectedMap = i
                mapDropdown.Visible = false
            end)
        end
    end
end
selectMapButton.MouseButton1Click:Connect(function()
    loadDropDownMaps()
    mapDropdown.Visible = not mapDropdown.Visible
end)

plusButton.MouseButton1Click:Connect(function()
    if playerCount < 10 then
        playerCount += 2
        playersCount.Text = playerCount
    end
end)

minusButton.MouseButton1Click:Connect(function()
    if playerCount > 2 then
        playerCount -= 2
        playersCount.Text = playerCount
    end
end)