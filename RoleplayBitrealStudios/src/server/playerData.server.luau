local DataStoreService = game:GetService("DataStoreService")
local DataStore = DataStoreService:GetDataStore("playerData")
local cpfStore = DataStoreService:GetDataStore("CPF_COUNTER_V1")

local function calcularDigitos(base: string): string
	local digitos = {}

	for i = 1, #base do
		digitos[i] = tonumber(base:sub(i, i))
	end

	local soma1 = 0
	for i = 1, 9 do
		soma1 += digitos[i] * (11 - i)
	end

	local resto1 = (soma1 * 10) % 11
	local d1 = (resto1 == 10) and 0 or resto1
	table.insert(digitos, d1)

	local soma2 = 0
	for i = 1, 10 do
		soma2 += digitos[i] * (12 - i)
	end

	local resto2 = (soma2 * 10) % 11
	local d2 = (resto2 == 10) and 0 or resto2

	return tostring(d1) .. tostring(d2)
end

local function formatarCPF(base: string, verificadores: string): string
	return string.format(
		"%s%s%s.%s%s%s.%s%s%s-%s%s",
		base:sub(1,1), base:sub(2,2), base:sub(3,3),
		base:sub(4,4), base:sub(5,5), base:sub(6,6),
		base:sub(7,7), base:sub(8,8), base:sub(9,9),
		verificadores:sub(1,1), verificadores:sub(2,2)
	)
end

local function gerarCPFUnico(): string?
	local sucesso, numero = pcall(function()
		return cpfStore:IncrementAsync("ultimoCPF", 1)
	end)

	if not sucesso then
		warn("Erro ao gerar CPF:", numero)
		return nil
	end

	if numero > 999999999 then
		warn("Limite de CPFs esgotado")
		return nil
	end

	local base = string.format("%09d", numero)
	local verificadores = calcularDigitos(base)

	return formatarCPF(base, verificadores)
end

game.Players.PlayerAdded:Connect(function(player)

    local leaderStats = Instance.new("Folder",player)
    leaderStats.Name  = "leaderstats"
    local playerData = Instance.new("Folder",player)
    playerData.Name = "playerdata"

    local cpf = Instance.new("StringValue",playerData)
    cpf.Name = "cpf"
    local occupation = Instance.new("StringValue",playerData)
    occupation.Name = "ocupação"
    local team = Instance.new("StringValue",playerData)
    team.Name = "time"

    local wallet = Instance.new("NumberValue",leaderStats)
    wallet.Name = "carteira"
    local bank = Instance.new("NumberValue",leaderStats)
    bank.Name = "banco"

    local succes,result =  pcall(function()
       return DataStore:GetAsync(player.UserId)
    end)

    if succes and result then
        cpf.Value = result["cpf"]
        team.Value = result["team"]
        wallet.Value = result["wallet"]
        bank.Value = result["bank"]
    elseif succes and  result == nil then
        task.spawn(function()
            cpf.Value = gerarCPFUnico()
        end)
        team.Value = "Civil"
        wallet.Value = 1000
        bank.Value = 10000
    else
        player:Kick("error while loading data, please rejoin")
        return
    end

end)

local function SaveData (player:Player)
    local leaderStats = player:FindFirstChild("leaderstats")
    local playerData = player:FindFirstChild("playerdata")
    local data = {
        ["cpf"] = playerData.cpf.Value,
        ["team"] = playerData.time.Value,
        ["wallet"] = leaderStats.carteira.Value,
        ["bank"] = leaderStats.banco.Value
    }
    DataStore:SetAsync(player.UserId,data)
end

game.Players.PlayerRemoving:Connect(function(player)
    SaveData(player)
end)

game:BindToClose(function()
    for i,v in pairs(game.Players:GetChildren()) do
        SaveData(v)
        task.wait(.1)
    end
    task.wait(3)
end)
