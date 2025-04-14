-- MapView类
local MapView = {}
MapView.__index = MapView

-- 引入地形配置
local TerrainConfig = require('config/terrain')

function MapView:new()
    local self = setmetatable({}, MapView)
    return self
end

function MapView:draw(mapModel)
    -- 获取地图尺寸和数据
    local dimensions = mapModel:getDimensions()
    local highResMap = mapModel:getHighResMap()
    local decorations = mapModel:getDecorations()
    local decorationData = mapModel:getDecorationData()
    
    -- 绘制高分辨率地图
    self:drawHighResMap(highResMap, dimensions)
    
    -- 绘制装饰物
    self:drawDecorations(mapModel, decorations, decorationData)
end

function MapView:drawHighResMap(highResMap, dimensions)
    -- 使用高分辨率地图绘制地形
    local subTileSize = dimensions.tileSize / dimensions.highResScale
    
    for highResY = 1, dimensions.gridHeight * dimensions.highResScale do
        for highResX = 1, dimensions.gridWidth * dimensions.highResScale do
            local terrainType = highResMap[highResY][highResX]
            local pixelX = (highResX - 1) * subTileSize
            local pixelY = (highResY - 1) * subTileSize
            
            -- 绘制小格子
            love.graphics.setColor(TerrainConfig.TERRAIN_COLORS[terrainType])
            love.graphics.rectangle('fill', pixelX, pixelY, subTileSize, subTileSize)
        end
    end
end

function MapView:drawDecorations(mapModel, decorations, decorationData)
    local tileSize = mapModel:getDimensions().tileSize
    local tiles = mapModel:getHighResMap()  -- 使用高分辨率地图获取地形类型
    
    -- 绘制装饰物
    for y = 1, #decorations do
        for x = 1, #decorations[y] do
            if decorations[y][x] then
                local terrainType = mapModel:getTerrainAt((x-0.5) * tileSize, (y-0.5) * tileSize)
                local pixelX = (x - 1) * tileSize
                local pixelY = (y - 1) * tileSize
                local data = decorationData[y][x]
                
                -- 根据地形类型绘制装饰物
                if terrainType == TerrainConfig.TERRAIN_TYPES.GRASS then
                    self:drawGrassDecorations(pixelX, pixelY, tileSize, data)
                elseif terrainType == TerrainConfig.TERRAIN_TYPES.WATER then
                    self:drawWaterDecorations(pixelX, pixelY, tileSize, data)
                elseif terrainType == TerrainConfig.TERRAIN_TYPES.SAND then
                    self:drawSandDecorations(pixelX, pixelY, tileSize, data)
                elseif terrainType == TerrainConfig.TERRAIN_TYPES.FOREST then
                    self:drawForestDecorations(pixelX, pixelY, tileSize, data)
                end
            end
        end
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function MapView:drawGrassDecorations(pixelX, pixelY, tileSize, data)
    -- 绘制小草
    if data.grassData then
        for _, grass in ipairs(data.grassData) do
            love.graphics.setColor(0.1, grass.greenShade, 0.1, 0.7)
            love.graphics.line(
                pixelX + grass.x, pixelY + grass.y + tileSize/4,
                pixelX + grass.x + grass.bend, pixelY + grass.y + tileSize/8,
                pixelX + grass.x + grass.bend * 2, pixelY + grass.y
            )
        end
    end
    
    -- 绘制小花
    if data.hasFlower and data.flower then
        local flower = data.flower
        local petalSize = tileSize / 12
        
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
end

