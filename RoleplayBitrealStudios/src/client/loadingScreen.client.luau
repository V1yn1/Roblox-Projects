local loadingScreen = game:GetService("ReplicatedFirst"):WaitForChild("loadingScreen")
local progressBar = loadingScreen:WaitForChild("Frame"):WaitForChild("progressBar")
local progress = progressBar:WaitForChild("life")
local skipButton = loadingScreen:WaitForChild("Frame"):WaitForChild("skip")
local player = game.Players.LocalPlayer
local menuMusic = game.SoundService:WaitForChild("menuMusic")
loadingScreen.Parent = player.PlayerGui


loadingScreen.Enabled = true
progress.Visible = true
local loading = 500
local jump = false
menuMusic:Play()
player.CharacterAdded:Wait()
player.Character:WaitForChild("HumanoidRootPart").Anchored = true
skipButton.MouseButton1Down:Connect(function()
    jump = true
    loadingScreen:Destroy()
    player.Character.HumanoidRootPart.Anchored = false
    menuMusic:Stop()
end)

repeat task.wait(1)
    if jump then
        break
    end
    progress:TweenSize(UDim2.new(loading/500,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint)
    loading -= 10
until loading <= 0

player.Character.HumanoidRootPart.Anchored = false
menuMusic:Stop()
loadingScreen:Destroy()