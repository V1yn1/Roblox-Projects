local module = {imagens = {}}

function module.Imagem(player:Player)
    if  table.find(module.imagens,player.UserId) then
        return module.imagens[player.UserId]
    else
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        local content, isReady = game.Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
        module.imagens[player.UserId] = content
        return content
    end
end

return module