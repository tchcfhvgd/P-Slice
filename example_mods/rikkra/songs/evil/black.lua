local blackOverlayCreated = false

function onCreate()
    -- 预创建黑色覆盖层（但不可见）
    makeLuaSprite('blackOverlay', nil, 0, 0)
    makeGraphic('blackOverlay', screenWidth * 2, screenHeight * 2, '000000') -- 创建纯黑色图形
    setObjectCamera('blackOverlay', 'hud') -- 确保覆盖在HUD层
    setProperty('blackOverlay.alpha', 0) -- 初始完全透明
    addLuaSprite('blackOverlay', true) -- 添加到屏幕最顶层
    setObjectOrder('blackOverlay', getObjectOrder('strumLineNotes') + 100) -- 确保在HUD上方
end

function onStepHit()
    if curStep == 1127 and not blackOverlayCreated then
        -- 瞬间显示黑色覆盖层
        doTweenAlpha('blackOverlayAppear', 'blackOverlay', 1, 0.01, 'linear')
        blackOverlayCreated = true
        
        -- 调试信息
        debugPrint('[You win] You win=-=-=-=-=s-=da-=-=-=-=')
    end
end

-- 可选：在需要时移除覆盖层
function onEvent(name, value1, value2)
    if name == 'Remove Black Overlay' then
        doTweenAlpha('blackOverlayDisappear', 'blackOverlay', 0, 0.5, 'linear')
    end
end