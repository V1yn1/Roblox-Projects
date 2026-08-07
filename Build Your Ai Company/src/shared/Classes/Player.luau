local player = {}

function player.New()
    local self = {}
    self.Name = ""
    self.Values = {}
    self.Values.Money = 0
    self.Values.Compute = 0
    self.Values.Energy = 0
    self.Values.Data = 0
    self.Progress = {}
    self.Progress.CurrentBase = 1
    self.Furniture = {}
    self.Workers = {}
    return self
end

return player