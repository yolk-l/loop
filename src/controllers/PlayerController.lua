-- 玩家控制器
local PlayerController = {}
PlayerController.__index = PlayerController

local PlayerModel = require('src/models/PlayerModel')
local PlayerView = require('src/views/PlayerView')
local BulletModel = require('src/models/BulletModel')

function PlayerController:new(x, y)
    local self = setmetatable({}, PlayerController)
    self.model = PlayerModel:new(x, y)
    self.view = PlayerView:new()
    return self
end

function PlayerController:setMap(map)
    self.model:setMap(map)
end

function PlayerController:update(dt)
    -- 更新动画
    if self.model.animation then
        self.model.animation:update(dt)
    end
    
    -- 更新子弹
    self.model:updateBullets(dt)
    
    -- 更新攻击冷却
    if self.model.attributes.lastAttackTime > 0 then
        local currentTime = love.timer.getTime()
        if currentTime - self.model.attributes.lastAttackTime > self.model.attributes.attackCooldown then
            self.model.attributes.lastAttackTime = 0  -- 冷却完毕
        end
    end
    
    -- 如果没有全局timer，则使用手动计时方式
    if not gameTimer and self.model.status.isAttacking then
        local currentTime = love.timer.getTime()
        if currentTime - self.model.status.attackStartTime > 0.2 then
            self.model.status.isAttacking = false  -- 攻击效果结束
        end
    end
end

function PlayerController:draw()
    self.view:draw(self.model)
end

function PlayerController:move(dx, dy, dt)
    return self.model:move(dx, dy, dt)
end

function PlayerController:attack(target)
    -- 攻击逻辑实现
    -- 例如：减少目标生命值，播放攻击动画等
end

function PlayerController:autoAttack(monsters)
    -- 如果正在冷却中，不进行攻击
    if self.model.attributes.lastAttackTime > 0 then
        return
    end
    
    -- 查找范围内的怪物并攻击
    local closestMonster = nil
    local closestDistance = self.model.attackRadius
    
    for _, monster in ipairs(monsters) do
        if not monster.status.isDead then
            local dx = monster.x - self.model.x
            local dy = monster.y - self.model.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance < closestDistance then
                closestDistance = distance
                closestMonster = monster
            end
        end
    end
    
    -- 执行攻击逻辑
    if closestMonster then
        self:attack(closestMonster)
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