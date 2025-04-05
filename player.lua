-- 玩家类
local Player = {}
Player.__index = Player

-- 引入物品系统
local ItemSystem = require('item')

-- 定义地形类型（与map.lua中保持一致）
local TERRAIN_TYPES = {
    GRASS = 1,
    WATER = 2,
    SAND = 3,
    FOREST = 4
}

-- 定义不同地形的移动速度修正
local TERRAIN_SPEED_MODIFIER = {
    [TERRAIN_TYPES.GRASS] = 1.0,   -- 草地正常速度
    [TERRAIN_TYPES.WATER] = 0.0,   -- 水面不能走
    [TERRAIN_TYPES.SAND] = 0.7,    -- 沙地减速
    [TERRAIN_TYPES.FOREST] = 0.8   -- 森林减速
}

-- 字体缓存
local playerFont = nil

-- 初始化字体
local function initFont()
    if not playerFont then
        playerFont = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function Player:new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.baseSpeed = 80  -- 基础移动速度
    self.size = 20       -- 玩家大小
    self.map = nil       -- 地图引用
    
    -- 属性系统
    self.attributes = {
        maxHp = 100,     -- 最大生命值
        hp = 100,        -- 当前生命值
        attack = 15,     -- 攻击力
        defense = 5,     -- 防御力
        level = 1,       -- 等级
        exp = 0,         -- 经验值
        nextLevelExp = 100,  -- 升级所需经验
        speed = 80      -- 移动速度
    }
    
    -- 装备栏
    self.equipment = {
        weapon = nil,    -- 武器
        armor = nil,     -- 护甲
        accessory = nil  -- 饰品
    }
    
    -- 状态系统
    self.status = {
        isAttacking = false,  -- 是否在攻击中
        attackCooldown = 0,   -- 攻击冷却
        attackRange = 50,     -- 攻击范围
        lastAttackTime = 0,   -- 上次攻击时间
        isAIControlled = false, -- 是否由AI控制
        targetMonster = nil,   -- 目标怪物
        wanderTimer = 0,      -- 随机移动计时器
        wanderX = nil,        -- 随机移动目标X
        wanderY = nil,        -- 随机移动目标Y
        detectRange = 150     -- 检测范围
    }
    
    initFont()  -- 确保字体已加载
    return self
end

function Player:setMap(map)
    self.map = map
end

function Player:canMoveTo(newX, newY)
    if not self.map then return true end
    
    -- 检查新位置的地形
    local terrain = self.map:getTerrainAt(newX, newY)
    if not terrain then return false end
    
    -- 水面不能走
    if terrain == TERRAIN_TYPES.WATER then
        return false
    end
    
    return true
end

function Player:getSpeedModifier(x, y)
    if not self.map then return 1.0 end
    
    local terrain = self.map:getTerrainAt(x, y)
    if not terrain then return 1.0 end
    
    return TERRAIN_SPEED_MODIFIER[terrain] or 1.0
end

function Player:gainExp(amount)
    self.attributes.exp = self.attributes.exp + amount
    -- 检查是否可以升级
    while self.attributes.exp >= self.attributes.nextLevelExp do
        self:levelUp()
    end
end

function Player:levelUp()
    self.attributes.level = self.attributes.level + 1
    self.attributes.exp = self.attributes.exp - self.attributes.nextLevelExp
    self.attributes.nextLevelExp = self.attributes.nextLevelExp * 1.5
    
    -- 属性提升
    self.attributes.maxHp = self.attributes.maxHp + 20
    self.attributes.hp = self.attributes.maxHp  -- 升级时回满血
    self.attributes.attack = self.attributes.attack + 5
    self.attributes.defense = self.attributes.defense + 2
end

function Player:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.attributes.defense)
    self.attributes.hp = math.max(0, self.attributes.hp - actualDamage)
    return actualDamage
end

function Player:heal(amount)
    self.attributes.hp = math.min(self.attributes.maxHp, self.attributes.hp + amount)
end

