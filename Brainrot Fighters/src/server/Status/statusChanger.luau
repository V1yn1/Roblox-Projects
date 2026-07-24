local ReplicatedStorage = game:GetService("ReplicatedStorage")
local statusModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Status_model"):WaitForChild("statusModule"))
local statusChanger ={
    defaultStatus = "IN_MENU",
    status = {
        inmenu = "IN_MENU",
        inlobby = "IN_LOBBY",
        playing = "PLAYING",
        spectating = "SPECTATING",
        dead = "DEAD"
    }
}


function statusChanger.ChangeStatus(player:Player,status)
    local postStatus:RemoteEvent = ReplicatedStorage.Events.postStatus

    statusModule[player.Name] = status
    postStatus:FireClient(player,status)

    return statusModule[player.Name]
end
return statusChanger