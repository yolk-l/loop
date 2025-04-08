-- 建筑类
local Building = {}
Building.__index = Building

-- 引入怪物系统
local Monster = require('src/entities/Monster')

-- 字体缓存
local buildingFont = nil

-- 初始化字体
local function initFont()
    if not buildingFont then
        buildingFont = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function Building:new(type, x, y)
    local self = setmetatable({}, Building)
    self.type = type
    self.x = x
    self.y = y
    self.size = 16  -- 建筑大小
    
    -- 初始化建筑属性
    self.attributes = {
        hp = 100,               -- 建筑生命值
        maxHp = 100,            -- 最大生命值
        lifespan = 60,          -- 建筑存在时间（秒）
        remainingTime = 60,     -- 剩余时间
        spawnRate = 10,         -- 怪物生成速率（秒/只）
        spawnRadius = 30,       -- 生成怪物的半径范围
        maxSpawns = 5,          -- 最大同时存在的怪物数量
        wanderRadius = 80       -- 怪物游荡半径
    }
    
    -- 根据建筑类型调整属性
    if self.type == "slime_nest" then
        self.color = {0.5, 0.8, 0.5}
        self.monsterType = "slime"
        self.name = "史莱姆巢穴"
    elseif self.type == "goblin_hut" then
        self.color = {0.8, 0.5, 0.3}
        self.monsterType = "goblin"
        self.name = "哥布林小屋"
        self.attributes.spawnRate = 15
        self.attributes.maxSpawns = 3
    elseif self.type == "skeleton_tomb" then
        self.color = {0.8, 0.8, 0.8}
        self.monsterType = "skeleton"
        self.name = "骷髅墓地"
        self.attributes.spawnRate = 20
        self.attributes.maxSpawns = 2
    end
    
    -- 状态系统
    self.status = {
        timeToNextSpawn = self.attributes.spawnRate, -- 下次生成怪物的时间
        spawnedMonsters = {},                        -- 已生成的怪物列表
        isDead = false                               -- 是否已经消失
    }
    
    initFont()
    return self
end

function Building:update(dt, monsters)
    -- 更新剩余时间
    self.attributes.remainingTime = self.attributes.remainingTime - dt
    
    -- 建筑存在时间到，标记为死亡
    if self.attributes.remainingTime <= 0 then
        self.status.isDead = true
        return
    end
    
    -- 更新怪物生成计时器
    self.status.timeToNextSpawn = self.status.timeToNextSpawn - dt
    
    -- 清理怪物列表中已死亡的怪物
    for i = #self.status.spawnedMonsters, 1, -1 do
        if self.status.spawnedMonsters[i].status.isDead then
            table.remove(self.status.spawnedMonsters, i)
        end
    end
    
    -- 如果当前生成的怪物数量少于最大值，且生成计时器到了，则生成新怪物
    if #self.status.spawnedMonsters < self.attributes.maxSpawns and self.status.timeToNextSpawn <= 0 then
        self:spawnMonster(monsters)
        self.status.timeToNextSpawn = self.attributes.spawnRate
    end
end

function Building:spawnMonster(globalMonsters)
    -- 在建筑周围随机位置生成怪物
    local angle = math.random() * math.pi * 2
    local distance = math.random(10, self.attributes.spawnRadius)
    local spawnX = self.x + math.cos(angle) * distance
    local spawnY = self.y + math.sin(angle) * distance
    
    -- 创建新怪物实例
    local monster = Monster:new(self.monsterType, spawnX, spawnY)
    
    -- 设置怪物的归属建筑，但不限制其游荡范围
    monster.status.homeBuilding = self
    
    -- 将怪物添加到全局怪物列表和建筑的怪物列表
    table.insert(globalMonsters, monster)
    table.insert(self.status.spawnedMonsters, monster)
    
    return monster
end

function Building:takeDamage(damage)
    self.attributes.hp = math.max(0, self.attributes.hp - damage)
    
    if self.attributes.hp <= 0 then
        self.status.isDead = true
    end
    
    return damage
end

function Building:draw()
    -- 绘制建筑
    love.graphics.setColor(unpack(self.color))
    love.graphics.rectangle('fill', self.x - self.size, self.y - self.size, self.size * 2, self.size * 2)
    
    -- 绘制建筑边框
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('line', self.x - self.size, self.y - self.size, self.size * 2, self.size * 2)
    
    -- 绘制建筑名称
    love.graphics.setFont(buildingFont)
    love.graphics.setColor(1, 1, 1)
    local textWidth = buildingFont:getWidth(self.name)
    love.graphics.print(self.name, self.x - textWidth/2, self.y - self.size - 20)
    
    -- 绘制生命条
    local hpBarWidth = self.size * 2
    local hpBarHeight = 4
    local hpPercentage = self.attributes.hp / self.attributes.maxHp
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', self.x - self.size, self.y + self.size + 5, hpBarWidth, hpBarHeight)
    
    love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
    love.graphics.rectangle('fill', self.x - self.size, self.y + self.size + 5, hpBarWidth * hpPercentage, hpBarHeight)
    
    -- 绘制剩余时间条
    local timeBarWidth = self.size * 2
    local timeBarHeight = 4
    local timePercentage = self.attributes.remainingTime / self.attributes.lifespan
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', self.x - self.size, self.y + self.size + 10, timeBarWidth, timeBarHeight)
    
    love.graphics.setColor(0.2, 0.6, 1.0)
    love.graphics.rectangle('fill', self.x - self.size, self.y + self.size + 10, timeBarWidth * timePercentage, timeBarHeight)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return Building 