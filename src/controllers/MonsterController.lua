-- 怪物控制器
local MonsterController = {}
MonsterController.__index = MonsterController

local MonsterModel = require('src/models/MonsterModel')
local MonsterView = require('src/views/MonsterView')
local BulletController = require('src/controllers/BulletController')

function MonsterController.new(type, x, y)
    local mt = setmetatable({}, MonsterController)
    mt.model = MonsterModel.new(type, x, y)
    mt.view = MonsterView.new()
    
    return mt
end

function MonsterController:update(dt, map)
    -- 只更新模型状态，不再处理攻击结果
    self.model:update(dt, map)
    
    -- 更新动画状态
    self.view:update(dt, self.model)
    
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
    return BulletController.new(
        bulletInfo.startX,
        bulletInfo.startY,
        bulletInfo.targetX,
        bulletInfo.targetY,
        bulletInfo.speed,
        bulletInfo.damage,
        bulletInfo.source
    )
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

-- 获取怪物类型
function MonsterController:getType()
    return self.model:getType()
end

-- 获取怪物等级
function MonsterController:getTier()
    return self.model:getTier()
end

-- 获取怪物配置
function MonsterController:getConfig()
    return self.model:getConfig()
end

-- 获取怪物掉落物
function MonsterController:getLoot()
    return self.model:getLoot()
end

-- 获取怪物经验值
function MonsterController:getExpValue()
    return self.model:getExpValue()
end

return MonsterController 