function Player:attack(monster)
    local currentTime = love.timer.getTime()
    if currentTime - self.status.lastAttackTime < 1.0 then  -- 1.0秒攻击冷却
        return false
    end
    
    -- 计算与怪物的距离
    local dx = monster.x - self.x
    local dy = monster.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance <= self.status.attackRange then
        self.status.isAttacking = true
        self.status.lastAttackTime = currentTime
        return monster:takeDamage(self.attributes.attack)
    end
    
    return false
end

function Player:setAIControl(enabled)
    self.status.isAIControlled = enabled
end

function Player:findNearestMonster(monsters)
    local nearestMonster = nil
    local minDistance = self.status.detectRange
    
    for _, monster in ipairs(monsters) do
        if not monster.status.isDead then
            local dx = monster.x - self.x
            local dy = monster.y - self.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < minDistance then
                minDistance = distance
                nearestMonster = monster
            end
        end
    end
    
    return nearestMonster
end

function Player:updateAI(dt, monsters)
    if not self.status.isAIControlled then return end
    
    -- 更新随机移动计时器
    self.status.wanderTimer = self.status.wanderTimer - dt
    
    -- 寻找最近的怪物
    local nearestMonster = self:findNearestMonster(monsters)
    
    if nearestMonster then
        self.status.targetMonster = nearestMonster
        -- 如果在攻击范围内，进行攻击
        local dx = nearestMonster.x - self.x
        local dy = nearestMonster.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= self.status.attackRange then
            self:attack(nearestMonster)
        else
            -- 移动向目标
            self:moveTowards(nearestMonster.x, nearestMonster.y, dt)
        end
    else
        -- 没有目标时随机移动
        if self.status.wanderTimer <= 0 or 
           (self.status.wanderX and self:reachedTarget(self.status.wanderX, self.status.wanderY)) then
            self:selectNewWanderTarget()
        end
        
        if self.status.wanderX then
            self:moveTowards(self.status.wanderX, self.status.wanderY, dt)
        end
    end
end

function Player:selectNewWanderTarget()
    -- 在地图范围内选择一个随机目标点
    local mapWidth = self.map.gridWidth * self.map.tileSize
    local mapHeight = self.map.gridHeight * self.map.tileSize
    
    local attempts = 0
    local maxAttempts = 10
    
    repeat
        self.status.wanderX = math.random(50, mapWidth - 50)
        self.status.wanderY = math.random(50, mapHeight - 50)
        attempts = attempts + 1
    until self:canMoveTo(self.status.wanderX, self.status.wanderY) or attempts >= maxAttempts
    
    self.status.wanderTimer = math.random(3, 6)  -- 3-6秒后重新选择目标
end

function Player:reachedTarget(targetX, targetY)
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < 10  -- 当距离小于10像素时认为已到达
end

function Player:moveTowards(targetX, targetY, dt)
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance > 0 then
        local moveX = (dx / distance) * self.baseSpeed * dt
        local moveY = (dy / distance) * self.baseSpeed * dt
        
        local newX = self.x + moveX
        local newY = self.y + moveY
        
        if self:canMoveTo(newX, newY) then
            local speedMod = self:getSpeedModifier(newX, newY)
            self.x = self.x + moveX * speedMod
            self.y = self.y + moveY * speedMod
        end
    end
end

function Player:update(dt)
    -- 更新实际属性
    self:updateSpeed()
    
    if self.status.isAIControlled then
        -- AI控制时不处理键盘输入
        return
    end
    
    -- 处理键盘输入移动
    local newX, newY = self.x, self.y
    local moved = false
    
    if love.keyboard.isDown('left') then
        newX = self.x - self.baseSpeed * dt
        moved = true
    end
    if love.keyboard.isDown('right') then
        newX = self.x + self.baseSpeed * dt
        moved = true
    end
    if love.keyboard.isDown('up') then
        newY = self.y - self.baseSpeed * dt
        moved = true
    end
    if love.keyboard.isDown('down') then
        newY = self.y + self.baseSpeed * dt
        moved = true
    end
    
    -- 如果有移动意图，检查新位置是否可行
    if moved and self.map then
        local speedMod = self:getSpeedModifier(newX, newY)
        if self:canMoveTo(newX, newY) then
            self.x = self.x + (newX - self.x) * speedMod
            self.y = self.y + (newY - self.y) * speedMod
        end
    end
    
    -- 更新攻击状态
    if self.status.isAttacking then
        if love.timer.getTime() - self.status.lastAttackTime > 0.2 then
            self.status.isAttacking = false
        end
    end
