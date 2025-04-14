-- MapController类
local MapController = {}
MapController.__index = MapController

local MapModel = require('src/models/MapModel')
local MapView = require('src/views/MapView')
local TerrainConfig = require('config/terrain')

function MapController:new()
    local self = setmetatable({}, MapController)
    self.model = MapModel:new()
    self.view = MapView:new()
    self:generateMap()
    self:regenerate()
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

function MapController:generateMap()
    -- 生成不同的种子用于不同的地形层
    local waterSeed = math.random(1, 1000)
    local forestSeed = math.random(1, 1000)
    local sandSeed = math.random(1, 1000)
    local mountainSeed = math.random(1, 1000)
    local snowSeed = math.random(1, 1000)
    local swampSeed = math.random(1, 1000)
    local volcanoSeed = math.random(1, 1000)
    
    -- 初始化地图
    for y = 1, self.model.gridHeight do
        self.model.tiles[y] = {}
        for x = 1, self.model.gridWidth do
            -- 生成各种地形的噪声值
            local waterNoise = self:perlinNoise(x/6, y/6, waterSeed, 4)  -- 水域
            local forestNoise = self:perlinNoise(x/8, y/8, forestSeed, 3)  -- 森林
            local sandNoise = self:perlinNoise(x/5, y/5, sandSeed, 2)  -- 沙地
            local mountainNoise = self:perlinNoise(x/7, y/7, mountainSeed, 4)  -- 山地
            local snowNoise = self:perlinNoise(x/8, y/8, snowSeed, 3)  -- 雪地
            local swampNoise = self:perlinNoise(x/5, y/5, swampSeed, 2)  -- 沼泽
            local volcanoNoise = self:perlinNoise(x/9, y/9, volcanoSeed, 3)  -- 火山
            
            -- 添加全局高度图，将世界分为不同的高度区域
            local heightNoise = self:perlinNoise(x/12, y/12, 12345, 4)
            
            -- 默认为草地
            local terrainType = TerrainConfig.TERRAIN_TYPES.GRASS
            
            -- 根据高度和噪声值决定地形
            if heightNoise < 0.3 then
                -- 低地: 水域、沙地、沼泽
                if waterNoise > 0.6 then
                    terrainType = TerrainConfig.TERRAIN_TYPES.WATER
                elseif sandNoise > 0.7 and waterNoise > 0.4 then
                    terrainType = TerrainConfig.TERRAIN_TYPES.SAND
                elseif swampNoise > 0.7 and waterNoise > 0.3 and waterNoise < 0.6 then
                    terrainType = TerrainConfig.TERRAIN_TYPES.SWAMP
                end
            elseif heightNoise < 0.6 then
                -- 中地: 草地、森林
                if forestNoise > 0.6 then
                    terrainType = TerrainConfig.TERRAIN_TYPES.FOREST
                end
                
                -- 沿水边生成沙地和沼泽
                if waterNoise > 0.5 and waterNoise < 0.6 then
                    if sandNoise > 0.6 then
                        terrainType = TerrainConfig.TERRAIN_TYPES.SAND
                    elseif swampNoise > 0.7 then
                        terrainType = TerrainConfig.TERRAIN_TYPES.SWAMP
                    end
                end
            elseif heightNoise < 0.85 then
                -- 高地: 山地
                if mountainNoise > 0.6 then
                    terrainType = TerrainConfig.TERRAIN_TYPES.MOUNTAIN
                    
                    -- 山顶有时有雪
                    if heightNoise > 0.75 and snowNoise > 0.7 then
                        terrainType = TerrainConfig.TERRAIN_TYPES.SNOW
                    end
                end
            else
                -- 最高地: 雪地，偶尔有火山
                if volcanoNoise > 0.85 then
                    terrainType = TerrainConfig.TERRAIN_TYPES.VOLCANO
                else
                    terrainType = TerrainConfig.TERRAIN_TYPES.SNOW
                end
            end
            
            self.model.tiles[y][x] = terrainType
        end
    end
    
    -- 后处理：平滑地形
    self:smoothTerrain()
    
    -- 后处理：确保水域周围有沙地或沼泽
    self:postProcessTerrain()
