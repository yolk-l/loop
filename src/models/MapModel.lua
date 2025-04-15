-- 地图模型类
local MapModel = {}
MapModel.__index = MapModel

-- 引入地形配置
local TerrainConfig = require('config/terrain')

function MapModel.new()
    
    math.randomseed(os.time())
    local mt = setmetatable({
        tileSize = 20,
        gridWidth = 40,
        gridHeight = 30,
        highResScale = 4,
        tiles = {},
        decorations = {},
        decorationData = {},
        highResMap = {},
    }, MapModel)
    return mt
end

-- 简单的噪声函数
function MapModel:noise(x, y, seed)
    local n = x * 113 + y * 157 + seed * 1223
    n = n * n * n
    n = math.fmod(math.floor(n / 8192), 256)
    return n / 255.0
end

-- 平滑噪声
function MapModel:smoothNoise(x, y, seed)
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

-- 插值
function MapModel:interpolate(a, b, x)
    local ft = x * 3.1415927
    local f = (1 - math.cos(ft)) * 0.5
    return a * (1 - f) + b * f
end

-- 生成柏林噪声
function MapModel:perlinNoise(x, y, seed, octaves)
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

-- 平滑地形，避免孤立的地块
function MapModel:smoothTerrain()
    local tempMap = {}
    
    -- 临时复制地图
    for y = 1, self.gridHeight do
        tempMap[y] = {}
        for x = 1, self.gridWidth do
            tempMap[y][x] = self.tiles[y][x]
        end
    end
    
    -- 平滑算法
    for y = 2, self.gridHeight - 1 do
        for x = 2, self.gridWidth - 1 do
            -- 统计周围8个格子的地形类型
            local terrainCounts = {}
            
            for ny = y-1, y+1 do
                for nx = x-1, x+1 do
                    if not (nx == x and ny == y) then
                        local terrain = self.tiles[ny][nx]
                        terrainCounts[terrain] = (terrainCounts[terrain] or 0) + 1
                    end
                end
            end
            
            -- 找出出现最多的地形类型
            local mostCommonTerrain = self.tiles[y][x]
            local maxCount = 0
            
            for terrain, count in pairs(terrainCounts) do
                if count > maxCount then
                    maxCount = count
                    mostCommonTerrain = terrain
                end
            end
            
            -- 如果周围超过5个格子都是同一类型，则转换当前格子
            if maxCount >= 5 and mostCommonTerrain ~= self.tiles[y][x] then
                tempMap[y][x] = mostCommonTerrain
            end
        end
    end
    
    -- 应用更改
    self.tiles = tempMap
end

-- 后处理：确保地形边界自然过渡
function MapModel:postProcessTerrain()
    local changes = {}
    
    for y = 2, self.gridHeight - 1 do
        for x = 2, self.gridWidth - 1 do
            -- 水域周围生成沙地或沼泽
            if self.tiles[y][x] == TerrainConfig.TERRAIN_TYPES.WATER then
                for ny = y-1, y+1 do
                    for nx = x-1, x+1 do
                        if self:isValidPosition(nx, ny) and
                           self.tiles[ny][nx] ~= TerrainConfig.TERRAIN_TYPES.WATER and
                           self.tiles[ny][nx] ~= TerrainConfig.TERRAIN_TYPES.SAND and
                           self.tiles[ny][nx] ~= TerrainConfig.TERRAIN_TYPES.SWAMP then
                            
                            -- 50%几率为沙地，50%几率为沼泽
                            if math.random() < 0.5 then
                                table.insert(changes, {x = nx, y = ny, type = TerrainConfig.TERRAIN_TYPES.SAND})
                            else
                                table.insert(changes, {x = nx, y = ny, type = TerrainConfig.TERRAIN_TYPES.SWAMP})
                            end
                        end
                    end
                end
            end
            
            -- 山地和雪地之间的过渡
            if self.tiles[y][x] == TerrainConfig.TERRAIN_TYPES.MOUNTAIN then
                for ny = y-1, y+1 do
                    for nx = x-1, x+1 do
                        if self:isValidPosition(nx, ny) and
                           self.tiles[ny][nx] == TerrainConfig.TERRAIN_TYPES.SNOW then
                            -- 山地旁边的雪地会扩展到山地上
                            table.insert(changes, {x = x, y = y, type = TerrainConfig.TERRAIN_TYPES.SNOW})
                            break
                        end
                    end
                end
            end
            
            -- 火山周围生成山地
            if self.tiles[y][x] == TerrainConfig.TERRAIN_TYPES.VOLCANO then
                for ny = y-2, y+2 do
                    for nx = x-2, x+2 do
                        if self:isValidPosition(nx, ny) and
                           not (nx == x and ny == y) and
                           math.random() < 0.7 and
                           self.tiles[ny][nx] ~= TerrainConfig.TERRAIN_TYPES.VOLCANO and
                           self.tiles[ny][nx] ~= TerrainConfig.TERRAIN_TYPES.MOUNTAIN and
                           self.tiles[ny][nx] ~= TerrainConfig.TERRAIN_TYPES.WATER then
                            
                            table.insert(changes, {x = nx, y = ny, type = TerrainConfig.TERRAIN_TYPES.MOUNTAIN})
                        end
                    end
                end
            end
        end
    end
    
    -- 应用更改
    for _, change in ipairs(changes) do
        self.tiles[change.y][change.x] = change.type
    end
