-- 怪物控制器
local MonsterController = {}
MonsterController.__index = MonsterController

local MonsterModel = require('src/models/MonsterModel')
local MonsterView = require('src/views/MonsterView')
local BulletController = require('src/controllers/BulletController')

-- 静态变量，用于管理所有怪物实例
MonsterController.instances = {}
MonsterController.bullets = {}

function MonsterController:new(type, x, y)
    local mt = setmetatable({}, MonsterController)
    mt.model = MonsterModel:new(type, x, y)
    mt.view = MonsterView:new()
    
    -- 添加到实例列表
    table.insert(MonsterController.instances, mt)
    
    return mt
end

function MonsterController:update(dt, map)
    -- 更新模型状态
    local attackResult = self.model:update(dt, map)
    
    -- 处理攻击结果
    if attackResult then
        if attackResult.type == "ranged" then
            -- 创建子弹
            self:createBullet(attackResult.bulletInfo)
        elseif attackResult.type == "melee" and attackResult.source.target then
            -- 处理近战攻击
            if attackResult.source.target.takeDamage then
                attackResult.source.target:takeDamage(attackResult.damage)
            end
        end
    end
end

function MonsterController:draw()
    self.view:draw(self.model)
end

function MonsterController:setTarget(target)
    self.model:setTarget(target)
end

function MonsterController:takeDamage(damage)
    return self.model:takeDamage(damage)
end

function MonsterController:stun(duration)
    self.model:stun(duration)
end

function MonsterController:heal(amount)
    self.model:heal(amount)
end

function MonsterController:createBullet(bulletInfo)
    local bullet = BulletController:new(
        bulletInfo.startX,
        bulletInfo.startY,
        bulletInfo.targetX,
        bulletInfo.targetY,
        bulletInfo.speed,
        bulletInfo.damage,
        bulletInfo.source
    )
    
    -- 添加到静态子弹列表
    table.insert(MonsterController.bullets, bullet)
end

function MonsterController:isDead()
    return self.model.status.isDead
end

function MonsterController:getPosition()
    return {x = self.model.x, y = self.model.y}
end

function MonsterController:getModel()
    return self.model
end

-- 静态方法：更新所有怪物实例
function MonsterController.updateAll(dt, map)
    -- 更新所有怪物
    for i = #MonsterController.instances, 1, -1 do
        local instance = MonsterController.instances[i]
        instance:update(dt, map)
        
        -- 移除已死亡的怪物
        if instance:isDead() then
            table.remove(MonsterController.instances, i)
        end
    end
    
    -- 更新所有子弹
    MonsterController.updateBullets(dt)
end

-- 静态方法：绘制所有怪物实例
function MonsterController.drawAll()
    for _, instance in ipairs(MonsterController.instances) do
        instance:draw()
    end
    
    -- 绘制所有子弹
    MonsterController.drawBullets()
end

-- 静态方法：更新所有子弹
function MonsterController.updateBullets(dt)
    for i = #MonsterController.bullets, 1, -1 do
        local bullet = MonsterController.bullets[i]
        bullet:update(dt)
        
        -- 移除失效的子弹
        if not bullet:isActive() then
            table.remove(MonsterController.bullets, i)
        end
    end
end

-- 静态方法：绘制所有子弹
function MonsterController.drawBullets()
    for _, bullet in ipairs(MonsterController.bullets) do
        bullet:draw()
    end
end

-- 静态方法：获取所有子弹
function MonsterController.getBullets()
    return MonsterController.bullets
end

-- 静态方法：获取所有怪物实例
function MonsterController.getInstances()
    return MonsterController.instances
end

-- 静态方法：清除所有怪物和子弹
function MonsterController.clearAll()
    MonsterController.instances = {}
    MonsterController.bullets = {}
end

-- 静态方法：创建怪物
function MonsterController.createMonster(type, x, y)
    return MonsterController:new(type, x, y)
end

return MonsterController 