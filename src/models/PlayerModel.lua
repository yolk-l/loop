-- 玩家模型
local PlayerModel = {}
PlayerModel.__index = PlayerModel

-- 引入物品系统和地形配置
local TerrainConfig = require('config/terrain')
local TypeDefines = require('config/type_defines')
local ResourceModel = require('src/models/ResourceModel')
local ResourceEffect = require('src/utils/ResourceEffect')

function PlayerModel.new(x, y)
    local self = setmetatable({}, PlayerModel)
    self.x = x
    self.y = y
    self.baseSpeed = 80  -- 基础移动速度
    self.size = 10       -- 玩家大小，从20减小到10
    self.map = nil       -- 地图引用
    self.bullets = {}    -- 玩家发射的子弹数组
    
    -- 防御区域设置
    self.defenseRadius = 150   -- 防御区域半径，不可建造建筑
    self.attackRadius = 100    -- 攻击范围半径，自动攻击该范围内的怪物
    
    -- 属性系统（包含暴击相关属性）
    self.attributes = {
        maxHp = 100,       -- 最大生命值
        hp = 100,          -- 当前生命值
        attack = 15,       -- 攻击力
        defense = 5,       -- 防御力
        level = 1,         -- 等级
        exp = 0,           -- 经验值
        nextLevelExp = 100,  -- 升级所需经验
        speed = 80,        -- 移动速度
        attackCooldown = 0.5,  -- 攻击冷却时间（秒）
        lastAttackTime = 0,    -- 上次攻击时间
        bulletSpeed = 300,     -- 子弹速度
        critRate = 5,      -- 暴击率（百分比）
        critDamage = 50,   -- 暴击伤害（百分比）
        accuracy = 0,      -- 命中率（百分比）
        resistance = 0     -- 抵抗率（百分比）
    }
    -- 状态系统
    self.status = {
        isAttacking = false,  -- 是否在攻击中
        attackCooldown = 0,   -- 攻击冷却
        attackRange = 200,    -- 攻击范围
        lastAttackTime = 0,   -- 上次攻击时间
        attackStartTime = 0,  -- 攻击开始时间
        isAIControlled = false, -- 是否由AI控制
        targetMonster = nil,   -- 目标怪物
        wanderTimer = 0,      -- 随机移动计时器
        wanderX = nil,        -- 随机移动目标X
        wanderY = nil,        -- 随机移动目标Y
        detectRange = 150,    -- 检测范围
        isCollecting = false, -- 是否正在采集资源
        collectingType = nil, -- 正在采集的资源类型
        collectTimer = 0      -- 采集计时器
    }
    -- 战斗增强效果
    self.combatEffects = {
        extraTurnChance = 0,   -- 额外回合几率
        stunChance = 0,        -- 眩晕敌人几率
        lifeSteal = 0          -- 生命偷取百分比
    }
    
    -- 资源系统
    self.resourceModel = ResourceModel.new()
    
    -- 地形-资源类型映射
    self.terrainResourceMap = {
        [TerrainConfig.TERRAIN_TYPES.GRASS] = ResourceModel.TYPES.FOOD,
        [TerrainConfig.TERRAIN_TYPES.MOUNTAIN] = ResourceModel.TYPES.WOOD,
        [TerrainConfig.TERRAIN_TYPES.WATER] = ResourceModel.TYPES.FISH,
        [TerrainConfig.TERRAIN_TYPES.SAND] = ResourceModel.TYPES.STONE,
    }
    
    return self
end

function PlayerModel:setMap(map)
    self.map = map
    -- 重新定位玩家到地图中央
    self.x = map.gridWidth * map.tileSize / 2
    self.y = map.gridHeight * map.tileSize / 2
end

function PlayerModel:canMoveTo(newX, newY)
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

function PlayerModel:getSpeedModifier(x, y)
    if not self.map then return 1.0 end
    
    local terrain = self.map:getTerrainAt(x, y)
    if not terrain then return 1.0 end
    
    return TerrainConfig.TERRAIN_SPEED_MODIFIER[terrain] or 1.0
