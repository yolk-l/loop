-- 玩家控制器
local PlayerController = {}
PlayerController.__index = PlayerController

local PlayerModel = require('src/models/PlayerModel')
local PlayerView = require('src/views/PlayerView')
local BulletModel = require('src/models/BulletModel')

function PlayerController:new(x, y)
    local mt = setmetatable({}, PlayerController)
    mt.model = PlayerModel:new(x, y)
    mt.view = PlayerView:new()
    return mt
end

function PlayerController:setMap(map)
    self.model:setMap(map)
end

function PlayerController:update(dt, monsters)
    -- 更新玩家模型
    self.model:update(dt)
    
    -- 如果是AI控制，更新AI行为
    if self.model.status.isAIControlled then
        local bulletInfo = self.model:updateAI(dt, monsters)
        
        -- 如果AI决定攻击，创建子弹
        if bulletInfo then
            self:createBullet(bulletInfo)
        end
    else
        -- 自动攻击范围内的怪物
        self:autoAttack(monsters)
    end
end

function PlayerController:draw()
    self.view:draw(self.model)
end

function PlayerController:move(dx, dy, dt)
    return self.model:move(dx, dy, dt)
end

function PlayerController:attack(target)
    local bulletInfo = self.model:attack(target)
    if bulletInfo then
        self:createBullet(bulletInfo)
        return true
    end
    return false
end

function PlayerController:autoAttack(monsters)
    if not monsters then return end
    
    local targetMonster = nil
    local closestDistance = self.model.status.attackRange
    
    -- 寻找范围内最近的怪物
    for _, monster in ipairs(monsters) do
        if not monster:isDead() then
            local monsterPos = monster:getPosition()
            local dx = monsterPos.x - self.model.x
            local dy = monsterPos.y - self.model.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < closestDistance then
                closestDistance = distance
                targetMonster = monster
            end
        end
    end
    
    -- 如果找到目标，攻击它
    if targetMonster then
        self:attack(targetMonster)
    end
end

function PlayerController:createBullet(bulletInfo)
    if bulletInfo.type == "melee" then
        -- 这是近战攻击，直接对目标造成伤害
        if targetMonster and targetMonster.takeDamage then
            targetMonster:takeDamage(bulletInfo.damage)
        end
    elseif bulletInfo.type == "ranged" then
        -- 这是远程攻击，需要创建子弹
        local bullet = BulletModel:new(
            bulletInfo.bulletInfo.startX,
            bulletInfo.bulletInfo.startY,
            bulletInfo.bulletInfo.targetX,
            bulletInfo.bulletInfo.targetY,
            bulletInfo.bulletInfo.speed,
            bulletInfo.bulletInfo.damage,
            "player"
        )
        table.insert(self.model.bullets, bullet)
    end
end

function PlayerController:getBullets()
    return self.model.bullets
end

function PlayerController:setAIControl(enabled)
    self.model.status.isAIControlled = enabled
    print(enabled and "AI控制已启用" or "AI控制已禁用")
end

function PlayerController:takeDamage(damage)
    return self.model:takeDamage(damage)
end

function PlayerController:heal(amount)
    return self.model:heal(amount)
end

function PlayerController:gainExp(exp)
    return self.model:gainExp(exp)
end

function PlayerController:equipRune(rune)
    return self.model:equipRune(rune)
end

function PlayerController:unequipRune(slot)
    return self.model:unequipRune(slot)
end

function PlayerController:getPosition()
    return {x = self.model.x, y = self.model.y}
end

function PlayerController:getModel()
    return self.model
end

function PlayerController:canBuildAt(x, y)
    -- 防御区域内不能建造
    local dx = x - self.model.x
    local dy = y - self.model.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    return distance > self.model.defenseRadius
end

return PlayerController 