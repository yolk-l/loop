-- 战斗管理器
local CombatManager = {}
CombatManager.__index = CombatManager

local ItemSystem = require('src/utils/Item')

function CombatManager:handleMonsterDeath(monster, player, inventoryController, cardController)
    local monsterModel = monster:getModel()
    
    -- 生成掉落物
    local drops = ItemSystem.Item.generateDrops(monsterModel.type, monsterModel.x, monsterModel.y)
    for _, drop in ipairs(drops) do
        if drop.isCard then
            -- 根据玩家等级检查是否可以获得该卡牌
            local canGetCard = false
            local cardType = drop.buildingCardType
            local playerModel = player:getModel()
            
            -- 根据怪物类型和玩家等级检查是否可以获得该卡牌
            if isMonsterInTier(monsterModel.type, "basic") then
                canGetCard = playerModel.attributes.level >= ItemSystem.CARD_LEVEL_REQUIREMENTS.basic
            elseif isMonsterInTier(monsterModel.type, "advanced") then
                canGetCard = playerModel.attributes.level >= ItemSystem.CARD_LEVEL_REQUIREMENTS.advanced
            elseif isMonsterInTier(monsterModel.type, "elite") then
                canGetCard = playerModel.attributes.level >= ItemSystem.CARD_LEVEL_REQUIREMENTS.elite
            end
            
            if canGetCard then
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
    player:gainExp(monsterModel.expValue or monsterModel.config.expValue)
end

function CombatManager:handlePlayerDeath(player)
    local playerModel = player:getModel()
    if playerModel.attributes.hp <= 0 then
        -- 玩家已死亡，游戏结束
        if not gameOver then
            gameOver = true
            gameOverTime = love.timer.getTime()
        end
        return true  -- 表示游戏结束
    end
    return false
end

function CombatManager:handleBulletCollisions(player, monsterController)
    local playerBullets = player:getBullets()
    local monsterBullets = monsterController.getBullets()
    
    -- 检查玩家子弹与怪物的碰撞
    for i = #playerBullets, 1, -1 do
        local bullet = playerBullets[i]
        for _, monster in ipairs(monsterController.instances) do
            if not monster:isDead() and bullet.checkCollision then
                local monsterPos = monster:getPosition()
                local monsterEntity = {
                    x = monsterPos.x, 
                    y = monsterPos.y, 
                    size = monster:getModel().size
                }
                
                if bullet:checkCollision(monsterEntity) then
                    monster:takeDamage(bullet.damage)
                    
                    -- 如果使用BulletController，使用其方法
                    if bullet.deactivate then
                        bullet:deactivate()
                    else
                        -- 兼容旧版本
                        bullet.status.isActive = false
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
        local entity = {x = playerPos.x, y = playerPos.y, size = player:getModel().size}
        if bullet:checkCollision(entity) then
            player:takeDamage(bullet.damage)
            bullet.status.isActive = false
        end
    end
end

return CombatManager 