local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vanguard = require(ReplicatedStorage.Packages.Vanguard)

Vanguard.Bootstrap({
    Controllers = script.Parent.Controllers,
    Options = {
        LogLevel = "info",
    },
}):catch(function(err)
    warn(`Vanguard client failed: {err}`)
end)