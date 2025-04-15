-- 子弹视图
local BulletView = {}
BulletView.__index = BulletView

-- 子弹图片缓存
local bulletImage = nil

-- 加载子弹图片
local function loadBulletImage()
    bulletImage = love.graphics.newImage("assets/sprites/bullets/normal_bullet.png")
end

function BulletView.new()
    local self = setmetatable({}, BulletView)
    
    -- 确保子弹图片已加载
    if not bulletImage then
        loadBulletImage()
    end
    
    -- 添加存储hit effects的数组
    self.hitEffects = {}
    
    return self
end

function BulletView:update(dt)
    -- 更新击中效果
    for i = #self.hitEffects, 1, -1 do
        self.hitEffects[i].lifetime = self.hitEffects[i].lifetime - dt
        if self.hitEffects[i].lifetime <= 0 then
            table.remove(self.hitEffects, i)
        end
    end
end

function BulletView:draw(bulletModel)
    if not bulletModel:isActive() then return end
    
    -- 暴击子弹使用不同颜色
    local effects = bulletModel:getEffects()
    local position = bulletModel:getPosition()
    local direction = bulletModel:getDirection()
    local sourceType = bulletModel:getSource()
    local radius = bulletModel:getRadius()
    
    if effects.isCritical then
        love.graphics.setColor(1, 0.2, 0.2)  -- 暴击用红色
    else
        -- 所有普通子弹都使用黑色
        love.graphics.setColor(0, 0, 0)  -- 黑色
    end
    
    -- 使用图片或简单图形绘制子弹
    if bulletImage then
        local scale = 0.5
        love.graphics.draw(bulletImage, position.x, position.y, 
                          math.atan2(direction.y, direction.x),  -- 旋转角度
                          scale, scale,  -- 缩放
                          bulletImage:getWidth()/2, bulletImage:getHeight()/2)  -- 锚点
    else
        -- 使用简单图形绘制子弹
        love.graphics.circle('fill', position.x, position.y, radius)
    end
    
    -- 添加子弹轨迹效果
    love.graphics.setColor(0, 0, 0, 0.2)  -- 黑色轨迹，透明度0.2
    love.graphics.line(position.x, position.y, 
                      position.x - direction.x * 10, 
                      position.y - direction.y * 10)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
    
    -- 绘制所有击中效果
    for _, effect in ipairs(self.hitEffects) do
        self:drawHitEffect(effect.x, effect.y, effect.isCritical)
    end
end

-- 创建击中效果
function BulletView:createHitEffect(x, y, isCritical)
    local effect = {
        x = x,
        y = y,
        isCritical = isCritical,
        lifetime = 0.3  -- 效果持续时间，单位秒
    }
    
    table.insert(self.hitEffects, effect)
end

-- 绘制子弹击中效果
function BulletView:drawHitEffect(x, y, isCritical)
    -- 击中效果圆圈
    if isCritical then
        -- 暴击效果
        love.graphics.setColor(1, 0.2, 0.2, 0.7)
        love.graphics.circle('fill', x, y, 8)
        love.graphics.setColor(1, 0.5, 0.1, 0.9)
        love.graphics.circle('line', x, y, 10)
    else
        -- 普通击中效果
        love.graphics.setColor(1, 1, 0.5, 0.7)
        love.graphics.circle('fill', x, y, 5)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return BulletView 