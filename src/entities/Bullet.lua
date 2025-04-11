-- 子弹类
local Bullet = {}
Bullet.__index = Bullet

function Bullet:new(x, y, targetX, targetY, speed, damage, owner)
    local self = setmetatable({}, Bullet)
    self.x = x
    self.y = y
    self.speed = speed
    self.damage = damage
    self.owner = owner  -- 子弹的发射者（玩家或怪物）
    self.size = 4  -- 子弹大小
    
    -- 计算方向向量
    local dx = targetX - x
    local dy = targetY - y
    local length = math.sqrt(dx * dx + dy * dy)
    self.dx = dx / length
    self.dy = dy / length
    
    -- 子弹状态
    self.status = {
        isActive = true,
        lifetime = 2.0,  -- 子弹存在时间（秒）
        currentTime = 0
    }
    
    return self
end

function Bullet:update(dt)
    if not self.status.isActive then return end
    
    -- 更新位置
    self.x = self.x + self.dx * self.speed * dt
    self.y = self.y + self.dy * self.speed * dt
    
    -- 更新生命周期
    self.status.currentTime = self.status.currentTime + dt
    if self.status.currentTime >= self.status.lifetime then
        self.status.isActive = false
    end
end

function Bullet:draw()
    if not self.status.isActive then return end
    
    -- 设置子弹颜色（根据发射者类型）
    if self.owner == "player" then
        love.graphics.setColor(1, 1, 0)  -- 玩家子弹为黄色
    else
        love.graphics.setColor(1, 0, 0)  -- 怪物子弹为红色
    end
    
    -- 绘制子弹
    love.graphics.circle("fill", self.x, self.y, self.size)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function Bullet:checkCollision(entity)
    if not self.status.isActive then return false end
    
    -- 计算与实体的距离
    local dx = entity.x - self.x
    local dy = entity.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- 如果距离小于实体半径，则发生碰撞
    if distance < (entity.size or 10) then
        self.status.isActive = false
        return true
    end
    
    return false
end

return Bullet 