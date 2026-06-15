local DataStoreService = game:GetService("DataStoreService")
local DataStore = DataStoreService:GetDataStore("playerData")
local DataStoreCpf = DataStoreService:GetDataStore("cpf")
local playersCpf = {nil}

--gera o cpf válido
local function gerarCPF(): string
	local digitos = {}

	-- 1. Gerar os 9 primeiros dígitos aleatórios
	for i = 1, 9 do
		table.insert(digitos, math.random(0, 9))
	end

	-- 2. Calcular o primeiro dígito verificador
	local soma1 = 0
	for i = 1, 9 do
		soma1 = soma1 + (digitos[i] * (11 - i))
	end
	local resto1 = (soma1 * 10) % 11
	local digito1 = (resto1 == 10 or resto1 == 11) and 0 or resto1
	table.insert(digitos, digito1)

	-- 3. Calcular o segundo dígito verificador
	local soma2 = 0
	for i = 1, 10 do
		soma2 = soma2 + (digitos[i] * (12 - i))
	end
	local resto2 = (soma2 * 10) % 11
	local digito2 = (resto2 == 10 or resto2 == 11) and 0 or resto2
	table.insert(digitos, digito2)

	-- 4. Formatar o resultado final (ex: 123.456.789-10)
	return string.format(
		"%d%d%d.%d%d%d.%d%d%d-%d%d",
		digitos[1], digitos[2], digitos[3],
		digitos[4], digitos[5], digitos[6],
		digitos[7], digitos[8], digitos[9],
		digitos[10], digitos[11]
	)
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
            repeat
                cpf.Value = gerarCPF()
            until table.find(playersCpf,cpf.Value,1) == nil
        end)
        team.Value = "Civil"
        wallet.Value = 1000
        bank.Value = 10000
    else
        player:Kick("error while loading data, please rejoin")
        return
    end
    playersCpf[#playersCpf+1] = cpf.Value
end)