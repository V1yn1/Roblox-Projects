local player = game.Players.LocalPlayer
local updateUi = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("UpdateUI")
local createLobbyEvent = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("CreateLobby")
local joinLobbyEvent = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("JoinLobby")
local loadLobbiesEvent = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("LoadLobbies")
local leaveLobbyEvent = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("LeaveLobby")
local idCache = require(game.ReplicatedStorage.LobbyShared:WaitForChild("idcache"))
local photosCache = require(game.ReplicatedStorage.LobbyShared:WaitForChild("photoscache"))
local maps = require(game.ReplicatedStorage.LobbyShared:WaitForChild("maps"))
local selectedMap,playerCount,currentLobby = nil,2,nil

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

local lobbyDetailsFrame = lobbyGui:WaitForChild("LobbyDetails")
local returnButtonDetails = lobbyDetailsFrame:WaitForChild("Return TextButton")
local confirmationFrame = lobbyDetailsFrame:WaitForChild("LeaveLobbyConfirm")
local cancelLeaveButton = confirmationFrame:WaitForChild("CancelLeave TextButton")
local confirmLeaveButton = confirmationFrame:WaitForChild("ConfirmLeave TextButton")
local startMatchButton = lobbyDetailsFrame:WaitForChild("StartMatch TextButton")
local lobbySummary = lobbyDetailsFrame:WaitForChild("LobbySummary")
local playerList = lobbyDetailsFrame:WaitForChild("PlayersList ScrollingFrame")
local guardsTeam = playerList:WaitForChild("GuardsTeam")
local intrudersTeam = playerList:WaitForChild("IntrudersTeam")
local spectatorsTeam = playerList:WaitForChild("SpectatorsTeam")
local statusPill = lobbyDetailsFrame:WaitForChild("Status Pill")

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
local function getPlayerNameFromId(playerId)
    local cachedName = idCache[playerId]
    if cachedName then
        return cachedName
    end

    for _,plr in pairs(game.Players:GetChildren()) do
        if plr.UserId == playerId then
            idCache[playerId] = plr.Name
            return plr.Name
        end
    end
    return nil
end

