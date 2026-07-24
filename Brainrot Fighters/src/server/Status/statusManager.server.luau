local ReplicatedStorage = game:GetService("ReplicatedStorage")


local statusModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Status_model"):WaitForChild("statusModule"))
local statusChanger = require(script.Parent:WaitForChild("statusChanger"))

local getStatus:RemoteFunction = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("getStatus")

game.Players.PlayerAdded:Connect(function(player)
    statusChanger.ChangeStatus(player,statusChanger.defaultStatus)
end)

getStatus.OnServerInvoke = function(player)
    return statusModule[player.Name]
end

local goToLobbyEvent:RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("goToLobby")
goToLobbyEvent.OnServerEvent:Connect(function(player)
    statusChanger.ChangeStatus(player,statusChanger.status.inlobby)
end)



