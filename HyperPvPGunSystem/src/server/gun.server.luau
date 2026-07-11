local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local guns = ServerStorage:WaitForChild("guns")
local gunFuncs = require(ServerScriptService:WaitForChild("Server"):WaitForChild("gunFunctions"))

gunFuncs.LoadTypes()
local function equip(tool:Tool, player:Player)
    tool.Parent = player.Character
    task.wait(.8)
    tool.Parent = player.Backpack
end
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(5)
        -- armas com instancias já configuradas
        local g19 = gunFuncs.GiveGun(player,"Glock 19")
        
        local g36 = gunFuncs.GiveGun(player,"G36")

        -- exemplo de arma sem instancias previamente declaradas
       --[[ gunFuncs.GiveGun(
            player,"Minigun",
            "AssaultRifles",
            {
                mode = "auto",
                rate = .05,
                ammo =  200,
                dmg = 5,
                headDmg = 20,
                image = 16600641613
            },
            {
                posture = 100243385547218,
                aimup = 100243385547218,
                aim = 100243385547218,
                shoot = 100243385547218,
                reload = 118487942516647,
                equip = 92415631426350
            }
        )]]--
    end)
end)

