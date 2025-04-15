-- 战斗管理器
local CombatManager = {}
CombatManager.__index = CombatManager

local ItemSystem = require('src/utils/Item')
local ItemConfig = require('config/items')

-- 游戏状态变量
CombatManager.gameOver = false
CombatManager.gameOverTime = 0

function CombatManager:handleMonsterDeath(monster, player, inventoryController, cardController)
    local monsterModel = monster:getModel()
    -- 生成掉落物
    local drops = ItemSystem.generateDrops(monsterModel:getType(), monsterModel:getPosition().x, monsterModel:getPosition().y)
    for _, drop in ipairs(drops) do
        if drop.isCard then
            -- 根据玩家等级检查是否可以获得该卡牌
            local cardType = drop.buildingCardType
            local playerModel = player:getModel()
            local playerLevel = playerModel:getLevel()

            if playerLevel >= ItemConfig.CARD_LEVEL_REQUIREMENTS[monsterModel:getTier()] then
                cardController:addCard(cardType)
            end
        else
            -- 添加装备掉落物
            if not inventoryController:addItem(drop) then
                -- 如果背包已满，将物品放在地上
                table.insert(items, drop)
            end
        end
    end
    
    -- 给玩家经验值
    local expValue = monsterModel:getExpValue() or monsterModel:getConfig().expValue
    player:gainExp(expValue)
end

function CombatManager:handlePlayerDeath(player)
    local playerModel = player:getModel()
    if playerModel.attributes.hp <= 0 then
        -- 玩家已死亡，游戏结束
        if not CombatManager.gameOver then
            CombatManager.gameOver = true
            CombatManager.gameOverTime = love.timer.getTime()
        end
        return true  -- 表示游戏结束
    end
    return false
end

-- 获取游戏是否结束
function CombatManager:isGameOver()
    return CombatManager.gameOver
end

-- 重置游戏状态
function CombatManager:resetGameState()
    CombatManager.gameOver = false
    CombatManager.gameOverTime = 0
end

-- 集中处理怪物死亡和移除
function CombatManager:processDeadMonsters(monsterManager, player, inventoryController, cardController)
    -- 处理怪物死亡和掉落
    local monsters = monsterManager:getInstances()
    for i = #monsters, 1, -1 do
        local monster = monsters[i]
        
        -- 如果怪物已死亡但未被移除
        if monster:isDead() then
            self:handleMonsterDeath(monster, player, inventoryController, cardController)
        end
    end
    
    -- 移除已死亡的怪物
    monsterManager:removeDeadMonsters()
end

function CombatManager:handleBulletCollisions(player, monsterManager)
    local playerBullets = player:getBullets()
    local monsterBullets = monsterManager:getBullets()
    local monsters = monsterManager:getInstances()
    
    -- 检查玩家子弹与怪物的碰撞
    for i = #playerBullets, 1, -1 do
        local bullet = playerBullets[i]
        for _, monster in ipairs(monsters) do
            if not monster:isDead() and bullet.checkCollision then
                local monsterPos = monster:getPosition()
                local monsterEntity = {
                    x = monsterPos.x, 
                    y = monsterPos.y, 
                    size = monster:getModel():getSize()
                }
                
                if bullet:checkCollision(monsterEntity) then
                    monster:takeDamage(bullet:getDamage())
                    
                    -- 如果使用BulletController，使用其方法
                    if bullet.deactivate then
                        bullet:deactivate()
                    else
                        -- 兼容旧版本，尝试直接调用deactivate方法
                        bullet:deactivate()
                    end
                    break
                end
            end
        end
    end
    
    -- 检查怪物子弹与玩家的碰撞
    for i = #monsterBullets, 1, -1 do
        local bullet = monsterBullets[i]
        local playerPos = player:getPosition()
        local entity = {x = playerPos.x, y = playerPos.y, size = player:getModel():getSize()}
        if bullet:checkCollision(entity) then
            player:takeDamage(bullet:getDamage())
            bullet:deactivate()
        end
    end
end

-- 集中处理怪物攻击
function CombatManager:handleMonsterAttacks(monsterManager, player)
    -- 遍历所有怪物
    local monsters = monsterManager:getInstances()
    for _, monster in ipairs(monsters) do
        -- 获取怪物模型
        local monsterModel = monster:getModel()
        
        -- 检查是否有目标且在攻击范围内
        if monsterModel.target and not monsterModel.status.isDead then
            -- 计算与目标的距离
            local targetX, targetY
            if monsterModel.target.getPosition then
                local pos = monsterModel.target:getPosition()
                targetX, targetY = pos.x, pos.y
            else
                targetX, targetY = monsterModel.target.x, monsterModel.target.y
            end
            
            local dx = targetX - monsterModel.x
            local dy = targetY - monsterModel.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- 在攻击范围内且冷却时间已过
            if distance <= monsterModel.attributes.attackRange and monsterModel.attributes.lastAttackTime == 0 then
                -- 调用怪物的攻击方法
                local attackResult = monsterModel:attack(monsterModel.target)
                
                -- 处理攻击结果
                if attackResult then
                    if attackResult.type == "ranged" then
                        -- 创建子弹并添加到管理器
                        local bullet = monster:createBullet(attackResult.bulletInfo)
                        monsterManager:addBullet(bullet)
                    elseif attackResult.type == "melee" and attackResult.source and attackResult.source.target then
                        -- 处理近战攻击
                        local target = attackResult.source.target
                        
                        -- 目标可能是PlayerController或者PlayerModel，需要适配
                        if target.takeDamage then
                            -- 直接调用目标的takeDamage方法
                            target:takeDamage(attackResult.damage)
                        elseif target.model and target.model.takeDamage then
                            -- 调用目标模型的takeDamage方法
                            target.model:takeDamage(attackResult.damage)
                        end
                    end
                end
            end
        end
    end
end

return CombatManager 