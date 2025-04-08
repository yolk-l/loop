-- 怪物类
local Monster = {}
Monster.__index = Monster

-- 引入配置
local MONSTER_CONFIG = require('config/monsters')

-- 字体缓存
local monsterFont = nil

-- 初始化字体
local function initFont()
    if not monsterFont then
        monsterFont = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function Monster:new(type, x, y)
    local self = setmetatable({}, Monster)
    self.type = type
    self.config = MONSTER_CONFIG[type]
    self.x = x
    self.y = y
    
    -- 复制属性，这样每个实例都有自己的属性副本
    self.attributes = {}
    for k, v in pairs(self.config.attributes) do
        self.attributes[k] = v
    end
    self.hp = self.attributes.maxHp
    
    -- 状态系统
    self.status = {
        isAttacking = false,
        lastAttackTime = 0,
        target = nil,
        isDead = false,
        wanderTimer = 0,      -- 随机移动计时器
        wanderX = nil,        -- 随机移动目标X
        wanderY = nil,        -- 随机移动目标Y
        state = "wander"      -- AI状态：wander（游荡）, chase（追击）, attack（攻击）
    }
    
    initFont()
    return self
end

function Monster:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.attributes.defense)
    self.hp = math.max(0, self.hp - actualDamage)
    
    if self.hp <= 0 then
        self.status.isDead = true
    end
    
    return actualDamage
end

function Monster:attack(target)
    local currentTime = love.timer.getTime()
    if currentTime - self.status.lastAttackTime < 1.5 then  -- 1.5秒攻击冷却
        return false
    end
    
    -- 计算与目标的距离
    local dx = target.x - self.x
    local dy = target.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance <= self.attributes.attackRange then
        self.status.isAttacking = true
        self.status.lastAttackTime = currentTime
        return target:takeDamage(self.attributes.attack)
    end
    
    return false
end

function Monster:selectNewWanderTarget(map)
    -- 在地图范围内选择一个随机目标点
    local mapWidth = map.gridWidth * map.tileSize
    local mapHeight = map.gridHeight * map.tileSize
    
    local attempts = 0
    local maxAttempts = 10
    
    repeat
        self.status.wanderX = math.random(50, mapWidth - 50)
        self.status.wanderY = math.random(50, mapHeight - 50)
        attempts = attempts + 1
    until attempts >= maxAttempts
    
    self.status.wanderTimer = math.random(3, 6)  -- 3-6秒后重新选择目标
end

function Monster:reachedTarget(targetX, targetY)
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < 10  -- 当距离小于10像素时认为已到达
end

function Monster:moveTowards(target, dt)
    if not target then return end
    
    local targetX = type(target) == "table" and target.x or target
    local targetY = type(target) == "table" and target.y or self.status.wanderY
    
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance > 0 then
        local speed = self.attributes.speed * dt
        self.x = self.x + (dx / distance) * speed
        self.y = self.y + (dy / distance) * speed
    end
end

function Monster:update(dt, map)
    if self.status.isDead then return end
    
    -- 更新攻击状态
    if self.status.isAttacking then
        if love.timer.getTime() - self.status.lastAttackTime > 0.2 then
            self.status.isAttacking = false
        end
    end
    
    -- 更新随机移动计时器
    self.status.wanderTimer = self.status.wanderTimer - dt
    
    -- 根据状态执行不同的行为
    if self.status.target then
        local dx = self.status.target.x - self.x
        local dy = self.status.target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= self.attributes.detectRange then
            if distance <= self.attributes.attackRange then
                -- 在攻击范围内
                self.status.state = "attack"
                self:attack(self.status.target)
            else
                -- 在检测范围内但不在攻击范围内
                self.status.state = "chase"
                self:moveTowards(self.status.target, dt)
            end
        else
            -- 目标超出检测范围，恢复游荡状态
            self.status.state = "wander"
            self.status.target = nil
        end
    end
    
    -- 游荡状态的处理
    if self.status.state == "wander" then
        -- 需要选择新的游荡目标
        if self.status.wanderTimer <= 0 or not self.status.wanderX then
            self:selectNewWanderTarget(map)
        end
        
        -- 向游荡目标移动
        if self.status.wanderX and self.status.wanderY then
            if self:reachedTarget(self.status.wanderX, self.status.wanderY) then
                -- 到达目标点，重置计时器
                self.status.wanderTimer = 0
            else
                -- 向目标点移动
                self:moveTowards({x = self.status.wanderX, y = self.status.wanderY}, dt)
            end
        end
    end
end

function Monster:setTarget(target)
    self.status.target = target
end

function Monster:draw()
    if self.status.isDead then return end
    
    -- 绘制怪物
    love.graphics.setColor(unpack(self.config.color))
    love.graphics.circle('fill', self.x, self.y, self.config.size)
    
    -- 绘制边框
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.circle('line', self.x, self.y, self.config.size)
    
    -- 绘制生命条
    local hpBarWidth = self.config.size * 2
    local hpBarHeight = 5
    local hpPercentage = self.hp / self.attributes.maxHp
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.config.size - 10, hpBarWidth, hpBarHeight)
    
    love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.config.size - 10, hpBarWidth * hpPercentage, hpBarHeight)
    
    -- 绘制怪物名称
    love.graphics.setFont(monsterFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.config.name, self.x - monsterFont:getWidth(self.config.name)/2, self.y - self.config.size - 25)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return Monster 