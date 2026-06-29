local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local inputConnection,aimConnection,releaseConnection
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local canAim = Instance.new("BoolValue",player); canAim.Name = "canAim"
local aiming = Instance.new("BoolValue",player); aiming.Name = "aiming";
local function playerCamera(character)
	local camera = workspace.CurrentCamera
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	local sensitivity = 0.25
	local distance = 8
	local shoulderOffset = 0
	local heightOffset = 2
	local minPitch = -60
	local maxPitch = 70
	local smoothness = 0.15

	local yaw = 0
	local pitch = -10
	local cameraEnabled = true
    
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false
	camera.CameraType = Enum.CameraType.Scriptable

	if inputConnection then
		inputConnection:Disconnect()
	end

	inputConnection = UserInputService.InputChanged:Connect(function(input)
		if cameraEnabled and input.UserInputType == Enum.UserInputType.MouseMovement then
			yaw -= input.Delta.X * sensitivity
			pitch = math.clamp(pitch - input.Delta.Y * sensitivity, minPitch, maxPitch)
            elseif cameraEnabled and input.UserInputType == Enum.UserInputType.Touch then
                yaw -= input.Delta.X * sensitivity
                pitch = math.clamp(pitch - input.Delta.Y * sensitivity, minPitch, maxPitch)
            end
    end)

    if cameraConnection then
        cameraConnection:Disconnect()
    end

    cameraConnection = RunService.RenderStepped:Connect(function()
        if not cameraEnabled then return end
        if not character.Parent then return end

        local targetPos = rootPart.Position + Vector3.new(0, heightOffset, 0)

        local rotation =
		    CFrame.Angles(0, math.rad(yaw), 0)
			* CFrame.Angles(math.rad(pitch), 0, 0)

        local offset = rotation:VectorToWorldSpace(Vector3.new(shoulderOffset, 0, distance))
        local desiredCameraPos = targetPos + offset

        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {character}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude

        local direction = desiredCameraPos - targetPos
        local result = workspace:Raycast(targetPos, direction, rayParams)

        if result then
            desiredCameraPos = result.Position + (targetPos - desiredCameraPos).Unit * 0.5
        end

        local goalCFrame = CFrame.lookAt(
            desiredCameraPos,
            targetPos + rotation:VectorToWorldSpace(Vector3.new(shoulderOffset, 0, 0))
        )

        camera.CFrame = camera.CFrame:Lerp(goalCFrame, smoothness)
        if aiming.Value == true then
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseIcon = "rbxassetid://4800863937"
            distance = 3
            shoulderOffset = 3
            sensitivity = 0.15

            local lookVector = camera.CFrame.LookVector
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
        else
            UserInputService.MouseIconEnabled = false
            distance = 8
            shoulderOffset = 0
            sensitivity = 0.25
        end
    end)
    if aimConnection then
        aimConnection:Disconnect()
    end
    aimConnection = mouse.Button2Down:Connect(function()
        if canAim.Value == true then
            aiming.Value = true
        end
    end)

    if releaseConnection then
        releaseConnection:Disconnect()
    end
    releaseConnection = mouse.Button2Up:Connect(function()
        aiming.Value = false
    end)

    humanoid.Died:Connect(function()
        if cameraConnection then
            cameraConnection:Disconnect()
            cameraConnection = nil
        end

        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end)
end

canAim.Value = false; aiming.Value = false
player.CharacterAdded:Connect(function(Character)
    playerCamera(Character)
end)