local player = game.Players.LocalPlayer
local sounds = game:GetService("SoundService"):WaitForChild("GUISounds")

local function playSound(sound)
	sounds:FindFirstChild(sound):Play()
end

local function implantStyle()
	for i,v in pairs(player.PlayerGui:GetDescendants()) do
		if v:IsA("TextButton") or v:IsA("ImageButton") then
			v.MouseEnter:Connect(function()
				playSound("Hover")
			end)
			v.MouseButton1Click:Connect(function()
				playSound("Click")
			end)
		end
	end
end

implantStyle()	
player.PlayerGui.DescendantAdded:Connect(implantStyle)