end

-- 辅助函数：检查坐标是否在地图范围内
function MapModel:isValidPosition(x, y)
    return x >= 1 and x <= self.gridWidth and y >= 1 and y <= self.gridHeight
end

-- 生成高分辨率地形数据，用于绘制平滑过渡
function MapModel:generateHighResMap()
    self.highResMap = {}
    
    for y = 1, self.gridHeight do
        for x = 1, self.gridWidth do
            local baseTerrainType = self.tiles[y][x]
            
            -- 为每个格子内部生成高分辨率点
            for subY = 1, self.highResScale do
                local highResY = (y - 1) * self.highResScale + subY
                if not self.highResMap[highResY] then
                    self.highResMap[highResY] = {}
                end
                
                for subX = 1, self.highResScale do
                    local highResX = (x - 1) * self.highResScale + subX
                    
                    -- 初始化为基础地形
                    self.highResMap[highResY][highResX] = baseTerrainType
                    
                    -- 如果靠近格子边缘，可能受到相邻格子的影响
                    if subX == 1 or subY == 1 or subX == self.highResScale or subY == self.highResScale then
                        -- 检查相邻格子的地形类型
                        local neighborX = x
                        local neighborY = y
                        
                        if subX == 1 and x > 1 then
                            neighborX = x - 1
                        elseif subX == self.highResScale and x < self.gridWidth then
                            neighborX = x + 1
                        end
                        
                        if subY == 1 and y > 1 then
                            neighborY = y - 1
                        elseif subY == self.highResScale and y < self.gridHeight then
                            neighborY = y + 1
                        end
                        
                        if neighborX ~= x or neighborY ~= y then
                            local neighborTerrainType = self.tiles[neighborY][neighborX]
                            
                            -- 基于柏林噪声的随机性决定是否产生过渡效果
                            local noiseVal = self:noise(highResX * 0.1, highResY * 0.1, 42)
                            if noiseVal > 0.5 then  -- 50%的概率
                                self.highResMap[highResY][highResX] = neighborTerrainType
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- 平滑处理
    self:smoothHighResMap()
end

-- 平滑高分辨率地图，使地形过渡更自然
function MapModel:smoothHighResMap()
    -- 多次迭代平滑，使过渡更加自然
    for iteration = 1, 2 do
        local changes = {}
        
        -- 遍历高分辨率地图
        for y = 2, self.gridHeight * self.highResScale - 1 do
            for x = 2, self.gridWidth * self.highResScale - 1 do
                local currentType = self.highResMap[y][x]
                local neighborTypes = {}
                
                -- 收集周围8个方向的地形类型
                for dy = -1, 1 do
                    for dx = -1, 1 do
                        if dx ~= 0 or dy ~= 0 then  -- 跳过中心点
                            local nx, ny = x + dx, y + dy
                            local neighborType = self.highResMap[ny][nx]
                            if neighborType then
                                neighborTypes[neighborType] = (neighborTypes[neighborType] or 0) + 1
                            end
                        end
                    end
                end
                
                -- 找出最多的邻居类型
                local maxCount = 0
                local dominantType = currentType
                for terrainType, count in pairs(neighborTypes) do
                    if count > maxCount then
                        maxCount = count
                        dominantType = terrainType
                    end
                end
                
                -- 如果周围大多数是不同的地形类型，则有可能转换
                if dominantType ~= currentType and maxCount >= 5 and math.random() < 0.7 then
                    table.insert(changes, {x = x, y = y, type = dominantType})
                end
            end
        end
        
        -- 应用变更
        for _, change in ipairs(changes) do
            self.highResMap[change.y][change.x] = change.type
        end
    end
