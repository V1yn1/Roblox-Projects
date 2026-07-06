
local module = {
    Guns = {
        AssaultRifles = {
            ["M4A1"] = {
                mode = "auto",
                rate = .09,
                ammo = 25,
                dmg = 20,
                headDmg = 50,
                image = 16600641613
            },
            ["G36"] = {
                mode = "auto",
                rate = .15,
                ammo = 30,
                dmg = 20,
                headDmg = 100,
                image = 16600641613
            }
        },
        Pistols = {
            ["Glock 22"] = {
                mode = "semi",
                rate = .3,
                ammo = 15,
                dmg = 15,
                headDmg = 100,
                image = 105540078
            },
            ["Glock 19"] = {
                mode = "semi",
                rate = .5,
                ammo = 33,
                dmg = 15,
                headDmg = 100,
                image = 105540078
            }
        }
    }
}

return module