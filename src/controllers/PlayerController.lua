-- 玩家控制器
local PlayerController = {}
PlayerController.__index = PlayerController

local PlayerModel = require('src/models/PlayerModel')
local PlayerView = require('src/views/PlayerView')
local BulletController = require('src/controllers/BulletController')

function PlayerController.new(x, y)
    local mt = setmetatable({}, PlayerController)
    mt.model = PlayerModel.new(x, y)
    mt.view = PlayerView.new()
    return mt
end

function PlayerController:setMap(map)
    self.model:setMap(map)
end

function PlayerController:update(dt)
    -- 调用模型的更新方法
    self.model:update(dt)
    
    -- 额外的控制器特有逻辑（如果有的话）
    -- 例如：处理用户输入等
end

function PlayerController:draw()
    self.view:draw(self.model)
end

function PlayerController:move(dx, dy, dt)
    return self.model:move(dx, dy, dt)
end

function PlayerController:attack(target)
    -- 调用模型的攻击方法
    local bulletInfo = self.model:attack(target)
    
    -- 如果返回了子弹信息，创建子弹
    if bulletInfo then
        self:createBullet(bulletInfo)
    end
    
    return bulletInfo
end

function PlayerController:autoAttack(monsters)
    -- 直接调用模型的自动攻击方法
    local bulletInfo = self.model:autoAttack(monsters)
    
    -- 如果返回了子弹信息，创建子弹
    if bulletInfo then
        self:createBullet(bulletInfo)
    end
    
    return bulletInfo
end

function PlayerController:createBullet(bulletInfo)
    if not bulletInfo then return end
    
    -- 创建远程攻击子弹控制器
    local bullet = BulletController.new(
        bulletInfo.startX,
        bulletInfo.startY,
        bulletInfo.targetX,
        bulletInfo.targetY,
        bulletInfo.speed,
        bulletInfo.damage,
        "player"
    )
    
    -- 设置子弹特殊效果
    if bulletInfo.effects then
        bullet.model.effects = bulletInfo.effects
    end
    
    -- 添加子弹到玩家的子弹列表
    table.insert(self.model.bullets, bullet)
    
    return bullet
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

function PlayerController:getPosition()
    return self.model:getPosition()
end

function PlayerController:getModel()
    return self.model
end

function PlayerController:canBuildAt(x, y)
    -- 调用模型的方法
    return self.model:canBuildAt(x, y)
end

return PlayerController 