end

-- 生成装饰物
function MapModel:generateDecorations()
    self.decorations = {}
    self.decorationData = {}
    
    for y = 1, self.gridHeight do
        self.decorations[y] = {}
        self.decorationData[y] = {}
        for x = 1, self.gridWidth do
            local terrainType = self.tiles[y][x]
            local decorationConfig = TerrainConfig.TERRAIN_DECORATIONS[terrainType]
            
            self.decorationData[y][x] = {}
            
            if decorationConfig and math.random() < decorationConfig.chance then
                self.decorations[y][x] = true
                
                -- 预先计算装饰物的随机数据
                local data = self.decorationData[y][x]
                
                -- 根据不同地形类型预先生成随机数据
                if terrainType == TerrainConfig.TERRAIN_TYPES.GRASS then
                    -- 草地装饰
                    data.grassCount = math.random(2, 5)
                    data.grassData = {}
                    for j = 1, data.grassCount do
                        table.insert(data.grassData, {
                            greenShade = 0.5 + math.random() * 0.3,
                            x = math.random(5, self.tileSize - 5),
                            y = math.random(5, self.tileSize - 5),
                            height = self.tileSize / 6 + math.random() * self.tileSize / 6,
                            bend = (math.random() - 0.5) * 3
                        })
                    end
                    
                    -- 小花数据
                    data.hasFlower = math.random() < 0.2
                    if data.hasFlower then
                        local flowerColors = {
                            {1, 0.8, 0.2}, -- 黄色
                            {1, 0.4, 0.4}, -- 红色
                            {0.8, 0.4, 1}, -- 紫色
                            {1, 1, 1}      -- 白色
                        }
                        data.flower = {
                            x = math.random(5, self.tileSize - 5),
                            y = math.random(5, self.tileSize - 5),
                            color = flowerColors[math.random(1, #flowerColors)]
                        }
                    end
                
                elseif terrainType == TerrainConfig.TERRAIN_TYPES.WATER then
                    -- 水面装饰
                    data.smallWaveCount = math.random(0, 2)
                    data.smallWaves = {}
                    for i = 1, data.smallWaveCount do
                        table.insert(data.smallWaves, {
                            offsetX = math.random(-self.tileSize/4, self.tileSize/4),
                            offsetY = math.random(-self.tileSize/4, self.tileSize/4)
                        })
                    end
                    
                    -- 水草或小鱼
                    local randFeature = math.random()
                    if randFeature < 0.1 then
                        -- 水草
                        data.hasWeed = true
                        data.weed = {
                            x = math.random(5, self.tileSize - 5),
                            height = math.random(self.tileSize/8, self.tileSize/4)
                        }
                    elseif randFeature < 0.15 then
                        -- 小鱼
                        data.hasFish = true
                    end
                
                elseif terrainType == TerrainConfig.TERRAIN_TYPES.SAND then
                    -- 沙地装饰
                    data.stoneCount = math.random(1, 3)
                    data.stones = {}
                    for i = 1, data.stoneCount do
                        local itemType = math.random(1, 10)
                        if itemType <= 7 then
                            -- 石子
                            table.insert(data.stones, {
                                type = "stone",
                                shade = 0.5 + math.random() * 0.3,
                                size = self.tileSize / (8 + math.random() * 4),
                                x = math.random() * (self.tileSize - self.tileSize/8),
                                y = math.random() * (self.tileSize - self.tileSize/8),
                                isCircle = math.random() > 0.5
                            })
                        else
                            -- 贝壳
                            table.insert(data.stones, {
                                type = "shell",
                                x = math.random() * (self.tileSize - self.tileSize/6),
                                y = math.random() * (self.tileSize - self.tileSize/6)
                            })
                        end
                    end
                    
                    -- 脚印
                    data.hasFootprint = math.random() < 0.05
                    if data.hasFootprint then
                        data.footprint = {
                            x = math.random(self.tileSize/4, self.tileSize*3/4),
                            y = math.random(self.tileSize/4, self.tileSize*3/4)
                        }
                    end
                
                elseif terrainType == TerrainConfig.TERRAIN_TYPES.FOREST then
                    -- 森林装饰
                    data.treeX = self.tileSize/2 + math.random(-self.tileSize/10, self.tileSize/10)
                    data.treeY = self.tileSize/2 + math.random(-self.tileSize/10, self.tileSize/10)
                    data.treeType = math.random(1, 10)
                    
                    if data.treeType <= 6 then
                        -- 常规树
                        data.trunkWidth = self.tileSize/10 + math.random() * self.tileSize/20
                        data.trunkHeight = self.tileSize/2 + math.random() * self.tileSize/10
                        data.isRoundCanopy = math.random() > 0.5
                        data.canopySize = self.tileSize/3 + math.random() * self.tileSize/10
                        data.canopyWidth = self.tileSize/2 + math.random() * self.tileSize/10
                        data.canopyHeight = self.tileSize/2 + math.random() * self.tileSize/10
                        data.treeColor = 0.4 + math.random() * 0.2
                        
                        -- 果实
                        data.hasFruit = math.random() < 0.2
                        if data.hasFruit then
                            data.fruitCount = math.random(1, 3)
                            data.fruits = {}
                            for i = 1, data.fruitCount do
                                table.insert(data.fruits, {
                                    x = data.treeX + math.random(-self.tileSize/4, self.tileSize/4),
                                    y = data.treeY - math.random(0, self.tileSize/4)
                                })
                            end
                        end
                    end
                    
                    -- 蘑菇
                    data.hasMushroom = math.random() < 0.15
                    if data.hasMushroom then
                        local mushroomColors = {
                            {1, 0.3, 0.3},  -- 红色
                            {1, 0.8, 0.3},  -- 黄色
                            {0.8, 0.8, 0.8}, -- 白色
                            {0.6, 0.4, 0.2}  -- 棕色
                        }
                        data.mushroom = {
                            x = math.random(5, self.tileSize - 5),
                            y = self.tileSize - 10,
                            color = mushroomColors[math.random(1, #mushroomColors)]
                        }
                    end
                end
            else
                self.decorations[y][x] = false
            end
        end
    end
end

-- 获取指定坐标位置的地形类型
function MapModel:getTerrainAt(x, y)
    -- 将像素坐标转换为网格坐标
    local gridX = math.floor(x / self.tileSize) + 1
    local gridY = math.floor(y / self.tileSize) + 1
    
    -- 检查坐标是否在地图范围内
    if gridX >= 1 and gridX <= self.gridWidth and gridY >= 1 and gridY <= self.gridHeight then
        return self.tiles[gridY][gridX]
    end
    
    -- 默认返回nil表示坐标超出地图范围
    return nil
end

-- 重新生成地图
function MapModel:generate()
    self:generateHighResMap()
    self:generateDecorations()
end

-- 获取高分辨率地图数据
function MapModel:getHighResMap()
    return self.highResMap
end

-- 获取装饰物数据
function MapModel:getDecorations()
    return self.decorations
end

-- 获取装饰物详细数据
function MapModel:getDecorationData()
    return self.decorationData
end

-- 获取地图尺寸和格子大小
function MapModel:getDimensions()
    return {
        tileSize = self.tileSize,
        gridWidth = self.gridWidth,
        gridHeight = self.gridHeight,
        highResScale = self.highResScale,
        pixelWidth = self.gridWidth * self.tileSize,
        pixelHeight = self.gridHeight * self.tileSize
    }
end

return MapModel 