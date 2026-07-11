local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local hud = playerGui:WaitForChild("Hud")
local lifeCanvas = hud:WaitForChild("handler"):WaitForChild("Life")
local staminaCanvas = hud:WaitForChild("handler"):WaitForChild("Stamina")
local lifeContainer = lifeCanvas:WaitForChild("CanvasGroup")
local staminaContainer = staminaCanvas:WaitForChild("CanvasGroup")
local lifeBar = lifeContainer:WaitForChild("Frame")
local staminaBar = staminaContainer:WaitForChild("Frame")

