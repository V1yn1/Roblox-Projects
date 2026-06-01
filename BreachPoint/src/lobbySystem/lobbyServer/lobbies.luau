local lobbies  = {}
    local maps = require(game.ReplicatedStorage.LobbyShared.maps)

    function lobbies.addlobby(hostId, map, playerCount)
        if  lobbies[hostId] then
            return
        end
        if not maps[map.name] then
            return
        end

        local lobbySetup  = {
            hostId = hostId,
            map = map,
            players = {hostId},
            maxPlayers = playerCount,
            intruders = {},
            guards = {},
            spectators = {hostId}
        }
        lobbies[hostId] = lobbySetup
    end
    function lobbies.joinLobby(playerId, hostId) -- adds player to lobby, does not assign team
        local lobby = lobbies[hostId]
        if not lobby then
            return warn("Lobby does not exist.")
        end
        if #lobby.players >= lobby.maxPlayers then
            return warn("Lobby is full.")
        end
        if table.find(lobby.players, playerId) then
            return warn("Player is already in the lobby.")
        end
        table.insert(lobby.players, playerId)
    end

    function lobbies.joinTeam(playerId, hostId, team) -- adds player to team, does not check for team limits
        local lobby = lobbies[hostId]
        if not lobby then
            return warn("Lobby does not exist.")
        end
        if not table.find(lobby.players, playerId) then
            return warn("Player is not in the lobby.")
        end

        if team == "intruders" then
            if table.find(lobby.intruders, playerId) then
                return warn("Player is already in the Intruders team.")
            end
            if table.find(lobby.guards, playerId) or table.find(lobby.spectators, playerId) then
                table.remove(lobby.guards, table.find(lobby.guards, playerId))
                table.remove(lobby.spectators, table.find(lobby.spectators, playerId))
            end
            table.insert(lobby.intruders, playerId)

        elseif team == "guards" then
            if table.find(lobby.guards, playerId) then
                return warn("Player is already in the Guards team.")
            end
            if table.find(lobby.intruders, playerId) or table.find(lobby.spectators, playerId) then
                table.remove(lobby.intruders, table.find(lobby.intruders, playerId))
                table.remove(lobby.spectators, table.find(lobby.spectators, playerId))
            end
            table.insert(lobby.guards, playerId)

        elseif team == "spectators" then
            if table.find(lobby.spectators, playerId) then
                return warn("Player is already in the Spectators team.")
            end
            if table.find(lobby.guards, playerId) or table.find(lobby.intruders, playerId) then
                table.remove(lobby.guards, table.find(lobby.guards, playerId))
                table.remove(lobby.intruders, table.find(lobby.intruders, playerId))
            end
            table.insert(lobby.spectators, playerId)

        else
            return warn("Invalid team.")
        end
    end

    function lobbies.leaveLobby(playerId, hostId) -- removes player from lobby and teams, if host leaves it deletes the lobby
        local lobby = lobbies[hostId]
        if not lobby then
            return warn("Lobby does not exist.")
        end
        if not table.find(lobby.players, playerId) then
            return warn("Player is not in the lobby.")
        end
        if playerId == hostId then
            lobbies.deleteLobby(hostId)
            return
        end

        if table.find(lobby.intruders, playerId) then
            table.remove(lobby.intruders, table.find(lobby.intruders, playerId))
        end
        if table.find(lobby.guards, playerId) then
            table.remove(lobby.guards, table.find(lobby.guards, playerId))
        end
        if table.find(lobby.spectators, playerId) then
            table.remove(lobby.spectators, table.find(lobby.spectators, playerId))
        end

        table.remove(lobby.players, table.find(lobby.players, playerId))
    end

    function lobbies.deleteLobby(hostId) -- deletes lobby and removes all players from it
        lobbies[hostId] = nil
    end
return lobbies