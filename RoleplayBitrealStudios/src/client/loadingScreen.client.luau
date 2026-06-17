local loadingScreen = game:GetService("ReplicatedFirst"):WaitForChild("loadingScreen")
local progressBar = loadingScreen:WaitForChild("Frame"):WaitForChild("progressBar")
local progress = progressBar:WaitForChild("life")
local skipButton = loadingScreen:WaitForChild("Frame"):WaitForChild("skip")
local player = game.Players.LocalPlayer
loadingScreen.Parent = player.PlayerGui


loadingScreen.Enabled = true
progress.Visible = true
local loading = 100
local jump = false

skipButton.MouseButton1Down:Connect(function()
    jump = true
end)
skipButton:Destroy()
repeat task.wait(.1)
    if jump then
        loadingScreen:Destroy()
        break
    end
    progress:TweenSize(UDim2.new(loading/100,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint)
    loading -= 1
until loading <= 0


loadingScreen:Destroy()