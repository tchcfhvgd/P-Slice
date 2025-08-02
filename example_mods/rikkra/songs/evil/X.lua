local bfMoved = false  -- 确保只触发一次
local damageApplied = false  -- 确保伤害只应用一次

function onStepHit()
    if curStep == 1124 and not bfMoved then
        -- 获取BF当前X位置
        local startX = getProperty('boyfriend.x')
        local targetX = 900
        
        -- 创建移动补间动画
        doTweenX('bfMoveTween', 'boyfriend', targetX, 0.1, 'sineOut')
        
        bfMoved = true
        damageApplied = false  -- 重置伤害标志
    end
end

function onTweenCompleted(tag)
    if tag == 'bfMoveTween' and not damageApplied then
        local currentHealth = getProperty('health')
        local healAmount = 2.0  -- 100点血量
        
        -- 计算新血量（确保不超过最大值2.0）
        local newHealth = math.min(2.0, currentHealth + healAmount)
        
        -- 设置新血量
        setProperty('health', newHealth)
        
        
        -- 设置新血量
        setProperty('health', newHealth)
        
        -- 添加视觉效果
        cameraFlash('hud', 'FF0000', 0.25)  -- 红色闪光
        
        -- 添加伤害粒子效果（可选）
        makeAnimatedLuaSprite('damageParticles', 'particles', getProperty('healthBar.x'), getProperty('healthBar.y'))
        addAnimationByPrefix('damageParticles', 'burst', 'hit', 24, false)
        setObjectCamera('damageParticles', 'hud')
        addLuaSprite('damageParticles', true)
        objectPlayAnimation('damageParticles', 'burst', true)
        runTimer('removeParticles', 0.5)
        
        -- 屏幕震动（可选）
        cameraShake('hud', 0.01, 0.1)
        
        damageApplied = true  -- 标记伤害已应用
    end
end

function onTimerCompleted(tag)
    if tag == 'removeParticles' then
        removeLuaSprite('damageParticles', true)
    end
end