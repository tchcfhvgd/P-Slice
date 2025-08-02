
local allowCountdown = false
local videoPlayed = false

function onStartCountdown()
    if not allowCountdown and not seenCutscene and not videoPlayed then
        startVideo('DDLC start')
        allowCountdown = true
        videoPlayed = true
        return Function_Stop
    end
    return Function_Continue
end