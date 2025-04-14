-- 建筑类
-- 已被MVC架构替代，此文件仅保留以兼容旧代码
-- 请改用：
-- BuildingModel - src/models/BuildingModel.lua
-- BuildingView - src/views/BuildingView.lua
-- BuildingController - src/controllers/BuildingController.lua

local Building = {}
Building.__index = Building

local BuildingConfig = require('config/buildings')
local Monster = require('src/entities/Monster')

function Building:new(type, x, y)
    print("警告：使用了旧版Building实体，请改用BuildingController")
    
    local self = setmetatable({}, Building)
    self.type = type
    self.x = x
    self.y = y
    
    -- 从配置文件获取建筑类型配置
    local config = BuildingConfig.get(type)
    
    -- 从配置复制属性
    self.name = config.name
    self.color = config.color
    self.monsterType = config.monsterType
    
    -- 初始化健康属性
    self.attributes = {
        hp = config.attributes.hp,
        maxHp = config.attributes.maxHp,
        lifespan = config.attributes.lifespan,
        remainingTime = config.attributes.lifespan,
        spawnRate = config.attributes.spawnRate,
        spawnRadius = config.attributes.spawnRadius,
        maxSpawns = config.attributes.maxSpawns,
        wanderRadius = config.attributes.wanderRadius
    }
    
    -- 状态系统
    self.status = {
        timeToNextSpawn = self.attributes.spawnRate, -- 下次生成怪物的时间
        spawnedMonsters = {},                        -- 已生成的怪物引用列表
        isDead = false,                              -- 是否已经消失
        animTime = 0                                 -- 用于动画效果时间计算
    }
    
    -- 建筑大小
    self.size = 16
    
    -- 加载建筑图片（如果有）
    self:loadImage()
    
    return self
end

function Building:loadImage()
    -- 建筑类型到图片名称的映射
    local imageNameMap = {
        slime_nest = "slime_nest",
        goblin_hut = "goblin_hut",
        skeleton_tomb = "skeleton_graveyard",
        zombie_graveyard = "zombie_graveyard",
        wolf_den = "werewolf_den",
        ghost_manor = "ghost_mansion",
        golem_forge = "giant_furnace",
        witch_hut = "witch_hut",
        dragon_cave = "dragon_cave"
    }
    
    -- 获取对应的图片名称
    local imageName = imageNameMap[self.type] or self.type
    
    -- 尝试加载特定建筑图片
    local imagePath = "assets/sprites/buildings/" .. imageName .. ".png"
    if love.filesystem.getInfo(imagePath) then
        self.sprite = love.graphics.newImage(imagePath)
    else
        -- 如果没有特定类型的图片，尝试加载默认图片
        imagePath = "assets/sprites/buildings/default_building.png"
        if love.filesystem.getInfo(imagePath) then
            self.sprite = love.graphics.newImage(imagePath)
        end
    end
    
    -- 如果有图片，计算缩放比例
    if self.sprite then
        local imgWidth, imgHeight = self.sprite:getDimensions()
        self.scale = 32 / math.max(imgWidth, imgHeight)  -- 目标大小为32像素
        self.size = (math.max(imgWidth, imgHeight) * self.scale) / 2  -- 半径作为碰撞大小
    end
end

function Building:update(dt, monsters)
    -- 更新动画时间
    self.status.animTime = self.status.animTime + dt
    
    -- 更新剩余时间
    self.attributes.remainingTime = self.attributes.remainingTime - dt
    
    -- 建筑存在时间到，标记为死亡
    if self.attributes.remainingTime <= 0 then
        self.status.isDead = true
        return
    end
    
    -- 更新怪物生成计时器
    self.status.timeToNextSpawn = self.status.timeToNextSpawn - dt
    
    -- 生成怪物
    if #self.status.spawnedMonsters < self.attributes.maxSpawns and self.status.timeToNextSpawn <= 0 then
        local monster = self:spawnMonster()
        if monster then
            monster.homeBuildingId = self
            table.insert(self.status.spawnedMonsters, monster)
        end
        
        -- 重置生成计时器
        self.status.timeToNextSpawn = self.attributes.spawnRate
    end
    
    -- 从列表中移除已死亡的怪物
    for i = #self.status.spawnedMonsters, 1, -1 do
        local monster = self.status.spawnedMonsters[i]
        if monster.status.isDead then
            table.remove(self.status.spawnedMonsters, i)
        end
    end
end

