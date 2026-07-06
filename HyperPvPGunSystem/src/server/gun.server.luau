local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local guns = ServerStorage:WaitForChild("guns")
local gunFuncs = require(ServerScriptService:WaitForChild("Server"):WaitForChild("gunFunctions"))

gunFuncs.LoadTypes()

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(2)
        gunFuncs.GiveGun(player,"Glock 19")
        gunFuncs.GiveGun(player,"G36")
        gunFuncs.GiveGun(player,"M4A1")
    end)
end)