function MapView:drawWaterDecorations(pixelX, pixelY, tileSize, data)
    -- 水波纹效果 (保留时间变化但位置不变)
    local time = love.timer.getTime()
    
    -- 主波纹
    love.graphics.setColor(1, 1, 1, 0.2)
    local waveSize = tileSize / 4 * (0.8 + math.sin(time * 2) * 0.2)
    love.graphics.circle('line', pixelX + tileSize/2, pixelY + tileSize/2, waveSize)
    
    -- 额外的小波纹
    if data.smallWaves then
        for i, wave in ipairs(data.smallWaves) do
            local smallWaveSize = tileSize / 8 * (0.8 + math.sin(time * 3 + i) * 0.2)
            love.graphics.setColor(1, 1, 1, 0.15)
            love.graphics.circle('line', 
                pixelX + tileSize/2 + wave.offsetX, 
                pixelY + tileSize/2 + wave.offsetY, 
                smallWaveSize)
        end
    end
    
    -- 水草
    if data.hasWeed and data.weed then
        love.graphics.setColor(0.1, 0.5, 0.3, 0.6)
        local waveFactor = math.sin(time * 1.5) * 3
        love.graphics.line(
            pixelX + data.weed.x, pixelY + tileSize - 5,
            pixelX + data.weed.x + waveFactor, pixelY + tileSize - 5 - data.weed.height/2,
            pixelX + data.weed.x, pixelY + tileSize - 5 - data.weed.height
        )
    end
    
    -- 小鱼 (保留动态游动)
    if data.hasFish then
        love.graphics.setColor(0.9, 0.4, 0.2, 0.7)
        local fishX = pixelX + tileSize/2 + math.sin(time * 2) * tileSize/4
        local fishY = pixelY + tileSize/2
        local fishSize = tileSize / 10
        
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
end

function MapView:drawSandDecorations(pixelX, pixelY, tileSize, data)
    -- 石子和贝壳
    if data.stones then
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
                local shellSize = tileSize / 12
                love.graphics.setColor(0.9, 0.85, 0.7, 0.9)
                love.graphics.arc('fill', pixelX + stone.x, pixelY + stone.y, shellSize, 0, math.pi)
                
                -- 贝壳纹路
                love.graphics.setColor(0.8, 0.75, 0.6, 0.9)
                love.graphics.arc('line', pixelX + stone.x, pixelY + stone.y, shellSize * 0.7, 0, math.pi)
                love.graphics.arc('line', pixelX + stone.x, pixelY + stone.y, shellSize * 0.4, 0, math.pi)
            end
        end
    end
    
    -- 脚印
    if data.hasFootprint and data.footprint then
        love.graphics.setColor(0.9, 0.82, 0.5, 0.5)
        local footSize = tileSize / 12
        love.graphics.ellipse('fill', 
            pixelX + data.footprint.x, 
            pixelY + data.footprint.y, 
            footSize, footSize * 2)
        love.graphics.ellipse('fill', 
            pixelX + data.footprint.x + footSize * 1.5, 
            pixelY + data.footprint.y + footSize, 
            footSize, footSize * 2)
    end
end

function MapView:drawForestDecorations(pixelX, pixelY, tileSize, data)
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
        if data.hasFruit and data.fruits then
            love.graphics.setColor(1, 0.3, 0.3, 0.9)
            for _, fruit in ipairs(data.fruits) do
                love.graphics.circle('fill', 
                    pixelX + fruit.x, 
                    pixelY + fruit.y, 
                    tileSize/20)
            end
        end
    
    elseif data.treeType <= 9 then
        -- 灌木丛
        local bushSize = tileSize/3
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
        local stumpSize = tileSize/6
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
    if data.hasMushroom and data.mushroom then
        -- 蘑菇柄
        love.graphics.setColor(0.9, 0.9, 0.8)
        love.graphics.rectangle('fill', 
            pixelX + data.mushroom.x - tileSize/40, 
            pixelY + data.mushroom.y - tileSize/10, 
            tileSize/20, tileSize/10)
        
        -- 蘑菇帽
        local color = data.mushroom.color
        love.graphics.setColor(color[1], color[2], color[3])
        love.graphics.ellipse('fill', 
            pixelX + data.mushroom.x, 
            pixelY + data.mushroom.y - tileSize/10, 
            tileSize/15, tileSize/30)
    end
end

return MapView 