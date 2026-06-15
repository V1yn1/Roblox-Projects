local module = {}
    local player = game.Players.LocalPlayer
    module.hud = player.PlayerGui:WaitForChild("hud")
    module.minimap = module.hud:WaitForChild("minimap")
    module.lifeBar = module.hud:WaitForChild("lifeBar")
    module.staminaBar = module.hud:WaitForChild("staminaBar")
    module.essentialButtons = module.hud:WaitForChild("essentialButtons")
    module.configButton = module.essentialButtons:WaitForChild("config")
    module.backpackButton = module.essentialButtons:WaitForChild("backpack")
    module.phoneButton = module.essentialButtons:WaitForChild("phone")
    module.backpack = player.PlayerGui:WaitForChild("backpack")
    module.backpackHandler = module.backpack:WaitForChild("handler")
    module.backpackFrame = module.backpackHandler:WaitForChild("backpack")
    module.playerInfo = module.backpackHandler:WaitForChild("playerInfo")
    module.playerPhoto = module.playerInfo:WaitForChild("playerPhoto")
    module.playerName = module.playerInfo:WaitForChild("playerName")
    module.playerCpf = module.playerInfo:WaitForChild("playerCpf")
return module