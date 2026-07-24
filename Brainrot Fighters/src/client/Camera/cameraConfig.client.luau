local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local player = game.Players.LocalPlayer

player.CharacterAdded:Wait()
local hrp = player.Character:WaitForChild("HumanoidRootPart")
local statusModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Status_model"):WaitForChild("statusModule"))

local droneCam = Workspace:WaitForChild("DroneCam")
local cam = droneCam:WaitForChild("Cam")

local height = 40
local distance = 15


local cameras = {
    ["IN_MENU"] = function(dt)
        camera.CameraType = Enum.CameraType.Scriptable
        droneCam.CFrame = droneCam.CFrame * CFrame.Angles(0,math.rad(1 * dt ),0)
        camera.CFrame = cam.CFrame
    end,
    ["PLAYING"] = function(dt)
        camera.CameraType = Enum.CameraType.Scriptable
        local offset = hrp.CFrame:VectorToWorldSpace(Vector3.new(0, height, distance))

        camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(
            hrp.Position + offset,
            hrp.Position
        ),.12)
    end,
    ["IN_LOBBY"] = function(dt)
        camera.CameraType = Enum.CameraType.Custom
    end
}

RunService.RenderStepped:Connect(function(dt)
  
    if statusModule[player.Name] then
        cameras[statusModule[player.Name]](dt)
    end
end)


