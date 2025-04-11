-- 建筑类
local Building = {}
Building.__index = Building

-- 引入怪物系统
local Monster = require('src/entities/Monster')

-- 引入动画系统
local AnimationSystem = require('src/systems/Animation')

-- 引入建筑配置
local BuildingConfig = require('config/buildings')

-- 字体缓存
local buildingFont = nil
-- 建筑图片缓存
local buildingImages = {}

-- 初始化字体
local function initFont()
    if not buildingFont then
        buildingFont = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

-- 加载建筑图片
local function loadBuildingImage(type)
    if buildingImages[type] then
        return buildingImages[type]
    end
    
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
    local imageName = imageNameMap[type] or type
    
    -- 尝试加载特定建筑图片
    local imagePath = "assets/sprites/buildings/" .. imageName .. ".png"
    if love.filesystem.getInfo(imagePath) then
        buildingImages[type] = love.graphics.newImage(imagePath)
        return buildingImages[type]
    end
    
    -- 如果没有特定类型的图片，尝试加载默认图片
    imagePath = "assets/sprites/buildings/default_building.png"
    if love.filesystem.getInfo(imagePath) then
        buildingImages[type] = love.graphics.newImage(imagePath)
        return buildingImages[type]
    end
    
    -- 如果没有默认图片，使用生成的图像
    buildingImages[type] = AnimationSystem.getImage("building")
    return buildingImages[type]
end

function Building:new(type, x, y)
    local self = setmetatable({}, Building)
    self.type = type
    self.x = x
    self.y = y
    
    -- 从配置文件获取建筑类型配置
    local config = BuildingConfig.get(type)
    
    -- 设置基本属性
    self.name = config.name
    self.color = config.color
    self.monsterType = config.monsterType
    self.spriteColor = config.spriteColor
    
    -- 初始化建筑属性
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
    
    -- 获取建筑图片
    self.sprite = loadBuildingImage(type)
    
    -- 设置适当的缩放比例，使图片大小适合游戏
    -- 根据图片尺寸设置不同的缩放比例，以保持建筑在游戏中的大小一致
    local imgWidth, imgHeight = self.sprite:getDimensions()
    self.scale = 32 / math.max(imgWidth, imgHeight)  -- 目标大小为32像素
    
    -- 设置建筑的碰撞尺寸，使用缩放后的图片尺寸
    self.size = (math.max(imgWidth, imgHeight) * self.scale) / 2
    
    -- 状态系统
    self.status = {
        timeToNextSpawn = self.attributes.spawnRate, -- 下次生成怪物的时间
        spawnedMonsters = {},                        -- 已生成的怪物列表
        isDead = false,                             -- 是否已经消失
        animTime = 0                                -- 用于简单动画效果
    }
    
    initFont()
    return self
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
    
    -- 设置怪物的归属建筑
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
    -- 应用一个微小的偏移量，用于呼吸动画效果
    local breathOffset = math.sin(self.status.animTime * 2) * 2
    
    -- 绘制建筑图片
    love.graphics.setColor(1, 1, 1)  -- 使用原始颜色，不再使用tint
    love.graphics.draw(
        self.sprite, 
        self.x, 
        self.y + breathOffset, 
        0,                       -- 旋转角度
        self.scale,              -- X缩放
        self.scale,              -- Y缩放
        self.sprite:getWidth()/2, -- 中心点X
        self.sprite:getHeight()/2 -- 中心点Y
    )
    
    -- 绘制建筑名称
    love.graphics.setFont(buildingFont)
    love.graphics.setColor(1, 1, 1)
    local textWidth = buildingFont:getWidth(self.name)
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
            0,                        -- 旋转角度
            self.scale * 1.1,         -- X缩放（略大一些）
            self.scale * 1.1,         -- Y缩放（略大一些）
            self.sprite:getWidth()/2, -- 中心点X
            self.sprite:getHeight()/2 -- 中心点Y
        )
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return Building 