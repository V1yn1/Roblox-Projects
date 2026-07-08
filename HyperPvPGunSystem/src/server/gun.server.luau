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

        gunFuncs.GiveGun(
            player,"Minigun",
            "AssaultRifles",
            {
                mode = "auto",
                rate = .01,
                ammo =  200,
                dmg = 5,
                headDmg = 20,
                image = 16600641613
            },
            {
                posture = 85100648547457,
                aimup = 98460758375509,
                aim = 124782385630725,
                shoot = 118487942516647,
                reload = 118487942516647,
                equip = 92415631426350
            }
        )
    end)
end)

