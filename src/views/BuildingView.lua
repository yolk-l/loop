-- BuildingView类
local BuildingView = {}
BuildingView.__index = BuildingView

-- 引入动画系统
local AnimationSystem = require('src/utils/Animation')

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

function BuildingView:new()
    local self = setmetatable({}, BuildingView)
    initFont()
    return self
end

function BuildingView:loadImage(buildingModel)
    local type = buildingModel.type
    local sprite = loadBuildingImage(type)
    
    -- 设置适当的缩放比例，使图片大小适合游戏
    local imgWidth, imgHeight = sprite:getDimensions()
    local scale = 32 / math.max(imgWidth, imgHeight)  -- 目标大小为32像素
    
    -- 更新模型中的图像相关数据
    buildingModel.imgWidth = imgWidth
    buildingModel.imgHeight = imgHeight
    buildingModel.scale = scale
    buildingModel.size = (math.max(imgWidth, imgHeight) * scale) / 2
    
    return sprite
end

function BuildingView:draw(buildingModel)
    -- 获取建筑图片
    local sprite = loadBuildingImage(buildingModel.type)
    local x, y = buildingModel.x, buildingModel.y
    local status = buildingModel.status
    local attributes = buildingModel.attributes
    
    -- 应用一个微小的偏移量，用于呼吸动画效果
    local breathOffset = math.sin(status.animTime * 2) * 2
    
    -- 绘制建筑图片
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        sprite, 
        x, 
        y + breathOffset, 
        0,                       -- 旋转角度
        buildingModel.scale,     -- X缩放
        buildingModel.scale,     -- Y缩放
        sprite:getWidth()/2,     -- 中心点X
        sprite:getHeight()/2     -- 中心点Y
    )
    
    -- 绘制建筑名称
    love.graphics.setFont(buildingFont)
    love.graphics.setColor(1, 1, 1)
    local textWidth = buildingFont:getWidth(buildingModel.name)
    love.graphics.print(buildingModel.name, x - textWidth/2, y - sprite:getHeight()/2 * buildingModel.scale - 20)
    
    -- 绘制生命条
    local hpBarWidth = buildingModel.size * 2
    local hpBarHeight = 4
    local hpPercentage = attributes.hp / attributes.maxHp
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', x - hpBarWidth/2, y + sprite:getHeight()/2 * buildingModel.scale + 5, hpBarWidth, hpBarHeight)
    
    love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
    love.graphics.rectangle('fill', x - hpBarWidth/2, y + sprite:getHeight()/2 * buildingModel.scale + 5, hpBarWidth * hpPercentage, hpBarHeight)
    
    -- 绘制剩余时间条
    local timeBarWidth = buildingModel.size * 2
    local timeBarHeight = 4
    local timePercentage = attributes.remainingTime / attributes.lifespan
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', x - timeBarWidth/2, y + sprite:getHeight()/2 * buildingModel.scale + 10, timeBarWidth, timeBarHeight)
    
    love.graphics.setColor(0.2, 0.6, 1.0)
    love.graphics.rectangle('fill', x - timeBarWidth/2, y + sprite:getHeight()/2 * buildingModel.scale + 10, timeBarWidth * timePercentage, timeBarHeight)
    
    -- 如果建筑即将消失，添加闪烁效果
    if attributes.remainingTime < 10 and math.floor(status.animTime * 4) % 2 == 0 then
        love.graphics.setColor(1, 0.3, 0.3, 0.3)
        love.graphics.draw(
            sprite, 
            x, 
            y + breathOffset, 
            0,                        -- 旋转角度
            buildingModel.scale * 1.1,         -- X缩放（略大一些）
            buildingModel.scale * 1.1,         -- Y缩放（略大一些）
            sprite:getWidth()/2, -- 中心点X
            sprite:getHeight()/2 -- 中心点Y
        )
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 添加批量绘制方法
function BuildingView:drawAll(buildings)
    for _, building in ipairs(buildings) do
        self:draw(building)
    end
end

return BuildingView 