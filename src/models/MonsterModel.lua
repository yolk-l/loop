-- 怪物模型
local MonsterModel = {}
MonsterModel.__index = MonsterModel

-- 引入怪物配置
local MonsterConfig = require('config/monsters')
local TerrainConfig = require('config/terrain')

-- 全局ID计数器
local nextMonsterId = 1

function MonsterModel:new(type, x, y)
    local mt = setmetatable({}, MonsterModel)
    
    -- 设置唯一ID
    mt.id = nextMonsterId
    nextMonsterId = nextMonsterId + 1
    
    mt.type = type
    mt.x = x
    mt.y = y
    
    -- 获取怪物配置
    mt.config = MonsterConfig.MONSTER_CONFIG[type] or MonsterConfig.MONSTER_CONFIG.slime
    
    -- 怪物属性
    mt.attributes = {
        maxHp = mt.config.hp or 100,
        hp = mt.config.hp or 100,
        attack = mt.config.attack or 10,
        defense = mt.config.defense or 5,
        speed = mt.config.speed or 40,
        attackRange = mt.config.attackRange or 50,
        detectRange = mt.config.detectRange or 200,
        attackCooldown = mt.config.attackCooldown or 1.5,
        lastAttackTime = 0
    }
    
    -- 怪物状态
    mt.status = {
        isDead = false,
        isMoving = false,
        isAttacking = false,
        attackStartTime = 0,
        direction = "right",
        stunned = false,
        stunnedTime = 0
    }
    
    -- 目标
    mt.target = nil
    
    -- 子弹数组
    mt.bullets = {}
    
    -- 怪物大小
    mt.size = mt.config.size or 15
    
    -- 路径和AI相关
    mt.ai = {
        path = {},
        pathIndex = 1,
        wanderTimer = 0,
        wanderX = nil,
        wanderY = nil,
        state = "idle", -- idle, chase, attack, wander
        lastSeenTarget = nil,
        lastSeenTime = 0
    }
    
    -- 其他属性
    mt.loot = mt.config.loot or {}
    mt.expValue = mt.config.expValue or 10
    
    -- 所属建筑引用
    mt.homeBuilding = nil

    return mt
end

function MonsterModel:update(dt, map)
    -- 如果已死亡，不更新
    if self.status.isDead then
        return
    end
    
    -- 更新眩晕状态
    if self.status.stunned then
        self.status.stunnedTime = self.status.stunnedTime - dt
        if self.status.stunnedTime <= 0 then
            self.status.stunned = false
        end
        return -- 眩晕时不执行其他动作
    end
    
    -- 更新攻击冷却
    if self.attributes.lastAttackTime > 0 then
        local currentTime = love.timer.getTime()
        if currentTime - self.attributes.lastAttackTime >= self.attributes.attackCooldown then
            self.attributes.lastAttackTime = 0
        end
    end
    
    -- 更新攻击状态
    if self.status.isAttacking then
        local currentTime = love.timer.getTime()
        if currentTime - self.status.attackStartTime > 0.3 then
            self.status.isAttacking = false
        end
    end
    
    -- 如果有目标，更新AI行为
    if self.target then
        self:updateAI(dt, map)
    else
        -- 没有目标时，随机移动
        self:wander(dt, map)
    end
end

function MonsterModel:setTarget(target)
    if target then
        -- 直接保存目标引用，无论是控制器还是普通对象
        self.target = target
    else
        self.target = nil
    end
end

function MonsterModel:canMoveTo(x, y, map)
    if not map then return true end
    
    -- 检查是否超出地图边界
    if x < 0 or y < 0 or x >= map.gridWidth * map.tileSize or y >= map.gridHeight * map.tileSize then
        return false
    end
    
    -- 检查地形是否可通过
    local terrain = map:getTerrainAt(x, y)
    if not terrain then return false end
    
    -- 水面不能通过
    if terrain == TerrainConfig.TERRAIN_TYPES.WATER then
        return false
    end
    
    return true
end

function MonsterModel:getSpeedModifier(x, y, map)
    if not map then return 1.0 end
    
    local terrain = map:getTerrainAt(x, y)
    if not terrain then return 1.0 end
    
    return TerrainConfig.TERRAIN_SPEED_MODIFIER[terrain] or 1.0
end

