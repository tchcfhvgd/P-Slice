-- 如果只想反转位置而不翻转图标：
function onCreatePost()
    setProperty('healthBar.flipX', true)
    
    -- 简单交换图标位置
    local p1X = getProperty('iconP1.x')
    local p2X = getProperty('iconP2.x')
    
    setProperty('iconP1.x', p2X)
    setProperty('iconP2.x', p1X)
    
    debugPrint('简单位置交换完成')
end

-- 如果需要保持图标原始方向（不翻转）：
function onCreatePost()
    setProperty('healthBar.flipX', true)
    
    -- 交换位置但不翻转图标
    local p1X = getProperty('iconP1.x')
    local p2X = getProperty('iconP2.x')
    
    setProperty('iconP1.x', p2X)
    setProperty('iconP2.x', p1X)
    
    -- 移除图标翻转
    setProperty('iconP1.flipX', false)
    setProperty('iconP2.flipX', false)
end

-- 如果需要调整反转后的位置：
function onCreatePost()
    setProperty('healthBar.flipX', true)
    
    -- 自定义位置偏移
    local offsetX = 10  -- 水平偏移量
    local offsetY = -70  -- 垂直偏移量
    
    setProperty('iconP1.x', getProperty('healthBar.x') + offsetX)
    setProperty('iconP1.y', getProperty('healthBar.y') - getProperty('iconP1.height') - offsetY)
    
    setProperty('iconP2.x', getProperty('healthBar.x') + getProperty('healthBar.width') - getProperty('iconP2.width') - offsetX)
    setProperty('iconP2.y', getProperty('healthBar.y') - getProperty('iconP2.height') - offsetY)
end