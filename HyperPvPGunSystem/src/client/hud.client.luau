local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local stamina = player:WaitForChild("stamina")

local TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

local lifeBar, staminaBar
local lifeFullSize, staminaFullSize

-- Se o Hud tiver ResetOnSpawn, as instâncias mudam a cada spawn
local function ResolveBars()
    local playerGui = player:WaitForChild("PlayerGui")
    local hud = playerGui:WaitForChild("Hud")
    local handler = hud:WaitForChild("handler")

    local newLifeBar = handler:WaitForChild("Life"):WaitForChild("CanvasGroup"):WaitForChild("Frame")
    if newLifeBar ~= lifeBar then
        lifeBar = newLifeBar
        lifeFullSize = lifeBar.Size
    end

    local newStaminaBar = handler:WaitForChild("Stamina"):WaitForChild("CanvasGroup"):WaitForChild("Frame")
    if newStaminaBar ~= staminaBar then
        staminaBar = newStaminaBar
        staminaFullSize = staminaBar.Size
    end
end

local function SetBar(bar, fullSize, fraction)
    if not bar then return end
    fraction = math.clamp(fraction, 0, 1)
    bar.Position = UDim2.new(.5,0,1,0)
    TweenService:Create(bar, TWEEN_INFO, {
        Size = UDim2.new(fullSize.X.Scale , fullSize.X.Offset * fraction, fullSize.Y.Scale* fraction, fullSize.Y.Offset),
    }):Play()
end

local function StaminaUpdate()
    SetBar(staminaBar, staminaFullSize, stamina.Value / 100)
end

stamina.Changed:Connect(StaminaUpdate)

local function HookCharacter(character)
    ResolveBars()

    local humanoid = character:WaitForChild("Humanoid")
    local function LifeUpdate()
        SetBar(lifeBar, lifeFullSize, humanoid.Health / humanoid.MaxHealth)
    end

    humanoid.HealthChanged:Connect(LifeUpdate)
    LifeUpdate()
    StaminaUpdate()
end

player.CharacterAdded:Connect(HookCharacter)
if player.Character then
    task.spawn(HookCharacter, player.Character)
end
