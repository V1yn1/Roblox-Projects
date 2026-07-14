local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local runningEvent = player:WaitForChild("running")
local stamina = player:WaitForChild("stamina")

-- gun.client deriva o canAim a partir deste atributo; este script não escreve canAim
player:SetAttribute("sprinting", false)

-- Desativa os sons padrão do Roblox
local characterSounds = player:WaitForChild("PlayerScripts"):FindFirstChild("RbxCharacterSounds")
if characterSounds then
	characterSounds.Enabled = false
end

local runAnimation = Instance.new("Animation",player)
runAnimation.AnimationId = "rbxassetid://101129562298989"

local humanoid
local runTrack

local sprinting = false
local NORMAL_SPEED = 7
local SPRINT_SPEED = 26
local MIN_STAMINA_TO_SPRINT = 5

local function UpdateRunAnimation()
	if not humanoid or not runTrack then
		return
	end

	local moving = humanoid.MoveDirection.Magnitude > 0

	if sprinting and moving then
		if not runTrack.IsPlaying then
			runTrack:Play()
		end
	else
		if runTrack.IsPlaying then
			runTrack:Stop(0.15)
		end
	end
end

local function stopSprint()
	if not sprinting then return end
	sprinting = false
	if humanoid then
		humanoid.WalkSpeed = NORMAL_SPEED
	end
	UpdateRunAnimation()
	runningEvent:FireServer(Enum.UserInputState.End)
	player:SetAttribute("sprinting", false)
end

local function startSprint(state)
	if sprinting then return end
	local aiming = player:FindFirstChild("aiming")
	if aiming and aiming.Value then return end
	if stamina.Value <= MIN_STAMINA_TO_SPRINT then return end

	sprinting = true
	if humanoid then
		humanoid.WalkSpeed = SPRINT_SPEED
	end
	UpdateRunAnimation()
	runningEvent:FireServer(state)
	player:SetAttribute("sprinting", true)
end

local function SetupCharacter(character)
	if sprinting then
		stopSprint()
	end

	humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	runTrack = animator:LoadAnimation(runAnimation)
	runTrack.Priority = Enum.AnimationPriority.Action
	runTrack.Looped = true

	humanoid.WalkSpeed = NORMAL_SPEED

	-- Garante que a animação de corrida só toque quando estiver andando
	humanoid.Running:Connect(UpdateRunAnimation)

	humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(UpdateRunAnimation)
end

local character = player.Character or player.CharacterAdded:Wait()
SetupCharacter(character)

player.CharacterAdded:Connect(function(character)
	SetupCharacter(character)
end)

-- Sem stamina, o sprint acaba sozinho
stamina.Changed:Connect(function()
	if sprinting and stamina.Value <= 0 then
		stopSprint()
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		startSprint(input.UserInputState)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		stopSprint()
	end
end)
