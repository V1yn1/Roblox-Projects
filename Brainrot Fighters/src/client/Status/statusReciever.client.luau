local ReplicatedStorage = game:GetService("ReplicatedStorage")
local postStatus:RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("postStatus")
local statusModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Status_model"):WaitForChild("statusModule"))
local player = game.Players.LocalPlayer

postStatus.OnClientEvent:Connect(function(status)
    statusModule[player.Name] = status
    
end)