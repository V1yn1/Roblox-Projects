local module = {}
    local player = game.Players.LocalPlayer
    module.hud = player.PlayerGui:WaitForChild("hud")
    module.minimap = module.hud:WaitForChild("minimap")
    module.lifeBar = module.hud:WaitForChild("lifeBar")
    module.staminaBar = module.hud:WaitForChild("staminaBar")
    module.essentialButtons = module.hud:WaitForChild("essentialButtons")
    module.configButton = module.essentialButtons:WaitForChild("config")
    module.backpackButton = module.essentialButtons:WaitForChild("phone")
return module