---@diagnostic disable: undefined-global, lowercase-global
local json

--Name of the char json
local char2parse = 'yongtai3'

--Sing Anims
local anims = {
    'singLEFT',
    'singDOWN',
    'singUP',
    'singRIGHT'
}

--Name of the Notetype that the character sings with
local noteTypeName = 'pico'
--Name of the alt anim suffix, will be used for the noteType name too so e.g: 'rizz-alt'
local altAnimSuffix = '-alt'

--If the character is the player or not 
local isPlayer = true 

--Character stage offset
local stageOffsets = {
    -200, --x
    50 --y
}
local order = 8


local idleSuffix = '' --alt idle thing don't touch


local idleLoop 
local doIdle = true
local specialAnim = false
function onCreate()
    if currentModDirectory ~= nil and currentModDirectory ~= '' then
        json = require("mods/"..currentModDirectory.."/scripts/jsonlua")
    else
        json = require("mods/scripts/jsonlua")
    end

    local charJson = json.parse(getTextFromFile('characters/'..char2parse..'.json'))

    makeAnimatedLuaSprite(char2parse, charJson.image, charJson.position[1] + stageOffsets[1], charJson.position[2] + stageOffsets[2])
    scaleObject(char2parse, charJson.scale, charJson.scale)
	setObjectOrder(char2parse, order)

    for i,animation in ipairs(charJson.animations) do
        addAnimationByPrefix(char2parse, animation.anim, animation.name, animation.fps, animation.loop)
        addOffset(char2parse, animation.anim, animation.offsets[1], animation.offsets[2])
        if animation.anim == 'idle' then
            idleLoop = animation.loop
        end
    end

    setProperty(char2parse..'.flipX', charJson.flip_x)


    addLuaSprite(char2parse)


    playAnim(char2parse, 'idle'..idleSuffix)
end

function onUpdate(elapsed)
    if specialAnim and getProperty(char2parse..'.animation.curAnim.finished') then
        specialAnim = false
    end
end

function onBeatHit()
    if not idleLoop then
        if curBeat % 2 == 0 and doIdle and not specialAnim then
            playAnim(char2parse, 'idle'..idleSuffix)
        end
        doIdle = true
    end
end

function singStuff(membersIndex, noteData, noteType, isSustainNote)
    if noteType == noteTypeName then
        doIdle = false
        playAnim(char2parse, anims[noteData + 1], true)
    elseif noteType == noteTypeName..altAnimSuffix then
        doIdle = false
        playAnim(char2parse, anims[noteData + 1]..altAnimSuffix, true)
    end
end


if isPlayer then
    function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
        singStuff(membersIndex, noteData, noteType, isSustainNote)
    end

else
    function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
        singStuff(membersIndex, noteData, noteType, isSustainNote)
    end
end


function onEvent(eventName, value1, value2)
    if eventName == 'Play Animation' then
        if value2 == char2parse then
            specialAnim = true
            playAnim(char2parse, value1)
        end
    end
    if eventName == 'Alt Idle Animation' then
        if value1 == char2parse then
            idleSuffix = value2
            playAnim(char2parse, 'idle'..idleSuffix)
        end
    end
end