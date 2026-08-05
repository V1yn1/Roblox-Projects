local Events = require(script.Parent.Parent.EventsService.Events)
local PlayerService = {
    Signals = {
        ClickUI = Events:CreateUnreliableSignal()
    }
}


return PlayerService