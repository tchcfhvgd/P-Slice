function onCreate()
    -- 初始化变量
    screenWidth = getPropertyFromClass('openfl.Lib', 'application.window.display.bounds.width')
    screenHeight = getPropertyFromClass('openfl.Lib', 'application.window.display.bounds.height')
    
    -- 初始窗口大小
    originalWidth = 1900
    originalHeight = math.floor(originalWidth * 9 / 16)
    
    -- 设置初始窗口大小并居中
    setWindowSize(originalWidth, originalHeight)
    centerWindow()
    
    -- 动画控制变量
    windowScale = 1.0
    rotationAngle = 0
    isRotating = false
    stretchFactor = 1.0
end

function onStepHit()
    -- step117处丝滑缩小至原来窗口大小，随后并顺时针缓慢移动转圈
    if curStep == 117 then
        cancelTween('initialResize')
        windowScale = 1
        setWindowSize(originalWidth * windowScale, originalHeight * windowScale)
        centerWindow()
        isRotating = true
        rotationStartTime = getSongPosition()
    end
    
    -- step203处停止移动，并在2秒内放大至全屏
    if curStep == 203 then
        isRotating = false
        centerWindow()
    end
    
    -- step360处添加，窗口瞬间移动至左边
    if curStep == 360 then
        setWindowPos(0, (screenHeight - getWindowHeight()) / 2)
    end
    
    -- step374处窗口瞬间移动至右边
    if curStep == 374 then
        setWindowPos(screenWidth - getWindowWidth(), (screenHeight - getWindowHeight()) / 2)
    end
    
    -- step389再次移动至左边
    if curStep == 389 then
        setWindowPos(0, (screenHeight - getWindowHeight()) / 2)
    end
    -- step483处瞬间移动至左上角
    if curStep == 483 then
        setWindowPos(0, 0)
    end
    
    -- step486处瞬间移动至右上角
    if curStep == 486 then
        setWindowPos(screenWidth - getWindowWidth(), 0)
    end
    
    -- step489瞬间移动至左下角
    if curStep == 489 then
        setWindowPos(0, screenHeight - getWindowHeight())
    end
    
    -- step494移动至右下角
    if curStep == 494 then
        setWindowPos(screenWidth - getWindowWidth(), screenHeight - getWindowHeight())
    end
    
    -- step497移动至中间
    if curStep == 497 then
        centerWindow()
    end
    
    -- step504移动至上方
    if curStep == 504 then
        setWindowPos((screenWidth - getWindowWidth()) / 2, 0)
    end
    
    -- step501移动至下方
    if curStep == 501 then
        setWindowPos((screenWidth - getWindowWidth()) / 2, screenHeight - getWindowHeight())
    end

    -- 游戏最后缩小至原来大小
    if curStep == 1900 then
        setFullscreen(false)
        windowScale = 0.5
        stretchFactor = 1.0
        setWindowSize(originalWidth * windowScale, originalHeight * windowScale)
        centerWindow()
    end
end

function onUpdate(elapsed)
    -- 计算当前目标窗口大小
    local targetWidth = math.floor(originalWidth * windowScale * stretchFactor)
    local targetHeight = math.floor(originalHeight * windowScale)
    
    -- 应用窗口大小
    setWindowSize(targetWidth, targetHeight)
    
    -- 旋转动画处理
    if isRotating then
        -- 计算旋转角度（基于时间）
        local timePassed = getSongPosition() - rotationStartTime
        rotationAngle = timePassed * 0.18
        
        -- 计算旋转位置
        local winWidth, winHeight = getWindowSize()
        local centerX = (screenWidth - winWidth) / 2
        local centerY = (screenHeight - winHeight) / 2
        
        local radius = 200
        local radians = math.rad(rotationAngle)
        local offsetX = radius * math.cos(radians)
        local offsetY = radius * math.sin(radians)
        
        -- 设置窗口位置
        setWindowPos(math.floor(centerX + offsetX), math.floor(centerY + offsetY))
    end
end

-- 自定义函数：窗口大小缓动
function doTweenWindowSize(tag, startWidth, startHeight, endWidth, endHeight, duration, ease)
    runHaxeCode([[
        var startW = ]]..startWidth..[[;
        var startH = ]]..startHeight..[[;
        var endW = ]]..endWidth..[[;
        var endH = ]]..endHeight..[[;
        var dur = ]]..duration..[[;
        var easeFunc = FlxEase.]]..ease..[[;
        
        FlxTween.tween(FlxG.game, {width: endW, height: endH}, dur, {
            ease: easeFunc,
            onUpdate: function(twn) {
                FlxG.resizeWindow(Std.int(FlxG.game.width), Std.int(FlxG.game.height));
            },
            onComplete: function(twn) {
                // 确保最终大小正确
                FlxG.resizeWindow(endW, endH);
            }
        });
    ]])
end

-- 自定义函数：X位置缓动
function doTweenX(tag, startX, endX, duration, ease)
    runHaxeCode([[
        var startX = ]]..startX..[[;
        var endX = ]]..endX..[[;
        var dur = ]]..duration..[[;
        var easeFunc = FlxEase.]]..ease..[[;
        
        FlxTween.tween(FlxG.game, {x: endX}, dur, {
            ease: easeFunc,
            onUpdate: function(twn) {
                Application.current.window.x = Std.int(FlxG.game.x);
            }
        });
    ]])
end

-- 自定义函数：Y位置缓动
function doTweenY(tag, startY, endY, duration, ease)
    runHaxeCode([[
        var startY = ]]..startY..[[;
        var endY = ]]..endY..[[;
        var dur = ]]..duration..[[;
        var easeFunc = FlxEase.]]..ease..[[;
        
        FlxTween.tween(FlxG.game, {y: endY}, dur, {
            ease: easeFunc,
            onUpdate: function(twn) {
                Application.current.window.y = Std.int(FlxG.game.y);
            }
        });
    ]])
end

-- 辅助函数：设置窗口大小
function setWindowSize(width, height)
    runHaxeCode('FlxG.resizeWindow(' .. math.max(100, width) .. ', ' .. math.max(100, height) .. ');')
end

-- 辅助函数：设置窗口位置
function setWindowPos(x, y)
    setPropertyFromClass('openfl.Lib', 'application.window.x', math.max(0, x))
    setPropertyFromClass('openfl.Lib', 'application.window.y', math.max(0, y))
end

-- 辅助函数：居中窗口
function centerWindow()
    local winWidth, winHeight = getWindowSize()
    local x = (screenWidth - winWidth) / 2
    local y = (screenHeight - winHeight) / 2
    setWindowPos(x, y)
end

-- 辅助函数：获取当前窗口大小
function getWindowSize()
    local width = getPropertyFromClass('openfl.Lib', 'application.window.width') or screenWidth
    local height = getPropertyFromClass('openfl.Lib', 'application.window.height') or screenHeight
    return width, height
end

-- 辅助函数：获取当前窗口宽度
function getWindowWidth()
    return getPropertyFromClass('openfl.Lib', 'application.window.width') or screenWidth
end

-- 辅助函数：获取当前窗口高度
function getWindowHeight()
    return getPropertyFromClass('openfl.Lib', 'application.window.height') or screenHeight
end