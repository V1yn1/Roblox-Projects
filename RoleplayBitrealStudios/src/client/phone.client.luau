local controller = require(game.ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("hudController"))
local player = game.Players.LocalPlayer
local playerImages =  require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("playerImages"))
local criarNumero = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("CriarNumero")
local salvarConfigPhone = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("SalvarConfigPhone")
local carregarConfigPhone = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("CarregarConfigPhone")
local phoneConfig


local function GoHome() -- retorna para a tela home
    for i,v in pairs(controller.handler_phone:GetChildren()) do
        if v.Name ~= "bezels" and v.Name ~= "home" and v:IsA("Frame") then
            v.Visible = false
        end
    end
    controller.home_phone.Visible = true
    controller.homeButton_phone.Visible = false
end

local function AbrirApp(nome) -- abre um app pelo nome
    GoHome()
    if controller.handler_phone:FindFirstChild(nome) and controller.handler_phone:FindFirstChild(nome):IsA("Frame") then
        controller.handler_phone:FindFirstChild(nome).Visible = true
        controller.homeButton_phone.Visible = true
        controller.home_phone.Visible = false
    else
        warn("no app screen found")
    end
end

-- configApp

local function MudarWallpaper() -- muda o wallpaper da tela home
    if controller.configApp_phone.wallpaperId.Text == "" then
        controller.home_phone.background.Image = "rbxassetid://105963729199069"
        return
    end

    controller.home_phone.background.Image = "rbxassetid://"..controller.configApp_phone.wallpaperId.Text
end

local function MudarKeybind()-- muda a keybind para abrir o telefone
    if controller.configApp_phone.keybind.Text == "" then
        return
    end
    local sucess,keyCode = pcall(function()
        return Enum.KeyCode[string.upper(string.sub(controller.configApp_phone.keybind.Text,1,1))..string.sub(controller.configApp_phone.keybind.Text,2)]
    end)
    if sucess and keyCode then
        controller.keyBind_phone = keyCode
    end
end

local function CarregarInformacoes()
   controller.configApp_phone:FindFirstChild("playerName").Text = player.DisplayName
   controller.configApp_phone:FindFirstChild("playerPhoto").Image = playerImages.Imagem(player)
   if player.playerdata.pNumber.Value ~= 0 and player.playerdata.pNumber.Value ~= nil then
        controller.configApp_phone:FindFirstChild("playerMail").Text = "("..string.sub(tostring(player.playerdata.pNumber.Value),1,2)..")"
            ..string.sub(tostring(player.playerdata.pNumber.Value),3,7).."-"..string.sub(tostring(player.playerdata.pNumber.Value),8)
   end
end

local function EditarNumero ()
     local editFrame = controller.configApp_phone.editEmail
     local textField = editFrame.keybind
     if tonumber(textField.Text) and textField.Text ~= "" then
        local text = textField.Text
        criarNumero:FireServer(text)
     end
    editFrame.Visible = false
    textField.Text = ""
    CarregarInformacoes()
end

local function NotificacoesSwitch()
    
end
task.wait(10)

for i,v in pairs(controller.apps_phone:GetChildren()) do
    if v:IsA("ImageButton") then
        v.MouseButton1Down:Connect(function()
            AbrirApp(v.Name)
        end)
    end
end

controller.configApp_phone:GetPropertyChangedSignal("Visible"):Connect(function()
    if controller.configApp_phone.Visible then
        CarregarInformacoes()
    end
end)

controller.configApp_phone.edit.MouseButton1Down:Connect(function()
    local editFrame = controller.configApp_phone.editEmail
    editFrame.Visible = true
end)

controller.configApp_phone.editEmail.exit.MouseButton1Down:Connect(function()
    local editFrame = controller.configApp_phone.editEmail
    local textField = editFrame.keybind
    editFrame.Visible = false
    textField.Text = ""
end)

controller.homeButton_phone.MouseButton1Down:Connect(GoHome)
controller.configApp_phone.wallpaperId:GetPropertyChangedSignal("Text"):Connect(MudarWallpaper)
controller.configApp_phone.keybind:GetPropertyChangedSignal("Text"):Connect(MudarKeybind)
controller.configApp_phone.editEmail.back.MouseButton1Down:Connect(EditarNumero)