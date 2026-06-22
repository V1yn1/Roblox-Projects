local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local controller = require(game.ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("hudController"))
local cameraConnection
local inputConnection

local function LoadMinimap()
    local minimap = controller.minimap
    local camera = game.Workspace.CurrentCamera
    for i,v in pairs(game.Workspace:FindFirstChild("Map"):GetDescendants()) do
        if v:IsA("BasePart") then
            v:Clone().Parent = minimap
        end
    end
    --for i,v in pairs(game.Workspace:GetChildren()) do
    --  if v:FindFirstChild("Humanoid") and game.Players:FindFirstChild(v.Name) then
    --  end
    --end
    task.spawn(function()
        local newCamera = Instance.new("Camera",workspace)
        newCamera.Name = "minimapCamera"
        newCamera.CameraType = Enum.CameraType.Attach
        newCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
        newCamera.CFrame = CFrame.new(newCamera.CFrame.Position + Vector3.new(0,100,0),player.Character.HumanoidRootPart.Position)
        minimap.CurrentCamera = newCamera
       RunService.Heartbeat:Connect(function()
            local rootPart = player.Character:WaitForChild("HumanoidRootPart")
            if not rootPart then return end
            local height = 100
            local cameraPos = rootPart.Position + Vector3.new(0, height, 0)
            local lookVector = rootPart.CFrame.LookVector
            local upDirection = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            newCamera.CFrame = CFrame.lookAt(cameraPos, rootPart.Position, upDirection)
        end)
    end)
end

local function playerCamera(character)
	local camera = workspace.CurrentCamera
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	local sensitivity = 0.25
	local distance = 8
	local shoulderOffset = 2
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

local function LifeBar()
    local lifeBar = controller.lifeBar
    local life = lifeBar.life
    life.Visible =true

    life:TweenSize(UDim2.new(player.Character.Humanoid.Health/100,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint)
end

controller.backpackButton.MouseButton1Down:Connect(function()
    controller.backpack.Enabled = not controller.backpack.Enabled
end)

controller.configButton.MouseButton1Down:Connect(function()
    print("open config")
end)

controller.phoneButton.MouseButton1Down:Connect(function()
    controller.phone.Enabled = not controller.phone.Enabled
end)

UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end

    if input.KeyCode == controller.keyBind_backpack then
        controller.backpack.Enabled = not controller.backpack.Enabled
    elseif input.KeyCode == controller.keyBind_phone then
        controller.phone.Enabled = not controller.phone.Enabled
    elseif input.KeyCode == controller.keyBind_config then
        print("open config")
    end
end)

local firstTimeLoading = true
controller.backpack:GetPropertyChangedSignal("Enabled"):Connect(function()
    if controller.backpack.Enabled then
        if firstTimeLoading then
            firstTimeLoading = false
            controller.playerName.Text = player.DisplayName
            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size420x420
            local content, isReady = game.Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
            controller.playerPhoto.Image = content
            local cpf = player:FindFirstChild("playerdata"):FindFirstChild("cpf")
            controller.playerCpf.Text = cpf.Value
        end
        controller.walletText.Text = " Carteira      : "..tostring(player:FindFirstChild("leaderstats"):FindFirstChild("carteira").Value)
        controller.bankText.Text = " Banco      : "..tostring(player:FindFirstChild("leaderstats"):FindFirstChild("banco").Value)
    end
end)

player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
    task.wait(10)
	LoadMinimap()
	playerCamera(character)
	LifeBar()

	humanoid:GetPropertyChangedSignal("Health"):Connect(LifeBar)
end)

if player.Character then
	local character = player.Character
	local humanoid = character:WaitForChild("Humanoid")
    task.wait(10)
	LoadMinimap()
	playerCamera(character)
	LifeBar()

	humanoid:GetPropertyChangedSignal("Health"):Connect(LifeBar)
end