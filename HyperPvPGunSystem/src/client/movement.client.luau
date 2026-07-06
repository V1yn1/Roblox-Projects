local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Desativa os sons padrão do Roblox
local characterSounds = player:WaitForChild("PlayerScripts"):FindFirstChild("RbxCharacterSounds")
if characterSounds then
	characterSounds.Enabled = false
end

local runAnimation = Instance.new("Animation")
runAnimation.AnimationId = "rbxassetid://101129562298989"

local humanoid
local runTrack

local sprinting = false
local NORMAL_SPEED = 7
local SPRINT_SPEED = 16

local function UpdateRunAnimation()
	if not humanoid or not runTrack then
		return
	end

	local moving = humanoid.MoveDirection.Magnitude > 0

	if sprinting and moving then
		if not runTrack.IsPlaying then
			runTrack:Play(0.15)
		end
	else
		if runTrack.IsPlaying then
			runTrack:Stop(0.15)
		end
	end
end

local function SetupCharacter(character)
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
local lastValue
player:FindFirstChild("canAim").Changed:Connect(function()
    if  player:FindFirstChild("canAim").Value  then
       lastValue = true
    end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift and not player:FindFirstChild("aiming").Value then
		sprinting = true
		humanoid.WalkSpeed = SPRINT_SPEED
		UpdateRunAnimation()
        lastValue = player:FindFirstChild("canAim").Value
        player:FindFirstChild("canAim").Value = false
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprinting = false
		humanoid.WalkSpeed = NORMAL_SPEED
		UpdateRunAnimation()
        player:FindFirstChild("canAim").Value = lastValue
	end
end)