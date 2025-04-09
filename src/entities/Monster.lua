-- 怪物类
local Monster = {}
Monster.__index = Monster

-- 引入配置
local MONSTER_CONFIG = require('config/monsters')

-- 引入动画系统
local AnimationSystem = require('src/systems/Animation')

-- 获取动画系统资源
local resources = AnimationSystem.getResources()

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
    self.attributes.hp = self.attributes.maxHp  -- 初始化当前生命值
    
    -- 状态系统
    self.status = {
        isAttacking = false,
        lastAttackTime = 0,
        target = nil,
        isDead = false,
        wanderTimer = 0,      -- 随机移动计时器
        wanderX = nil,        -- 随机移动目标X
        wanderY = nil,        -- 随机移动目标Y
        state = "idle",       -- AI状态：idle（空闲）, move（移动）, attack（攻击）
        homeBuilding = nil,   -- 怪物所属的建筑
        homeX = nil,          -- 出生地点X
        homeY = nil,          -- 出生地点Y
        wanderRadius = 80     -- 游荡半径，默认值
    }
    
    -- 初始化动画
    self.animations = {
        idle = AnimationSystem.getMonsterAnimation(self.type, "idle"),
        move = AnimationSystem.getMonsterAnimation(self.type, "move"),
        attack = AnimationSystem.getMonsterAnimation(self.type, "attack")
    }
    
    initFont()
    return self
end

function Monster:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.attributes.defense)
    self.attributes.hp = math.max(0, self.attributes.hp - actualDamage)
    
    if self.attributes.hp <= 0 then
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
    -- 如果有所属建筑，则限制在建筑周围游荡
    if self.status.homeX and self.status.homeY then
        local attempts = 0
        local maxAttempts = 10
        local angle, distance, targetX, targetY
        
        repeat
            angle = math.random() * math.pi * 2
            distance = math.random(10, self.status.wanderRadius)
            targetX = self.status.homeX + math.cos(angle) * distance
            targetY = self.status.homeY + math.sin(angle) * distance
            
            -- 确保目标点在地图范围内
            targetX = math.max(50, math.min(map.gridWidth * map.tileSize - 50, targetX))
            targetY = math.max(50, math.min(map.gridHeight * map.tileSize - 50, targetY))
            
            attempts = attempts + 1
        until attempts >= maxAttempts
        
        self.status.wanderX = targetX
        self.status.wanderY = targetY
    else
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
    end
    
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
    
    -- 获取地图中心（玩家所在位置）
    local centerX = map.gridWidth * map.tileSize / 2
    local centerY = map.gridHeight * map.tileSize / 2
    
    -- 计算与玩家的距离
    local dx = centerX - self.x
    local dy = centerY - self.y
    local distanceToCenter = math.sqrt(dx * dx + dy * dy)
    
    -- 根据状态执行不同的行为
    if self.status.target then
        local dx = self.status.target.x - self.x
        local dy = self.status.target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= self.attributes.attackRange then
            -- 在攻击范围内
            self.status.state = "attack"
            self:attack(self.status.target)
        else
            -- 向目标移动
            self.status.state = "move"
            self:moveTowards(self.status.target, dt)
        end
    else
        -- 直接向玩家位置移动
        if distanceToCenter > self.attributes.attackRange then
            self.status.state = "move"
            self:moveTowards({x = centerX, y = centerY}, dt)
        else
            self.status.state = "idle"
        end
    end
    
    -- 更新当前状态的动画
    local currentAnimation = self.animations[self.status.state]
    if currentAnimation then
        currentAnimation:update(dt)
    end
end

function Monster:setTarget(target)
    self.status.target = target
end

function Monster:draw()
    -- 获取当前状态的动画
    local currentAnimation = self.animations[self.status.state]
    
    if currentAnimation then
        -- 设置颜色
        love.graphics.setColor(1, 1, 1)
        -- 绘制动画
        currentAnimation:draw(resources.images[self.type], self.x, self.y, 0, 1, 1, 8, 8)
    else
        -- 如果没有动画，使用默认绘制
        love.graphics.setColor(self.config.color[1], self.config.color[2], self.config.color[3])
        love.graphics.circle('fill', self.x, self.y, self.config.size)
    end
    
    -- 绘制生命条
    local hpBarWidth = self.config.size * 2
    local hpBarHeight = 3
    local hpPercentage = self.attributes.hp / self.attributes.maxHp
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.config.size - 5, hpBarWidth, hpBarHeight)
    
    love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.config.size - 5, hpBarWidth * hpPercentage, hpBarHeight)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return Monster 