end

function PlayerModel:update(dt)
    -- 更新子弹
    self:updateBullets(dt)
    
    -- 更新资源系统
    self.resourceModel:update(dt)
    
    -- 更新攻击冷却
    if self.attributes.lastAttackTime > 0 then
        local currentTime = love.timer.getTime()
        if currentTime - self.attributes.lastAttackTime > self.attributes.attackCooldown then
            self.attributes.lastAttackTime = 0  -- 冷却完毕
        end
    end
    
    -- 如果在攻击中，检查是否需要结束攻击状态
    if self.status.isAttacking then
        local currentTime = love.timer.getTime()
        if currentTime - self.status.attackStartTime > 0.2 then
            self.status.isAttacking = false  -- 攻击效果结束
        end
    end
    
    -- 如果正在采集资源，更新采集状态
    if self.status.isCollecting then
        self.status.collectTimer = self.status.collectTimer - dt
        if self.status.collectTimer <= 0 then
            self:finishCollecting()
        end
    end
end

function PlayerModel:autoAttack(monsters)
    -- 如果正在冷却中，不进行攻击
    if self.attributes.lastAttackTime > 0 then
        return nil
    end
    
    -- 查找范围内的怪物并攻击
    local closestMonster = nil
    local closestDistance = self.attackRadius
    
    for _, monster in ipairs(monsters) do
        if not monster:isDead() then
            local pos = monster:getPosition()
            local dx = pos.x - self.x
            local dy = pos.y - self.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < closestDistance then
                closestDistance = distance
                closestMonster = monster
            end
        end
    end
    
    -- 如果找到范围内的怪物，进行攻击
    if closestMonster then
        -- 返回攻击结果（子弹信息）
        return self:attack(closestMonster)
    end
    
    return nil  -- 没有找到怪物或无法攻击
end

function PlayerModel:attack(target)
    -- 检查是否在攻击冷却中
    local currentTime = love.timer.getTime()
    if currentTime - self.attributes.lastAttackTime < self.attributes.attackCooldown then
        return false  -- 冷却中，不能攻击
    end
    
    if target then
        -- 获取目标位置
        local pos = target:getPosition()
        local targetX, targetY = pos.x, pos.y
        
        -- 计算玩家到目标的距离
        local dx = targetX - self.x
        local dy = targetY - self.y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        -- 如果目标在攻击范围内
        if distance <= self.status.attackRange then
            -- 将玩家状态设置为攻击中
            self.status.isAttacking = true
            self.status.attackStartTime = currentTime
            self.attributes.lastAttackTime = currentTime  -- 设置上次攻击时间，启动冷却
            
            -- 计算是否暴击
            local isCritical = math.random(100) <= self.attributes.critRate
            local damage = self.attributes.attack
            
            -- 如果暴击，增加伤害
            if isCritical then
                damage = damage * (1 + self.attributes.critDamage / 100)
            end
            
            -- 创建子弹信息
            local bulletInfo = {
                startX = self.x,
                startY = self.y,
                targetX = targetX,
                targetY = targetY,
                speed = self.attributes.bulletSpeed,
                damage = damage,
                source = "player",
                effects = {
                    isCritical = isCritical,
                    stunChance = self.combatEffects.stunChance,
                    lifeSteal = self.combatEffects.lifeSteal
                }
            }
            
            return bulletInfo  -- 返回子弹信息，而不是直接创建子弹
        end
    end
    
    return false  -- 攻击失败
end

function PlayerModel:canBuildAt(x, y)
    -- 计算距离玩家的距离
    local dx = x - self.x
    local dy = y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- 如果在防御区域内，不能建造
    return distance > self.defenseRadius
end

function PlayerModel:gainExp(amount)
    self.attributes.exp = self.attributes.exp + amount
    -- 检查是否可以升级
    while self.attributes.exp >= self.attributes.nextLevelExp do
        self:levelUp()
    end