function MonsterModel:updateAI(dt, map)
    if not self.target then return end
    
    -- 获取目标当前位置
    local targetX, targetY
    if self.target.getPosition then
        local pos = self.target:getPosition()
        targetX, targetY = pos.x, pos.y
    else
        targetX, targetY = self.target.x, self.target.y
    end
    
    -- 计算与目标的距离
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- 设置移动方向
    if math.abs(dx) > math.abs(dy) then
        self.status.direction = dx > 0 and "right" or "left"
    else
        self.status.direction = dy > 0 and "down" or "up"
    end
    
    -- 增加检测范围，使怪物更容易发现玩家
    local expandedDetectRange = self.attributes.detectRange * 1.5
    
    -- 计算理想的攻击距离 - 让怪物保持在这个位置
    local idealDistance = self.attributes.attackRange * 0.8
    
    -- 在攻击范围内则攻击
    if distance <= self.attributes.attackRange then
        self.ai.state = "attack"
        local attackResult = self:attack(self.target)
        
        -- 如果在理想攻击距离之内，停止接近玩家
        if distance <= idealDistance then
            -- 设置为不移动状态，让怪物停止靠近
            self.status.isMoving = false
        end
        
        if attackResult then
            -- 攻击成功，返回
            return attackResult
        end
        -- 否则，继续追逐
    end
    
    -- 追逐目标
    -- 扩大检测范围，增强怪物的追踪能力
    if distance <= expandedDetectRange then
        self.ai.state = "chase"
        self.ai.lastSeenTarget = {x = targetX, y = targetY}
        self.ai.lastSeenTime = love.timer.getTime()
        
        -- 只有当距离大于理想攻击距离时才移动
        if distance > idealDistance then
            self.status.isMoving = true
            
            -- 提高追踪速度，但设置上限
            local moveSpeed = self.attributes.speed * dt
            -- 当距离较远时稍微提高移动速度以加快追踪
            if distance > self.attributes.attackRange * 3 then
                moveSpeed = moveSpeed * 1.2
            end
            
            local speedModifier = self:getSpeedModifier(self.x, self.y, map)
            moveSpeed = moveSpeed * speedModifier
            
            -- 计算新位置
            local moveDistRatio = moveSpeed / distance
            local newX = self.x + dx * moveDistRatio
            local newY = self.y + dy * moveDistRatio
            
            -- 检查能否移动到新位置
            if self:canMoveTo(newX, newY, map) then
                self.x = newX
                self.y = newY
            else
                -- 尝试智能避障 - 先尝试只在X方向移动
                if self:canMoveTo(newX, self.y, map) then
                    self.x = newX
                -- 然后尝试只在Y方向移动
                elseif self:canMoveTo(self.x, newY, map) then
                    self.y = newY
                -- 如果两个方向都无法移动，尝试对角线移动
                else
                    -- 对角线方向1
                    local diagX1 = self.x + dx * moveDistRatio * 0.7
                    local diagY1 = self.y - dy * moveDistRatio * 0.7
                    if self:canMoveTo(diagX1, diagY1, map) then
                        self.x = diagX1
                        self.y = diagY1
                    -- 对角线方向2
                    else
                        local diagX2 = self.x - dx * moveDistRatio * 0.7
                        local diagY2 = self.y + dy * moveDistRatio * 0.7
                        if self:canMoveTo(diagX2, diagY2, map) then
                            self.x = diagX2
                            self.y = diagY2
                        end
                    end
                end
            end
        else
            -- 已经在理想攻击距离内，停止移动
            self.status.isMoving = false
        end
    else
        -- 超出检测范围但之前看到过目标，朝最后看到的位置移动
        if self.ai.lastSeenTarget and (love.timer.getTime() - self.ai.lastSeenTime) < 5 then
            self.ai.state = "chase"
            self.status.isMoving = true
            
            -- 向最后看到的位置移动
            local lastDx = self.ai.lastSeenTarget.x - self.x
            local lastDy = self.ai.lastSeenTarget.y - self.y
            local lastDistance = math.sqrt(lastDx * lastDx + lastDy * lastDy)
            
            if lastDistance > 10 then
                local moveSpeed = self.attributes.speed * dt * 0.8
                local speedModifier = self:getSpeedModifier(self.x, self.y, map)
                moveSpeed = moveSpeed * speedModifier
                
                local moveDistRatio = moveSpeed / lastDistance
                local newX = self.x + lastDx * moveDistRatio
                local newY = self.y + lastDy * moveDistRatio
                
                if self:canMoveTo(newX, newY, map) then
                    self.x = newX
                    self.y = newY
                end
            else
                -- 到达最后看到的位置，重置记忆
                self.ai.lastSeenTarget = nil
                self.ai.state = "wander"
            end
        else
            -- 完全没有目标线索，返回徘徊状态
            self.ai.state = "wander"
            self:wander(dt, map)
        end
    end
end

