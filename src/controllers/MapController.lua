-- MapController类
local MapController = {}
MapController.__index = MapController

local MapModel = require('src/models/MapModel')
local MapView = require('src/views/MapView')

function MapController:new()
    local self = setmetatable({}, MapController)
    self.model = MapModel:new()
    self.view = MapView:new()
    return self
end

function MapController:draw()
    self.view:draw(self.model)
end

function MapController:getTerrainAt(x, y)
    return self.model:getTerrainAt(x, y)
end

function MapController:regenerate()
    self.model:generate()
end

function MapController:canBuildAt(x, y, type)
    -- 基本地形检查
    local terrain = self.model:getTerrainAt(x, y)
    if not terrain then
        return false  -- 地图外不能建造
    end
    
    local TerrainConfig = require('config/terrain')
    
    -- 检查地形是否可建造
    local canBuild = false
    
    -- 不同的建筑对地形有不同的要求
    if type == "slime_nest" then
        canBuild = terrain == TerrainConfig.TERRAIN_TYPES.GRASS or
                   terrain == TerrainConfig.TERRAIN_TYPES.SWAMP
    elseif type == "goblin_hut" then
        canBuild = terrain == TerrainConfig.TERRAIN_TYPES.GRASS or
                   terrain == TerrainConfig.TERRAIN_TYPES.FOREST
    elseif type == "skeleton_tomb" then
        canBuild = terrain ~= TerrainConfig.TERRAIN_TYPES.WATER and
                   terrain ~= TerrainConfig.TERRAIN_TYPES.VOLCANO
    elseif type == "zombie_graveyard" then
        canBuild = terrain == TerrainConfig.TERRAIN_TYPES.GRASS or
                   terrain == TerrainConfig.TERRAIN_TYPES.FOREST
    elseif type == "wolf_den" then
        canBuild = terrain == TerrainConfig.TERRAIN_TYPES.FOREST or
                   terrain == TerrainConfig.TERRAIN_TYPES.MOUNTAIN
    elseif type == "ghost_manor" then
        canBuild = terrain == TerrainConfig.TERRAIN_TYPES.GRASS or
                   terrain == TerrainConfig.TERRAIN_TYPES.FOREST
    elseif type == "golem_forge" then
        canBuild = terrain == TerrainConfig.TERRAIN_TYPES.MOUNTAIN or
                   terrain == TerrainConfig.TERRAIN_TYPES.VOLCANO
    elseif type == "witch_hut" then
        canBuild = terrain == TerrainConfig.TERRAIN_TYPES.SWAMP or
                   terrain == TerrainConfig.TERRAIN_TYPES.FOREST
    elseif type == "dragon_cave" then
        canBuild = terrain == TerrainConfig.TERRAIN_TYPES.MOUNTAIN or
                   terrain == TerrainConfig.TERRAIN_TYPES.VOLCANO
    else
        -- 默认情况：不允许在水面上建造
        canBuild = terrain ~= TerrainConfig.TERRAIN_TYPES.WATER
    end
    
    return canBuild
end

function MapController:getDimensions()
    return self.model:getDimensions()
end

function MapController:getModel()
    return self.model
end

function MapController:checkCollision(entity1, entity2)
    -- 简单的圆形碰撞检测
    local dx = entity1.x - entity2.x
    local dy = entity1.y - entity2.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    return distance < (entity1.size + entity2.size)
end

function MapController:getRandomPosition(margin)
    margin = margin or 50
    local dimensions = self.model:getDimensions()
    local x = margin + math.random(dimensions.pixelWidth - 2 * margin)
    local y = margin + math.random(dimensions.pixelHeight - 2 * margin)
    return x, y
end

function MapController:getRandomValidPosition(entityType, playerX, playerY, minDistFromPlayer)
    local dimensions = self.model:getDimensions()
    local margin = 50
    minDistFromPlayer = minDistFromPlayer or 150
    
    -- 最多尝试30次找到合适的位置
    for i = 1, 30 do
        local x = margin + math.random(dimensions.pixelWidth - 2 * margin)
        local y = margin + math.random(dimensions.pixelHeight - 2 * margin)
        
        -- 检查是否在玩家防御范围外
        local dx = x - playerX
        local dy = y - playerY
        local distFromPlayer = math.sqrt(dx * dx + dy * dy)
        
        if distFromPlayer >= minDistFromPlayer and self:canBuildAt(x, y, entityType) then
            return x, y
        end
    end
    
    -- 如果找不到合适的位置，返回nil
    return nil, nil
end

return MapController 