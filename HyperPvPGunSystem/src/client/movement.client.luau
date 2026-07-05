local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local aiming = player:WaitForChild("aiming")
player.CharacterAdded:Wait()

aiming.Changed:Connect(function()
    if aiming.Value then
        player.Character.Humanoid.WalkSpeed = 7
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift and not aiming.Value then
        player.Character.Humanoid.WalkSpeed = 16
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        player.Character.Humanoid.WalkSpeed = 7
    end
end)