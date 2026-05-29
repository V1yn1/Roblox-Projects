local lobbies  = {} 
    local maps = require(game.ReplicatedStorage.LobbyShared.maps)

    function lobbies.addlobby(hostId, map)
        if  lobbies[hostId] then
            return
        end
        if not maps[map] then
            return
        end
        
        local lobbySetup  = {
            hostId = hostId,
            map = map,
            players = {hostId}
        }
        lobbies[hostId] = lobbySetup
    end

return lobbies