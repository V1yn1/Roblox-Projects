local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = {}
function Events:CreateSignal()
    local Signal:RemoteEvent =Instance.new("RemoteEvent",ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"))
    return Signal
end
function Events:CreateUnreliableSignal()
    local Signal:UnreliableRemoteEvent =Instance.new("UnreliableRemoteEvent",ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Events"))
    return Signal
end
return Events