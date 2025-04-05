-- 地图类
local Map = {}
Map.__index = Map

-- 定义地形类型
local TERRAIN_TYPES = {
    GRASS = 1,
    WATER = 2,
    SAND = 3,
    FOREST = 4
}

-- 地形颜色配置
local TERRAIN_COLORS = {
    [TERRAIN_TYPES.GRASS] = {0.2, 0.8, 0.2},  -- 绿色草地
    [TERRAIN_TYPES.WATER] = {0.2, 0.4, 0.8},  -- 蓝色水域
    [TERRAIN_TYPES.SAND] = {0.9, 0.8, 0.5},   -- 黄色沙地
    [TERRAIN_TYPES.FOREST] = {0.1, 0.6, 0.1}  -- 深绿色森林
}

-- 地形装饰物配置
local TERRAIN_DECORATIONS = {
    [TERRAIN_TYPES.GRASS] = {
        chance = 0.1,  -- 10%的几率生成装饰
        draw = function(x, y, size)
            -- 绘制小草
            love.graphics.setColor(0.1, 0.7, 0.1, 0.7)
            local grassSize = size / 8
            local centerX = x + size/2
            local centerY = y + size/2
            for i = 1, 3 do
                local angle = (i-1) * math.pi/3 + math.random() * 0.5
                local length = grassSize * (0.8 + math.random() * 0.4)
                love.graphics.line(
                    centerX, centerY,
                    centerX + math.cos(angle) * length,
                    centerY + math.sin(angle) * length
                )
            end
        end
    },
    [TERRAIN_TYPES.WATER] = {
        chance = 0.2,  -- 20%的几率生成装饰
        draw = function(x, y, size)
            -- 绘制波纹
            love.graphics.setColor(1, 1, 1, 0.2)
            local time = love.timer.getTime()
            local waveSize = size / 4 * (0.8 + math.sin(time * 2) * 0.2)
            love.graphics.circle('line', x + size/2, y + size/2, waveSize)
        end
    },
    [TERRAIN_TYPES.SAND] = {
        chance = 0.15,  -- 15%的几率生成装饰
        draw = function(x, y, size)
            -- 绘制小石子
            love.graphics.setColor(0.8, 0.7, 0.4, 0.7)
            local stoneSize = size / 10
            local px = x + math.random() * (size - stoneSize)
            local py = y + math.random() * (size - stoneSize)
            love.graphics.circle('fill', px, py, stoneSize)
        end
    },
    [TERRAIN_TYPES.FOREST] = {
        chance = 0.8,  -- 80%的几率生成装饰
        draw = function(x, y, size)
            -- 绘制简单的树
            local treeX = x + size/2
            local treeY = y + size/2
            -- 树干
            love.graphics.setColor(0.4, 0.3, 0.2)
            love.graphics.rectangle('fill', treeX - size/10, treeY, size/5, size/2)
            -- 树冠
            love.graphics.setColor(0.1, 0.5, 0.1)
            love.graphics.circle('fill', treeX, treeY, size/3)
        end
    }
}

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
    self.tileSize = 40  -- 每个格子的大小
    self.gridWidth = 20  -- 地图宽度（格子数）
    self.gridHeight = 15 -- 地图高度（格子数）
    
    -- 初始化随机数生成器
    math.randomseed(os.time())
    
    -- 初始化地图数据和装饰物数据
    self.tiles = {}
    self.decorations = {}
    self:generateMap()
    self:generateDecorations()
    
    return self
end

function Map:generateMap()
    -- 生成不同的种子用于不同的地形层
    local waterSeed = math.random(1, 1000)
    local forestSeed = math.random(1, 1000)
    local sandSeed = math.random(1, 1000)
    
    -- 初始化地图
    for y = 1, self.gridHeight do
        self.tiles[y] = {}
        for x = 1, self.gridWidth do
            -- 生成各种地形的噪声值
            local waterNoise = self:perlinNoise(x/5, y/5, waterSeed, 4)
            local forestNoise = self:perlinNoise(x/7, y/7, forestSeed, 3)
            local sandNoise = self:perlinNoise(x/4, y/4, sandSeed, 2)
            
            -- 默认为草地
            local terrainType = TERRAIN_TYPES.GRASS
            
            -- 根据噪声值决定地形
            if waterNoise > 0.7 then
                terrainType = TERRAIN_TYPES.WATER
            elseif waterNoise > 0.6 and sandNoise > 0.6 then
                terrainType = TERRAIN_TYPES.SAND
            elseif forestNoise > 0.6 and waterNoise < 0.5 then
                terrainType = TERRAIN_TYPES.FOREST
            end
            
            self.tiles[y][x] = terrainType
        end
    end
    
    -- 后处理：确保水域周围有沙地
    self:postProcessTerrain()
