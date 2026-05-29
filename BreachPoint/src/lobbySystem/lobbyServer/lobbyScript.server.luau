local updateUi = game.ReplicatedStorage:WaitForChild("LobbyEvents"):WaitForChild("UpdateUI")
local lobbies = require(script.Parent:WaitForChild("lobbies"))

updateUi.OnServerInvoke = function(player)
    return lobbies or nil
end