end

function PlayerModel:levelUp()
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

function PlayerModel:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.attributes.defense)
    self.attributes.hp = math.max(0, self.attributes.hp - actualDamage)
    return actualDamage
end

function PlayerModel:heal(amount)
    self.attributes.hp = math.min(self.attributes.maxHp, self.attributes.hp + amount)
end

function PlayerModel:setAIControl(enabled)
    self.status.isAIControlled = enabled
end

function PlayerModel:findNearestMonster(monsters)
    local nearestMonster = nil
    local minDistance = self.status.detectRange
    
    for _, monster in ipairs(monsters) do
        if not monster:isDead() then
            local pos = monster:getPosition()
            local dx = pos.x - self.x
            local dy = pos.y - self.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < minDistance then
                minDistance = distance
                nearestMonster = monster
            end
        end
    end
    
    return nearestMonster, minDistance
end

function PlayerModel:updateAI(dt, monsters)
    if not self.status.isAIControlled then return end
    
    -- 更新随机移动计时器
    self.status.wanderTimer = self.status.wanderTimer - dt
    
    -- 如果正在采集资源，不执行其他AI行为
    if self.status.isCollecting then
        return false
    end
    
    -- 寻找最近的怪物
    local nearestMonster, monsterDistance = self:findNearestMonster(monsters)
    
    if nearestMonster then
        self.status.targetMonster = nearestMonster
        -- 获取目标位置
        local pos = nearestMonster:getPosition()
        local monsterX, monsterY = pos.x, pos.y
        
        -- 如果在攻击范围内，进行攻击
        if monsterDistance <= self.status.attackRange then
            return self:attack(nearestMonster)  -- 返回攻击结果
        else
            -- 移动向目标怪物
            local dx = monsterX - self.x
            local dy = monsterY - self.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- 计算移动速度，根据地形可能有变化
            local speedModifier = self:getSpeedModifier(self.x, self.y)
            local moveSpeed = self.attributes.speed * speedModifier * dt
            
            -- 计算新位置
            local nx = self.x + (dx / distance) * moveSpeed
            local ny = self.y + (dy / distance) * moveSpeed
            
            if self:canMoveTo(nx, ny) then
                self.x = nx
                self.y = ny
            else
                -- 如果无法直接移动到目标，尝试只在x或y方向移动
                if self:canMoveTo(nx, self.y) then
                    self.x = nx
                elseif self:canMoveTo(self.x, ny) then
                    self.y = ny
                end
            end
        end
    else
        -- 没有怪物时，有几率采集资源
        if math.random() < 0.02 and not self.status.isCollecting then
            self:startCollecting()
            return false
        end
        
        -- 没有目标并且不在采集，随机移动
        if self.status.wanderTimer <= 0 or not self.status.wanderX then
            -- 选择新的随机目标
            if self.map then
                local mapWidth = self.map.gridWidth * self.map.tileSize
                local mapHeight = self.map.gridHeight * self.map.tileSize
                
                local attempts = 0
                local maxAttempts = 10
                local validTarget = false
                
                repeat
                    -- 以当前位置为中心，在一定范围内选择随机目标
                    local wanderRange = 150  -- 游荡范围
                    local randomAngle = math.random() * math.pi * 2  -- 随机角度
                    local randomDist = math.random(50, wanderRange)  -- 随机距离
                    
                    -- 计算新的目标点
                    self.status.wanderX = self.x + math.cos(randomAngle) * randomDist
                    self.status.wanderY = self.y + math.sin(randomAngle) * randomDist
                    
                    -- 确保目标点在地图范围内
                    self.status.wanderX = math.max(50, math.min(mapWidth - 50, self.status.wanderX))
                    self.status.wanderY = math.max(50, math.min(mapHeight - 50, self.status.wanderY))
                    
                    validTarget = self:canMoveTo(self.status.wanderX, self.status.wanderY)
                    attempts = attempts + 1
                until validTarget or attempts >= maxAttempts
                
                -- 设置游荡时间（2-4秒）
                self.status.wanderTimer = math.random(2, 4)
            end
        end
        
        -- 向随机目标移动
        if self.status.wanderX and self.status.wanderY then
            local dx = self.status.wanderX - self.x
            local dy = self.status.wanderY - self.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < 10 then
                -- 到达目标点，开始采集资源
                self:startCollecting()
                -- 重置定时器以选择新目标
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
                    -- 如果无法直接移动到目标，尝试只在x或y方向移动
                    if self:canMoveTo(nx, self.y) then
                        self.x = nx
                    elseif self:canMoveTo(self.x, ny) then
                        self.y = ny
                    else
                        -- 完全无法移动，重新选择目标
                        self.status.wanderTimer = 0
                    end
                end
            end
        end
    end
    
    return false  -- 没有进行攻击
