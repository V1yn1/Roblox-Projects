local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local module = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("defaultGunsStats"))
local confete = ReplicatedStorage:WaitForChild("confete"):WaitForChild("confete")
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
type weaponProperties = {
    mode : string,
    rate : number,
    ammo : number,
    dmg : number,
    headDmg : number,
    image : number
}
type animations = {
    posture : number,
    aimup : number,
    aim : number,
    shoot : number,
    reload : number,
    equip : number,
}
type sounds = {
    GunShot : number,
    AimUp : number,
    AimDown : number,
    Tick : number,
    Reload : number,
    GunEquip : number,

}


funcs.GiveGun = function(player:Player,gunName:string,gunType:"AssaultRifles | Pistols", properties:weaponProperties, animations:animations, sounds:sounds)
    local char = player.Character
    local backpack = player.Backpack
    local tools = game:GetService("ServerStorage"):WaitForChild("guns")
    local gun = tools:FindFirstChild(gunName)
    local autoFire = false
    local aiming = Instance.new("BoolValue",player) aiming.Name = "aiming"
    if not gun then return warn("Gun not found!") end
    if not (gun:FindFirstChild("Mag") and gun:FindFirstChild("Muzzle") and gun:FindFirstChild("shoot")) then return warn("Gun is missing Parts") end
    if properties and gunType then
        if not module.Guns[gunType] then return warn("Invalid gunType, please select between the avaliables ones in defaultGunsStats") end
        module.Guns[gunType][gunName] = properties
        gun:SetAttribute("gunType",gunType)
        local RE = Instance.new("RemoteEvent",player)
        RE.Name = "infos"
        task.delay(.5,function()
            RE:FireClient(player,properties)
            task.wait(.5)
            RE:Destroy()
        end)
    end

    local gunObject = gun:Clone()

    gunObject.Parent = backpack
    local events = Instance.new("Folder",gunObject)
    events.Name = "Events"
    local shootEvent = Instance.new("RemoteEvent",events)
    shootEvent.Name = "Shoot"
    local getPosRF = Instance.new("RemoteFunction",events)
    getPosRF.Name = "GetPosition"
    local reloadEvent = Instance.new("RemoteEvent",events)
    reloadEvent.Name = "Reload"
    local aimingEvent = Instance.new("RemoteEvent",events)
    aimingEvent.Name = "Aiming"
    local ammo = Instance.new("NumberValue",gunObject)
    ammo.Name  = "ammo"
    ammo.Value = module.Guns[gunObject:GetAttribute("gunType")][gunName].ammo or properties.ammo

    local sounds = gunObject:WaitForChild("Handle"):WaitForChild("gunsSounds")
    local shootSound = sounds:WaitForChild("GunShot")

    if not gunObject:FindFirstChild("Anims") then
        local Anims = Instance.new("Folder",gunObject)
        Anims.Name = "Anims"
        for i,v in pairs(animations) do
            local animTrack = Instance.new("Animation",Anims)
            animTrack.Name = i
            animTrack.AnimationId = "rbxassetid://"..v
        end
    end
    aimingEvent.OnServerEvent:Connect(function(player,state:boolean)
            aiming.Value = state
            if state == false then
                autoFire = false
            end
            print("recieved" .. tostring(aiming.Value))
    end)
    gunObject.Activated:Connect(function()
        if aiming.Value then
            autoFire = true
        end
    end)
    gunObject.Deactivated:Connect(function()
        autoFire = false
    end)
    local function reloadgun()
        autoFire = false
        task.delay(2.5, function()
            ammo.Value = module.Guns[gunObject:GetAttribute("gunType")][gunName].ammo
        end)
    end
    gunObject:WaitForChild("Events"):WaitForChild("Reload").OnServerEvent:Connect(function(player)
        if ammo.Value < module.Guns[gunObject:GetAttribute("gunType")][gunName].ammo then
            reloadgun()
        end
    end)
    gunObject:WaitForChild("Events"):WaitForChild("Shoot").OnServerEvent:Connect(function(player, action)
        local params = RaycastParams.new()

        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {player.Character}
        params.IgnoreWater = true
        params.CollisionGroup = "Default" -- opcional

        local function shoot()
            local getPos = task.spawn(function()
                local pos = getPosRF:InvokeClient(player)
                local origin = gunObject:FindFirstChild("shoot").WorldPosition
                local result = workspace:Raycast(origin, pos * 200, params)
                if result then
                        local hitPart = result.Instance
                        local hitPos = result.Position
                        local hitNormal = result.Normal

                    if hitPart and hitPart.Parent then
                        local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid") or hitPart.Parent.Parent:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            print(hitPart.Name)
                            if hitPart == humanoid.Parent:FindFirstChild("Head") or hitPart:FindFirstChild("HatAttachment") or hitPart:FindFirstChild("FaceCenterAttachment") or hitPart:FindFirstChild("HairAttachment") then
                                if not humanoid.Parent:FindFirstChild("Head"):FindFirstChild("confete") then
                                    local confeteInstance = confete:Clone()
                                    for i,v in pairs(confeteInstance:GetChildren()) do
                                        v.Parent = humanoid.Parent:FindFirstChild("Head")
                                        v.Name = "confete"
                                    end
                                    confeteInstance:Destroy()
                                end
                                for i,v in pairs(humanoid.Parent:FindFirstChild("Head"):GetChildren()) do
                                    if v:IsA("ParticleEmitter") then
                                        v.Enabled = true
                                        task.delay(1, function()
                                            v.Enabled = false
                                        end)
                                    end
                                end
                                humanoid:TakeDamage(module.Guns[gunObject:GetAttribute("gunType")][gunName].headDmg)
                            else
                                humanoid:TakeDamage(module.Guns[gunObject:GetAttribute("gunType")][gunName].dmg)
                            end
                        end
                    end
                end
            end)
           

            if shootSound then
                shootSound:Play()
            end
            ammo.Value -= 1
            print(player.Name.." fired "..gunName.." with "..ammo.Value.." ammo left.")
        end

        if action == "auto" then
            while autoFire and  aiming.Value do
                if gunObject.Parent ~= char or not autoFire or not aiming.Value then
                    break
                end

                if ammo.Value and ammo.Value > 0 then
                    shoot()
                else
                    print(player.Name.." tried to fire "..gunName.." but is out of ammo.")
                    break
                end
                task.wait(module.Guns[gunObject:GetAttribute("gunType")][gunName].rate)
            end
        end
        if action == "semi" then
            autoFire = false
            if ammo.Value and ammo.Value > 0 then
                shoot()
            else
                print(player.Name.." tried to fire "..gunName.." but is out of ammo.")
            end
        end

    end)
    return gunObject
end
return funcs