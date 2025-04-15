-- BuildingController类
local BuildingController = {}
BuildingController.__index = BuildingController

local BuildingModel = require('src/models/BuildingModel')
local BuildingView = require('src/views/BuildingView')
local MonsterController = require('src/controllers/MonsterController')

-- 静态引用，将在main.lua中设置
BuildingController.monsterManager = nil

function BuildingController.new(type, x, y)
    local mt = setmetatable({}, BuildingController)
    mt.model = BuildingModel.new(type, x, y)
    mt.view = BuildingView.new()
    
    -- 加载并设置图像尺寸数据
    mt.view:loadImage(mt.model)
    
    return mt
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
    
    -- 创建新怪物实例并添加到manager
    local monsterController
    if BuildingController.monsterManager then
        monsterController = BuildingController.monsterManager:createMonster(
            self.model:getMonsterType(), 
            spawnX, 
            spawnY
        )
    else
        -- 后向兼容，如果没有monsterManager，则直接使用MonsterController
        monsterController = MonsterController.new(
            self.model:getMonsterType(), 
            spawnX, 
            spawnY
        )
    end
    
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
    -- 从monsterManager或MonsterController获取所有怪物模型
    local monsterModels = {}
    
    if BuildingController.monsterManager then
        -- 使用monsterManager获取所有怪物实例
        for _, monsterController in ipairs(BuildingController.monsterManager:getInstances()) do
            monsterModels[monsterController.model.id] = monsterController.model
        end
    else
        -- 后向兼容，直接从MonsterController获取
        for _, monsterController in ipairs(MonsterController.instances) do
            monsterModels[monsterController.model.id] = monsterController.model
        end
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

-- 获取建筑类型
function BuildingController:getType()
    return self.model:getType()
end

return BuildingController 