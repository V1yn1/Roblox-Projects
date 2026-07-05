local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local module = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("defaultGunsStats"))
local funcs = {}
funcs.LoadTypes = function()
    for type,guntable in module.Guns do
        for gun,_ in guntable do
            local tool = ServerStorage:WaitForChild("guns"):WaitForChild(tostring(gun))
            if tool then
                tool:SetAttribute("gunType",tostring(type))
            end
        end
    end
end
-- only callable via server
funcs.GiveGun = function(player:Player,gunName:string)
    local char = player.Character
    local backpack = player.Backpack
    local tools = game:GetService("ServerStorage"):WaitForChild("guns")
    local gun = tools:FindFirstChild(gunName)
    local autoFire = false

    if not gun then return end
    local gunObject = gun:Clone()
    gunObject.Parent = backpack
    local events = Instance.new("Folder",gunObject)
    events.Name = "Events"
    local shootEvent = Instance.new("RemoteEvent",events)
    shootEvent.Name = "Shoot"
    local getPosRF = Instance.new("RemoteFunction",events)
    getPosRF.Name = "GetPosition"

    local ammo = Instance.new("NumberValue",gunObject)
    ammo.Name  = "ammo"
    ammo.Value = module.Guns[gunObject:GetAttribute("gunType")][gunName].ammo

    gunObject.Activated:Connect(function()
       autoFire = true
    end)
    gunObject.Deactivated:Connect(function()
        autoFire = false
    end)
    gunObject:WaitForChild("Events"):WaitForChild("Shoot").OnServerEvent:Connect(function(player, action)
        if action == "auto" then
            while autoFire do
                if gunObject.Parent ~= char then
                    break
                end
                if autoFire == false then
                    break
                end
                if ammo.Value and ammo.Value > 0 then
                    local getPos = task.spawn(function()
                        local pos = getPosRF:InvokeClient(player)
                        if pos then
                            return pos
                        end
                    end)
                    ammo.Value -= 1
                    print(player.Name.." fired "..gunName.." with "..ammo.Value.." ammo left.")
                else
                    print(player.Name.." tried to fire "..gunName.." but is out of ammo.")
                    break
                end
                task.wait(module.Guns[gunObject:GetAttribute("gunType")][gunName].rate)
            end
        end
        if action == "semi" then
            
            if ammo.Value and ammo.Value > 0 then
                local getPos = task.spawn(function()
                    local pos = getPosRF:InvokeClient(player)
                    if pos then
                        return pos
                    end
                end)
                ammo.Value -= 1
                print(player.Name.." fired "..gunName.." with "..ammo.Value.." ammo left.")
            else
                print(player.Name.." tried to fire "..gunName.." but is out of ammo.")
            end
        end
    end)
end
return funcs