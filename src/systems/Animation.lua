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
    MONSTER_SKELETON_ATTACK = "monster_skeleton_attack",
    MONSTER_ZOMBIE_IDLE = "monster_zombie_idle",
    MONSTER_ZOMBIE_MOVE = "monster_zombie_move",
    MONSTER_ZOMBIE_ATTACK = "monster_zombie_attack",
    MONSTER_WOLF_IDLE = "monster_wolf_idle",
    MONSTER_WOLF_MOVE = "monster_wolf_move",
    MONSTER_WOLF_ATTACK = "monster_wolf_attack",
    MONSTER_WITCH_IDLE = "monster_witch_idle",
    MONSTER_WITCH_MOVE = "monster_witch_move",
    MONSTER_WITCH_ATTACK = "monster_witch_attack",
    MONSTER_GHOST_IDLE = "monster_ghost_idle",
    MONSTER_GHOST_MOVE = "monster_ghost_move",
    MONSTER_GHOST_ATTACK = "monster_ghost_attack",
    MONSTER_GOLEM_IDLE = "monster_golem_idle",
    MONSTER_GOLEM_MOVE = "monster_golem_move",
    MONSTER_GOLEM_ATTACK = "monster_golem_attack",
    MONSTER_DRAGON_IDLE = "monster_dragon_idle",
    MONSTER_DRAGON_MOVE = "monster_dragon_move",
    MONSTER_DRAGON_ATTACK = "monster_dragon_attack"
}

