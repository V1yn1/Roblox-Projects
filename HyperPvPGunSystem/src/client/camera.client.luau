local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local inputConnection
local aimConnection
local releaseConnection
local diedConnection

local CAMERA_BIND_NAME = "CustomShoulderCamera_" .. player.UserId

local canAim = player:FindFirstChild("canAim")
if not canAim then
	canAim = Instance.new("BoolValue")
	canAim.Name = "canAim"
	canAim.Parent = player
end

local aiming = player:FindFirstChild("aiming")
if not aiming then
	aiming = Instance.new("BoolValue")
	aiming.Name = "aiming"
	aiming.Parent = player
end

canAim.Value = false
aiming.Value = false

local shoulderSide = 1

local NORMAL_SENSITIVITY = 0.25
local AIM_SENSITIVITY = 0.15

local NORMAL_DISTANCE = 8
local AIM_DISTANCE = 2

local NORMAL_SHOULDER_OFFSET = 0
local AIM_SHOULDER_OFFSET = 2

local heightOffset = 2
local minPitch = -60
local maxPitch = 70

local smoothness = 0.15

local sensitivity = NORMAL_SENSITIVITY
local yaw = 0
local pitch = -10

local function disconnect(connection)
	if connection then
		connection:Disconnect()
	end
end

local function stopCamera()
	RunService:UnbindFromRenderStep(CAMERA_BIND_NAME)

	disconnect(inputConnection)
	disconnect(aimConnection)
	disconnect(releaseConnection)
	disconnect(diedConnection)

	inputConnection = nil
	aimConnection = nil
	releaseConnection = nil
	diedConnection = nil

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true

	local camera = workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Custom
	end
end

local function playerCamera(character)
	stopCamera()

	local camera = workspace.CurrentCamera
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	local cameraEnabled = true

	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false

	camera.CameraType = Enum.CameraType.Scriptable

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { character }
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	inputConnection = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if not cameraEnabled then return end
		if UserInputService:GetFocusedTextBox() then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement then
			yaw -= input.Delta.X * sensitivity
			pitch = math.clamp(
				pitch - input.Delta.Y * sensitivity,
				minPitch,
				maxPitch
			)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			yaw -= input.Delta.X * sensitivity
			pitch = math.clamp(
				pitch - input.Delta.Y * sensitivity,
				minPitch,
				maxPitch
			)
		end
	end)

	aimConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end

		if input.KeyCode == Enum.KeyCode.F then
			shoulderSide *= -1
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			if canAim.Value == true then
				aiming.Value = true
			end
		end
	end)

	releaseConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			aiming.Value = false
		end
	end)

	RunService:BindToRenderStep(
		CAMERA_BIND_NAME,
		Enum.RenderPriority.Camera.Value + 1,
		function(deltaTime)
			if not cameraEnabled then return end

			if not character.Parent or not rootPart.Parent then
				stopCamera()
				return
			end

			local isAiming = aiming.Value == true and canAim.Value == true

			local currentDistance
			local currentShoulderOffset

			if isAiming then
				UserInputService.MouseIconEnabled = true
				UserInputService.MouseIcon = "rbxassetid://4800863937"

				sensitivity = AIM_SENSITIVITY
				currentDistance = AIM_DISTANCE
				currentShoulderOffset = AIM_SHOULDER_OFFSET * shoulderSide

				humanoid.AutoRotate = false
			else
				UserInputService.MouseIconEnabled = false

				sensitivity = NORMAL_SENSITIVITY
				currentDistance = NORMAL_DISTANCE
				currentShoulderOffset = NORMAL_SHOULDER_OFFSET

				humanoid.AutoRotate = true
			end

			local targetPos = rootPart.Position + Vector3.new(0, heightOffset, 0)

			local rotation =
				CFrame.Angles(0, math.rad(yaw), 0)
				* CFrame.Angles(math.rad(pitch), 0, 0)

			local offset = rotation:VectorToWorldSpace(
				Vector3.new(currentShoulderOffset, 0, currentDistance)
			)

			local desiredCameraPos = targetPos + offset

			local direction = desiredCameraPos - targetPos
			local result = workspace:Raycast(targetPos, direction, rayParams)

			if result then
				desiredCameraPos = result.Position - direction.Unit * 0.5
			end

			local lookAtPos = targetPos + rotation:VectorToWorldSpace(
				Vector3.new(currentShoulderOffset, 0, 0)
			)

			local goalCFrame = CFrame.lookAt(desiredCameraPos, lookAtPos)

			if isAiming then
				camera.CFrame = goalCFrame
			else
				local alpha = 1 - ((1 - smoothness) ^ (deltaTime * 60))
				camera.CFrame = camera.CFrame:Lerp(goalCFrame, alpha)
			end

			if isAiming then
				local lookVector = goalCFrame.LookVector

				local flatDirection = Vector3.new(
					lookVector.X,
					0,
					lookVector.Z
				)

				if flatDirection.Magnitude > 0 then
					flatDirection = flatDirection.Unit

					rootPart.CFrame = CFrame.lookAt(
						rootPart.Position,
						rootPart.Position + flatDirection
					)
				end
			end
		end
	)

	diedConnection = humanoid.Died:Connect(function()
		humanoid.AutoRotate = true
		aiming.Value = false
		stopCamera()
	end)
end

player.CharacterAdded:Connect(function(character)
	playerCamera(character)
end)

if player.Character then
	task.defer(playerCamera, player.Character)
end