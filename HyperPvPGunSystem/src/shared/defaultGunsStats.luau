local ServerStorage = game:GetService("ServerStorage")
local module = {
    Guns = {
        AssaultRifles = {
            ["M4A1"] = {
                mode = "auto",
                rate = .09,
                ammo = 25,
                dmg = 20,
                headDmg = 50,
                image = "rbxassetid://16600641613"
            },
            ["G36"] = {
                mode = "auto",
                rate = .15,
                ammo = 30,
                dmg = 20,
                headDmg = 100,
                image = "rbxassetid://16600641613"
            }
        },
        Pistols = {
            ["Glock 22"] = {
                mode = "semi",
                rate = .3,
                ammo = 15,
                dmg = 15,
                headDmg = 100,
                image = "rbxassetid://105540078"
            }
        }
    }
}
module.LoadTypes = function()
    for type,guntable in module.Guns do
        for gun,properties in guntable do 
            local tool = ServerStorage:WaitForChild("guns"):WaitForChild(tostring(gun))
            if tool then
                tool:SetAttribute("gunType",tostring(type))
            end
        end
    end
end
return module