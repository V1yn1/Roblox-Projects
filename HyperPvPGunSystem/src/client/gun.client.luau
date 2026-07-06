local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gunStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("defaultGunsStats"))
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local canAim = player:WaitForChild("canAim")
local aiming = player:WaitForChild("aiming")
local mouse = player:GetMouse()
local aimConnection,releaseConnection,mouseConnection,mouseUpConnection
local canFire = false
local cooldown = 1
local mode, currentGunEquiped,sounds,shotLight

local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

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
    shotLight.Enabled = true
    task.wait(.15)
    shotLight.Enabled = false
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

	local animList = {
		equip,
		posture,
		aimUp,
		aim,
        shoot,
	}

	-- Pré-carrega os assets antes do uso real
	local success, err = pcall(function()
		ContentProvider:PreloadAsync(animList)
	end)

	if not success then
		warn("Erro ao pré-carregar animações da arma:", gun.Name, err)
	end

	local tracks = {
		equip = animator:GetTrackByAnimationId(equip.AnimationId) or animator:LoadAnimation(equip),
		posture = animator:GetTrackByAnimationId(posture.AnimationId) or animator:LoadAnimation(posture),
		aimUp = animator:GetTrackByAnimationId(aimUp.AnimationId) or animator:LoadAnimation(aimUp),
		aim = animator:GetTrackByAnimationId(aim.AnimationId) or animator:LoadAnimation(aim),
		shoot = animator:GetTrackByAnimationId(shoot.AnimationId) or animator:LoadAnimation(shoot),
	}

	tracks.equip.Priority = Enum.AnimationPriority.Action
	tracks.posture.Priority = Enum.AnimationPriority.Action
	tracks.aimUp.Priority = Enum.AnimationPriority.Action
	tracks.aim.Priority = Enum.AnimationPriority.Action
	tracks.shoot.Priority = Enum.AnimationPriority.Action

	tracks.posture.Looped = true
	tracks.aim.Looped = true
	tracks.aimUp.Looped = true

	for _, track in pairs(tracks) do
		warmupTrack(track)
	end

	LoadedGunTracks[gun] = tracks

	return tracks
end

local function GenerateBulletPart(origin, direction, distance)
    local bullet = Instance.new("Part")
    bullet.Anchored = true
    bullet.CanCollide = false
    bullet.Material = Enum.Material.Neon
    bullet.Color = Color3.fromRGB(255, 255, 0)
    bullet.Transparency = 0.5
    bullet.CastShadow = false

    bullet.Size = Vector3.new(0.1, 0.1, distance)

    local center = origin + direction * (distance / 2)

    bullet.CFrame = CFrame.lookAt(center, center + direction)

    bullet.Parent = workspace

    task.delay(0.05, function()
        bullet:Destroy()
    end)
