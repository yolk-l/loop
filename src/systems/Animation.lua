-- 动画系统
local AnimationSystem = {}

-- 引入anim8库
local anim8 = require('lib/anim8')

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

-- 初始化动画系统
function AnimationSystem.initialize()
    -- 加载所有精灵表
    resources.images.player = love.graphics.newImage("assets/sprites/player_sheet.png")
    resources.images.slime = love.graphics.newImage("assets/sprites/slime_sheet.png")
    resources.images.goblin = love.graphics.newImage("assets/sprites/goblin_sheet.png")
    resources.images.skeleton = love.graphics.newImage("assets/sprites/skeleton_sheet.png")
    
    -- 创建网格
    -- 玩家网格 (16x16像素每帧)
    resources.grids.player = anim8.newGrid(16, 16, resources.images.player:getWidth(), resources.images.player:getHeight())
    
    -- 怪物网格
    resources.grids.slime = anim8.newGrid(16, 16, resources.images.slime:getWidth(), resources.images.slime:getHeight())
    resources.grids.goblin = anim8.newGrid(16, 16, resources.images.goblin:getWidth(), resources.images.goblin:getHeight())
    resources.grids.skeleton = anim8.newGrid(16, 16, resources.images.skeleton:getWidth(), resources.images.skeleton:getHeight())
    
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