function Building:spawnMonster()
    -- 在建筑周围随机位置生成怪物
    local angle = math.random() * math.pi * 2
    local distance = math.random(10, self.attributes.spawnRadius)
    local spawnX = self.x + math.cos(angle) * distance
    local spawnY = self.y + math.sin(angle) * distance
    
    -- 创建怪物实例
    local monster = Monster:new(self.monsterType, spawnX, spawnY)
    
    -- 设置怪物的徘徊半径
    monster.wanderRadius = self.attributes.wanderRadius
    
    return monster
end

function Building:draw()
    if self.sprite then
        -- 应用一个微小的偏移量，用于呼吸动画效果
        local breathOffset = math.sin(self.status.animTime * 2) * 2
        
        -- 绘制建筑图片
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            self.sprite, 
            self.x, 
            self.y + breathOffset, 
            0,                   -- 旋转角度
            self.scale,          -- X缩放
            self.scale,          -- Y缩放
            self.sprite:getWidth()/2,  -- 中心点X
            self.sprite:getHeight()/2  -- 中心点Y
        )
        
        -- 绘制建筑名称
        local font = love.graphics.getFont()
        love.graphics.setColor(1, 1, 1)
        local textWidth = font:getWidth(self.name)
        love.graphics.print(self.name, self.x - textWidth/2, self.y - self.sprite:getHeight()/2 * self.scale - 20)
        
        -- 绘制生命条
        local hpBarWidth = self.size * 2
        local hpBarHeight = 4
        local hpPercentage = self.attributes.hp / self.attributes.maxHp
        
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y + self.sprite:getHeight()/2 * self.scale + 5, hpBarWidth, hpBarHeight)
        
        love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
        love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y + self.sprite:getHeight()/2 * self.scale + 5, hpBarWidth * hpPercentage, hpBarHeight)
        
        -- 绘制剩余时间条
        local timeBarWidth = self.size * 2
        local timeBarHeight = 4
        local timePercentage = self.attributes.remainingTime / self.attributes.lifespan
        
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('fill', self.x - timeBarWidth/2, self.y + self.sprite:getHeight()/2 * self.scale + 10, timeBarWidth, timeBarHeight)
        
        love.graphics.setColor(0.2, 0.6, 1.0)
        love.graphics.rectangle('fill', self.x - timeBarWidth/2, self.y + self.sprite:getHeight()/2 * self.scale + 10, timeBarWidth * timePercentage, timeBarHeight)
        
        -- 如果建筑即将消失，添加闪烁效果
        if self.attributes.remainingTime < 10 and math.floor(self.status.animTime * 4) % 2 == 0 then
            love.graphics.setColor(1, 0.3, 0.3, 0.3)
            love.graphics.draw(
                self.sprite, 
                self.x, 
                self.y + breathOffset, 
                0,                   -- 旋转角度
                self.scale * 1.1,    -- X缩放（略大一些）
                self.scale * 1.1,    -- Y缩放（略大一些）
                self.sprite:getWidth()/2,  -- 中心点X
                self.sprite:getHeight()/2  -- 中心点Y
            )
        end
    else
        -- 如果没有图片，绘制一个简单的形状
        love.graphics.setColor(self.color)
        love.graphics.rectangle('fill', self.x - self.size/2, self.y - self.size/2, self.size, self.size)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('line', self.x - self.size/2, self.y - self.size/2, self.size, self.size)
        
        -- 绘制建筑名称
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(self.name)
        love.graphics.print(self.name, self.x - textWidth/2, self.y - self.size/2 - 20)
        
        -- 绘制生命条
        local hpBarWidth = self.size
        local hpBarHeight = 4
        local hpPercentage = self.attributes.hp / self.attributes.maxHp
        
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y + self.size/2 + 5, hpBarWidth, hpBarHeight)
        
        love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
        love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y + self.size/2 + 5, hpBarWidth * hpPercentage, hpBarHeight)
        
        -- 绘制剩余时间条
        local timeBarWidth = self.size
        local timeBarHeight = 4
        local timePercentage = self.attributes.remainingTime / self.attributes.lifespan
        
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle('fill', self.x - timeBarWidth/2, self.y + self.size/2 + 10, timeBarWidth, timeBarHeight)
        
        love.graphics.setColor(0.2, 0.6, 1.0)
        love.graphics.rectangle('fill', self.x - timeBarWidth/2, self.y + self.size/2 + 10, timeBarWidth * timePercentage, timeBarHeight)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function Building:takeDamage(damage)
    self.attributes.hp = math.max(0, self.attributes.hp - damage)
    
    if self.attributes.hp <= 0 then
        self.status.isDead = true
    end
    
    return damage
end

return Building 