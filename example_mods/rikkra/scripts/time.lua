function onCreatePost()
    makeLuaText('timeText', '', 0, 1150, 680)
    setTextSize('timeText', 24)
    addLuaText('timeText')
end

function onUpdatePost(elapsed)
    local hours = os.date('%H')
    local minutes = os.date('%M')
    local seconds = os.date('%S')

    local timeString = string.format('%s:%s:%s', hours, minutes, seconds)

    setTextString('timeText', timeString)
end