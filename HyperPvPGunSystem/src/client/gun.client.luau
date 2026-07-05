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

	local animList = {
		equip,
		posture,
		aimUp,
		aim,
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
	}

	tracks.equip.Priority = Enum.AnimationPriority.Action
	tracks.posture.Priority = Enum.AnimationPriority.Action
	tracks.aimUp.Priority = Enum.AnimationPriority.Action
	tracks.aim.Priority = Enum.AnimationPriority.Action

	tracks.posture.Looped = true
	tracks.aim.Looped = true
	tracks.aimUp.Looped = true

	for _, track in pairs(tracks) do
		warmupTrack(track)
	end

	LoadedGunTracks[gun] = tracks

	return tracks
end

player.CharacterAdded:Connect(function(char)
    local animator = char:WaitForChild("Humanoid"):WaitForChild("Animator")
    for i,gun:Tool in pairs(player.Backpack:GetChildren()) do
        if gun:IsA("Tool") and gun:GetAttribute("gunType") ~= nil then
            sounds = gun:WaitForChild("Handle"):WaitForChild("gunsSounds")

            gun:WaitForChild("Events"):WaitForChild("GetPosition").OnClientInvoke = function()
                return (mouse.Hit.Position - gun:FindFirstChild("Muzzle").Position).Unit
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
                aimConnection = mouse.Button2Down:Connect(function()
                    if currentGunEquiped ~= gun then return end

                    tracks.posture:Stop(0.1)
                    tracks.aim:Play(0.1, 1, 1)
                end)

                releaseConnection = mouse.Button2Up:Connect(function()
                    if currentGunEquiped ~= gun then return end

                    tracks.aim:Stop(0.1)
                    tracks.posture:Play(0.1, 1, 1)
                end)

                local shotEvent = gun:FindFirstChild("Events"):FindFirstChild("Shoot")

                mouseConnection = mouse.Button1Down:Connect(function()
                    canFire = true
                    if aiming.Value then
                        if mode == "semi"  then
                        sounds = currentGunEquiped:WaitForChild("Handle"):WaitForChild("gunsSounds")
                            local shootSound = sounds:FindFirstChild("GunShot")

                            if shootSound then
                                shootSound:Play()
                            end
                            task.spawn(TickLight)
                        end
                        shotEvent:FireServer(mode)
                    end
                end)

                mouseUpConnection = mouse.Button1Up:Connect(function()
                    canFire = false
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
    end
    local lastFireTime = 0

    RunService.Heartbeat:Connect(function()
        if not canFire then return end
        if not aiming.Value then return end
        if mode ~= "auto" then return end
        if not currentGunEquiped then return end

        local now = os.clock()
        if now - lastFireTime < cooldown then
            return
        end

        lastFireTime = now

        -- Aqui você executa sua ação de disparo/efeito visual
        sounds = currentGunEquiped:WaitForChild("Handle"):WaitForChild("gunsSounds")
        local shootSound = sounds:FindFirstChild("GunShot")

        if shootSound then
            shootSound:Play()
        end
        task.spawn(TickLight)

    end)
end)


