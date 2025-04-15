-- BuildingModel类
local BuildingModel = {}
BuildingModel.__index = BuildingModel

-- 引入建筑配置
local BuildingConfig = require('config/buildings')
local MonsterModel = require('src/models/MonsterModel')
-- 初始化配置

function BuildingModel.new(type, x, y)
    local config = BuildingConfig[type]
    local mt = setmetatable({
        type = type,
        x = x,
        y = y,
        name = config.name,
        color = config.color,
        monsterType = config.monsterType,
        spriteColor = config.spriteColor,
        attributes = config.attributes,
        imgWidth = 32,
        imgHeight = 32,
        scale = 1,
        size = 16,
        status = {
            timeToNextSpawn = config.attributes.spawnRate,
            spawnedMonsters = {},
            isDead = false,
            animTime = 0
        },
        remainingTime = config.attributes.lifespan,
    }, BuildingModel)

    return mt
end

function BuildingModel:update(dt)
    -- 更新动画时间
    self.status.animTime = self.status.animTime + dt
    
    -- 更新剩余时间
    self.remainingTime = self.remainingTime - dt
    
    -- 建筑存在时间到，标记为死亡
    if self.remainingTime <= 0 then
        self.status.isDead = true
        return
    end
    
    -- 更新怪物生成计时器
    self.status.timeToNextSpawn = self.status.timeToNextSpawn - dt
end

function BuildingModel:canSpawnMonster()
    return #self.status.spawnedMonsters < self.attributes.maxSpawns and self.status.timeToNextSpawn <= 0
end

function BuildingModel:getSpawnPosition()
    -- 在建筑周围随机位置生成怪物
    local angle = math.random() * math.pi * 2
    local distance = math.random(10, self.attributes.spawnRadius)
    local spawnX = self.x + math.cos(angle) * distance
    local spawnY = self.y + math.sin(angle) * distance
    
    return spawnX, spawnY
end

function BuildingModel:addSpawnedMonster(monsterId)
    table.insert(self.status.spawnedMonsters, monsterId)
    -- 重置生成计时器
    self.status.timeToNextSpawn = self.attributes.spawnRate
end

function BuildingModel:removeMonster(monsterId)
    for i, id in ipairs(self.status.spawnedMonsters) do
        if id == monsterId then
            table.remove(self.status.spawnedMonsters, i)
            return true
        end
    end
    return false
end

function BuildingModel:clearDeadMonsters(monsterModels)
    for i = #self.status.spawnedMonsters, 1, -1 do
        local monsterId = self.status.spawnedMonsters[i]
        local monster = monsterModels[monsterId]
        if not monster or monster.status.isDead then
            table.remove(self.status.spawnedMonsters, i)
        end
    end
end

function BuildingModel:takeDamage(damage)
    self.attributes.hp = math.max(0, self.attributes.hp - damage)
    
    if self.attributes.hp <= 0 then
        self.status.isDead = true
    end
    
    return damage
end

function BuildingModel:isDead()
    return self.status.isDead
end

function BuildingModel:getMonsterType()
    return self.monsterType
end

function BuildingModel:getPosition()
    return self.x, self.y
end

function BuildingModel:getAttributes()
    return self.attributes
end

function BuildingModel:getStatus()
    return self.status
end

function BuildingModel:getName()
    return self.name
end

return BuildingModel 