local function loadLobbies()
    local lobbies = updateUi:InvokeServer()
    for _,child in pairs(lobbyList:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = false
        end
    end
    for i,v in pairs(lobbies) do
        local newLobby
        local host = getPlayerNameFromId(v.hostId)
        if not host then
            return warn("Host not found for lobby: "..i)
        end

        if lobbyList:FindFirstChild(i) then
            newLobby = lobbyList:FindFirstChild(i)
        else
           newLobby = exampleButton:Clone()
        end
        newLobby.Name = i
        newLobby.MapName.Text = v.map.name
        newLobby["MapPhoto ImageLabel"].Image = v.map.imageId
        newLobby.PlayerAmount.Text = #v.players.."/"..v.maxPlayers
        newLobby.HostName.Text = "Host: "..host
        newLobby.Parent = lobbyList
        newLobby.Visible = true
        if v.hostId == player.UserId then
            newLobby["Join TextButton"].Visible = false
        end
        newLobby["Join TextButton"].MouseButton1Click:Connect(function()
            joinLobbyEvent:FireServer(v.hostId)
            currentLobby = i
            newLobby["Join TextButton"].Visible = false
        end)
    end

end

loadLobbiesEvent.OnClientEvent:Connect(function()
    loadLobbies()
end)

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

local function createLobby()
     createLobbyUi.Visible = false
     createLobbyEvent:FireServer(selectedMap,playerCount)
end

local function loadLobbyDetails(lobbyId)
    local lobbies = updateUi:InvokeServer()
    local lobby = lobbies[lobbyId]
    print(lobbies)
    if lobby then
        if lobby.hostId == player.UserId then
            startMatchButton.Visible = true
        else
            startMatchButton.Visible = false
        end

        local host,newPlr = getPlayerNameFromId(lobby.hostId),nil
        currentLobby = lobbyId
        lobbySummary["MapPhoto ImageLabel"].Image = lobby.map.imageId
        lobbySummary.LobbyName.Text = lobby.map.name.." - "..host
        lobbySummary.HostName.Text = host
        lobbySummary.PlayerCount.Text = #lobby.players.."/"..lobby.maxPlayers
        statusPill.StatusText.Text = "Waiting"
        for i,ids in pairs(lobby.spectators) do
            local plrName = getPlayerNameFromId(ids)
            if not spectatorsTeam:FindFirstChild(plrName) then
                if plrName and ids ~= lobby.hostId then
                    newPlr = intrudersTeam.PlayerExample:Clone()
                    newPlr.Name = plrName
                    newPlr.PlayerName.Text = plrName
                    newPlr.Parent = spectatorsTeam
                    newPlr["Avatar Photo"].Image = photosCache.getPlayerPhoto(ids)
                    newPlr.Visible = true
                elseif plrName and ids == lobby.hostId then
                    newPlr = guardsTeam.Host:Clone()
                    newPlr.Name = host
                    newPlr.PlayerName.Text = host
                    newPlr.Parent = spectatorsTeam
                    newPlr["Avatar Photo"].Image = photosCache.getPlayerPhoto(ids)
                    newPlr.Visible = true
                end
            end
        end
        for i,ids in pairs(lobby.intruders) do
            local plrName = getPlayerNameFromId(ids)
            if not intrudersTeam:FindFirstChild(plrName) then
                if plrName and ids ~= lobby.hostId then
                    newPlr = intrudersTeam.PlayerExample:Clone()
                    newPlr.Name = plrName
                    newPlr.PlayerName.Text = plrName
                    newPlr.Parent = intrudersTeam
                    newPlr["Avatar Photo"].Image = photosCache.getPlayerPhoto(ids)
                    newPlr.Visible = true
                elseif plrName and ids == lobby.hostId then
                    newPlr = guardsTeam.Host:Clone()
                    newPlr.Name = host
                    newPlr.PlayerName.Text = host
                    newPlr.Parent = intrudersTeam
                    newPlr["Avatar Photo"].Image = photosCache.getPlayerPhoto(ids)
                    newPlr.Visible = true
                end
            end
        end
        for i,ids in pairs(lobby.guards) do
            local plrName = getPlayerNameFromId(ids)
            if not guardsTeam:FindFirstChild(plrName) then
                if plrName and ids ~= lobby.hostId then
                    newPlr = guardsTeam.PlayerExample:Clone()
                    newPlr.Name = plrName
                    newPlr.PlayerName.Text = plrName
                    newPlr.Parent = guardsTeam
                    newPlr["Avatar Photo"].Image = photosCache.getPlayerPhoto(ids)
                    newPlr.Visible = true
                elseif plrName and ids == lobby.hostId then
                    newPlr = guardsTeam.Host:Clone()
                    newPlr.Name = host
                    newPlr.PlayerName.Text = host
                    newPlr.Parent = guardsTeam
                    newPlr["Avatar Photo"].Image = photosCache.getPlayerPhoto(ids)
                    newPlr.Visible = true
                end
            end
        end
        lobbyDetailsFrame.Visible = true
    end
end
local function leaveLobby()
    leaveLobbyEvent:FireServer(currentLobby)
    confirmationFrame.Visible = false
    lobbyDetailsFrame.Visible = false
end
createLobbyButton.MouseButton1Click:Connect(function()
    if selectedMap then
        print("Creating lobby with map: " .. selectedMap .. " and player count: " .. playerCount)
        createLobbyUi.Visible = false
        createLobby()
        selectedMap,playerCount = nil,2
        selectedMapText.Text = "Selected Map:"
        task.wait(.5)
        loadLobbyDetails(tostring(player.UserId))

    else
        print("Please select a map before creating a lobby.")
    end
end)

joinLobbyEvent.OnClientEvent:Connect(function(hostId)
    task.wait(.5)
    loadLobbyDetails(tostring(hostId))
end)

returnButtonDetails.MouseButton1Click:Connect(function()
    confirmationFrame.Visible = true
end)

cancelLeaveButton.MouseButton1Click:Connect(function()
    confirmationFrame.Visible = false
end)

confirmLeaveButton.MouseButton1Click:Connect(function()
   
    leaveLobby()
end)

leaveLobbyEvent.OnClientEvent:Connect(function(hostId,playerWhoLeft)
    if currentLobby == tostring(hostId) then
        if playerWhoLeft.UserId == player.UserId then
            lobbyDetailsFrame.Visible = false
        else
            local plrName = getPlayerNameFromId(playerWhoLeft.UserId)
            if guardsTeam:FindFirstChild(plrName) then
                guardsTeam:FindFirstChild(plrName):Destroy()
            end
            if intrudersTeam:FindFirstChild(plrName) then
                intrudersTeam:FindFirstChild(plrName):Destroy()
            end
            if spectatorsTeam:FindFirstChild(plrName) then
                spectatorsTeam:FindFirstChild(plrName):Destroy()
            end
        end
    end
end)