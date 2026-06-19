local module = {}
    local player = game.Players.LocalPlayer


    --keybinds
    module.keyBind_backpack = Enum.KeyCode.Tab
    module.keyBind_phone = Enum.KeyCode.B
    module.keyBind_config = Enum.KeyCode.P


    --hud
    module.hud = player.PlayerGui:WaitForChild("hud")
    module.handler_hud = module.hud:WaitForChild("handler")
    module.minimap = module.handler_hud:WaitForChild("minimap")
    module.lifeBar = module.handler_hud:WaitForChild("lifeBar")
    module.staminaBar = module.handler_hud:WaitForChild("staminaBar")
    module.essentialButtons = module.handler_hud:WaitForChild("essentialButtons")
    module.configButton = module.essentialButtons:WaitForChild("config")
    module.backpackButton = module.essentialButtons:WaitForChild("backpack")
    module.phoneButton = module.essentialButtons:WaitForChild("phone")

    --backpack
    module.backpack = player.PlayerGui:WaitForChild("backpack")
    module.backpackHandler = module.backpack:WaitForChild("handler")
    module.backpackFrame = module.backpackHandler:WaitForChild("backpack")
    module.playerInfo = module.backpackHandler:WaitForChild("playerInfo")
    module.playerPhoto = module.playerInfo:WaitForChild("playerPhoto")
    module.playerName = module.playerInfo:WaitForChild("playerName")
    module.playerCpf = module.playerInfo:WaitForChild("playerCpf")
    module.walletText = module.playerInfo:WaitForChild("walletText")
     module.bankText = module.playerInfo:WaitForChild("bankText")

    --telefone
    module.phone = player.PlayerGui:WaitForChild("phone")
    module.handler_phone = module.phone:WaitForChild("handler")
    module.home_phone = module.handler_phone:WaitForChild("home")
    module.homeButton_phone = module.handler_phone:WaitForChild("bezels"):WaitForChild("home")
    module.apps_phone = module.home_phone:WaitForChild("apps")
    module.configApp_phone = module.handler_phone:WaitForChild("config")
    module.telefoneApp_phone = module.handler_phone:WaitForChild("telefone")
    module.phoneSounds = game.SoundService:WaitForChild("phoneSounds")
    module.touchBeep = module.phoneSounds:WaitForChild("TouchBeep")
return module