local Players = game:GetService("Players")

local function findMotorBetween(character, partA, partB)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("Motor6D") then
			if (obj.Part0 == partA and obj.Part1 == partB) or (obj.Part0 == partB and obj.Part1 == partA) then
				return obj
			end
		end
	end

	return nil
end

local function removeWeldsBetween(character, partA, partB)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("WeldConstraint") then
			if (obj.Part0 == partA and obj.Part1 == partB) or (obj.Part0 == partB and obj.Part1 == partA) then
				obj:Destroy()
			end
		end

		if obj:IsA("Weld") then
			if (obj.Part0 == partA and obj.Part1 == partB) or (obj.Part0 == partB and obj.Part1 == partA) then
				obj:Destroy()
			end
		end
	end
end

local function createMotor(name, part0, part1)
	local motor = Instance.new("Motor6D")
	motor.Name = name
	motor.Part0 = part0
	motor.Part1 = part1

	-- Mantém as partes na posição atual
	motor.C0 = part0.CFrame:ToObjectSpace(part1.CFrame)
	motor.C1 = CFrame.new()

	motor.Parent = part0

	return motor
end

local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then return end

	local lowerTorso = character:WaitForChild("LowerTorso", 10)
	local upperTorso = character:WaitForChild("UpperTorso", 10)
	local head = character:WaitForChild("Head", 10)

	if not lowerTorso or not upperTorso or not head then
		warn("LowerTorso, UpperTorso ou Head não encontrados")
		return
	end

	lowerTorso.Anchored = false
	upperTorso.Anchored = false
	head.Anchored = false

	local waist = findMotorBetween(character, lowerTorso, upperTorso)
	if not waist then
		removeWeldsBetween(character, lowerTorso, upperTorso)
		waist = createMotor("Waist", lowerTorso, upperTorso)
		print("Motor6D Waist criado manualmente")
	end

	local neck = findMotorBetween(character, upperTorso, head)
	if not neck then
		removeWeldsBetween(character, upperTorso, head)
		neck = createMotor("Neck", upperTorso, head)
		print("Motor6D Neck criado manualmente")
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupCharacter)
end)