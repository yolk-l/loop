-- 玩家类
local Player = {}
Player.__index = Player

-- 引入物品系统和地形配置
local ItemSystem = require('src/systems/Item')
local TerrainConfig = require('config/terrain')

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
    self.size = 10       -- 玩家大小，从20减小到10
    self.map = nil       -- 地图引用
    
    -- 防御区域设置
    self.defenseRadius = 150   -- 防御区域半径，不可建造建筑
    self.attackRadius = 100    -- 攻击范围半径，自动攻击该范围内的怪物
    
    -- 属性系统
    self.attributes = {
        maxHp = 100,     -- 最大生命值
        hp = 100,        -- 当前生命值
        attack = 15,     -- 攻击力
        defense = 5,     -- 防御力
        level = 1,       -- 等级
        exp = 0,         -- 经验值
        nextLevelExp = 100,  -- 升级所需经验
        speed = 80,      -- 移动速度
        attackCooldown = 1.0,  -- 攻击冷却时间（秒）
        lastAttackTime = 0     -- 上次攻击时间
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
        attackStartTime = 0,  -- 攻击开始时间
        isAIControlled = false, -- 是否由AI控制
        targetMonster = nil,   -- 目标怪物
        wanderTimer = 0,      -- 随机移动计时器
        wanderX = nil,        -- 随机移动目标X
        wanderY = nil,        -- 随机移动目标Y
        detectRange = 150     -- 检测范围
    }
    
    -- 装备属性加成记录
    self.equipmentBonuses = {
        maxHp = 0,
        attack = 0,
        defense = 0,
        speed = 0
    }
    
    initFont()  -- 确保字体已加载
    return self
end

function Player:setMap(map)
    self.map = map
    -- 重新定位玩家到地图中央
    self.x = map.gridWidth * map.tileSize / 2
    self.y = map.gridHeight * map.tileSize / 2
end

function Player:canMoveTo(newX, newY)
    if not self.map then return true end
    
    -- 检查新位置的地形
    local terrain = self.map:getTerrainAt(newX, newY)
    if not terrain then return false end
    
    -- 水面不能走
    if terrain == TerrainConfig.TERRAIN_TYPES.WATER then
        return false
    end
    
    return true
end

function Player:getSpeedModifier(x, y)
    if not self.map then return 1.0 end
    
    local terrain = self.map:getTerrainAt(x, y)
    if not terrain then return 1.0 end
    
    return TerrainConfig.TERRAIN_SPEED_MODIFIER[terrain] or 1.0
end

function Player:update(dt)
    -- 玩家固定在地图中央，所以不再处理移动逻辑
    
    -- 更新攻击冷却
    if self.attributes.lastAttackTime > 0 then
        local currentTime = love.timer.getTime()
        if currentTime - self.attributes.lastAttackTime > self.attributes.attackCooldown then
            self.attributes.lastAttackTime = 0  -- 冷却完毕
        end
    end
    
    -- 检查攻击状态持续时间
    if self.status.isAttacking then
        local currentTime = love.timer.getTime()
        if currentTime - self.status.attackStartTime > 0.2 then
            self.status.isAttacking = false  -- 攻击效果结束
        end
    end
end

function Player:autoAttack(monsters)
    -- 如果正在冷却中，不进行攻击
    if self.attributes.lastAttackTime > 0 then
        return
    end
    
    -- 查找范围内的怪物并攻击
    local closestMonster = nil
    local closestDistance = self.attackRadius
    
    for _, monster in ipairs(monsters) do
        if not monster.status.isDead then
            local dx = monster.x - self.x
            local dy = monster.y - self.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < closestDistance then
                closestDistance = distance
                closestMonster = monster
            end
        end
    end
    
    -- 如果找到范围内的怪物，进行攻击
    if closestMonster then
        self:attack(closestMonster)
    end
end

function Player:attack(target)
    if not target or target.status.isDead then
        return false
    end
    
    self.attributes.lastAttackTime = love.timer.getTime()
    self.status.isAttacking = true
    self.status.attackStartTime = love.timer.getTime()  -- 记录攻击开始时间
    
    -- 计算伤害并应用
    local damage = self.attributes.attack
    local actualDamage = target:takeDamage(damage)
    
    return actualDamage
end

function Player:canBuildAt(x, y)
    -- 计算距离玩家的距离
    local dx = x - self.x
    local dy = y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- 如果在防御区域内，不能建造
    return distance > self.defenseRadius
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
    -- 每次升级时，稍微扩大防御和攻击范围
    self.defenseRadius = self.defenseRadius + 5
    self.attackRadius = self.attackRadius + 3
end

function Player:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.attributes.defense)
    self.attributes.hp = math.max(0, self.attributes.hp - actualDamage)
    return actualDamage
end

