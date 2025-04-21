-- 资源效果工具
local ResourceEffect = {}

-- 效果队列
ResourceEffect.effects = {}

-- 资源类型对应的颜色
ResourceEffect.COLORS = {
    wood = {0.6, 0.3, 0.1, 1},   -- 棕色
    food = {0.1, 0.8, 0.1, 1},   -- 绿色
    fish = {0.1, 0.5, 0.9, 1},   -- 蓝色
    stone = {0.7, 0.7, 0.7, 1}   -- 灰色
}

-- 创建一个新的资源采集效果
function ResourceEffect.create(x, y, resourceType, amount)
    local effect = {
        x = x,
        y = y,
        resourceType = resourceType,
        amount = amount,
        text = "+" .. amount .. " " .. resourceType,
        color = ResourceEffect.COLORS[resourceType] or {1, 1, 1, 1},
        alpha = 1,
        lifetime = 1.0,  -- 效果显示时间
        yOffset = 0,     -- 上升偏移量
        speed = 50       -- 上升速度
    }
    
    -- 钓鱼特殊效果
    if resourceType == "fish" then
        effect.isFish = true
        effect.fishX = 0
        effect.fishY = -5
        effect.fishAngle = 0
        effect.fishSpeed = 20
    end
    
    table.insert(ResourceEffect.effects, effect)
end

-- 更新所有效果
function ResourceEffect.update(dt)
    for i = #ResourceEffect.effects, 1, -1 do
        local effect = ResourceEffect.effects[i]
        
        -- 更新效果生命周期
        effect.lifetime = effect.lifetime - dt
        
        -- 透明度逐渐降低
        effect.alpha = effect.lifetime
        
        -- 向上移动
        effect.yOffset = effect.yOffset + effect.speed * dt
        
        -- 钓鱼特殊效果更新
        if effect.isFish then
            effect.fishAngle = effect.fishAngle + dt * 5  -- 摆动
            effect.fishX = math.sin(effect.fishAngle) * 5  -- 左右摆动
        end
        
        -- 如果生命周期结束，移除效果
        if effect.lifetime <= 0 then
            table.remove(ResourceEffect.effects, i)
        end
    end
end

-- 绘制所有效果
function ResourceEffect.draw()
    for _, effect in ipairs(ResourceEffect.effects) do
        -- 设置文本颜色
        love.graphics.setColor(effect.color[1], effect.color[2], effect.color[3], effect.alpha)
        
        -- 绘制钓鱼特殊效果
        if effect.isFish then
            local fishSize = 8
            
            -- 绘制小鱼
            love.graphics.ellipse('fill', 
                effect.x + effect.fishX, 
                effect.y - 20 - effect.yOffset + effect.fishY, 
                fishSize, fishSize/2)
            
            -- 鱼尾
            local tailDirection = math.sin(effect.fishAngle) > 0 and 1 or -1
            love.graphics.polygon('fill', 
                effect.x + effect.fishX - fishSize, effect.y - 20 - effect.yOffset + effect.fishY,
                effect.x + effect.fishX - fishSize - fishSize/2, effect.y - 20 - effect.yOffset + effect.fishY - fishSize/2 * tailDirection,
                effect.x + effect.fishX - fishSize - fishSize/2, effect.y - 20 - effect.yOffset + effect.fishY + fishSize/2 * tailDirection
            )
        end
        
        -- 绘制文本
        love.graphics.print(
            effect.text,
            effect.x - 20,  -- 文本居中显示
            effect.y - 20 - effect.yOffset  -- 稍微上方并随时间上移
        )
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1, 1)
end

return ResourceEffect 