-- 怪物管理器
-- 用于管理所有怪物实例和子弹，符合MVC架构
local MonsterManager = {}
MonsterManager.__index = MonsterManager

local MonsterController = require('src/controllers/MonsterController')

function MonsterManager.new()
    local self = setmetatable({}, MonsterManager)
    self.monsterInstances = {}  -- 所有怪物实例
    self.bullets = {}           -- 所有怪物子弹
    return self
end

-- 创建新怪物
function MonsterManager:createMonster(type, x, y)
    local monster = MonsterController.new(type, x, y)
    table.insert(self.monsterInstances, monster)
    return monster
end

-- 更新所有怪物
function MonsterManager:updateAll(dt, map)
    -- 更新所有怪物
    for i = #self.monsterInstances, 1, -1 do
        local instance = self.monsterInstances[i]
        instance:update(dt, map)
    end
    
    -- 更新所有子弹
    self:updateBullets(dt)
end

-- 移除所有标记为死亡的怪物
function MonsterManager:removeDeadMonsters()
    for i = #self.monsterInstances, 1, -1 do
        local instance = self.monsterInstances[i]
        if instance:isDead() then
            table.remove(self.monsterInstances, i)
        end
    end
end

-- 绘制所有怪物实例
function MonsterManager:drawAll()
    for _, instance in ipairs(self.monsterInstances) do
        instance:draw()
    end
    
    -- 绘制所有子弹
    self:drawBullets()
end

-- 添加子弹
function MonsterManager:addBullet(bullet)
    table.insert(self.bullets, bullet)
end

-- 更新所有子弹
function MonsterManager:updateBullets(dt)
    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        bullet:update(dt)
        
        -- 移除失效的子弹
        if not bullet:isActive() then
            table.remove(self.bullets, i)
        end
    end
end

-- 绘制所有子弹
function MonsterManager:drawBullets()
    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
end

-- 获取所有子弹
function MonsterManager:getBullets()
    return self.bullets
end

-- 获取所有怪物实例
function MonsterManager:getInstances()
    return self.monsterInstances
end

-- 清除所有怪物和子弹
function MonsterManager:clearAll()
    self.monsterInstances = {}
    self.bullets = {}
end

-- 为所有怪物设置目标
function MonsterManager:setTargetForAll(target)
    for _, monster in ipairs(self.monsterInstances) do
        monster:setTarget(target)
    end
end

-- 获取怪物数量
function MonsterManager:getMonsterCount()
    return #self.monsterInstances
end

return MonsterManager 