end

function Player:draw()
    -- 绘制玩家本体
    if self.status.isAttacking then
        love.graphics.setColor(1, 0.5, 0.5)  -- 攻击时变色
    else
        love.graphics.setColor(1, 0, 0)  -- 红色
    end
    love.graphics.rectangle('fill', self.x - self.size/2, self.y - self.size/2, self.size, self.size)
    
    -- 绘制血条背景
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('fill', 
        self.x - self.size, 
        self.y - self.size - 10, 
        self.size * 2, 
        5)
    
    -- 绘制血条
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle('fill', 
        self.x - self.size, 
        self.y - self.size - 10, 
        (self.size * 2) * (self.attributes.hp / self.attributes.maxHp), 
        5)
    
    -- 绘制等级和生命值
    love.graphics.setFont(playerFont)
    love.graphics.setColor(1, 1, 1)
    local levelText = string.format("Lv.%d", self.attributes.level)
    local hpText = string.format("%d/%d", self.attributes.hp, self.attributes.maxHp)
    love.graphics.print(levelText, self.x - self.size, self.y - self.size - 25)
    love.graphics.print(hpText, self.x - self.size, self.y + self.size + 5)
    
    -- 如果在攻击中，显示攻击范围
    if self.status.isAttacking then
        love.graphics.setColor(1, 0, 0, 0.2)
        love.graphics.circle('fill', self.x, self.y, self.status.attackRange)
    end
    
    -- 绘制装备信息
    local equipY = self.y + self.size + 25
    love.graphics.setFont(playerFont)
    love.graphics.setColor(1, 1, 1)
    
    -- 显示装备名称
    if self.equipment.weapon then
        love.graphics.print("武器: " .. self.equipment.weapon.config.name, 
            self.x - self.size, equipY)
        equipY = equipY + 15
    end
    if self.equipment.armor then
        love.graphics.print("护甲: " .. self.equipment.armor.config.name, 
            self.x - self.size, equipY)
        equipY = equipY + 15
    end
    if self.equipment.accessory then
        love.graphics.print("饰品: " .. self.equipment.accessory.config.name, 
            self.x - self.size, equipY)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 获取装备后的实际属性
function Player:getActualAttributes()
    local attrs = {
        maxHp = self.attributes.maxHp,
        hp = self.attributes.hp,
        attack = self.attributes.attack,
        defense = self.attributes.defense,
        speed = self.attributes.speed
    }
    
    -- 计算装备加成
    for _, equipment in pairs(self.equipment) do
        if equipment and equipment.config.attributes then
            for attr, value in pairs(equipment.config.attributes) do
                if attrs[attr] then
                    attrs[attr] = attrs[attr] + value
                end
            end
        end
    end
    
    return attrs
end

-- 装备物品
function Player:equip(item)
    if not item or not item.config then return nil end
    
    -- 检查物品类型和装备槽
    local slot
    if item.config.type == ItemSystem.EQUIPMENT_TYPES.WEAPON then
        slot = "weapon"
    elseif item.config.type == ItemSystem.EQUIPMENT_TYPES.ARMOR then
        slot = "armor"
    elseif item.config.type == ItemSystem.EQUIPMENT_TYPES.ACCESSORY then
        slot = "accessory"
    else
        return nil
    end
    
    -- 保存旧装备
    local oldEquipment = self.equipment[slot]
    
    -- 装备新物品
    self.equipment[slot] = item
    
    -- 返回旧装备（如果有的话）
    return oldEquipment
end

-- 更新移动速度
function Player:updateSpeed()
    local actualAttributes = self:getActualAttributes()
    self.baseSpeed = actualAttributes.speed
end

return Player 