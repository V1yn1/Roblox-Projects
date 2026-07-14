local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local module = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("defaultGunsStats"))
local confete = ReplicatedStorage:WaitForChild("confete"):WaitForChild("confete")

local RELOAD_TIME = 2.5
local MAX_DISTANCE = 200

-- Tracer global: os outros clientes desenham os tiros de cada jogador por aqui
local tracerEvent = ReplicatedStorage:FindFirstChild("BulletTracer")
if not tracerEvent then
    tracerEvent = Instance.new("RemoteEvent")
    tracerEvent.Name = "BulletTracer"
    tracerEvent.Parent = ReplicatedStorage
end

local funcs = {}

funcs.LoadTypes = function()
    local tools = ServerStorage:WaitForChild("guns")
    for gunType, guntable in module.Guns do
        for gunName, _ in guntable do
            local tool = tools:FindFirstChild(tostring(gunName))
            if tool then
                tool:SetAttribute("gunType", tostring(gunType))
            else
                warn("LoadTypes: arma definida em defaultGunsStats sem Tool em ServerStorage.guns:", gunName)
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


function funcs.GiveGun (player:Player,gunName:string,gunType:("AssaultRifles" | "Pistols")?, properties:weaponProperties?, animations:animations?, gunSounds:sounds?)
    local backpack = player.Backpack
    local tools = ServerStorage:WaitForChild("guns")
    local gun = tools:FindFirstChild(gunName)
    local autoFire = false
    local aiming = player:FindFirstChild("aiming")

    if not aiming then
        aiming = Instance.new("BoolValue",player) aiming.Name = "aiming"
    end

    if not gun then return warn("Gun not found!") end
    if not (gun:FindFirstChild("Mag") and gun:FindFirstChild("Muzzle") and gun:FindFirstChild("shoot")) then return warn("Gun is missing Parts") end

    if properties and gunType then
        if not module.Guns[gunType] then return warn("Invalid gunType, please select between the avaliables ones in defaultGunsStats") end
        module.Guns[gunType][gunName] = properties
        gun:SetAttribute("gunType",gunType)
    end

    local resolvedType = gun:GetAttribute("gunType")
    local stats = resolvedType and module.Guns[resolvedType] and module.Guns[resolvedType][gunName]
    if not stats then
        return warn("Sem stats para a arma "..gunName.." — cadastre em defaultGunsStats ou passe properties no GiveGun")
    end

    local gunObject = gun:Clone()
    -- Arma largada no chão não é utilizável por outros (remotes presos ao dono)
    gunObject.CanBeDropped = false
    -- Os stats replicam como atributo junto com o próprio Tool, então o cliente
    -- sempre os tem disponíveis ao ver a arma (sem corrida de RemoteEvent)
    local props = table.clone(stats)
    props.reloadTime = RELOAD_TIME
    gunObject:SetAttribute("props", HttpService:JSONEncode(props))

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
    ammo.Value = stats.ammo


    if not gunObject:FindFirstChild("Anims") and animations then
        local Anims = Instance.new("Folder",gunObject)
        Anims.Name = "Anims"
        for i,v in pairs(animations) do
            local animTrack = Instance.new("Animation",Anims)
            animTrack.Name = i
            animTrack.AnimationId = "rbxassetid://" .. v
        end
    end

    local handle = gunObject:FindFirstChild("Handle")
    if not handle then return warn("Arma sem Handle: "..gunName) end
    if not handle:FindFirstChild("gunsSounds") and gunSounds then
        local newSounds = Instance.new("SoundGroup",handle)
        newSounds.Name = "gunsSounds"
        for i,v in pairs(gunSounds) do
            local sound = Instance.new("Sound",newSounds)
            sound.Name = i
            sound.SoundId = "rbxassetid://" .. v
        end
    end

    local sounds = handle:FindFirstChild("gunsSounds")
    if not sounds then return warn("Arma sem gunsSounds e sem tabela de sons no GiveGun: "..gunName) end
    local shootSound = sounds:FindFirstChild("GunShot")

    local reloading = false
    local lastShot = 0
    local firingLoop = false

    aimingEvent.OnServerEvent:Connect(function(sender,state:boolean)
        if sender ~= player then return end
        if typeof(state) ~= "boolean" then return end
        aiming.Value = state
        if state == false then
            autoFire = false
        end
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
        reloading = true
        autoFire = false
        task.delay(RELOAD_TIME, function()
            reloading = false
            -- Sem recarga grátis se a arma foi guardada no meio
            if gunObject.Parent ~= player.Character then return end
            ammo.Value = stats.ammo
        end)
    end

    reloadEvent.OnServerEvent:Connect(function(sender)
        if sender ~= player then return end
        if reloading then return end
        if gunObject.Parent ~= player.Character then return end
        if ammo.Value < stats.ammo then
            reloadgun()
        end
    end)

    local function applyHit(result: RaycastResult)
        local hitPart = result.Instance
        if not (hitPart and hitPart.Parent) then return end
        local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
            or (hitPart.Parent.Parent and hitPart.Parent.Parent:FindFirstChildOfClass("Humanoid"))
        if not humanoid or not humanoid.Parent then return end

        local head = humanoid.Parent:FindFirstChild("Head")
        local isHeadshot = head and (hitPart == head
            or hitPart:FindFirstChild("HatAttachment")
            or hitPart:FindFirstChild("FaceCenterAttachment")
            or hitPart:FindFirstChild("HairAttachment"))

        if isHeadshot then
            if not head:FindFirstChild("confete") then
                local confeteInstance = confete:Clone()
                for _,v in pairs(confeteInstance:GetChildren()) do
                    v.Parent = head
                    v.Name = "confete"
                end
                confeteInstance:Destroy()
            end
            for _,v in pairs(head:GetChildren()) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = true
                    task.delay(1, function()
                        v.Enabled = false
                    end)
                end
            end
            humanoid:TakeDamage(stats.headDmg)
        else
            humanoid:TakeDamage(stats.dmg)
        end
    end

    local function shoot()
        lastShot = os.clock()

        local invokeThread
        invokeThread = task.spawn(function()
            -- A direção vem do cliente: valida tipo e normaliza antes de usar
            local ok, dir = pcall(function()
                return getPosRF:InvokeClient(player)
            end)
            invokeThread = nil
            if not ok or typeof(dir) ~= "Vector3" then return end
            if dir.Magnitude == 0 or dir.Magnitude ~= dir.Magnitude then return end
            dir = dir.Unit
            if dir.X ~= dir.X then return end

            local shootPart = gunObject:FindFirstChild("shoot")
            if not shootPart then return end
            local origin = shootPart.WorldPosition

            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {player.Character}
            params.IgnoreWater = true
            params.CollisionGroup = "Default"

            local result = workspace:Raycast(origin, dir * MAX_DISTANCE, params)
            local distance = result and result.Distance or MAX_DISTANCE

            -- O atirador já desenha o próprio tracer no GetPosition; replica para os demais
            for _,other in Players:GetPlayers() do
                if other ~= player then
                    tracerEvent:FireClient(other, origin, dir, distance)
                end
            end

            if result then
                applyHit(result)
            end
        end)

        -- Watchdog: cliente que nunca responde o InvokeClient não acumula threads
        task.delay(1, function()
            if invokeThread then
                pcall(task.cancel, invokeThread)
                invokeThread = nil
            end
        end)

        if shootSound then
            shootSound:Play()
        end
        ammo.Value -= 1
    end

    shootEvent.OnServerEvent:Connect(function(sender, action)
        if sender ~= player then return end
        if action == "stop" then
            autoFire = false
            return
        end
        if gunObject.Parent ~= player.Character then return end
        if reloading then return end
        if not aiming.Value then return end
        if ammo.Value <= 0 then return end

        -- O modo vem dos stats do servidor, nunca do argumento do cliente
        if stats.mode == "auto" then
            if firingLoop then return end
            firingLoop = true
            autoFire = true -- não depende da ordem de replicação do Tool.Activated
            while autoFire and aiming.Value and not reloading do
                if gunObject.Parent ~= player.Character then break end
                if ammo.Value <= 0 then break end
                shoot()
                task.wait(stats.rate)
            end
            firingLoop = false
        else
            autoFire = false
            if os.clock() - lastShot < stats.rate * 0.9 then return end
            shoot()
        end
    end)

    gunObject.Parent = backpack

    return gunObject
end
return funcs
