local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local controller = require(game.ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("hudController"))

local function LoadMinimap()
    local minimap = controller.minimap
    local camera = game.Workspace.CurrentCamera
    for i,v in pairs(game.Workspace:FindFirstChild("Map"):GetDescendants()) do
        if v:IsA("BasePart") then
            v:Clone().Parent = minimap
        end
    end
    for i,v in pairs(game.Workspace:GetChildren()) do
        if v:FindFirstChild("Humanoid") and game.Players:FindFirstChild(v.Name) then
            
        end
    end
    task.spawn(function()
        local newCamera = Instance.new("Camera",workspace)
        newCamera.Name = "minimapCamera"
        newCamera.CameraType = Enum.CameraType.Attach
        newCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
        newCamera.CFrame = CFrame.new(newCamera.CFrame.Position + Vector3.new(0,100,0),player.Character.HumanoidRootPart.Position)
        minimap.CurrentCamera = newCamera
       RunService.Heartbeat:Connect(function()
            local rootPart = player.Character.HumanoidRootPart
            local height = 100
            local cameraPos = rootPart.Position + Vector3.new(0, height, 0)
            local lookVector = rootPart.CFrame.LookVector
            local upDirection = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            newCamera.CFrame = CFrame.lookAt(cameraPos, rootPart.Position, upDirection)
        end)
    end)
end

local function playerCamera()
    local camera = game.Workspace.CurrentCamera
    local mouse = player:GetMouse()
    -- ===== CONFIGURAÇÕES =====
    local sensitivity = 0.25
    local distance = 8          -- distância da câmera ao player
    local shoulderOffset = 2    -- deslocamento lateral (estilo GTA)
    local heightOffset = 2      -- altura do alvo (mira na altura do peito/cabeça)
    local minPitch = -60        -- limite de olhar pra baixo
    local maxPitch = 70         -- limite de olhar pra cima
    local smoothness = 0.15     -- suavização (0 = travado, 1 = instantâneo)

    -- Ângulos
    local yaw = 0    -- horizontal
    local pitch = -10  -- vertical (começa levemente pra baixo)

    -- Trava o mouse
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false

    camera.CameraType = Enum.CameraType.Scriptable
    -- Captura movimento do mouse
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            yaw = yaw - input.Delta.X * sensitivity
            pitch = math.clamp(pitch - input.Delta.Y * sensitivity, minPitch, maxPitch)
        end
    end)

    -- Atualiza câmera
    local spawncamera = task.spawn(function()
        RunService.RenderStepped:Connect(function()
            local character = player.Character
            if not character then return end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end

            -- Ponto de mira (centro da órbita)
            local targetPos = rootPart.Position + Vector3.new(0, heightOffset, 0)

            -- Rotação da câmera baseada no mouse
            local rotation = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)

            -- Offset do ombro + distância
            local offset = rotation:VectorToWorldSpace(Vector3.new(shoulderOffset, 0, distance))
            local desiredCameraPos = targetPos + offset

            -- ===== COLISÃO DA CÂMERA (evita atravessar paredes) =====
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude

            local direction = desiredCameraPos - targetPos
            local result = workspace:Raycast(targetPos, direction, rayParams)
            if result then
                desiredCameraPos = result.Position + (targetPos - desiredCameraPos).Unit * 0.5
            end

            -- Suavização (lerp pra movimento fluido)
            local goalCFrame = CFrame.lookAt(desiredCameraPos, targetPos + rotation:VectorToWorldSpace(Vector3.new(shoulderOffset, 0, 0)))
            camera.CFrame = camera.CFrame:Lerp(goalCFrame, smoothness)
        end)

    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftAlt then
            if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
                task.cancel(spawncamera)
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                UserInputService.MouseIconEnabled = true
            else
                task.spawn(spawncamera)
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                UserInputService.MouseIconEnabled = false
            end
        end
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
    print("open phone")
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Tab then
        controller.backpack.Enabled = not controller.backpack.Enabled
    elseif input.KeyCode == Enum.KeyCode.B then
        print("open phone")
    elseif input.KeyCode == Enum.KeyCode.P then
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

    end
end)

player.Character:WaitForChild("HumanoidRootPart")

LoadMinimap()
playerCamera()

LifeBar()
player.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(LifeBar)