-- 玩家模型
local PlayerModel = {}
PlayerModel.__index = PlayerModel

-- 引入物品系统和地形配置
local ItemSystem = require('src/systems/Item')
local TerrainConfig = require('config/terrain')

function PlayerModel:new(x, y)
    local self = setmetatable({}, PlayerModel)
    self.x = x
    self.y = y
    self.baseSpeed = 80  -- 基础移动速度
    self.size = 10       -- 玩家大小
    self.map = nil       -- 地图引用
    self.bullets = {}    -- 玩家发射的子弹数组
    
    -- 防御区域设置
    self.defenseRadius = 150   -- 防御区域半径，不可建造建筑
    self.attackRadius = 100    -- 攻击范围半径，自动攻击该范围内的怪物
    
    -- 属性系统
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
    
    -- 符文系统
    self.runes = {
        [1] = nil,  -- 位置1 (右上)
        [2] = nil,  -- 位置2 (右中)
        [3] = nil,  -- 位置3 (右下)
        [4] = nil,  -- 位置4 (左上)
        [5] = nil,  -- 位置5 (左中)
        [6] = nil   -- 位置6 (左下)
    }
    
    -- 激活的套装效果
    self.activeRuneSets = {}
    
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
        detectRange = 150     -- 检测范围
    }
    
    -- 符文属性加成记录
    self.runeBonuses = {
        maxHp = {flat = 0, percent = 0},
        attack = {flat = 0, percent = 0},
        defense = {flat = 0, percent = 0},
        speed = {flat = 0, percent = 0},
        critRate = 0,
        critDamage = 0,
        accuracy = 0,
        resistance = 0
    }
    
    -- 战斗增强效果
    self.combatEffects = {
        extraTurnChance = 0,   -- 额外回合几率
        stunChance = 0,        -- 眩晕敌人几率
        lifeSteal = 0          -- 生命偷取百分比
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
end

function PlayerModel:autoAttack(monsters)
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

function PlayerModel:attack(target)
    -- 检查是否在攻击冷却中
    local currentTime = love.timer.getTime()
    if currentTime - self.attributes.lastAttackTime < self.attributes.attackCooldown then
        return false  -- 冷却中，不能攻击
    end
    
    if target then
        -- 计算玩家到目标的距离
        local dx = target.x - self.x
        local dy = target.y - self.y
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
                targetX = target.x,
                targetY = target.y,
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

function PlayerModel:updateAI(dt, monsters)
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
            return self:attack(nearestMonster)  -- 返回攻击结果
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
    
    return false  -- 没有进行攻击
end

function PlayerModel:updateRuneBonuses()
    -- 保存旧的最大生命值和当前生命值比例
    local oldMaxHp = self.attributes.maxHp
    local hpRatio = self.attributes.hp / oldMaxHp
    
    -- 重置基础属性
    self.attributes.attack = 15 + (self.attributes.level - 1) * 5
    self.attributes.defense = 5 + (self.attributes.level - 1) * 2
    self.attributes.speed = 80
    self.attributes.maxHp = 100 + (self.attributes.level - 1) * 20
    self.attributes.critRate = 5
    self.attributes.critDamage = 50
    self.attributes.accuracy = 0
    self.attributes.resistance = 0
    
    -- 重置符文加成记录
    self.runeBonuses = {
        maxHp = {flat = 0, percent = 0},
        attack = {flat = 0, percent = 0},
        defense = {flat = 0, percent = 0},
        speed = {flat = 0, percent = 0},
        critRate = 0,
        critDamage = 0,
        accuracy = 0,
        resistance = 0
    }
    
    -- 重置战斗效果
    self.combatEffects = {
        extraTurnChance = 0,
        stunChance = 0,
        lifeSteal = 0
    }
    
    -- 重置激活的套装效果
    self.activeRuneSets = {}
    
    -- 应用符文主属性和次属性加成
    for position, rune in pairs(self.runes) do
        if rune then
            -- 应用主属性
            self:applyRuneStat(rune.primaryStat)
            
            -- 应用次属性
            for _, stat in ipairs(rune.subStats) do
                self:applyRuneStat(stat)
            end
        end
    end
    
    -- 计算激活的套装效果
    local setCounts = self:countRuneSetTypes()
    local ItemConfig = require('config/items')
    
    for setType, count in pairs(setCounts) do
        local setEffect = ItemConfig.RUNE_SET_EFFECTS[setType]
        if setEffect and count >= setEffect.count then
            -- 激活套装效果
            table.insert(self.activeRuneSets, {
                name = setEffect.name,
                effect = setEffect.effect,
                count = count
            })
            
            -- 应用套装效果
            self:applySetEffect(setEffect.effect)
        end
    end
    
    -- 计算百分比加成（在应用所有固定值后）
    if self.runeBonuses.maxHp.percent > 0 then
        self.attributes.maxHp = math.floor(self.attributes.maxHp * (1 + self.runeBonuses.maxHp.percent/100))
    end
    if self.runeBonuses.attack.percent > 0 then
        self.attributes.attack = math.floor(self.attributes.attack * (1 + self.runeBonuses.attack.percent/100))
    end
    if self.runeBonuses.defense.percent > 0 then
        self.attributes.defense = math.floor(self.attributes.defense * (1 + self.runeBonuses.defense.percent/100))
    end
    if self.runeBonuses.speed.percent > 0 then
        self.attributes.speed = math.floor(self.attributes.speed * (1 + self.runeBonuses.speed.percent/100))
    end
    
    -- 按照相同比例调整当前生命值
    self.attributes.hp = math.floor(self.attributes.maxHp * hpRatio)
end

function PlayerModel:applyRuneStat(stat)
    local ItemConfig = require('config/items')
    
    if stat.type == ItemConfig.RUNE_PRIMARY_STATS.HP_FLAT then
        self.attributes.maxHp = self.attributes.maxHp + stat.value
        self.runeBonuses.maxHp.flat = self.runeBonuses.maxHp.flat + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.HP_PERCENT then
        self.runeBonuses.maxHp.percent = self.runeBonuses.maxHp.percent + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.ATK_FLAT then
        self.attributes.attack = self.attributes.attack + stat.value
        self.runeBonuses.attack.flat = self.runeBonuses.attack.flat + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.ATK_PERCENT then
        self.runeBonuses.attack.percent = self.runeBonuses.attack.percent + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.DEF_FLAT then
        self.attributes.defense = self.attributes.defense + stat.value
        self.runeBonuses.defense.flat = self.runeBonuses.defense.flat + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.DEF_PERCENT then
        self.runeBonuses.defense.percent = self.runeBonuses.defense.percent + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.SPEED_FLAT then
        self.attributes.speed = self.attributes.speed + stat.value
        self.runeBonuses.speed.flat = self.runeBonuses.speed.flat + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.CRIT_RATE then
        self.attributes.critRate = self.attributes.critRate + stat.value
        self.runeBonuses.critRate = self.runeBonuses.critRate + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.CRIT_DMG then
        self.attributes.critDamage = self.attributes.critDamage + stat.value
        self.runeBonuses.critDamage = self.runeBonuses.critDamage + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.ACCURACY then
        self.attributes.accuracy = self.attributes.accuracy + stat.value
        self.runeBonuses.accuracy = self.runeBonuses.accuracy + stat.value
    elseif stat.type == ItemConfig.RUNE_PRIMARY_STATS.RESISTANCE then
        self.attributes.resistance = self.attributes.resistance + stat.value
        self.runeBonuses.resistance = self.runeBonuses.resistance + stat.value
    end
end

function PlayerModel:applySetEffect(effect)
    if effect.type == "atk_percent" then
        self.runeBonuses.attack.percent = self.runeBonuses.attack.percent + effect.value
    elseif effect.type == "crit_rate" then
        self.attributes.critRate = self.attributes.critRate + effect.value
        self.runeBonuses.critRate = self.runeBonuses.critRate + effect.value
    elseif effect.type == "speed" then
        self.runeBonuses.speed.percent = self.runeBonuses.speed.percent + effect.value
    elseif effect.type == "accuracy" then
        self.attributes.accuracy = self.attributes.accuracy + effect.value
        self.runeBonuses.accuracy = self.runeBonuses.accuracy + effect.value
    elseif effect.type == "def_percent" then
        self.runeBonuses.defense.percent = self.runeBonuses.defense.percent + effect.value
    elseif effect.type == "resistance" then
        self.attributes.resistance = self.attributes.resistance + effect.value
        self.runeBonuses.resistance = self.runeBonuses.resistance + effect.value
    elseif effect.type == "extra_turn" then
        self.combatEffects.extraTurnChance = self.combatEffects.extraTurnChance + effect.value
    elseif effect.type == "crit_dmg" then
        self.attributes.critDamage = self.attributes.critDamage + effect.value
        self.runeBonuses.critDamage = self.runeBonuses.critDamage + effect.value
    elseif effect.type == "stun_chance" then
        self.combatEffects.stunChance = self.combatEffects.stunChance + effect.value
    elseif effect.type == "lifesteal" then
        self.combatEffects.lifeSteal = self.combatEffects.lifeSteal + effect.value
    elseif effect.type == "all_stats" then
        -- 所有属性百分比增加
        self.runeBonuses.maxHp.percent = self.runeBonuses.maxHp.percent + effect.value
        self.runeBonuses.attack.percent = self.runeBonuses.attack.percent + effect.value
        self.runeBonuses.defense.percent = self.runeBonuses.defense.percent + effect.value
        self.runeBonuses.speed.percent = self.runeBonuses.speed.percent + effect.value
        self.attributes.critRate = self.attributes.critRate + effect.value
        self.runeBonuses.critRate = self.runeBonuses.critRate + effect.value
        self.attributes.critDamage = self.attributes.critDamage + effect.value * 2  -- 暴击伤害加倍收益
        self.runeBonuses.critDamage = self.runeBonuses.critDamage + effect.value * 2
    end
end

-- 以下是符文系统相关方法

-- 装备符文
function PlayerModel:equipRune(rune, position)
    -- 检查符文是否能装备到指定位置
    if position and position ~= rune.position then
        -- 只能装备到符文对应的位置
        return nil
    end
    
    -- 使用符文自带的位置
    position = rune.position
    
    -- 保存当前装备
    local oldRune = self.runes[position]
    
    -- 装备新符文
    self.runes[position] = rune
    
    -- 更新符文属性加成
    self:updateRuneBonuses()
    
    -- 返回旧符文
    return oldRune
end

-- 卸下符文
function PlayerModel:unequipRune(position)
    if not self.runes[position] then
        return nil
    end
    
    local rune = self.runes[position]
    self.runes[position] = nil
    
    -- 更新符文属性加成
    self:updateRuneBonuses()
    
    return rune
end

-- 获取装备符文数量
function PlayerModel:getEquippedRuneCount()
    local count = 0
    for i = 1, 6 do
        if self.runes[i] then
            count = count + 1
        end
    end
    return count
end

-- 计算套装激活数量
function PlayerModel:countRuneSetTypes()
    local setCounts = {}
    
    -- 计算每种套装类型的数量
    for i = 1, 6 do
        if self.runes[i] and self.runes[i].setType then
            local setType = self.runes[i].setType
            setCounts[setType] = (setCounts[setType] or 0) + 1
        end
    end
    
    return setCounts
end

-- 添加子弹
function PlayerModel:addBullet(bullet)
    table.insert(self.bullets, bullet)
end

-- 更新所有子弹
function PlayerModel:updateBullets(dt)
    for i = #self.bullets, 1, -1 do
        self.bullets[i]:update(dt)
        if not self.bullets[i].status.isActive then
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
        return true
    end
    
    return false
end

return PlayerModel
 