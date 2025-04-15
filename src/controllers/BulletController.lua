-- 子弹控制器
local BulletController = {}
BulletController.__index = BulletController

local BulletModel = require('src/models/BulletModel')
local BulletView = require('src/views/BulletView')

function BulletController.new(startX, startY, targetX, targetY, speed, damage, sourceType)
    local mt = setmetatable({}, BulletController)
    mt.model = BulletModel.new(startX, startY, targetX, targetY, speed, damage, sourceType)
    mt.view = BulletView.new()
    mt.hitEffects = {}  -- 存储击中效果
    return mt
end

function BulletController:update(dt)
    self.model:update(dt)
    
    -- 更新击中效果（如果有）
    for i = #self.hitEffects, 1, -1 do
        self.hitEffects[i].lifetime = self.hitEffects[i].lifetime - dt
        if self.hitEffects[i].lifetime <= 0 then
            table.remove(self.hitEffects, i)
        end
    end
end

function BulletController:draw()
    self.view:draw(self.model)
    
    -- 绘制击中效果
    for _, effect in ipairs(self.hitEffects) do
        self.view:drawHitEffect(effect.x, effect.y, effect.isCritical)
    end
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
    local effect = {
        x = x,
        y = y,
        isCritical = self.model.effects.isCritical,
        lifetime = 0.3  -- 效果持续时间，单位秒
    }
    
    table.insert(self.hitEffects, effect)
    self.model:deactivate()  -- 击中后停用子弹
end

return BulletController 