local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = require(ReplicatedStorage.Shared.Packages.Framework.Classes)

local PlayerClass = Classes:CreateClass({
    Name = "PlayerClass",
    PlayerName = "",
    Health = 100;
    Inventory = {}
})


return PlayerClass