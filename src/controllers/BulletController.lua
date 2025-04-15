-- 子弹控制器
local BulletController = {}
BulletController.__index = BulletController

local BulletModel = require('src/models/BulletModel')
local BulletView = require('src/views/BulletView')

function BulletController.new(startX, startY, targetX, targetY, speed, damage, sourceType)
    local mt = setmetatable({}, BulletController)
    mt.model = BulletModel.new(startX, startY, targetX, targetY, speed, damage, sourceType)
    mt.view = BulletView.new()
    return mt
end

function BulletController:update(dt)
    self.model:update(dt)
    
    -- 更新视图层的效果
    self.view:update(dt)
end

function BulletController:draw()
    -- 使用视图对象绘制子弹和效果
    self.view:draw(self.model)
end

function BulletController:isActive()
    return self.model:isActive()
end

function BulletController:deactivate()
    self.model:deactivate()
end

function BulletController:checkCollision(entity)
    return self.model:checkCollision(entity)
end

function BulletController:getPosition()
    return self.model:getPosition()
end

function BulletController:getDamage()
    return self.model:getDamage()
end

function BulletController:getEffects()
    return self.model:getEffects()
end

function BulletController:getSource()
    return self.model:getSource()
end

function BulletController:createHitEffect(x, y)
    -- 通知视图创建击中效果
    self.view:createHitEffect(x, y, self.model.effects.isCritical)
    
    -- 停用子弹模型
    self.model:deactivate()
end

return BulletController 