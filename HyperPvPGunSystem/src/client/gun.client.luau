local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local gunStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("defaultGunsStats"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local canAim = player:FindFirstChild("canAim")
if not canAim then
    canAim = Instance.new("BoolValue")
    canAim.Name = "canAim"
    canAim.Parent = player
end
local aiming = player:WaitForChild("aiming")

local aimConnection,releaseConnection,mouseConnection,mouseUpConnection,reloadConnection,magdropConnection
local currentGunEquiped, shotLight
local lastShotTime = 0

-- canAim é derivado de um único lugar: arma pronta E sem sprint
-- (movement.client publica o atributo "sprinting"; ninguém mais escreve canAim)
local gunReady = false
local function updateCanAim()
    canAim.Value = gunReady and not player:GetAttribute("sprinting")
end
player:GetAttributeChangedSignal("sprinting"):Connect(updateCanAim)

local LoadedGunTracks = {}

local function warmupTrack(track: AnimationTrack)
    -- Toca invisível: peso 0 e velocidade 0
    track:Play(0, 0, 0)

    task.delay(0.05, function()
        if track.IsPlaying then
            track:Stop(0)
        end
    end)
end

local function TickLight()
    -- Captura local: shotLight pode mudar durante o task.wait
    local light = shotLight
    if not light then return end
    light.Enabled = true
    task.wait(.15)
    light.Enabled = false
end

local function GenerateBulletPart(origin, direction, distance)
    local bullet = Instance.new("Part")
    bullet.Anchored = true
    bullet.CanCollide = false
    bullet.Material = Enum.Material.Neon
    bullet.Color = Color3.fromRGB(255, 255, 0)
    bullet.CastShadow = false

    bullet.Size = Vector3.new(0.1, 0.1, distance)
    bullet.Transparency = 0.8

    local center = origin + direction * (distance / 2)

    bullet.CFrame = CFrame.lookAt(center, center + direction)

    bullet.Parent = workspace

    task.delay(0.05, function()
        bullet:Destroy()
    end)
end

-- Tracers dos tiros dos outros jogadores
task.spawn(function()
    local tracerEvent = ReplicatedStorage:WaitForChild("BulletTracer")
    tracerEvent.OnClientEvent:Connect(function(origin, direction, distance)
        if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" and typeof(distance) == "number" then
            GenerateBulletPart(origin, direction, distance)
        end
    end)
end)

-- Os stats chegam num atributo JSON junto com o Tool (sem corrida de RemoteEvent)
local function getStats(gun: Tool)
    local gunType = gun:GetAttribute("gunType")
    if not gunType then return nil end
    if not gunStats.Guns[gunType] then
        gunStats.Guns[gunType] = {}
    end

    local raw = gun:GetAttribute("props")
    if raw then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(decoded) == "table" then
            gunStats.Guns[gunType][gun.Name] = decoded
            return decoded
        end
    end
    return gunStats.Guns[gunType][gun.Name]
end

local function loadGunAnimations(animator: Animator, gun: Tool)
    if LoadedGunTracks[gun] then
        return LoadedGunTracks[gun]
    end

    local anims = gun:WaitForChild("Anims")

    local equip = anims:WaitForChild("equip")
    local posture = anims:WaitForChild("posture")
    local aimUp = anims:WaitForChild("aimup")
    local aim = anims:WaitForChild("aim")
    local shoot = anims:WaitForChild("shoot")
    local reload = anims:WaitForChild("reload")
    local animList = {
        equip,
        posture,
        aimUp,
        aim,
        shoot,
        reload,
    }

    -- Pré-carrega em segundo plano para não atrasar a conexão do Equipped
    task.spawn(function()
        local success, err = pcall(function()
            ContentProvider:PreloadAsync(animList)
        end)

        if not success then
            warn("Erro ao pré-carregar animações da arma:", gun.Name, err)
        end
    end)

    -- LoadedGunTracks já evita cargas duplicadas por arma
    local tracks = {
        equip = animator:LoadAnimation(equip),
        posture = animator:LoadAnimation(posture),
        aimUp = animator:LoadAnimation(aimUp),
        aim = animator:LoadAnimation(aim),
        shoot = animator:LoadAnimation(shoot),
        reload = animator:LoadAnimation(reload),
    }

    tracks.equip.Priority = Enum.AnimationPriority.Action2
    tracks.posture.Priority = Enum.AnimationPriority.Action2
    tracks.aimUp.Priority = Enum.AnimationPriority.Action2
    tracks.aim.Priority = Enum.AnimationPriority.Action2
    tracks.shoot.Priority = Enum.AnimationPriority.Action4
    tracks.reload.Priority = Enum.AnimationPriority.Action3

    tracks.posture.Looped = true
    tracks.aim.Looped = true
    tracks.aimUp.Looped = true

    for _, track in pairs(tracks) do
        warmupTrack(track)
    end

    LoadedGunTracks[gun] = tracks

    return tracks
end

local backpackConnection

local function onCharacterAdded(char)
    -- As tracks antigas pertencem ao Animator do personagem anterior
    table.clear(LoadedGunTracks)

    local animator = char:WaitForChild("Humanoid"):WaitForChild("Animator")
    local gui = player:WaitForChild("PlayerGui"):WaitForChild("gunSystem")
    local guninfo = gui:WaitForChild("gunInfo")
    local gunimage = guninfo:WaitForChild("gunImage")
    local gunimageShadow = guninfo:WaitForChild("gunImageshadow")
    local ammotext = guninfo:WaitForChild("ammo")

    local function initialize(gun: Tool)
        if not gun:IsA("Tool") or gun:GetAttribute("gunType") == nil then return end
        if gun:GetAttribute("initialized") then return end
        gun:SetAttribute("initialized", true)

        local stats = getStats(gun)
        if not stats then
            warn("Sem stats no cliente para a arma:", gun.Name)
            return
        end

        local events = gun:WaitForChild("Events")
        local getPosRF = events:WaitForChild("GetPosition")
        local shotEvent = events:WaitForChild("Shoot")
        local aimEvent = events:WaitForChild("Aiming")
        local reloadEvent = events:WaitForChild("Reload")
        local ammoValue = gun:WaitForChild("ammo")
        local gunSounds = gun:WaitForChild("Handle"):WaitForChild("gunsSounds")

        local currentEquipToken = 0
        local reloading = false
        local mode = stats.mode
        local cooldown = stats.rate

        getPosRF.OnClientInvoke = function()
            local shootPart = gun:FindFirstChild("shoot")
            if not shootPart then return Vector3.zero end

            local origin = shootPart.WorldPosition
            local direction = (mouse.Hit.Position - origin).Unit
            local distance = 200
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {player.Character}
            params.IgnoreWater = true

            local result = workspace:Raycast(origin, direction * distance, params)

            if result then
                distance = result.Distance
            end

            GenerateBulletPart(origin, direction, distance)
            return direction
        end

        local tracks = loadGunAnimations(animator, gun)

        local function onEquipped()
            gunimage.Image = "rbxassetid://"..stats.image
            gunimageShadow.Image = "rbxassetid://"..stats.image
            ammotext.Text = ammoValue.Value.."/"..stats.ammo
            guninfo.Visible = true

            shotLight = nil
            local muzzle = gun:FindFirstChild("Muzzle")
            if muzzle and muzzle:FindFirstChild("PointLight") then
                shotLight = muzzle.PointLight
            end

            currentEquipToken += 1
            local myToken = currentEquipToken
            tracks = loadGunAnimations(animator, gun)
            reloading = false
            currentGunEquiped = gun

            local equipSound = gunSounds:FindFirstChild("GunEquip")
            if equipSound then
                equipSound:Play()
            end
            RunService.Heartbeat:Wait()
            if myToken ~= currentEquipToken then return end
            tracks.posture:Stop(0)
            tracks.aim:Stop(0)
            tracks.aimUp:Stop(0)

            tracks.equip:Play(0.1, 1, 1)

            local playedPosture = false

            local function startPosture()
                if playedPosture then return end
                playedPosture = true

                if myToken ~= currentEquipToken then return end
                if gun.Parent ~= char then return end

                tracks.posture:Play(0.1, 1, 1)
            end

            local stoppedConnection
            stoppedConnection = tracks.equip.Stopped:Connect(function()
                if stoppedConnection then
                    stoppedConnection:Disconnect()
                end

                startPosture()
            end)

            -- Fallback caso Length ainda venha 0 ou a track não dispare como esperado
            task.delay(math.max(tracks.equip.Length, 0.4), startPosture)

            task.wait(.9)
            -- A arma pode ter sido trocada ou guardada durante a espera
            if myToken ~= currentEquipToken or gun.Parent ~= char then return end
            gunReady = true
            updateCanAim()

            if aimConnection then
                aimConnection:Disconnect()
                aimConnection = nil
            end
            local aimDebounce = false
            aimConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
                if currentGunEquiped ~= gun or aimDebounce then return end
                if not canAim.Value then return end
                aimDebounce = true
                tracks.posture:Stop(0.1)
                tracks.aim:Play(0.1, 1, 1)
                gunSounds:WaitForChild("AimUp"):Play()
                aimEvent:FireServer(true)
                task.wait(.1)
                aimDebounce = false
            end)

            if releaseConnection then
                releaseConnection:Disconnect()
                releaseConnection = nil
            end
            local releaseDebounce = false
            releaseConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
                if currentGunEquiped ~= gun or releaseDebounce then return end
                releaseDebounce = true
                tracks.aim:Stop(0.1)
                tracks.shoot:Stop(0.1)
                tracks.posture:Play(0.1, 1, 1)
                if canAim.Value then
                    gunSounds:WaitForChild("AimDown"):Play()
                end
                -- O servidor precisa saber que a mira acabou mesmo com canAim falso
                aimEvent:FireServer(false)
                task.wait(.1)
                releaseDebounce = false
            end)

            if mouseConnection then
                mouseConnection:Disconnect()
                mouseConnection = nil
            end
            mouseConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                if currentGunEquiped ~= gun or reloading then return end
                if not aiming.Value then return end

                if ammoValue.Value <= 0 then
                    gunSounds:WaitForChild("Tick"):Play()
                    return
                end

                if mode == "semi" then
                    if os.clock() - lastShotTime < cooldown then return end
                    lastShotTime = os.clock()
                    tracks.shoot.Looped = false
                    tracks.shoot:Play(0.1, 1, 1)
                    task.spawn(TickLight)
                    shotEvent:FireServer(mode)
                elseif mode == "auto" then
                    tracks.shoot.Looped = true
                    tracks.shoot:Play()
                    shotEvent:FireServer(mode)
                end
            end)

            if mouseUpConnection then
                mouseUpConnection:Disconnect()
                mouseUpConnection = nil
            end
            mouseUpConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                if mode == "auto" then
                    if LoadedGunTracks[gun] then
                        LoadedGunTracks[gun].shoot.Looped = false
                        LoadedGunTracks[gun].shoot:Stop()
                    end
                    -- Sinal explícito de parada, sem depender só do Tool.Deactivated
                    shotEvent:FireServer("stop")
                end
            end)

            if reloadConnection then
                reloadConnection:Disconnect()
                reloadConnection = nil
            end
            reloadConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode ~= Enum.KeyCode.R then return end
                if currentGunEquiped ~= gun or reloading then return end
                if ammoValue.Value >= stats.ammo then return end

                reloading = true
                local reloadToken = currentEquipToken
                tracks.aim.Looped = false
                tracks.aim:Stop(0.1)
                tracks.shoot.Looped = false
                tracks.shoot:Stop(0.1)
                aiming.Value = false
                aimEvent:FireServer(false)
                gunReady = false
                updateCanAim()
                task.wait(.1)
                tracks.reload:Play()
                gunSounds:WaitForChild("Reload"):Play()

                local newMag
                local mag = gun:FindFirstChild("Mag")
                if mag then
                    newMag = mag:Clone()
                    newMag.Parent = workspace
                    newMag.CFrame = mag.CFrame
                    newMag.CanCollide = true
                    for _,v in pairs(newMag:GetChildren()) do
                        if v:IsA("WeldConstraint") then
                            v:Destroy()
                        end
                    end
                    newMag.Transparency = 1
                    mag.Transparency = 0
                end

                reloadEvent:FireServer()

                if magdropConnection then
                    magdropConnection:Disconnect()
                end
                magdropConnection = tracks.reload:GetMarkerReachedSignal("FakeMag"):Connect(function()
                    if reloadToken ~= currentEquipToken or not mag or not newMag then return end
                    mag.Transparency = 1
                    newMag.Transparency = 0
                    newMag.CFrame = mag.CFrame
                    task.wait(.5)
                    mag.Transparency = 0
                end)

                -- Usa a duração do servidor como mínimo (Length pode ser 0 antes do asset carregar)
                task.delay(math.max(tracks.reload.Length, stats.reloadTime or 2.5), function()
                    -- Limpeza incondicional, mesmo se a arma foi guardada no meio
                    if newMag then
                        newMag:Destroy()
                    end
                    reloading = false
                    if mag then
                        mag.Transparency = 0
                    end
                    tracks.posture.Looped = true
                    tracks.aim.Looped = true
                    if reloadToken ~= currentEquipToken or gun.Parent ~= char then return end
                    tracks.posture:Play()
                    gunReady = true
                    updateCanAim()
                end)
            end)
        end

        gun.Equipped:Connect(onEquipped)

        gun.Unequipped:Connect(function()
            guninfo.Visible = false
            currentEquipToken += 1

            gunReady = false
            updateCanAim()
            aiming.Value = false
            reloading = false
            -- Garante que o servidor não fique com a mira presa em true
            aimEvent:FireServer(false)

            if currentGunEquiped == gun then
                currentGunEquiped = nil
            end

            local tracks = LoadedGunTracks[gun]
            if tracks then
                tracks.equip:Stop(0.05)
                tracks.posture:Stop(0.1)
                tracks.aim:Stop(0.1)
                tracks.aimUp:Stop(0.1)
                tracks.shoot:Stop(0.1)
                tracks.reload:Stop(0.1)
            end
            local reloadSound = gunSounds:FindFirstChild("Reload")
            if reloadSound then
                reloadSound:Stop()
            end
            if aimConnection then
                aimConnection:Disconnect()
                aimConnection = nil
            end

            if releaseConnection then
                releaseConnection:Disconnect()
                releaseConnection = nil
            end

            if mouseConnection then
                mouseConnection:Disconnect()
                mouseConnection = nil
            end

            if mouseUpConnection then
                mouseUpConnection:Disconnect()
                mouseUpConnection = nil
            end

            if reloadConnection then
                reloadConnection:Disconnect()
                reloadConnection = nil
            end

            if magdropConnection then
                magdropConnection:Disconnect()
                magdropConnection = nil
            end
        end)

        ammoValue.Changed:Connect(function()
            if ammoValue.Value <= 0 then
                gunSounds:WaitForChild("Tick"):Play()
                if LoadedGunTracks[gun] then
                    LoadedGunTracks[gun].shoot:Stop()
                end
            elseif ammoValue.Value ~= stats.ammo and currentGunEquiped == gun then
                task.spawn(TickLight)
            end
            if currentGunEquiped == gun then
                ammotext.Text = ammoValue.Value.."/"..stats.ammo
            end
        end)

        -- A arma pode já estar equipada quando o initialize roda
        if gun.Parent == char then
            task.spawn(onEquipped)
        end
    end

    if backpackConnection then
        backpackConnection:Disconnect()
    end
    backpackConnection = player.Backpack.ChildAdded:Connect(function(gun: Tool)
        initialize(gun)
    end)

    -- Ferramentas que chegaram antes deste script conectar
    for _,tool in pairs(player.Backpack:GetChildren()) do
        task.spawn(initialize, tool)
    end
    for _,tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            task.spawn(initialize, tool)
        end
    end
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    task.spawn(onCharacterAdded, player.Character)
end
