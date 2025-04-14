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
    
    -- 特殊效果
    self.effects = {
        isCritical = false,    -- 是否暴击
        stunChance = 0,        -- 眩晕几率
        lifeSteal = 0          -- 生命偷取百分比
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
    
    -- 设置子弹颜色（根据发射者类型和是否暴击）
    if self.owner == "player" then
        if self.effects.isCritical then
            -- 暴击为橙色
            love.graphics.setColor(1, 0.5, 0)
            self.size = 6  -- 暴击子弹稍大
        else
            -- 普通为黄色
            love.graphics.setColor(1, 1, 0)
        end
    else
        -- 怪物子弹为红色
        love.graphics.setColor(1, 0, 0)
    end
    
    -- 绘制子弹
    love.graphics.circle("fill", self.x, self.y, self.size)
    
    -- 如果是暴击，添加发光效果
    if self.effects.isCritical then
        love.graphics.setColor(1, 0.8, 0.2, 0.5)
        love.graphics.circle("line", self.x, self.y, self.size + 2)
    end
    
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
        -- 成功命中
        self.status.isActive = false
        
        -- 检查是否需要应用特殊效果
        if self.owner == "player" then
            -- 生命偷取效果
            if self.effects.lifeSteal > 0 and entity.takeDamage then
                -- 计算偷取的生命值
                local stealAmount = math.floor(self.damage * (self.effects.lifeSteal / 100))
                
                -- 寻找玩家对象来回复生命
                local gameState = _G.gameState
                if gameState and gameState.player then
                    gameState.player:heal(stealAmount)
                end
            end
            
            -- 眩晕效果
            if self.effects.stunChance > 0 and entity.status then
                if math.random(100) <= self.effects.stunChance then
                    -- 眩晕怪物
                    if entity.status.stunDuration then
                        entity.status.stunDuration = math.max(entity.status.stunDuration, 1.5)  -- 眩晕1.5秒
                    else
                        entity.status.stunDuration = 1.5
                    end
                end
            end
        end
        
        return true
    end
    
    return false
end

function Bullet:getDamageWithEffects()
    return self.damage
end

return Bullet 