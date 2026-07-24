local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local playergui = player.PlayerGui
local Menu = playergui:WaitForChild("Menu")
local goToLobbyEvent:RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("goToLobby")
local VERSION_LOGS = {
    ["v1.0.0"] = 
    "=CHANGELOGS== wellcome to Brainrot Hunters, this game is inspired on vampire survivors, so you will farm killing the brainrots while upgrade your levels, feel free to give some feedback on our discord server linked on description, also join our group and recieve exclusive rewards!!"
}
local currentVersion = "v1.0.0"
local function Turn(bool:boolean) -- turn screenguis enabled propertie
    for _,v in pairs(playergui:GetChildren()) do
        if v.Name ~= "Menu" and v:IsA("ScreenGui") then
            v.Enabled = bool
        elseif v.Name == "Menu" then
            v.Enabled = not bool
        end
    end
end

local function GetStatus() -- get current player status with server credibility
    local remoteFunction:RemoteFunction = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("getStatus")
    local response = remoteFunction:InvokeServer()
    return response
end

local function ChangelogsUpdate(text)
    local changelogsText = Menu:WaitForChild("ChangeLogs"):WaitForChild("TextLabel")
    changelogsText.Text = text
end
Turn(false)
ChangelogsUpdate(VERSION_LOGS["v1.0.0"])
Menu:WaitForChild("PlayButton").MouseButton1Click:Connect(function()
    if GetStatus() == "IN_MENU" then
        Turn(true)
        goToLobbyEvent:FireServer()
    end
end)