end

function MapController:perlinNoise(x, y, seed, octaves)
    -- 生成柏林噪声
    local noise = 0
    local amplitude = 1.0
    local frequency = 1.0
    local persistence = 0.5
    local totalAmplitude = 0

    for i = 1, octaves do
        local sx = x * frequency
        local sy = y * frequency
        local ix = math.floor(sx)
        local iy = math.floor(sy)
        local fx = sx - ix
        local fy = sy - iy

        local v1 = self:smoothNoise(ix, iy, seed)
        local v2 = self:smoothNoise(ix + 1, iy, seed)
        local v3 = self:smoothNoise(ix, iy + 1, seed)
        local v4 = self:smoothNoise(ix + 1, iy + 1, seed)

        local i1 = self:interpolate(v1, v2, fx)
        local i2 = self:interpolate(v3, v4, fx)
        local value = self:interpolate(i1, i2, fy)

        noise = noise + value * amplitude
        totalAmplitude = totalAmplitude + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end

    return noise / totalAmplitude
end

function MapController:smoothNoise(x, y, seed)
    local corners = (
        self:noise(x-1, y-1, seed) + self:noise(x+1, y-1, seed) +
        self:noise(x-1, y+1, seed) + self:noise(x+1, y+1, seed)
    ) / 16
    local sides = (
        self:noise(x-1, y, seed) + self:noise(x+1, y, seed) +
        self:noise(x, y-1, seed) + self:noise(x, y+1, seed)
    ) / 8
    local center = self:noise(x, y, seed) / 4
    return corners + sides + center
end

function MapController:noise(x, y, seed)
    local n = x * 113 + y * 157 + seed * 1223
    n = n * n * n
    n = math.fmod(math.floor(n / 8192), 256)
    return n / 255.0
end

function MapController:interpolate(a, b, x)
    local ft = x * 3.1415927
    local f = (1 - math.cos(ft)) * 0.5
    return a * (1 - f) + b * f
end

function MapController:smoothTerrain()
    -- 平滑地形，避免孤立的地块
    local changes = {}
    
    -- 临时复制地图
    local tempMap = {}
    for y = 1, self.model.gridHeight do
        tempMap[y] = {}
        for x = 1, self.model.gridWidth do
            tempMap[y][x] = self.model.tiles[y][x]
        end
    end
    
    -- 平滑算法
    for y = 2, self.model.gridHeight - 1 do
        for x = 2, self.model.gridWidth - 1 do
            -- 统计周围8个格子的地形类型
            local terrainCounts = {}
            
            for ny = y-1, y+1 do
                for nx = x-1, x+1 do
                    local terrain = tempMap[ny][nx]
                    terrainCounts[terrain] = (terrainCounts[terrain] or 0) + 1
                end
            end
            
            -- 找到出现次数最多的地形类型
            local maxCount = 0
            local dominantTerrain = tempMap[y][x]
            for terrain, count in pairs(terrainCounts) do
                if count > maxCount then
                    maxCount = count
                    dominantTerrain = terrain
                end
            end
            
            -- 如果当前地形不是最常见的地形，进行更改
            if tempMap[y][x] ~= dominantTerrain then
                changes[#changes + 1] = {x = x, y = y, terrain = dominantTerrain}
            end
        end
    end
    
    -- 应用更改
    for _, change in ipairs(changes) do
        self.model.tiles[change.y][change.x] = change.terrain
    end
end

function MapController:postProcessTerrain()
    -- 确保水域周围有沙地或沼泽
    for y = 2, self.model.gridHeight - 1 do
        for x = 2, self.model.gridWidth - 1 do
            if self.model.tiles[y][x] == TerrainConfig.TERRAIN_TYPES.WATER then
                for ny = y-1, y+1 do
                    for nx = x-1, x+1 do
                        if self.model.tiles[ny][nx] == TerrainConfig.TERRAIN_TYPES.GRASS then
                            self.model.tiles[ny][nx] = TerrainConfig.TERRAIN_TYPES.SAND
                        end
                    end
                end
            end
        end
    end
end

return MapController 