function onEvent(tag, arg1, arg2)
    if tag ~= "coe" then return end

    -- 定义位置配置
    local leftPositions = {112, 224, 336, 448}   -- 新的左侧位置
    local rightPositions = {732, 844, 956, 1068}  -- 默认右侧位置
    local tweenType = arg2 ~= '' and arg2 or "quadOut"
    local isActive = stringTrim(arg1:lower()) == "true"

    for i = 0, 7 do
        if isActive then
            -- 玩家箭头（4-7）移动到新左侧位置
            if i >= 4 then
                noteTweenX('playerMove'..i, i, leftPositions[i-3], 0.5, tweenType)
            -- 对手箭头（0-3）移动到右侧默认位置
            else
                noteTweenX('opponentMove'..i, i, rightPositions[i+1], 0.5, tweenType)
            end
        else
            -- 玩家箭头恢复右侧默认位置
            if i >= 4 then
                noteTweenX('resetPlayer'..i, i, rightPositions[i-3], 0.5, tweenType)
            -- 对手箭头恢复左侧默认位置
            else
                noteTweenX('resetOpponent'..i, i, leftPositions[i+1], 0.5, tweenType)
            end
        end
        
        noteTweenAlpha('keepVisible'..i, i, 1, 0.5, tweenType)
    end
end