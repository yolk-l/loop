-- 地形配置文件

-- 定义地形类型
local TERRAIN_TYPES = {
    GRASS = 1,
    WATER = 2,
    SAND = 3,
    FOREST = 4,
    MOUNTAIN = 5,  -- 新增：山地
    SNOW = 6,      -- 新增：雪地
    SWAMP = 7,     -- 新增：沼泽
    VOLCANO = 8    -- 新增：火山
}

-- 地形颜色配置
local TERRAIN_COLORS = {
    [TERRAIN_TYPES.GRASS] = {0.3, 0.8, 0.3},  -- 绿色草地
    [TERRAIN_TYPES.WATER] = {0.2, 0.5, 0.9},  -- 蓝色水域
    [TERRAIN_TYPES.SAND] = {0.95, 0.85, 0.55},   -- 黄色沙地
    [TERRAIN_TYPES.FOREST] = {0.15, 0.55, 0.15},  -- 深绿色森林
    [TERRAIN_TYPES.MOUNTAIN] = {0.6, 0.6, 0.6},  -- 灰色山地
    [TERRAIN_TYPES.SNOW] = {0.95, 0.95, 0.95},   -- 白色雪地
    [TERRAIN_TYPES.SWAMP] = {0.4, 0.5, 0.2},    -- 暗绿色沼泽
    [TERRAIN_TYPES.VOLCANO] = {0.5, 0.2, 0.1}    -- 暗红色火山
}

