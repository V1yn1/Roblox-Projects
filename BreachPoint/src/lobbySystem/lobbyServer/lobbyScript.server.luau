local updateUi = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("UpdateUI")
local createLobbyEvent = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("CreateLobby")
local loadLobbiesEvent = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("LoadLobbies")
local joinLobbyEvent = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("JoinLobby")
local leaveLobbyEvent = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("LeaveLobby")
local maps = require(game.ReplicatedStorage.LobbyShared:WaitForChild("maps"))
local lobbies = require(script.Parent:WaitForChild("lobbies"))

updateUi.OnServerInvoke = function(player)
    return lobbies
end

createLobbyEvent.OnServerEvent:Connect(function(player,map,playerCount)
    if maps[map] and playerCount >= 2 and playerCount <= 10 and not lobbies[player.UserId] then
        lobbies.addlobby(player.UserId, maps[map],playerCount)
        task.wait(2.5)
        loadLobbiesEvent:FireAllClients()
    else
        print("Player "..player.Name.." attempted to create a lobby with invalid parameters.")
    end
end)

joinLobbyEvent.OnServerEvent:Connect(function(player, hostId)
    if lobbies[hostId] then
        if lobbies[hostId].maxPlayers <= #lobbies[hostId].players then
            return warn("Lobby is full.")
        end
        if table.find(lobbies[hostId].players, player.UserId) then
            return warn("Player is already in the lobby.")
        end

        lobbies.joinLobby(player.UserId, hostId)
        lobbies.joinTeam(player.UserId, hostId, "spectators")
        task.wait(.5)
        loadLobbiesEvent:FireAllClients()
        joinLobbyEvent:FireAllClients(hostId)
    end
end)

leaveLobbyEvent.OnServerEvent:Connect(function(player, hostId)
    if lobbies[hostId] and table.find(lobbies[hostId].players, player.UserId) then
        lobbies.leaveLobby(player.UserId, hostId)
        task.wait(.5)
        loadLobbiesEvent:FireAllClients()
        leaveLobbyEvent:FireAllClients(hostId,player)
    end
end)
