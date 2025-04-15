-- BuildingController类
local BuildingController = {}
BuildingController.__index = BuildingController

local BuildingModel = require('src/models/BuildingModel')
local BuildingView = require('src/views/BuildingView')
local MonsterController = require('src/controllers/MonsterController')

-- 静态变量，用于管理所有建筑实例
BuildingController.instances = {}

function BuildingController:new(type, x, y)
    local self = setmetatable({}, BuildingController)
    self.model = BuildingModel:new(type, x, y)
    self.view = BuildingView:new()
    
    -- 加载并设置图像尺寸数据
    self.view:loadImage(self.model)
    
    -- 添加到实例列表
    table.insert(BuildingController.instances, self)
    
    return self
end

function BuildingController:update(dt, player)
    -- 更新模型状态
    self.model:update(dt)
    
    -- 尝试生成怪物
    if self.model:canSpawnMonster() then
        self:spawnMonster(player)
    end
    
    -- 清理已死亡的怪物
    self:clearDeadMonsters()
end

function BuildingController:spawnMonster(player)
    -- 获取生成位置
    local spawnX, spawnY = self.model:getSpawnPosition()
    
    -- 创建新怪物实例
    local monsterController = MonsterController:new(
        self.model:getMonsterType(), 
        spawnX, 
        spawnY
    )
    
    -- 设置怪物归属建筑
    monsterController.model.homeBuilding = self.model
    
    -- 将怪物ID添加到建筑的怪物列表
    self.model:addSpawnedMonster(monsterController.model.id)
    
    -- 如果提供了玩家，则将其设置为目标并立即激活追踪行为
    if player then
        monsterController:setTarget(player)
        
        -- 获取与玩家的距离
        local pos = player:getPosition()
        local dx = pos.x - monsterController.model.x
        local dy = pos.y - monsterController.model.y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        -- 计算理想攻击距离
        local idealDistance = monsterController.model.attributes.attackRange * 0.8
        
        -- 强制设置为追踪状态
        monsterController.model.ai.state = "chase"
        
        -- 如果超出理想攻击距离，则移动
        if distance > idealDistance then
            monsterController.model.status.isMoving = true
        else
            -- 否则在理想距离内停止移动
            monsterController.model.status.isMoving = false
        end
        
        -- 记录最后见到玩家的位置
        monsterController.model.ai.lastSeenTarget = {x = pos.x, y = pos.y}
        monsterController.model.ai.lastSeenTime = love.timer.getTime()
    end
    
    return monsterController
end

function BuildingController:clearDeadMonsters()
    -- 从MonsterController获取所有怪物模型
    local monsterModels = {}
    for _, monsterController in ipairs(MonsterController.instances) do
        monsterModels[monsterController.model.id] = monsterController.model
    end
    
    -- 清理已死亡的怪物
    self.model:clearDeadMonsters(monsterModels)
end

function BuildingController:takeDamage(damage)
    return self.model:takeDamage(damage)
end

function BuildingController:draw()
    self.view:draw(self.model)
end

function BuildingController:getPosition()
    return self.model:getPosition()
end

function BuildingController:isDead()
    return self.model:isDead()
end

function BuildingController:getModel()
    return self.model
end

-- 静态方法：更新所有建筑实例
function BuildingController.updateAll(dt, player)
    for i = #BuildingController.instances, 1, -1 do
        local instance = BuildingController.instances[i]
        instance:update(dt, player)
        
        -- 移除已死亡的建筑
        if instance:isDead() then
            table.remove(BuildingController.instances, i)
        end
    end
end

-- 静态方法：绘制所有建筑实例
function BuildingController.drawAll()
    for _, instance in ipairs(BuildingController.instances) do
        instance:draw()
    end
end

-- 静态方法：获取所有建筑实例
function BuildingController.getInstances()
    return BuildingController.instances
end

-- 静态方法：清除所有建筑
function BuildingController.clearAll()
    BuildingController.instances = {}
end

-- 静态方法：创建建筑
function BuildingController.createBuilding(type, x, y)
    return BuildingController:new(type, x, y)
end

return BuildingController 