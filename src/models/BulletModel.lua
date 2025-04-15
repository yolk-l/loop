-- 子弹模型
local BulletModel = {}
BulletModel.__index = BulletModel

function BulletModel.new(startX, startY, targetX, targetY, speed, damage, sourceType)
    
    -- 计算方向
    local dx = targetX - startX
    local dy = targetY - startY
    local distance = math.sqrt(dx * dx + dy * dy)
    local dirX, dirY
    -- 如果目标就在起点，给一个默认方向
    if distance == 0 then
        dirX = 1
        dirY = 0
    else
        dirX = dx / distance
        dirY = dy / distance
    end
    local mt = setmetatable({
        x = startX,
        y = startY,
        startX = startX,
        startY = startY,
        targetX = targetX,
        targetY = targetY,
        dirX = dirX,
        dirY = dirY,
        speed = speed or 300,
        damage = damage or 10,
        sourceType = sourceType or "player",
        maxDistance = distance,
        distanceTraveled = 0,
        radius = 3,
        status = {
            isActive = true  -- 子弹是否有效
        },
        effects = {
            isCritical = false,    -- 是否暴击
            stunChance = 0,        -- 眩晕几率
            lifeSteal = 0          -- 生命偷取比例
        }
    }, BulletModel)
    return mt
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

function BulletModel:getDirection()
    return {x = self.dirX, y = self.dirY}
end

function BulletModel:getRadius()
    return self.radius
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