-- 动画系统
local AnimationSystem = {}

-- 引入anim8库
local anim8 = require('lib/anim8')

-- 引入像素精灵生成器
local PixelSprites = require('src/utils/PixelSprites')

-- 存储游戏所有的资源图片、精灵表和动画
local resources = {
    images = {},     -- 存储所有图片
    grids = {},      -- 存储所有网格
    animations = {}  -- 存储所有动画
}

-- 预先定义的动画类型
local ANIMATION_TYPES = {
    PLAYER_IDLE = "player_idle",
    PLAYER_ATTACK = "player_attack",
    MONSTER_SLIME_IDLE = "monster_slime_idle",
    MONSTER_SLIME_MOVE = "monster_slime_move",
    MONSTER_GOBLIN_IDLE = "monster_goblin_idle",
    MONSTER_GOBLIN_MOVE = "monster_goblin_move",
    MONSTER_SKELETON_IDLE = "monster_skeleton_idle",
    MONSTER_SKELETON_MOVE = "monster_skeleton_move",
    MONSTER_SKELETON_ATTACK = "monster_skeleton_attack"
}

-- 确保资源目录存在
local function ensureResourceDirectories()
    love.filesystem.createDirectory("assets")
    love.filesystem.createDirectory("assets/sprites")
end

-- 生成简单的单帧图像
local function generateSimpleImage(type, size, color)
    local image
    if type == "monster" then
        image = PixelSprites.generateMonsterSprite(size, color)
    elseif type == "building" then
        image = PixelSprites.generateBuildingSprite(size, color)
    elseif type == "item" then
        image = PixelSprites.generateItemSprite(size, color)
    elseif type == "effect" then
        image = PixelSprites.generateEffectSprite(size, color)
    else -- 默认为玩家
        -- 生成蓝色圆形玩家
        local imageData = love.image.newImageData(size, size)
        local center = size/2 - 0.5
        local radius = size/3
        
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                local dx = x - center
                local dy = y - center
                local distance = math.sqrt(dx*dx + dy*dy)
                
                if distance <= radius then
                    imageData:setPixel(x, y, 0.2, 0.6, 1.0, 1) -- 蓝色
                else
                    imageData:setPixel(x, y, 0, 0, 0, 0) -- 透明
                end
            end
        end
        
        image = love.graphics.newImage(imageData)
    end
    
    return image
end

-- 尝试加载图像，如果不存在则生成临时图像
local function loadOrGenerateImage(path, type, size, color)
    if love.filesystem.getInfo(path) then
        return love.graphics.newImage(path)
    else
        print("警告: 找不到图像 " .. path .. "，生成临时图像代替")
        return generateSimpleImage(type, size or 16, color)
    end
end