-- 确保资源目录存在
local function ensureResourceDirectories()
    love.filesystem.createDirectory("assets")
    love.filesystem.createDirectory("assets/sprites")
    love.filesystem.createDirectory("assets/sprites/player")
    love.filesystem.createDirectory("assets/sprites/monsters")
    love.filesystem.createDirectory("assets/sprites/equipments")
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
    resources.images.player = loadOrGenerateImage("assets/sprites/player/player_sheet.png", "player", 16, PixelSprites.COLORS.BLUE)
    resources.images.slime = loadOrGenerateImage("assets/sprites/monsters/slime_sheet.png", "monster", 16, PixelSprites.COLORS.GREEN)
    resources.images.goblin = loadOrGenerateImage("assets/sprites/monsters/goblin_sheet.png", "monster", 16, PixelSprites.COLORS.ORANGE)
    resources.images.skeleton = loadOrGenerateImage("assets/sprites/monsters/skeleton_sheet.png", "monster", 16, PixelSprites.COLORS.GRAY)
    resources.images.wolf = loadOrGenerateImage("assets/sprites/monsters/wolf_sheet.png", "monster", 16, PixelSprites.COLORS.PURPLE)
    resources.images.zombie = loadOrGenerateImage("assets/sprites/monsters/zombie_sheet.png", "monster", 16, PixelSprites.COLORS.RED)
    resources.images.witch = loadOrGenerateImage("assets/sprites/monsters/witch_sheet.png", "monster", 16, PixelSprites.COLORS.YELLOW)
    resources.images.ghost = loadOrGenerateImage("assets/sprites/monsters/ghost_sheet.png", "monster", 16, PixelSprites.COLORS.GRAY)
    resources.images.golem = loadOrGenerateImage("assets/sprites/monsters/golem_sheet.png", "monster", 16, PixelSprites.COLORS.GRAY)
    resources.images.dragon = loadOrGenerateImage("assets/sprites/monsters/dragon_sheet.png", "monster", 16, PixelSprites.COLORS.RED)
    
    -- 添加额外资源
    resources.images.building = loadOrGenerateImage("assets/sprites/building_sheet.png", "building", 32, PixelSprites.COLORS.BLUE)
    resources.images.item = loadOrGenerateImage("assets/sprites/equipments/item_sheet.png", "item", 8, PixelSprites.COLORS.YELLOW)
    resources.images.effect = loadOrGenerateImage("assets/sprites/effect_sheet.png", "effect", 16, PixelSprites.COLORS.WHITE)
    
    -- 创建网格
    -- 玩家网格 (16x16像素每帧)
    resources.grids.player = anim8.newGrid(16, 16, resources.images.player:getWidth(), resources.images.player:getHeight())
    
    -- 怪物网格
    resources.grids.slime = anim8.newGrid(16, 16, resources.images.slime:getWidth(), resources.images.slime:getHeight())
    resources.grids.goblin = anim8.newGrid(16, 16, resources.images.goblin:getWidth(), resources.images.goblin:getHeight())
    resources.grids.skeleton = anim8.newGrid(16, 16, resources.images.skeleton:getWidth(), resources.images.skeleton:getHeight())
    resources.grids.wolf = anim8.newGrid(16, 16, resources.images.wolf:getWidth(), resources.images.wolf:getHeight())
    resources.grids.zombie = anim8.newGrid(16, 16, resources.images.zombie:getWidth(), resources.images.zombie:getHeight())
    resources.grids.witch = anim8.newGrid(16, 16, resources.images.witch:getWidth(), resources.images.witch:getHeight())
    resources.grids.ghost = anim8.newGrid(16, 16, resources.images.ghost:getWidth(), resources.images.ghost:getHeight())
    resources.grids.golem = anim8.newGrid(16, 16, resources.images.golem:getWidth(), resources.images.golem:getHeight())
    resources.grids.dragon = anim8.newGrid(16, 16, resources.images.dragon:getWidth(), resources.images.dragon:getHeight())
    
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
    
    -- 女巫动画
    resources.animations[ANIMATION_TYPES.MONSTER_WITCH_IDLE] = anim8.newAnimation(resources.grids.witch('1-4', 1), 0.2)
    resources.animations[ANIMATION_TYPES.MONSTER_WITCH_MOVE] = anim8.newAnimation(resources.grids.witch('1-4', 2), 0.15)
    resources.animations[ANIMATION_TYPES.MONSTER_WITCH_ATTACK] = anim8.newAnimation(resources.grids.witch('1-4', 3), 0.1)

    -- 狼人动画
    resources.animations[ANIMATION_TYPES.MONSTER_WOLF_IDLE] = anim8.newAnimation(resources.grids.wolf('1-4', 1), 0.2)
    resources.animations[ANIMATION_TYPES.MONSTER_WOLF_MOVE] = anim8.newAnimation(resources.grids.wolf('1-4', 2), 0.15)
    resources.animations[ANIMATION_TYPES.MONSTER_WOLF_ATTACK] = anim8.newAnimation(resources.grids.wolf('1-4', 3), 0.1)

    -- 僵尸动画
    resources.animations[ANIMATION_TYPES.MONSTER_ZOMBIE_IDLE] = anim8.newAnimation(resources.grids.zombie('1-4', 1), 0.2)
    resources.animations[ANIMATION_TYPES.MONSTER_ZOMBIE_MOVE] = anim8.newAnimation(resources.grids.zombie('1-4', 2), 0.15)
    resources.animations[ANIMATION_TYPES.MONSTER_ZOMBIE_ATTACK] = anim8.newAnimation(resources.grids.zombie('1-4', 3), 0.1)

    -- 石头巨人动画
    resources.animations[ANIMATION_TYPES.MONSTER_GOLEM_IDLE] = anim8.newAnimation(resources.grids.golem('1-4', 1), 0.2)
    resources.animations[ANIMATION_TYPES.MONSTER_GOLEM_MOVE] = anim8.newAnimation(resources.grids.golem('1-4', 2), 0.15)
    resources.animations[ANIMATION_TYPES.MONSTER_GOLEM_ATTACK] = anim8.newAnimation(resources.grids.golem('1-4', 3), 0.1)
    

    -- 龙动画
    resources.animations[ANIMATION_TYPES.MONSTER_DRAGON_IDLE] = anim8.newAnimation(resources.grids.dragon('1-4', 1), 0.2)
    resources.animations[ANIMATION_TYPES.MONSTER_DRAGON_MOVE] = anim8.newAnimation(resources.grids.dragon('1-4', 2), 0.15)
    resources.animations[ANIMATION_TYPES.MONSTER_DRAGON_ATTACK] = anim8.newAnimation(resources.grids.dragon('1-4', 3), 0.1)
    

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
    -- 获取怪物配置
    local monsterConfig = require('config/monsters')
    
    -- 检查该怪物是否存在配置
    if monsterConfig[monsterType] and monsterConfig[monsterType].animations and monsterConfig[monsterType].animations[state] then
        -- 从配置中获取动画类型
        local animationType = monsterConfig[monsterType].animations[state]
        return AnimationSystem.getAnimation(animationType)
    end
    
    -- 如果没有找到对应配置，使用默认动画
    return AnimationSystem.getAnimation(ANIMATION_TYPES.MONSTER_SLIME_IDLE)
end

-- 导出动画类型常量
AnimationSystem.TYPES = ANIMATION_TYPES

-- 获取动画系统资源
function AnimationSystem.getResources()
    return resources
end

return AnimationSystem 