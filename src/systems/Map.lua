-- 地图系统
local Map = {}
Map.__index = Map

-- 引入地形配置
local TerrainConfig = require('config/terrain')

-- 简单的噪声函数
function Map:noise(x, y, seed)
    local n = x * 113 + y * 157 + seed * 1223
    n = n * n * n
    n = math.fmod(math.floor(n / 8192), 256)
    return n / 255.0
end

-- 平滑噪声
function Map:smoothNoise(x, y, seed)
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
function Map:interpolate(a, b, x)
    local ft = x * 3.1415927
    local f = (1 - math.cos(ft)) * 0.5
    return a * (1 - f) + b * f
end

-- 生成柏林噪声
function Map:perlinNoise(x, y, seed, octaves)
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

function Map:new()
    local self = setmetatable({}, Map)
    self.tileSize = 20  -- 从30减小到20
    self.gridWidth = 40  -- 从26增加到40
    self.gridHeight = 30 -- 从20增加到30
    
    -- 初始化随机数生成器
    math.randomseed(os.time())
    
    -- 初始化地图数据和装饰物数据
    self.tiles = {}
    self.decorations = {}
    
    -- 高分辨率地形数据，用于平滑过渡
    self.highResMap = {}
    self.highResScale = 4  -- 每个格子内部的高分辨率点数
    
    -- 存储装饰物的预计算数据
    self.decorationData = {}
    
    self:generateMap()
    self:generateHighResMap()
    self:generateDecorations()
    
    return self
end

function Map:generateMap()
    -- 生成不同的种子用于不同的地形层
    local waterSeed = math.random(1, 1000)
    local forestSeed = math.random(1, 1000)
    local sandSeed = math.random(1, 1000)
    local mountainSeed = math.random(1, 1000)
    local snowSeed = math.random(1, 1000)
    local swampSeed = math.random(1, 1000)
    local volcanoSeed = math.random(1, 1000)
    
    -- 初始化地图
    for y = 1, self.gridHeight do
        self.tiles[y] = {}
        for x = 1, self.gridWidth do
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
            
            self.tiles[y][x] = terrainType
        end
    end
    
    -- 后处理：平滑地形
    self:smoothTerrain()
    
    -- 后处理：确保水域周围有沙地或沼泽
    self:postProcessTerrain()
end

-- 平滑地形，避免孤立的地块
function Map:smoothTerrain()
    local changes = {}
    
    -- 临时复制地图
    local tempMap = {}
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
function Map:postProcessTerrain()
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
function Map:isValidPosition(x, y)
    return x >= 1 and x <= self.gridWidth and y >= 1 and y <= self.gridHeight
end

-- 生成高分辨率地形数据，用于绘制平滑过渡
function Map:generateHighResMap()
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
                            
                            -- 决定是否应用过渡
                            local shouldTransition = false
                            
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
function Map:smoothHighResMap()
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

function Map:generateDecorations()
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
function Map:getTerrainAt(x, y)
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

function Map:generate()
    self:generateMap()
    self:generateHighResMap()
    self:generateDecorations()
end

