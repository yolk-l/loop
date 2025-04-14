-- 子弹模型
local BulletModel = {}
BulletModel.__index = BulletModel

function BulletModel:new(startX, startY, targetX, targetY, speed, damage, sourceType)
    local self = setmetatable({}, BulletModel)
    
    -- 位置信息
    self.x = startX
    self.y = startY
    self.startX = startX
    self.startY = startY
    self.targetX = targetX
    self.targetY = targetY
    
    -- 计算方向
    local dx = targetX - startX
    local dy = targetY - startY
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- 如果目标就在起点，给一个默认方向
    if distance == 0 then
        self.dirX = 1
        self.dirY = 0
    else
        self.dirX = dx / distance
        self.dirY = dy / distance
    end
    
    -- 属性
    self.speed = speed or 300
    self.damage = damage or 10
    self.sourceType = sourceType or "player"  -- 发射源类型：player或monster
    self.maxDistance = distance              -- 最大飞行距离
    self.distanceTraveled = 0                -- 已飞行距离
    
    -- 状态
    self.status = {
        isActive = true  -- 子弹是否有效
    }
    
    -- 特效
    self.effects = {
        isCritical = false,    -- 是否暴击
        stunChance = 0,        -- 眩晕几率
        lifeSteal = 0          -- 生命偷取比例
    }
    
    -- 碰撞检测参数
    self.radius = 3  -- 子弹碰撞半径
    
    return self
end

function BulletModel:update(dt)
    if not self.status.isActive then return end
    
    -- 更新位置
    local moveDistance = self.speed * dt
    self.x = self.x + self.dirX * moveDistance
    self.y = self.y + self.dirY * moveDistance
    
    -- 更新已飞行距离
    self.distanceTraveled = self.distanceTraveled + moveDistance
    
    -- 检查是否超出最大飞行距离
    if self.distanceTraveled >= self.maxDistance then
        self.status.isActive = false
    end
end

function BulletModel:getPosition()
    return {x = self.x, y = self.y}
end

function BulletModel:getSource()
    return self.sourceType
end

function BulletModel:getDamage()
    return self.damage
end

function BulletModel:getEffects()
    return self.effects
end

function BulletModel:deactivate()
    self.status.isActive = false
end

function BulletModel:isActive()
    return self.status.isActive
end

function BulletModel:checkCollision(entity)
    if not self.status.isActive then return false end
    
    local dx = self.x - entity.x
    local dy = self.y - entity.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- 简单碰撞检测：子弹半径 + 实体半径
    local collisionRadius = self.radius + (entity.size or 10)
    
    return distance <= collisionRadius
end

return BulletModel 