-- 初始化动画系统
function AnimationSystem.initialize()
    -- 确保资源目录存在
    ensureResourceDirectories()
    
    -- 加载所有精灵表，如果不存在则生成简单版本
    resources.images.player = loadOrGenerateImage("assets/sprites/player_sheet.png", "player", 16, PixelSprites.COLORS.BLUE)
    resources.images.slime = loadOrGenerateImage("assets/sprites/slime_sheet.png", "monster", 16, PixelSprites.COLORS.GREEN)
    resources.images.goblin = loadOrGenerateImage("assets/sprites/goblin_sheet.png", "monster", 16, PixelSprites.COLORS.ORANGE)
    resources.images.skeleton = loadOrGenerateImage("assets/sprites/skeleton_sheet.png", "monster", 16, PixelSprites.COLORS.GRAY)
    
    -- 添加额外资源
    resources.images.building = loadOrGenerateImage("assets/sprites/building_sheet.png", "building", 32, PixelSprites.COLORS.BLUE)
    resources.images.item = loadOrGenerateImage("assets/sprites/item_sheet.png", "item", 8, PixelSprites.COLORS.YELLOW)
    resources.images.effect = loadOrGenerateImage("assets/sprites/effect_sheet.png", "effect", 16, PixelSprites.COLORS.WHITE)
    
    -- 创建网格
    -- 玩家网格 (16x16像素每帧)
    resources.grids.player = anim8.newGrid(16, 16, resources.images.player:getWidth(), resources.images.player:getHeight())
    
    -- 怪物网格
    resources.grids.slime = anim8.newGrid(16, 16, resources.images.slime:getWidth(), resources.images.slime:getHeight())
    resources.grids.goblin = anim8.newGrid(16, 16, resources.images.goblin:getWidth(), resources.images.goblin:getHeight())
    resources.grids.skeleton = anim8.newGrid(16, 16, resources.images.skeleton:getWidth(), resources.images.skeleton:getHeight())
    
    -- 额外网格
    resources.grids.building = anim8.newGrid(32, 32, resources.images.building:getWidth(), resources.images.building:getHeight())
    resources.grids.item = anim8.newGrid(8, 8, resources.images.item:getWidth(), resources.images.item:getHeight())
    resources.grids.effect = anim8.newGrid(16, 16, resources.images.effect:getWidth(), resources.images.effect:getHeight())
    
    -- 创建动画
    -- 玩家动画
    resources.animations[ANIMATION_TYPES.PLAYER_IDLE] = anim8.newAnimation(resources.grids.player('1-4', 1), 0.2)
    resources.animations[ANIMATION_TYPES.PLAYER_ATTACK] = anim8.newAnimation(resources.grids.player('1-4', 2), 0.1)
    
    -- 史莱姆动画
    resources.animations[ANIMATION_TYPES.MONSTER_SLIME_IDLE] = anim8.newAnimation(resources.grids.slime('1-4', 1), 0.3)
    resources.animations[ANIMATION_TYPES.MONSTER_SLIME_MOVE] = anim8.newAnimation(resources.grids.slime('1-4', 2), 0.2)
    
    -- 哥布林动画
    resources.animations[ANIMATION_TYPES.MONSTER_GOBLIN_IDLE] = anim8.newAnimation(resources.grids.goblin('1-4', 1), 0.2)
    resources.animations[ANIMATION_TYPES.MONSTER_GOBLIN_MOVE] = anim8.newAnimation(resources.grids.goblin('1-4', 2), 0.15)
    
    -- 骷髅动画
    resources.animations[ANIMATION_TYPES.MONSTER_SKELETON_IDLE] = anim8.newAnimation(resources.grids.skeleton('1-4', 1), 0.2)
    resources.animations[ANIMATION_TYPES.MONSTER_SKELETON_MOVE] = anim8.newAnimation(resources.grids.skeleton('1-4', 2), 0.15)
    resources.animations[ANIMATION_TYPES.MONSTER_SKELETON_ATTACK] = anim8.newAnimation(resources.grids.skeleton('1-4', 3), 0.1)
end

-- 获取单帧图像（适用于非动画对象，如建筑物、物品等）
function AnimationSystem.getImage(type, customColor)
    if type == "building" then
        return resources.images.building
    elseif type == "item" then
        return resources.images.item
    elseif type == "effect" then
        return resources.images.effect
    elseif type == "monster" then
        -- 随机返回一个怪物图像
        local monsters = {resources.images.slime, resources.images.goblin, resources.images.skeleton}
        return monsters[math.random(1, #monsters)]
    elseif type == "custom" then
        -- 根据传入的自定义颜色生成图像
        local size = 16
        local color = customColor or PixelSprites.COLORS.WHITE
        return generateSimpleImage("monster", size, color)
    else
        return resources.images.player
    end
end

-- 获取动画实例（返回一个克隆，以便每个实体有自己的动画状态）
function AnimationSystem.getAnimation(animationType)
    if resources.animations[animationType] then
        return resources.animations[animationType]:clone()
    end
    return nil
end

-- 根据怪物类型获取对应的动画
function AnimationSystem.getMonsterAnimation(monsterType, state)
    if monsterType == "slime" then
        if state == "idle" or state == "attack" then
            return AnimationSystem.getAnimation(ANIMATION_TYPES.MONSTER_SLIME_IDLE)
        else
            return AnimationSystem.getAnimation(ANIMATION_TYPES.MONSTER_SLIME_MOVE)
        end
    elseif monsterType == "goblin" then
        if state == "idle" then
            return AnimationSystem.getAnimation(ANIMATION_TYPES.MONSTER_GOBLIN_IDLE)
        else
            return AnimationSystem.getAnimation(ANIMATION_TYPES.MONSTER_GOBLIN_MOVE)
        end
    elseif monsterType == "skeleton" then
        if state == "idle" then
            return AnimationSystem.getAnimation(ANIMATION_TYPES.MONSTER_SKELETON_IDLE)
        elseif state == "attack" then
            return AnimationSystem.getAnimation(ANIMATION_TYPES.MONSTER_SKELETON_ATTACK)
        else
            return AnimationSystem.getAnimation(ANIMATION_TYPES.MONSTER_SKELETON_MOVE)
        end
    end
    
    -- 默认返回史莱姆动画
    return AnimationSystem.getAnimation(ANIMATION_TYPES.MONSTER_SLIME_IDLE)
end

-- 导出动画类型常量
AnimationSystem.TYPES = ANIMATION_TYPES

-- 获取动画系统资源
function AnimationSystem.getResources()
    return resources
end

return AnimationSystem 