end

function Map:postProcessTerrain()
    -- 创建一个临时表来存储要更改的瓦片
    local changes = {}
    
    for y = 1, self.gridHeight do
        for x = 1, self.gridWidth do
            if self.tiles[y][x] == TERRAIN_TYPES.WATER then
                -- 检查周围8个格子
                for dy = -1, 1 do
                    for dx = -1, 1 do
                        local nx, ny = x + dx, y + dy
                        if nx >= 1 and nx <= self.gridWidth and
                           ny >= 1 and ny <= self.gridHeight and
                           self.tiles[ny][nx] == TERRAIN_TYPES.GRASS then
                            table.insert(changes, {x = nx, y = ny, type = TERRAIN_TYPES.SAND})
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

-- 颜色混合函数
function Map:blendColors(color1, color2, factor)
    return {
        color1[1] * (1 - factor) + color2[1] * factor,
        color1[2] * (1 - factor) + color2[2] * factor,
        color1[3] * (1 - factor) + color2[3] * factor
    }
end

-- 检查是否是边界瓦片
function Map:isTransitionTile(x, y)
    local currentType = self.tiles[y][x]
    
    -- 检查周围8个格子
    for dy = -1, 1 do
        for dx = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local nx, ny = x + dx, y + dy
                if nx >= 1 and nx <= self.gridWidth and
                   ny >= 1 and ny <= self.gridHeight then
                    if self.tiles[ny][nx] ~= currentType then
                        return self.tiles[ny][nx]
                    end
                end
            end
        end
    end
    return nil
end

function Map:generateDecorations()
    self.decorations = {}
    for y = 1, self.gridHeight do
        self.decorations[y] = {}
        for x = 1, self.gridWidth do
            local terrainType = self.tiles[y][x]
            local decoration = TERRAIN_DECORATIONS[terrainType]
            if decoration and math.random() < decoration.chance then
                self.decorations[y][x] = true
            end
        end
    end
end

function Map:draw()
    for y = 1, self.gridHeight do
        for x = 1, self.gridWidth do
            local tileX = (x - 1) * self.tileSize
            local tileY = (y - 1) * self.tileSize
            
            -- 获取当前格子的地形类型
            local terrainType = self.tiles[y][x]
            local color = TERRAIN_COLORS[terrainType]
            
            -- 检查是否需要过渡效果
            local neighborType = self:isTransitionTile(x, y)
            if neighborType then
                local neighborColor = TERRAIN_COLORS[neighborType]
                color = self:blendColors(color, neighborColor, 0.3)
            end
            
            -- 绘制地形
            love.graphics.setColor(color[1], color[2], color[3])
            love.graphics.rectangle('fill', tileX, tileY, self.tileSize - 1, self.tileSize - 1)
            
            -- 绘制装饰物
            if self.decorations[y][x] then
                local decoration = TERRAIN_DECORATIONS[terrainType]
                if decoration then
                    decoration.draw(tileX, tileY, self.tileSize)
                end
            end
            
            -- 绘制网格线
            love.graphics.setColor(0.1, 0.1, 0.1, 0.3)
            love.graphics.rectangle('line', tileX, tileY, self.tileSize, self.tileSize)
        end
    end
    love.graphics.setColor(1, 1, 1) -- 重置颜色为白色
end

-- 获取指定位置的地形类型
function Map:getTerrainAt(x, y)
    local gridX = math.floor(x / self.tileSize) + 1
    local gridY = math.floor(y / self.tileSize) + 1
    
    if gridX >= 1 and gridX <= self.gridWidth and gridY >= 1 and gridY <= self.gridHeight then
        return self.tiles[gridY][gridX]
    end
    return nil
end

return Map 