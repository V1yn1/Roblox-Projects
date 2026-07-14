local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local guns = ServerStorage:WaitForChild("guns")
local gunFuncs = require(ServerScriptService:WaitForChild("Server"):WaitForChild("gunFunctions"))

gunFuncs.LoadTypes()

local function giveGuns(player)
    -- armas com instancias já configuradas
    local g19 = gunFuncs.GiveGun(player,"Glock 19","Pistols",
    { -- properties
        mode = "semi",
        rate = .2,
        ammo = 33,
        dmg = 15,
        headDmg = 100,
        image = 105540078
    },
    {--animations
        aim = 132025824383295,
        aimup = 80199894013053,
        equip = 92415631426350,
        posture = 85100648547457,
        reload = 98346327662516,
        shoot = 132926202227848
    },
    {--sounds
        GunShot = 3742720331,
        AimUp = 619576578,
        AimDown = 619578856,
        Tick = 321719832,
        Reload = 402318477,
        GunEquip = 137595180744957,
    }
)
    local g22 = gunFuncs.GiveGun(player,"Glock 22","Pistols",
    { -- properties
        mode = "auto",
        rate = .5,
        ammo = 15,
        dmg = 15,
        headDmg = 100,
        image = 105540078
    },
    {--animations
        aim = 132025824383295,
        aimup = 80199894013053,
        equip = 92415631426350,
        posture = 85100648547457,
        reload = 98346327662516,
        shoot = 132926202227848
    },
    {--sounds
        GunShot = 3742720331,
        AimUp = 619576578,
        AimDown = 619578856,
        Tick = 321719832,
        Reload = 402318477,
        GunEquip = 137595180744957,
    }
)
    local g36 = gunFuncs.GiveGun(player,"G36")

    -- exemplo de arma sem instancias previamente declaradas
   gunFuncs.GiveGun(
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
        },
        {
            GunShot = 146830867,
            AimUp = 619576578,
            AimDown = 619578856,
            Tick = 321719832,
            Reload = 402318477,
            GunEquip = 7127178040,
        }
    )
end

local function onPlayerAdded(player)
    if not player:FindFirstChild("aiming") then
        local aiming = Instance.new("BoolValue",player)
        aiming.Name = "aiming"
    end

    player.CharacterAdded:Connect(function()
        giveGuns(player)
    end)
    if player.Character then
        task.spawn(giveGuns, player)
    end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)
for _,player in game.Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end