function MonsterModel:wander(dt, map)
    -- 更新徘徊计时器
    if self.ai.wanderTimer > 0 then
        self.ai.wanderTimer = self.ai.wanderTimer - dt
    end
    
    -- 如果没有目标点或计时器到期，选择新的徘徊目标
    if self.ai.wanderTimer <= 0 or not self.ai.wanderX then
        -- 随机选择新目标点
        local wanderRange = 100
        local attempts = 0
        local maxAttempts = 10
        local validTarget = false
        
        repeat
            local angle = math.random() * math.pi * 2
            local distance = math.random(wanderRange / 2, wanderRange)
            self.ai.wanderX = self.x + math.cos(angle) * distance
            self.ai.wanderY = self.y + math.sin(angle) * distance
            
            validTarget = self:canMoveTo(self.ai.wanderX, self.ai.wanderY, map)
            attempts = attempts + 1
        until validTarget or attempts >= maxAttempts
        
        -- 如果找不到有效目标，就保持原地
        if not validTarget then
            self.ai.wanderX = self.x
            self.ai.wanderY = self.y
        end
        
        -- 设置徘徊时间
        self.ai.wanderTimer = math.random(2, 5)
        self.status.isMoving = true
    end
    
    -- 向徘徊目标移动
    if self.ai.wanderX and self.ai.wanderY then
        local dx = self.ai.wanderX - self.x
        local dy = self.ai.wanderY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        -- 设置移动方向
        if math.abs(dx) > math.abs(dy) then
            self.status.direction = dx > 0 and "right" or "left"
        else
            self.status.direction = dy > 0 and "down" or "up"
        end
        
        -- 如果达到目标点附近，停止移动
        if distance < 10 then
            self.status.isMoving = false
            self.ai.wanderTimer = 0
        else
            -- 继续移动
            local moveSpeed = self.attributes.speed * 0.5 * dt  -- 徘徊时速度减半
            local speedModifier = self:getSpeedModifier(self.x, self.y, map)
            moveSpeed = moveSpeed * speedModifier
            
            -- 计算新位置
            local moveDistRatio = moveSpeed / distance
            local newX = self.x + dx * moveDistRatio
            local newY = self.y + dy * moveDistRatio
            
            -- 检查能否移动到新位置
            if self:canMoveTo(newX, newY, map) then
                self.x = newX
                self.y = newY
            else
                -- 不能到达，重置徘徊目标
                self.ai.wanderTimer = 0
            end
        end
    end
end

function MonsterModel:attack(target)
    -- 如果在冷却中，不能攻击
    if self.attributes.lastAttackTime > 0 then
        return false
    end
    
    -- 获取目标位置
    local targetX, targetY
    if target.getPosition then
        local pos = target:getPosition()
        targetX, targetY = pos.x, pos.y
    else
        targetX, targetY = target.x, target.y
    end
    
    -- 检查目标是否在攻击范围内
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance > self.attributes.attackRange then
        return false  -- 目标超出攻击范围
    end
    
    -- 设置攻击状态
    self.status.isAttacking = true
    self.status.attackStartTime = love.timer.getTime()
    self.attributes.lastAttackTime = self.status.attackStartTime
    
    -- 根据怪物类型选择不同的攻击方式
    if self.config.attackType == "melee" then
        -- 近战攻击：直接造成伤害，返回伤害信息
        return {
            type = "melee",
            damage = self.attributes.attack,
            source = {
                target = target  -- 保存目标引用
            }
        }
    else
        -- 远程攻击：创建子弹，返回子弹信息
        return {
            type = "ranged",
            bulletInfo = {
                startX = self.x,
                startY = self.y,
                targetX = targetX,
                targetY = targetY,
                speed = 150,
                damage = self.attributes.attack,
                source = "monster"
            }
        }
    end
end

function MonsterModel:takeDamage(damage)
    -- 计算实际伤害，考虑防御
    local actualDamage = math.max(1, damage - self.attributes.defense)
    
    -- 减少生命值
    self.attributes.hp = math.max(0, self.attributes.hp - actualDamage)
    
    -- 检查是否死亡
    if self.attributes.hp <= 0 then
        self:onDeath()
    end
    
    return actualDamage
end

function MonsterModel:stun(duration)
    self.status.stunned = true
    self.status.stunnedTime = duration
end

function MonsterModel:heal(amount)
    -- 回复生命值，不超过最大值
    self.attributes.hp = math.min(self.attributes.maxHp, self.attributes.hp + amount)
end

function MonsterModel:getHomeBuilding()
    return self.homeBuilding
end

function MonsterModel:setHomeBuilding(building)
    self.homeBuilding = building
end

-- 清除所属建筑的引用
function MonsterModel:clearHomeBuilding()
    if self.homeBuilding then
        -- 通知建筑移除自己
        self.homeBuilding:removeMonster(self.id)
        self.homeBuilding = nil
    end
end

-- 在死亡时清理关联
function MonsterModel:onDeath()
    -- 清理建筑关联
    self:clearHomeBuilding()
    self.status.isDead = true
end

-- 获取唯一ID
function MonsterModel:getId()
    return self.id
end

-- 重置全局ID计数器（用于游戏重置）
function MonsterModel.resetIdCounter()
    nextMonsterId = 1
end

return MonsterModel 