-- 地形装饰物配置
local TERRAIN_DECORATIONS = {
    [TERRAIN_TYPES.GRASS] = {
        chance = 0.3,  -- 增加草地装饰几率
        draw = function(x, y, size)
            -- 绘制小草
            local grassCount = math.random(2, 5)  -- 随机几根草
            for j = 1, grassCount do
                -- 变化草的颜色
                local greenShade = 0.5 + math.random() * 0.3
                love.graphics.setColor(0.1, greenShade, 0.1, 0.7)
                
                local grassX = x + math.random(5, size - 5)
                local grassY = y + math.random(5, size - 5)
                local grassHeight = size / 6 + math.random() * size / 6
                
                -- 弯曲的草
                local bend = (math.random() - 0.5) * 3
                love.graphics.line(
                    grassX, grassY + size/4,
                    grassX + bend, grassY + size/8,
                    grassX + bend * 2, grassY
                )
            end
            
            -- 偶尔添加一朵小花
            if math.random() < 0.2 then
                local flowerX = x + math.random(5, size - 5)
                local flowerY = y + math.random(5, size - 5)
                
                -- 随机花色
                local flowerColors = {
                    {1, 0.8, 0.2}, -- 黄色
                    {1, 0.4, 0.4}, -- 红色
                    {0.8, 0.4, 1}, -- 紫色
                    {1, 1, 1}      -- 白色
                }
                
                local flowerColor = flowerColors[math.random(1, #flowerColors)]
                love.graphics.setColor(flowerColor[1], flowerColor[2], flowerColor[3], 0.9)
                
                -- 绘制花瓣
                local petalSize = size / 12
                love.graphics.circle('fill', flowerX, flowerY, petalSize)
                love.graphics.circle('fill', flowerX + petalSize, flowerY, petalSize)
                love.graphics.circle('fill', flowerX - petalSize, flowerY, petalSize)
                love.graphics.circle('fill', flowerX, flowerY + petalSize, petalSize)
                love.graphics.circle('fill', flowerX, flowerY - petalSize, petalSize)
                
                -- 花蕊
                love.graphics.setColor(1, 1, 0, 1)
                love.graphics.circle('fill', flowerX, flowerY, petalSize / 2)
            end
        end
    },
    [TERRAIN_TYPES.WATER] = {
        chance = 0.5,  -- 增加水面装饰几率
        draw = function(x, y, size)
            -- 生成多个波纹，呈现更丰富的水面效果
            love.graphics.setColor(1, 1, 1, 0.2)
            local time = love.timer.getTime()
            
            -- 主波纹
            local waveSize = size / 4 * (0.8 + math.sin(time * 2) * 0.2)
            love.graphics.circle('line', x + size/2, y + size/2, waveSize)
            
            -- 额外的小波纹
            local smallWaveCount = math.random(0, 2)
            for i = 1, smallWaveCount do
                local offsetX = math.random(-size/4, size/4)
                local offsetY = math.random(-size/4, size/4)
                local smallWaveSize = size / 8 * (0.8 + math.sin(time * 3 + i) * 0.2)
                
                love.graphics.setColor(1, 1, 1, 0.15)
                love.graphics.circle('line', x + size/2 + offsetX, y + size/2 + offsetY, smallWaveSize)
            end
            
            -- 随机添加水草或小鱼
            if math.random() < 0.1 then
                -- 水草
                love.graphics.setColor(0.1, 0.5, 0.3, 0.6)
                local weedX = x + math.random(5, size - 5)
                local weedY = y + size - 5
                local weedHeight = math.random(size/8, size/4)
                
                -- 弯曲的水草
                local waveFactor = math.sin(time * 1.5) * 3
                love.graphics.line(
                    weedX, weedY,
                    weedX + waveFactor, weedY - weedHeight/2,
                    weedX, weedY - weedHeight
                )
            elseif math.random() < 0.05 then
                -- 小鱼
                love.graphics.setColor(0.9, 0.4, 0.2, 0.7)
                local fishX = x + size/2 + math.sin(time * 2) * size/4
                local fishY = y + size/2
                local fishSize = size / 10
                
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
    },
    [TERRAIN_TYPES.SAND] = {
        chance = 0.4,  -- 增加沙地装饰几率
        draw = function(x, y, size)
            -- 随机生成多个石子或贝壳
            local stoneCount = math.random(1, 3)
            
            for i = 1, stoneCount do
                -- 随机选择绘制石子或贝壳
                local itemType = math.random(1, 10)
                
                if itemType <= 7 then
                    -- 石子
                    local sandShade = 0.5 + math.random() * 0.3
                    love.graphics.setColor(sandShade, sandShade * 0.9, sandShade * 0.7, 0.8)
                    
                    local stoneSize = size / (8 + math.random() * 4)
                    local px = x + math.random() * (size - stoneSize)
                    local py = y + math.random() * (size - stoneSize)
                    
                    -- 不规则石子
                    if math.random() > 0.5 then
                        love.graphics.circle('fill', px, py, stoneSize)
                    else
                        love.graphics.ellipse('fill', px, py, stoneSize, stoneSize * 0.7)
                    end
                else
                    -- 贝壳
                    love.graphics.setColor(0.9, 0.85, 0.7, 0.9)
                    
                    local shellSize = size / 12
                    local px = x + math.random() * (size - shellSize * 2)
                    local py = y + math.random() * (size - shellSize * 2)
                    
                    -- 贝壳形状
                    love.graphics.arc('fill', px, py, shellSize, 0, math.pi)
                    
                    -- 贝壳纹路
                    love.graphics.setColor(0.8, 0.75, 0.6, 0.9)
                    love.graphics.arc('line', px, py, shellSize * 0.7, 0, math.pi)
                    love.graphics.arc('line', px, py, shellSize * 0.4, 0, math.pi)
                end
            end
            
            -- 偶尔添加沙滩上的脚印
            if math.random() < 0.05 then
                love.graphics.setColor(0.9, 0.82, 0.5, 0.5)
                local footX = x + math.random(size/4, size*3/4)
                local footY = y + math.random(size/4, size*3/4)
                local footSize = size / 12
                
                -- 脚印形状
                love.graphics.ellipse('fill', footX, footY, footSize, footSize * 2)
                love.graphics.ellipse('fill', footX + footSize * 1.5, footY + footSize, footSize, footSize * 2)
            end
        end
    },
    [TERRAIN_TYPES.FOREST] = {
        chance = 0.9,  -- 增加森林装饰几率
        draw = function(x, y, size)
            -- 绘制森林
            local treeX = x + size/2 + math.random(-size/10, size/10)
            local treeY = y + size/2 + math.random(-size/10, size/10)
            local treeType = math.random(1, 10)
            
            if treeType <= 6 then
                -- 常规树
                -- 树干
                love.graphics.setColor(0.4, 0.3, 0.2)
                local trunkWidth = size/10 + math.random() * size/20
                local trunkHeight = size/2 + math.random() * size/10
                love.graphics.rectangle('fill', treeX - trunkWidth/2, treeY, trunkWidth, trunkHeight)
                
                -- 随机树冠形状
                love.graphics.setColor(0.1, 0.4 + math.random() * 0.2, 0.1)
                
                if math.random() > 0.5 then
                    -- 圆形树冠
                    local canopySize = size/3 + math.random() * size/10
                    love.graphics.circle('fill', treeX, treeY, canopySize)
                else
                    -- 三角形树冠（类似松树）
                    local canopyWidth = size/2 + math.random() * size/10
                    local canopyHeight = size/2 + math.random() * size/10
                    love.graphics.polygon('fill', 
                        treeX, treeY - canopyHeight,
                        treeX - canopyWidth/2, treeY,
                        treeX + canopyWidth/2, treeY
                    )
                end
                
                -- 随机添加树上的果实或花朵
                if math.random() < 0.2 then
                    love.graphics.setColor(1, 0.3, 0.3, 0.9)  -- 红色果实
                    local fruitCount = math.random(1, 3)
                    
                    for i = 1, fruitCount do
                        local fruitX = treeX + math.random(-size/4, size/4)
                        local fruitY = treeY - math.random(0, size/4)
                        love.graphics.circle('fill', fruitX, fruitY, size/20)
                    end
                end
            elseif treeType <= 9 then
                -- 灌木丛
                love.graphics.setColor(0.2, 0.45, 0.2)
                local bushSize = size/3
                love.graphics.circle('fill', treeX, treeY, bushSize)
                
                -- 灌木丛细节
                love.graphics.setColor(0.15, 0.4, 0.15)
                love.graphics.circle('fill', treeX - bushSize/2, treeY, bushSize/2)
                love.graphics.circle('fill', treeX + bushSize/2, treeY, bushSize/2)
                love.graphics.circle('fill', treeX, treeY - bushSize/2, bushSize/2)
            else
                -- 树桩
                love.graphics.setColor(0.35, 0.25, 0.1)
                local stumpSize = size/6
                love.graphics.circle('fill', treeX, treeY, stumpSize)
                
                -- 年轮
                love.graphics.setColor(0.4, 0.3, 0.15)
                love.graphics.circle('line', treeX, treeY, stumpSize * 0.7)
                love.graphics.circle('line', treeX, treeY, stumpSize * 0.4)
            end
            
            -- 随机添加地面上的蘑菇
            if math.random() < 0.15 then
                local mushroomX = x + math.random(5, size - 5)
                local mushroomY = y + size - 10
                
                -- 蘑菇颜色
                local mushroomColors = {
                    {1, 0.3, 0.3},  -- 红色
                    {1, 0.8, 0.3},  -- 黄色
                    {0.8, 0.8, 0.8}, -- 白色
                    {0.6, 0.4, 0.2}  -- 棕色
                }
                
                local color = mushroomColors[math.random(1, #mushroomColors)]
                
                -- 蘑菇柄
                love.graphics.setColor(0.9, 0.9, 0.8)
                love.graphics.rectangle('fill', mushroomX - size/40, mushroomY - size/10, size/20, size/10)
                
                -- 蘑菇帽
                love.graphics.setColor(color[1], color[2], color[3])
                love.graphics.ellipse('fill', mushroomX, mushroomY - size/10, size/15, size/30)
            end
        end
    },
    [TERRAIN_TYPES.MOUNTAIN] = {
        chance = 0.8,  -- 山地装饰几率
        draw = function(x, y, size)
            -- 绘制山石
            local rockCount = math.random(1, 3)
            local rockColors = {
                {0.5, 0.5, 0.5}, -- 灰色
                {0.45, 0.42, 0.4}, -- 褐灰色
                {0.6, 0.58, 0.55} -- 浅灰色
            }
            
            for i = 1, rockCount do
                local rockColor = rockColors[math.random(1, #rockColors)]
                love.graphics.setColor(rockColor[1], rockColor[2], rockColor[3])
                
                local rockX = x + math.random(5, size - 5)
                local rockY = y + math.random(5, size - 5)
                local rockSize = size / 3 + math.random() * size / 6
                
                -- 不规则多边形岩石
                local vertices = {}
                local pointCount = math.random(5, 8)
                for j = 1, pointCount do
                    local angle = (j - 1) * (2 * math.pi / pointCount)
                    local radius = rockSize * (0.7 + math.random() * 0.3)
                    table.insert(vertices, rockX + math.cos(angle) * radius)
                    table.insert(vertices, rockY + math.sin(angle) * radius)
                end
                
                love.graphics.polygon('fill', unpack(vertices))
                
                -- 岩石阴影
                love.graphics.setColor(rockColor[1] * 0.8, rockColor[2] * 0.8, rockColor[3] * 0.8)
                love.graphics.line(vertices[1], vertices[2], vertices[3], vertices[4])
                
                -- 有时添加雪顶
                if math.random() < 0.3 then
                    love.graphics.setColor(0.95, 0.95, 0.95, 0.7)
                    love.graphics.polygon('fill', 
                        vertices[1], vertices[2], 
                        vertices[3], vertices[4], 
                        vertices[5], vertices[6])
                end
            end
            
            -- 偶尔添加山羊
            if math.random() < 0.05 then
                love.graphics.setColor(0.8, 0.8, 0.7)
                local goatX = x + math.random(5, size - 5)
                local goatY = y + math.random(5, size - 5)
                love.graphics.circle('fill', goatX, goatY, size/12)  -- 身体
                love.graphics.circle('fill', goatX + size/16, goatY - size/20, size/18)  -- 头
                love.graphics.setColor(0.3, 0.3, 0.3)
                love.graphics.line(goatX + size/12, goatY - size/15, goatX + size/8, goatY - size/10)  -- 角
                love.graphics.line(goatX - size/12, goatY, goatX - size/8, goatY + size/12)  -- 尾巴
                love.graphics.line(goatX - size/12, goatY + size/15, goatX - size/12, goatY + size/8)  -- 腿
                love.graphics.line(goatX + size/12, goatY + size/15, goatX + size/12, goatY + size/8)  -- 腿
            end
        end
    },
    [TERRAIN_TYPES.SNOW] = {
        chance = 0.6,  -- 雪地装饰几率
        draw = function(x, y, size)
            -- 雪堆
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.circle('fill', x + size/2, y + size/2, size/4 + math.random() * size/8)
            
            -- 随机雪花
            local snowflakeCount = math.random(3, 8)
            love.graphics.setColor(1, 1, 1, 0.9)
            
            for i = 1, snowflakeCount do
                local flakeX = x + math.random(2, size - 2)
                local flakeY = y + math.random(2, size - 2)
                local flakeSize = size / 40 + math.random() * size / 40
                
                -- 简单雪花
                love.graphics.circle('fill', flakeX, flakeY, flakeSize)
                
                -- 复杂雪花
                if math.random() < 0.2 then
                    for j = 0, 5 do
                        local angle = j * math.pi / 3
                        local length = flakeSize * 2
                        love.graphics.line(
                            flakeX, flakeY,
                            flakeX + math.cos(angle) * length,
                            flakeY + math.sin(angle) * length
                        )
                    end
                end
            end
            
            -- 偶尔添加雪人
            if math.random() < 0.08 then
                love.graphics.setColor(1, 1, 1)
                local snowmanX = x + size/2
                local snowmanY = y + size/2
                
                -- 雪人身体（两个雪球）
                love.graphics.circle('fill', snowmanX, snowmanY, size/8)
                love.graphics.circle('fill', snowmanX, snowmanY - size/10, size/12)
                
                -- 雪人眼睛和按钮
                love.graphics.setColor(0, 0, 0)
                love.graphics.circle('fill', snowmanX - size/25, snowmanY - size/10, size/60)
                love.graphics.circle('fill', snowmanX + size/25, snowmanY - size/10, size/60)
                love.graphics.circle('fill', snowmanX, snowmanY - size/20, size/60)
                love.graphics.circle('fill', snowmanX, snowmanY, size/60)
                
                -- 胡萝卜鼻子
                love.graphics.setColor(1, 0.6, 0.2)
                love.graphics.polygon('fill', 
                    snowmanX, snowmanY - size/10,
                    snowmanX + size/20, snowmanY - size/11,
                    snowmanX, snowmanY - size/9
                )
            end
        end
    },
    [TERRAIN_TYPES.SWAMP] = {
        chance = 0.7,  -- 沼泽装饰几率
        draw = function(x, y, size)
            -- 沼泽水面
            love.graphics.setColor(0.3, 0.4, 0.2, 0.5)
            local poolSize = math.random() * size/3 + size/6
            love.graphics.circle('fill', x + size/2, y + size/2, poolSize)
            
            -- 气泡
            if math.random() < 0.5 then
                love.graphics.setColor(0.5, 0.6, 0.4, 0.3)
                local bubbleCount = math.random(1, 3)
                for i = 1, bubbleCount do
                    love.graphics.circle('line', 
                        x + size/2 + math.random(-poolSize/2, poolSize/2), 
                        y + size/2 + math.random(-poolSize/2, poolSize/2), 
                        size/30)
                end
            end
            
            -- 沼泽植物
            love.graphics.setColor(0.2, 0.5, 0.1)
            local plantCount = math.random(1, 3)
            for i = 1, plantCount do
                local plantX = x + math.random(5, size - 5)
                local plantY = y + math.random(5, size - 5)
                
                -- 芦苇或沼泽植物
                local plantHeight = size/4 + math.random() * size/8
                love.graphics.line(plantX, plantY, plantX, plantY - plantHeight)
                
                -- 叶子
                love.graphics.line(
                    plantX, plantY - plantHeight/2,
                    plantX + size/10, plantY - plantHeight/2 - size/20
                )
                love.graphics.line(
                    plantX, plantY - plantHeight*3/4,
                    plantX - size/10, plantY - plantHeight*3/4 - size/20
                )
            end
            
            -- 偶尔添加青蛙
            if math.random() < 0.15 then
                love.graphics.setColor(0.3, 0.7, 0.3)
                local frogX = x + math.random(5, size - 5)
                local frogY = y + math.random(5, size - 5)
                
                -- 青蛙身体
                love.graphics.circle('fill', frogX, frogY, size/15)
                
                -- 青蛙眼睛
                love.graphics.setColor(1, 1, 1)
                love.graphics.circle('fill', frogX - size/30, frogY - size/30, size/40)
                love.graphics.circle('fill', frogX + size/30, frogY - size/30, size/40)
                
                -- 青蛙瞳孔
                love.graphics.setColor(0, 0, 0)
                love.graphics.circle('fill', frogX - size/30, frogY - size/30, size/80)
                love.graphics.circle('fill', frogX + size/30, frogY - size/30, size/80)
            end
        end
    },
    [TERRAIN_TYPES.VOLCANO] = {
        chance = 0.8,  -- 火山装饰几率
        draw = function(x, y, size)
            -- 火山锥体
            local volcanoX = x + size/2
            local volcanoY = y + size/2
            
            -- 火山基座
            love.graphics.setColor(0.3, 0.2, 0.1)
            love.graphics.polygon('fill',
                volcanoX - size/2, volcanoY + size/3,
                volcanoX + size/2, volcanoY + size/3,
                volcanoX + size/3, volcanoY - size/4,
                volcanoX - size/3, volcanoY - size/4
            )
            
            -- 火山口
            love.graphics.setColor(0.8, 0.2, 0.1)
            love.graphics.circle('fill', volcanoX, volcanoY - size/8, size/8)
            
            -- 熔岩
            love.graphics.setColor(1, 0.5, 0.1)
            love.graphics.circle('fill', volcanoX, volcanoY - size/8, size/12)
            
            -- 偶尔喷发
            if math.random() < 0.3 then
                love.graphics.setColor(1, 0.3, 0.1, 0.8)
                
                -- 熔岩流
                local lavaStreamCount = math.random(3, 5)
                for i = 1, lavaStreamCount do
                    local angle = math.random() * math.pi - math.pi/2  -- 向上的一半圆
                    local length = size/4 + math.random() * size/4
                    love.graphics.line(
                        volcanoX, volcanoY - size/8,
                        volcanoX + math.cos(angle) * length,
                        volcanoY - size/8 + math.sin(angle) * length
                    )
                end
                
                -- 火花
                local sparkCount = math.random(3, 8)
                love.graphics.setColor(1, 0.6, 0.2, 0.9)
                for i = 1, sparkCount do
                    local sparkX = volcanoX + math.random(-size/8, size/8)
                    local sparkY = volcanoY - size/8 - math.random(0, size/4)
                    love.graphics.circle('fill', sparkX, sparkY, size/40)
                end
            end
            
            -- 火山周围的岩石
            local rockCount = math.random(2, 4)
            for i = 1, rockCount do
                love.graphics.setColor(0.4, 0.3, 0.2)
                local rockX = x + math.random(5, size-5)
                local rockY = y + math.random(size/2, size-5)  -- 只在下半部分
                local rockSize = size/12 + math.random() * size/12
                
                -- 不规则形状的岩石
                local vertices = {}
                local pointCount = math.random(5, 7)
                for j = 1, pointCount do
                    local angle = (j - 1) * (2 * math.pi / pointCount)
                    local radius = rockSize * (0.8 + math.random() * 0.4)
                    table.insert(vertices, rockX + math.cos(angle) * radius)
                    table.insert(vertices, rockY + math.sin(angle) * radius)
                end
                
                love.graphics.polygon('fill', unpack(vertices))
            end
        end
    }
}

-- 定义不同地形的移动速度修正
local TERRAIN_SPEED_MODIFIER = {
    [TERRAIN_TYPES.GRASS] = 1.0,   -- 草地正常速度
    [TERRAIN_TYPES.WATER] = 0.0,   -- 水面不能走
    [TERRAIN_TYPES.SAND] = 0.7,    -- 沙地减速
    [TERRAIN_TYPES.FOREST] = 0.8,  -- 森林减速
    [TERRAIN_TYPES.MOUNTAIN] = 0.5, -- 山地大幅减速
    [TERRAIN_TYPES.SNOW] = 0.6,     -- 雪地减速
    [TERRAIN_TYPES.SWAMP] = 0.4,    -- 沼泽严重减速
    [TERRAIN_TYPES.VOLCANO] = 0.3   -- 火山地区严重减速
}

return {
    TERRAIN_TYPES = TERRAIN_TYPES,
    TERRAIN_COLORS = TERRAIN_COLORS,
    TERRAIN_DECORATIONS = TERRAIN_DECORATIONS,
    TERRAIN_SPEED_MODIFIER = TERRAIN_SPEED_MODIFIER
} 