end

-- 添加子弹
function PlayerModel:addBullet(bullet)
    table.insert(self.bullets, bullet)
end

-- 更新所有子弹
function PlayerModel:updateBullets(dt)
    for i = #self.bullets, 1, -1 do
        self.bullets[i]:update(dt)
        if not self.bullets[i]:isActive() then
            table.remove(self.bullets, i)
        end
    end
end

-- 获取所有子弹
function PlayerModel:getBullets()
    return self.bullets
end

-- 获取位置信息
function PlayerModel:getPosition()
    return {x = self.x, y = self.y}
end

-- 获取玩家大小
function PlayerModel:getSize()
    return self.size
end

-- 获取玩家等级
function PlayerModel:getLevel()
    return self.attributes.level
end

-- 设置位置
function PlayerModel:setPosition(x, y)
    self.x = x
    self.y = y
end

-- 移动玩家
function PlayerModel:move(dx, dy, dt)
    local newX = self.x + dx * self.attributes.speed * dt
    local newY = self.y + dy * self.attributes.speed * dt
    
    if self:canMoveTo(newX, newY) then
        self.x = newX
        self.y = newY
        
        -- 调试输出：检查是否靠近水域
        if self.map and self.map:isNearWater(self.x, self.y) then
            print("玩家靠近水域，可以钓鱼")
        end
        
        return true
    end
    
    return false
end

-- 获取当前地形类型
function PlayerModel:getCurrentTerrainType()
    if not self.map then return nil end
    return self.map:getTerrainAt(self.x, self.y)
end

-- 开始采集资源
function PlayerModel:startCollecting()
    if self.status.isCollecting then return false end
    
    -- 获取当前地形类型
    local terrainType = self:getCurrentTerrainType()
    if not terrainType then return false end
    
    -- 获取对应的资源类型
    local resourceType = self.terrainResourceMap[terrainType]
    
    -- 特殊情况：钓鱼时检查是否靠近水域
    if not resourceType and terrainType ~= TerrainConfig.TERRAIN_TYPES.WATER and self.map:isNearWater(self.x, self.y) then
        resourceType = ResourceModel.TYPES.FISH
    end
    
    if not resourceType then return false end
    
    -- 检查资源冷却时间
    if self.resourceModel:getCollectCooldown(resourceType) > 0 then
        return false
    end
    
    -- 开始采集
    self.status.isCollecting = true
    self.status.collectingType = resourceType
    self.status.collectTimer = 1.0  -- 采集时间
    
    return true
end

-- 完成资源采集
function PlayerModel:finishCollecting()
    if not self.status.isCollecting then return end
    
    local resourceType = self.status.collectingType
    if not resourceType then
        self.status.isCollecting = false
        return
    end
    
    -- 收集资源
    if self.resourceModel:collect(resourceType) then
        -- 创建资源采集效果
        ResourceEffect.create(self.x, self.y, resourceType, 1)
    end
    
    -- 重置采集状态
    self.status.isCollecting = false
    self.status.collectingType = nil
end

-- 获取资源模型
function PlayerModel:getResourceModel()
    return self.resourceModel
end

return PlayerModel
 