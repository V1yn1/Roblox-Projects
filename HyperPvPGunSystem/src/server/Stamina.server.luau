local Players = game:GetService("Players")

local STAMINA_MAXVALUE = 100
local STAMINA_MINVALUE = 0
local DRAIN_TICK = .2   -- segundos entre cada ponto drenado no sprint
local REGEN_TICK = .2   -- segundos entre cada ponto regenerado
local REGEN_DELAY = 1   -- espera após parar de correr antes de regenerar

local function onPlayerAdded(player)
    if player:FindFirstChild("running") then return end

    local running = Instance.new("RemoteEvent")
    running.Name = "running"
    running.Parent = player

    local stamina = Instance.new("NumberValue")
    stamina.Name = "stamina"
    stamina.Value = STAMINA_MAXVALUE
    stamina.Parent = player

    local sprinting = false
    local lastSprintStop = 0

    running.OnServerEvent:Connect(function(_, inputState)
        if inputState == Enum.UserInputState.Begin then
            sprinting = true
        elseif inputState == Enum.UserInputState.End then
            sprinting = false
            lastSprintStop = os.clock()
        end
    end)

    player.CharacterAdded:Connect(function()
        sprinting = false
        stamina.Value = STAMINA_MAXVALUE
    end)

    -- Um único loop por jogador: drena no sprint, regenera fora dele
    task.spawn(function()
        while player.Parent do
            if sprinting and stamina.Value > STAMINA_MINVALUE then
                stamina.Value = math.max(STAMINA_MINVALUE, stamina.Value - 1)
                task.wait(DRAIN_TICK)
            elseif not sprinting and stamina.Value < STAMINA_MAXVALUE and os.clock() - lastSprintStop >= REGEN_DELAY then
                stamina.Value = math.min(STAMINA_MAXVALUE, stamina.Value + 1)
                task.wait(REGEN_TICK)
            else
                task.wait(.1)
            end
        end
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
