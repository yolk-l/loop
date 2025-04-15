-- 怪物控制器
local MonsterController = {}
MonsterController.__index = MonsterController

local MonsterModel = require('src/models/MonsterModel')
local MonsterView = require('src/views/MonsterView')
local BulletController = require('src/controllers/BulletController')

-- 静态变量，用于管理所有怪物实例
MonsterController.instances = {}
MonsterController.bullets = {}

function MonsterController.new(type, x, y)
    local mt = setmetatable({}, MonsterController)
    mt.model = MonsterModel.new(type, x, y)
    mt.view = MonsterView.new()
    
    -- 添加到实例列表
    table.insert(MonsterController.instances, mt)
    
    return mt
end

function MonsterController:update(dt, map)
    -- 只更新模型状态，不再处理攻击结果
    self.model:update(dt, map)
    
    -- 攻击结果处理已移至CombatManager
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
    local bullet = BulletController.new(
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
    return self.model:isDead()
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
        
        -- 标记已死亡的怪物，但不立即移除
        -- 移除操作将在main.lua中处理完经验值和掉落后进行
    end
    
    -- 更新所有子弹
    MonsterController.updateBullets(dt)
end

-- 静态方法：移除所有标记为死亡的怪物
function MonsterController.removeDeadMonsters()
    for i = #MonsterController.instances, 1, -1 do
        local instance = MonsterController.instances[i]
        if instance:isDead() then
            table.remove(MonsterController.instances, i)
        end
    end
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
    return MonsterController.new(type, x, y)
end

return MonsterController 