function Map:draw()
    -- 使用高分辨率地图绘制地形
    local subTileSize = self.tileSize / self.highResScale
    
    for highResY = 1, self.gridHeight * self.highResScale do
        for highResX = 1, self.gridWidth * self.highResScale do
            local terrainType = self.highResMap[highResY][highResX]
            local pixelX = (highResX - 1) * subTileSize
            local pixelY = (highResY - 1) * subTileSize
            
            -- 绘制小格子
            love.graphics.setColor(TerrainConfig.TERRAIN_COLORS[terrainType])
            love.graphics.rectangle('fill', pixelX, pixelY, subTileSize, subTileSize)
        end
    end
    
    -- 绘制地形装饰
    for y = 1, self.gridHeight do
        for x = 1, self.gridWidth do
            if self.decorations[y][x] then
                local terrainType = self.tiles[y][x]
                local pixelX = (x - 1) * self.tileSize
                local pixelY = (y - 1) * self.tileSize
                local data = self.decorationData[y][x]
                
                -- 根据地形类型和预计算的数据绘制装饰物
                if terrainType == TerrainConfig.TERRAIN_TYPES.GRASS then
                    -- 绘制小草
                    for _, grass in ipairs(data.grassData) do
                        love.graphics.setColor(0.1, grass.greenShade, 0.1, 0.7)
                        love.graphics.line(
                            pixelX + grass.x, pixelY + grass.y + self.tileSize/4,
                            pixelX + grass.x + grass.bend, pixelY + grass.y + self.tileSize/8,
                            pixelX + grass.x + grass.bend * 2, pixelY + grass.y
                        )
                    end
                    
                    -- 绘制小花
                    if data.hasFlower then
                        local flower = data.flower
                        local petalSize = self.tileSize / 12
                        
                        -- 花瓣
                        love.graphics.setColor(flower.color[1], flower.color[2], flower.color[3], 0.9)
                        love.graphics.circle('fill', pixelX + flower.x, pixelY + flower.y, petalSize)
                        love.graphics.circle('fill', pixelX + flower.x + petalSize, pixelY + flower.y, petalSize)
                        love.graphics.circle('fill', pixelX + flower.x - petalSize, pixelY + flower.y, petalSize)
                        love.graphics.circle('fill', pixelX + flower.x, pixelY + flower.y + petalSize, petalSize)
                        love.graphics.circle('fill', pixelX + flower.x, pixelY + flower.y - petalSize, petalSize)
                        
                        -- 花蕊
                        love.graphics.setColor(1, 1, 0, 1)
                        love.graphics.circle('fill', pixelX + flower.x, pixelY + flower.y, petalSize / 2)
                    end
                
                elseif terrainType == TerrainConfig.TERRAIN_TYPES.WATER then
                    -- 水波纹效果 (保留时间变化但位置不变)
                    local time = love.timer.getTime()
                    
                    -- 主波纹
                    love.graphics.setColor(1, 1, 1, 0.2)
                    local waveSize = self.tileSize / 4 * (0.8 + math.sin(time * 2) * 0.2)
                    love.graphics.circle('line', pixelX + self.tileSize/2, pixelY + self.tileSize/2, waveSize)
                    
                    -- 额外的小波纹
                    for i, wave in ipairs(data.smallWaves) do
                        local smallWaveSize = self.tileSize / 8 * (0.8 + math.sin(time * 3 + i) * 0.2)
                        love.graphics.setColor(1, 1, 1, 0.15)
                        love.graphics.circle('line', 
                            pixelX + self.tileSize/2 + wave.offsetX, 
                            pixelY + self.tileSize/2 + wave.offsetY, 
                            smallWaveSize)
                    end
                    
                    -- 水草
                    if data.hasWeed then
                        love.graphics.setColor(0.1, 0.5, 0.3, 0.6)
                        local waveFactor = math.sin(time * 1.5) * 3
                        love.graphics.line(
                            pixelX + data.weed.x, pixelY + self.tileSize - 5,
                            pixelX + data.weed.x + waveFactor, pixelY + self.tileSize - 5 - data.weed.height/2,
                            pixelX + data.weed.x, pixelY + self.tileSize - 5 - data.weed.height
                        )
                    end
                    
                    -- 小鱼 (保留动态游动)
                    if data.hasFish then
                        love.graphics.setColor(0.9, 0.4, 0.2, 0.7)
                        local fishX = pixelX + self.tileSize/2 + math.sin(time * 2) * self.tileSize/4
                        local fishY = pixelY + self.tileSize/2
                        local fishSize = self.tileSize / 10
                        
                        -- 鱼身
                        love.graphics.ellipse('fill', fishX, fishY, fishSize, fishSize/2)
                        
                        -- 鱼尾
                        local tailDirection = math.sin(time * 5) > 0 and 1 or -1
                        love.graphics.polygon('fill', 
                            fishX - fishSize, fishY,
                            fishX - fishSize - fishSize/2, fishY - fishSize/2 * tailDirection,
                            fishX - fishSize - fishSize/2, fishY + fishSize/2 * tailDirection
                        )
                    end
                
                elseif terrainType == TerrainConfig.TERRAIN_TYPES.SAND then
                    -- 石子和贝壳
                    for _, stone in ipairs(data.stones) do
                        if stone.type == "stone" then
                            -- 石子
                            local sandShade = stone.shade
                            love.graphics.setColor(sandShade, sandShade * 0.9, sandShade * 0.7, 0.8)
                            
                            if stone.isCircle then
                                love.graphics.circle('fill', pixelX + stone.x, pixelY + stone.y, stone.size)
                            else
                                love.graphics.ellipse('fill', pixelX + stone.x, pixelY + stone.y, stone.size, stone.size * 0.7)
                            end
                        else
                            -- 贝壳
                            local shellSize = self.tileSize / 12
                            love.graphics.setColor(0.9, 0.85, 0.7, 0.9)
                            love.graphics.arc('fill', pixelX + stone.x, pixelY + stone.y, shellSize, 0, math.pi)
                            
                            -- 贝壳纹路
                            love.graphics.setColor(0.8, 0.75, 0.6, 0.9)
                            love.graphics.arc('line', pixelX + stone.x, pixelY + stone.y, shellSize * 0.7, 0, math.pi)
                            love.graphics.arc('line', pixelX + stone.x, pixelY + stone.y, shellSize * 0.4, 0, math.pi)
                        end
                    end
                    
                    -- 脚印
                    if data.hasFootprint then
                        love.graphics.setColor(0.9, 0.82, 0.5, 0.5)
                        local footSize = self.tileSize / 12
                        love.graphics.ellipse('fill', 
                            pixelX + data.footprint.x, 
                            pixelY + data.footprint.y, 
                            footSize, footSize * 2)
                        love.graphics.ellipse('fill', 
                            pixelX + data.footprint.x + footSize * 1.5, 
                            pixelY + data.footprint.y + footSize, 
                            footSize, footSize * 2)
                    end
                
                elseif terrainType == TerrainConfig.TERRAIN_TYPES.FOREST then
                    if data.treeType <= 6 then
                        -- 树干
                        love.graphics.setColor(0.4, 0.3, 0.2)
                        love.graphics.rectangle('fill', 
                            pixelX + data.treeX - data.trunkWidth/2, 
                            pixelY + data.treeY, 
                            data.trunkWidth, data.trunkHeight)
                        
                        -- 树冠
                        love.graphics.setColor(0.1, data.treeColor, 0.1)
                        
                        if data.isRoundCanopy then
                            -- 圆形树冠
                            love.graphics.circle('fill', 
                                pixelX + data.treeX, 
                                pixelY + data.treeY, 
                                data.canopySize)
                        else
                            -- 三角形树冠
                            love.graphics.polygon('fill', 
                                pixelX + data.treeX, pixelY + data.treeY - data.canopyHeight,
                                pixelX + data.treeX - data.canopyWidth/2, pixelY + data.treeY,
                                pixelX + data.treeX + data.canopyWidth/2, pixelY + data.treeY
                            )
                        end
                        
                        -- 果实
                        if data.hasFruit then
                            love.graphics.setColor(1, 0.3, 0.3, 0.9)
                            for _, fruit in ipairs(data.fruits) do
                                love.graphics.circle('fill', 
                                    pixelX + fruit.x, 
                                    pixelY + fruit.y, 
                                    self.tileSize/20)
                            end
                        end
                    
                    elseif data.treeType <= 9 then
                        -- 灌木丛
                        local bushSize = self.tileSize/3
                        love.graphics.setColor(0.2, 0.45, 0.2)
                        love.graphics.circle('fill', 
                            pixelX + data.treeX, 
                            pixelY + data.treeY, 
                            bushSize)
                        
                        -- 灌木丛细节
                        love.graphics.setColor(0.15, 0.4, 0.15)
                        love.graphics.circle('fill', 
                            pixelX + data.treeX - bushSize/2, 
                            pixelY + data.treeY, 
                            bushSize/2)
                        love.graphics.circle('fill', 
                            pixelX + data.treeX + bushSize/2, 
                            pixelY + data.treeY, 
                            bushSize/2)
                        love.graphics.circle('fill', 
                            pixelX + data.treeX, 
                            pixelY + data.treeY - bushSize/2, 
                            bushSize/2)
                    else
                        -- 树桩
                        local stumpSize = self.tileSize/6
                        love.graphics.setColor(0.35, 0.25, 0.1)
                        love.graphics.circle('fill', 
                            pixelX + data.treeX, 
                            pixelY + data.treeY, 
                            stumpSize)
                        
                        -- 年轮
                        love.graphics.setColor(0.4, 0.3, 0.15)
                        love.graphics.circle('line', 
                            pixelX + data.treeX, 
                            pixelY + data.treeY, 
                            stumpSize * 0.7)
                        love.graphics.circle('line', 
                            pixelX + data.treeX, 
                            pixelY + data.treeY, 
                            stumpSize * 0.4)
                    end
                    
                    -- 蘑菇
                    if data.hasMushroom then
                        -- 蘑菇柄
                        love.graphics.setColor(0.9, 0.9, 0.8)
                        love.graphics.rectangle('fill', 
                            pixelX + data.mushroom.x - self.tileSize/40, 
                            pixelY + data.mushroom.y - self.tileSize/10, 
                            self.tileSize/20, self.tileSize/10)
                        
                        -- 蘑菇帽
                        local color = data.mushroom.color
                        love.graphics.setColor(color[1], color[2], color[3])
                        love.graphics.ellipse('fill', 
                            pixelX + data.mushroom.x, 
                            pixelY + data.mushroom.y - self.tileSize/10, 
                            self.tileSize/15, self.tileSize/30)
                    end
                end
            end
        end
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return Map 