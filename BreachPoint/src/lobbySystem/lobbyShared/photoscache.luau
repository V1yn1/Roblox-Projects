local photos = {}

function photos.getPlayerPhoto(playerId)
    if photos[playerId] then
        return photos[playerId]
    else
        local success, result = pcall(function()
            return game.Players:GetUserThumbnailAsync(playerId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        if success then
            photos[playerId] = result
            return result
        else
            warn("Failed to get thumbnail for player ID: " .. playerId)
            return nil
        end
    end
end
return photos