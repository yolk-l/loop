-- 生成简单的像素精灵表
local PixelSprites = {}

-- 像素精灵类型
PixelSprites.TYPES = {
    MONSTER = 1,
    BUILDING = 2,
    ITEM = 3,
    PLAYER = 4,
    EFFECT = 5
}

-- 预定义的颜色
PixelSprites.COLORS = {
    RED = {1, 0, 0},
    GREEN = {0, 1, 0},
    BLUE = {0, 0, 1},
    YELLOW = {1, 1, 0},
    PURPLE = {1, 0, 1},
    CYAN = {0, 1, 1},
    WHITE = {1, 1, 1},
    BLACK = {0, 0, 0},
    GRAY = {0.5, 0.5, 0.5},
    ORANGE = {1, 0.5, 0},
    BROWN = {0.6, 0.3, 0}
}

-- 从像素数据生成精灵图像
function PixelSprites.createFromPixelData(pixelData, size, color)
    -- 创建一个新的图像数据
    local imageData = love.image.newImageData(size, size)
    
    -- 设置每个像素
    for y = 0, size - 1 do
        for x = 0, size - 1 do
            local index = y * size + x + 1
            if pixelData[index] == 1 then
                imageData:setPixel(x, y, color[1], color[2], color[3], 1)
            else
                imageData:setPixel(x, y, 0, 0, 0, 0)
            end
        end
    end
    
    -- 从图像数据创建图像
    return love.graphics.newImage(imageData)
end

-- 生成随机怪物精灵
function PixelSprites.generateMonsterSprite(size, color)
    size = size or 8
    color = color or PixelSprites.COLORS.RED
    
    -- 创建像素数据（随机生成）
    local pixelData = {}
    for i = 1, size * size do
        pixelData[i] = 0
    end
    
    -- 生成怪物外形（对称设计）
    for y = 0, math.floor(size/2) do
        for x = 0, size - 1 do
            local index = y * size + x + 1
            if math.random() > 0.7 then
                pixelData[index] = 1
                -- 垂直对称
                local mirrorY = (size - 1 - y)
                local mirrorIndex = mirrorY * size + x + 1
                pixelData[mirrorIndex] = 1
            end
        end
    end
    
    -- 生成怪物的眼睛（两个像素点）
    local eyeY = math.floor(size/3)
    local leftEyeX = math.floor(size/3)
    local rightEyeX = size - 1 - leftEyeX
    
    pixelData[eyeY * size + leftEyeX + 1] = 1
    pixelData[eyeY * size + rightEyeX + 1] = 1
    
    return PixelSprites.createFromPixelData(pixelData, size, color)
end

-- 生成随机建筑精灵
function PixelSprites.generateBuildingSprite(size, color)
    size = size or 16
    color = color or PixelSprites.COLORS.BLUE
    
    -- 创建像素数据
    local pixelData = {}
    for i = 1, size * size do
        pixelData[i] = 0
    end
    
    -- 生成建筑基础（底部实心）
    for y = math.floor(size * 0.7), size - 1 do
        for x = 0, size - 1 do
            local index = y * size + x + 1
            pixelData[index] = 1
        end
    end
    
    -- 生成建筑上部结构
    local buildingWidth = math.floor(size * 0.8)
    local startX = math.floor((size - buildingWidth) / 2)
    local endX = startX + buildingWidth - 1
    
    for y = math.floor(size * 0.3), math.floor(size * 0.7) - 1 do
        for x = startX, endX do
            local index = y * size + x + 1
            pixelData[index] = 1
        end
    end
    
    -- 添加一些随机细节
    for i = 1, math.floor(size/3) do
        local x = math.random(startX + 1, endX - 1)
        local y = math.random(math.floor(size * 0.4), math.floor(size * 0.6))
        local index = y * size + x + 1
        pixelData[index] = 0  -- 窗户
    end
    
    return PixelSprites.createFromPixelData(pixelData, size, color)
end

-- 生成简单的物品精灵
function PixelSprites.generateItemSprite(size, color)
    size = size or 8
    color = color or PixelSprites.COLORS.YELLOW
    
    -- 创建像素数据
    local pixelData = {}
    for i = 1, size * size do
        pixelData[i] = 0
    end
    
    -- 生成物品（通常为简单几何形状）
    local itemType = math.random(1, 3)
    
    if itemType == 1 then  -- 圆形
        local center = size/2 - 0.5
        local radius = size/3
        
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                local dx = x - center
                local dy = y - center
                local distance = math.sqrt(dx*dx + dy*dy)
                
                if distance <= radius then
                    local index = y * size + x + 1
                    pixelData[index] = 1
                end
            end
        end
    elseif itemType == 2 then  -- 方形
        local padding = math.floor(size/4)
        
        for y = padding, size - 1 - padding do
            for x = padding, size - 1 - padding do
                local index = y * size + x + 1
                pixelData[index] = 1
            end
        end
    else  -- 三角形
        for y = 0, size - 1 do
            local width = math.floor((size - y) * 0.8)
            local startX = math.floor((size - width) / 2)
            
            for x = startX, startX + width - 1 do
                if x >= 0 and x < size and y >= 0 and y < size then
                    local index = y * size + x + 1
                    pixelData[index] = 1
                end
            end
        end
    end
    
    return PixelSprites.createFromPixelData(pixelData, size, color)
end

-- 生成简单的特效精灵
function PixelSprites.generateEffectSprite(size, color)
    size = size or 16
    color = color or PixelSprites.COLORS.WHITE
    
    -- 创建像素数据
    local pixelData = {}
    for i = 1, size * size do
        pixelData[i] = 0
    end
    
    -- 生成一个爆炸效果
    local center = size/2 - 0.5
    local maxRadius = size/2 - 1
    
    for y = 0, size - 1 do
        for x = 0, size - 1 do
            local dx = x - center
            local dy = y - center
            local distance = math.sqrt(dx*dx + dy*dy)
            
            -- 爆炸效果：随着距离中心越远，绘制概率越低
            if distance <= maxRadius and math.random() > (distance / maxRadius) then
                local index = y * size + x + 1
                pixelData[index] = 1
            end
        end
    end
    
    return PixelSprites.createFromPixelData(pixelData, size, color)
end

return PixelSprites 