function Player:heal(amount)
    self.attributes.hp = math.min(self.attributes.maxHp, self.attributes.hp + amount)
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
            local moveSpeed = self.attributes.speed * dt
            local nx = self.x + (dx / distance) * moveSpeed
            local ny = self.y + (dy / distance) * moveSpeed
            
            if self:canMoveTo(nx, ny) then
                self.x = nx
                self.y = ny
            end
        end
    else
        -- 没有目标，随机移动
        if self.status.wanderTimer <= 0 or not self.status.wanderX then
            -- 选择新的随机目标
            if self.map then
                local mapWidth = self.map.gridWidth * self.map.tileSize
                local mapHeight = self.map.gridHeight * self.map.tileSize
                
                local attempts = 0
                local maxAttempts = 10
                local validTarget = false
                
                repeat
                    self.status.wanderX = math.random(50, mapWidth - 50)
                    self.status.wanderY = math.random(50, mapHeight - 50)
                    validTarget = self:canMoveTo(self.status.wanderX, self.status.wanderY)
                    attempts = attempts + 1
                until validTarget or attempts >= maxAttempts
                
                self.status.wanderTimer = math.random(2, 4)  -- 随机游荡时间
            end
        end
        
        -- 向随机目标移动
        if self.status.wanderX and self.status.wanderY then
            local dx = self.status.wanderX - self.x
            local dy = self.status.wanderY - self.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < 10 then
                -- 到达目标点，重置定时器
                self.status.wanderTimer = 0
            else
                -- 继续移动
                local speedModifier = self:getSpeedModifier(self.x, self.y)
                local moveSpeed = self.attributes.speed * speedModifier * dt
                
                local nx = self.x + (dx / distance) * moveSpeed
                local ny = self.y + (dy / distance) * moveSpeed
                
                if self:canMoveTo(nx, ny) then
                    self.x = nx
                    self.y = ny
                else
                    -- 不能移动到目标点，重新选择
                    self.status.wanderTimer = 0
                end
            end
        end
    end
end

function Player:updateEquipmentBonuses()
    -- 保存旧的最大生命值和当前生命值比例
    local oldMaxHp = self.attributes.maxHp
    local hpRatio = self.attributes.hp / oldMaxHp
    
    -- 重置基础属性
    self.attributes.attack = 15 + (self.attributes.level - 1) * 5
    self.attributes.defense = 5 + (self.attributes.level - 1) * 2
    self.attributes.speed = 80
    self.attributes.maxHp = 100 + (self.attributes.level - 1) * 20
    
    -- 重置装备加成记录
    self.equipmentBonuses = {
        maxHp = 0,
        attack = 0,
        defense = 0,
        speed = 0
    }
    
    -- 应用装备加成
    for slot, item in pairs(self.equipment) do
        if item and item.config and item.config.attributes then
            for stat, value in pairs(item.config.attributes) do
                if self.attributes[stat] then
                    self.attributes[stat] = self.attributes[stat] + value
                    -- 记录装备加成
                    if self.equipmentBonuses[stat] then
                        self.equipmentBonuses[stat] = self.equipmentBonuses[stat] + value
                    end
                end
            end
        end
    end
    
    -- 按照相同比例调整当前生命值
    self.attributes.hp = math.floor(self.attributes.maxHp * hpRatio)
end

function Player:equip(item)
    local slot = nil
    
    -- 确定装备槽
    if item.config.type == ItemSystem.EQUIPMENT_TYPES.WEAPON then
        slot = "weapon"
    elseif item.config.type == ItemSystem.EQUIPMENT_TYPES.ARMOR then
        slot = "armor"
    elseif item.config.type == ItemSystem.EQUIPMENT_TYPES.ACCESSORY then
        slot = "accessory"
    end
    
    if not slot then return nil end
    
    -- 保存当前装备
    local oldEquipment = self.equipment[slot]
    
    -- 装备新物品
    self.equipment[slot] = item
    
    -- 更新属性
    self:updateEquipmentBonuses()
    
    -- 返回旧装备
    return oldEquipment
end

function Player:draw()
    -- 绘制防御区域（不可建造区域）
    love.graphics.setColor(0.8, 0.2, 0.2, 0.15)  -- 淡红色
    love.graphics.circle('fill', self.x, self.y, self.defenseRadius)
    
    -- 绘制防御区域边界
    love.graphics.setColor(0.8, 0.2, 0.2, 0.5)
    love.graphics.circle('line', self.x, self.y, self.defenseRadius)
    
    -- 绘制攻击范围
    love.graphics.setColor(0.2, 0.6, 0.8, 0.1)  -- 淡蓝色
    love.graphics.circle('fill', self.x, self.y, self.attackRadius)
    
    -- 绘制攻击范围边界
    love.graphics.setColor(0.2, 0.6, 0.8, 0.3)
    love.graphics.circle('line', self.x, self.y, self.attackRadius)
    
    -- 绘制玩家
    love.graphics.setColor(0.2, 0.6, 1.0)
    love.graphics.circle('fill', self.x, self.y, self.size)
    
    -- 绘制边框
    love.graphics.setColor(0.1, 0.3, 0.5)
    love.graphics.circle('line', self.x, self.y, self.size)
    
    -- 绘制生命条
    local hpBarWidth = self.size * 2
    local hpBarHeight = 5
    local hpPercentage = self.attributes.hp / self.attributes.maxHp
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.size - 10, hpBarWidth, hpBarHeight)
    
    love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.size - 10, hpBarWidth * hpPercentage, hpBarHeight)
    
    -- 绘制AI状态指示器
    if self.status.isAIControlled then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.circle('fill', self.x, self.y - self.size - 20, 3)
    end
    
    -- 绘制装备状态
    if self.equipment.weapon then
        love.graphics.setColor(self.equipment.weapon.config.color)
        love.graphics.circle('fill', self.x - 15, self.y - self.size - 20, 3)
    end
    
    if self.equipment.armor then
        love.graphics.setColor(self.equipment.armor.config.color)
        love.graphics.circle('fill', self.x, self.y - self.size - 20, 3)
    end
    
    if self.equipment.accessory then
        love.graphics.setColor(self.equipment.accessory.config.color)
        love.graphics.circle('fill', self.x + 15, self.y - self.size - 20, 3)
    end
    
    -- 如果处于攻击状态，绘制攻击效果
    if self.status.isAttacking then
        love.graphics.setColor(1, 0.7, 0.2, 0.6)
        love.graphics.circle('line', self.x, self.y, self.size * 1.5)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return Player 