local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vanguard = require(ReplicatedStorage.Packages.Vanguard)

Vanguard.Bootstrap({
    Classes = ReplicatedStorage.Shared.Classes,
    Services = script.Parent.Services,
    Options = {
        LogLevel = "debug",
    },
}):catch(function(err)
    warn(`Vanguard server failed: {err}`)
end)