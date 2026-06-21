local DataStoreService = game:GetService("DataStoreService")
local playerDataStore = DataStoreService:GetDataStore("playerData")
local numbers = DataStoreService:GetDataStore("numbers")
local criarNumero = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("CriarNumero")

local function VerificarNumero(numero)
    local success,number = pcall(function()
        return numbers:GetAsync(numero)
    end)
    if number then
        return false
    end

    return true
end

local function RegistrarNumero(player,numero)
    pcall(function()
        numbers:UpdateAsync(numero, function()
            return {
                UserId = player.UserId,
                PlayerName = player.Name,
                CreatedAt = os.time()
            }
        end)
    end)
end

criarNumero.OnServerEvent:Connect(function(player,numero)
    if not tonumber(numero) then return end

    if not VerificarNumero(numero) then return end

    local pNumber = player.playerdata.pNumber
    RegistrarNumero(player,numero)
    pNumber.Value = numero
end)