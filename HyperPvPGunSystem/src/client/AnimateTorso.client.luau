local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_UP = math.rad(45)
local MAX_DOWN = math.rad(-35)

local WAIST_POWER = 0.75
local NECK_POWER = 0.25

local currentConnection

local function findMotorBetween(character, partA, partB)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("Motor6D") and obj.Part0 and obj.Part1 then
			if (obj.Part0 == partA and obj.Part1 == partB) or (obj.Part0 == partB and obj.Part1 == partA) then
				return obj
			end
		end
	end

	return nil
end

local function setupCharacter(character)
	if currentConnection then
		currentConnection:Disconnect()
		currentConnection = nil
	end

	local lowerTorso = character:WaitForChild("LowerTorso")
	local upperTorso = character:WaitForChild("UpperTorso")
	local head = character:WaitForChild("Head")

	local waist
	local neck

	for i = 1, 50 do
		waist = findMotorBetween(character, lowerTorso, upperTorso)
		neck = findMotorBetween(character, upperTorso, head)

		if waist and neck then
			break
		end

		task.wait(0.1)
	end

	if not waist then
		warn("Waist ainda não foi encontrado no client")
		return
	end

	if not neck then
		warn("Neck ainda não foi encontrado no client")
		return
	end

	local originalWaistC0 = waist.C0
	local originalNeckC0 = neck.C0

	currentConnection = RunService.RenderStepped:Connect(function()
		if not character.Parent then
			currentConnection:Disconnect()
			currentConnection = nil
			return
		end

		local lookVector = camera.CFrame.LookVector

		local pitch = math.asin(math.clamp(lookVector.Y, -1, 1))
		pitch = math.clamp(pitch, MAX_DOWN, MAX_UP)

		waist.C0 = originalWaistC0 * CFrame.Angles(pitch * WAIST_POWER, 0, 0)
		neck.C0 = originalNeckC0 * CFrame.Angles(pitch * NECK_POWER, 0, 0)
	end)
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)