end
player.CharacterAdded:Connect(function(char)
    local animator = char:WaitForChild("Humanoid"):WaitForChild("Animator")
    local function initialize (gun: Tool)
        if gun:GetAttribute("initialized") then return end
        local initialized = gun:SetAttribute("initialized", true)
         if gun:IsA("Tool") and gun:GetAttribute("gunType") ~= nil then
            sounds = gun:WaitForChild("Handle"):WaitForChild("gunsSounds")

            gun:WaitForChild("Events"):WaitForChild("GetPosition").OnClientInvoke = function()
                local origin = gun.shoot.WorldPosition
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
                return (mouse.Hit.Position - gun:FindFirstChild("shoot").WorldPosition).Unit
            end

            local currentEquipToken = 0
            gun.Equipped:Connect(function()
                if gun:FindFirstChild("Muzzle") then
                    if gun:FindFirstChild("Muzzle"):FindFirstChild("PointLight") then
                        shotLight = gun.Muzzle.PointLight
                    end
                end
                currentEquipToken += 1
                local myToken = currentEquipToken

                local tracks = loadGunAnimations(animator, gun)
                sounds = gun:WaitForChild("Handle"):WaitForChild("gunsSounds")

                mode = gunStats["Guns"][gun:GetAttribute("gunType")][gun.Name].mode
                cooldown = gunStats["Guns"][gun:GetAttribute("gunType")][gun.Name].rate


                currentGunEquiped = gun

                local equipSound = sounds:FindFirstChild("GunEquip")
                if equipSound then
                    equipSound:Play()
                end

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
                task.delay(math.max(tracks.equip.Length, 0.4), function()
                   startPosture()
                end)
                task.wait(.9)
                canAim.Value = true
                if aimConnection then
                    aimConnection:Disconnect()
                    aimConnection = nil
                end
                aimConnection = mouse.Button2Down:Connect(function()
                   
                    if currentGunEquiped ~= gun then return end
                    if not canAim.Value then return end
                    tracks.posture:Stop(0.1)
                    tracks.aim:Play(0.1, 1, 1)
                    sounds:WaitForChild("AimUp"):Play()
                end)
                if releaseConnection then
                    releaseConnection:Disconnect()
                    releaseConnection = nil
                end
                releaseConnection = mouse.Button2Up:Connect(function()
                    if currentGunEquiped ~= gun then return end
                    
                    tracks.aim:Stop(0.1)
                    tracks.posture:Play(0.1, 1, 1)
                    if canAim.Value then
                        sounds:WaitForChild("AimDown"):Play()
                    end
                end)

                local shotEvent = gun:FindFirstChild("Events"):FindFirstChild("Shoot")
                 if mouseConnection then
                    mouseConnection:Disconnect()
                    mouseConnection = nil
                end
                mouseConnection = mouse.Button1Down:Connect(function()
                    canFire = true
                    if aiming.Value then
                        if mode == "semi" and currentGunEquiped:FindFirstChild("ammo") and currentGunEquiped:FindFirstChild("ammo").Value > 0 then
                        sounds = currentGunEquiped:WaitForChild("Handle"):WaitForChild("gunsSounds")
                           
                            tracks.shoot.Looped = false
                            LoadedGunTracks[currentGunEquiped].shoot:Play(0.1, 1, 1)
                            task.spawn(TickLight)
                        end
                        shotEvent:FireServer(mode)
                        if mode == "auto" and currentGunEquiped:FindFirstChild("ammo") and currentGunEquiped:FindFirstChild("ammo").Value > 0 then
                            tracks.shoot.Looped = true
                            LoadedGunTracks[currentGunEquiped].shoot:Play()
                        end
                        if currentGunEquiped:FindFirstChild("ammo") and currentGunEquiped:FindFirstChild("ammo").Value <= 0 then
                            sounds:WaitForChild("Tick"):Play()
                        end
                    end
                end)
                if mouseUpConnection then
                    mouseUpConnection:Disconnect()
                    mouseUpConnection = nil
                end
                mouseUpConnection = mouse.Button1Up:Connect(function()
                    canFire = false
                    if mode == "auto" then
                        tracks.shoot.Looped = false
                        LoadedGunTracks[currentGunEquiped].shoot:Stop()
                    end
                end)
            end)
           gun.Unequipped:Connect(function()
                currentEquipToken += 1

                canAim.Value = false
                aiming.Value = false
                canFire = false

                if currentGunEquiped == gun then
                    currentGunEquiped = nil
                end

                local tracks = LoadedGunTracks[gun]
                if tracks then
                    tracks.equip:Stop(0.05)
                    tracks.posture:Stop(0.1)
                    tracks.aim:Stop(0.1)
                    tracks.aimUp:Stop(0.1)
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
            end)
        end
        gun:FindFirstChild("ammo").Changed:Connect(function()
            if gun:FindFirstChild("ammo").Value <= 0 then
                sounds:WaitForChild("Tick"):Play()
                LoadedGunTracks[gun].shoot:Stop()
            else
                task.spawn(TickLight)
            end
        end)
    end
    player.Backpack.ChildAdded:Connect(function(gun: Tool)
        initialize(gun)
    end)
   
end)


