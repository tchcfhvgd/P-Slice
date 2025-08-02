function onCreatePost()
    local bfName = getProperty('boyfriend.curCharacter')
    if string.sub(bfName, 1, 4) == "pico" then
        setPropertyFromClass('backend.ClientPrefs','data.pauseMusic','breakfast-pico/breakfast-pico')
        end
        if string.sub(bfName, 1, 2) == "bf" then
            setPropertyFromClass('backend.ClientPrefs','data.pauseMusic','breakfast')
            end
end
function lerp(a, b, t)
    return a + (b - a) * t
end

function onUpdate(elapsed)
    local targetScale = 1
    local lerpSpeed = 0.01  

    local currentBfScaleX = getProperty('iconP1.scale.x')
    local currentBfScaleY = getProperty('iconP1.scale.y')
    setProperty('iconP1.scale.x', lerp(currentBfScaleX, targetScale, lerpSpeed))
    setProperty('iconP1.scale.y', lerp(currentBfScaleY, targetScale, lerpSpeed))

    local currentOppScaleX = getProperty('iconP2.scale.x')
    local currentOppScaleY = getProperty('iconP2.scale.y')
    setProperty('iconP2.scale.x', lerp(currentOppScaleX, targetScale, lerpSpeed))
    setProperty('iconP2.scale.y', lerp(currentOppScaleY, targetScale, lerpSpeed))
end


local flip = false
local percent = 50
function onUpdatePost(e)
    flip = getProperty('healthBar.flipX') or getProperty('healthBar.angle') == 180 or getProperty('healthBar.scale.x') == -1

    percent = math.lerp(percent, math.max((getProperty('health') * 50), 0), (e * 10))
    setProperty('healthBar.percent', percent)
    if percent > 100 then percent = 100 end

    local usePer = (flip and percent or remap(percent, 0, 100, 100, 0)) * 0.01
    local part1 = getProperty('healthBar.x') + ((getProperty('healthBar.width')) * usePer)
    local iconParts = {part1 + (150 * getProperty('iconP1.scale.x') - 150) / 2 - 26, part1 - (150 * getProperty('iconP2.scale.x')) / 2 - 26 * 2}

    for i = 1, 2 do
        setProperty('iconP'..i..'.x', iconParts[flip and ((i % 2) + 1) or i])
        setProperty('iconP'..i..'.flipX', flip)
    end
end

function math.lerp(a, b, t)
    return (b - a) * t + a;
end

function remap(v, str1, stp1, str2, stp2)
	return str2 + (v - str1) * ((stp2 - str2) / (stp1 - str1));
end