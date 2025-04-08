-- 像素精灵生成工具
local PixelSprites = {}

-- 生成简单的像素精灵表
function PixelSprites.generateSprites()
    local hasSprites = love.filesystem.getInfo("assets/sprites/player_sheet.png")
    
    -- 如果精灵表已存在，则不再重新生成
    if hasSprites then
        return
    end
    
    -- 创建sprites目录（如果不存在）
    love.filesystem.createDirectory("assets/sprites")
    
    -- 生成玩家精灵表 (64x32)
    PixelSprites.generatePlayerSheet()
    
    -- 生成怪物精灵表
    PixelSprites.generateSlimeSheet()
    PixelSprites.generateGoblinSheet()
    PixelSprites.generateSkeletonSheet()
end

-- 生成玩家精灵表
function PixelSprites.generatePlayerSheet()
    local sheetWidth, sheetHeight = 64, 32  -- 4x2帧，每帧16x16
    local canvas = love.graphics.newCanvas(sheetWidth, sheetHeight)
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    
    -- 绘制玩家空闲动画帧（第一行）
    for i = 0, 3 do
        local x, y = i * 16, 0
        
        -- 基础形状
        love.graphics.setColor(0.2, 0.6, 1.0)  -- 蓝色
        love.graphics.circle("fill", x + 8, y + 8, 6)
        
        -- 边缘
        love.graphics.setColor(0.1, 0.3, 0.5)
        love.graphics.circle("line", x + 8, y + 8, 6)
        
        -- 添加动画变化（脉动效果）
        local scale = 0.8 + 0.2 * math.sin(i * math.pi / 2)
        
        -- 武器
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.line(x + 8, y + 8, x + 8 + 4 * scale, y + 8 - 4 * scale)
    end
    
    -- 绘制玩家攻击动画帧（第二行）
    for i = 0, 3 do
        local x, y = i * 16, 16
        
        -- 基础形状
        love.graphics.setColor(0.2, 0.6, 1.0)  -- 蓝色
        love.graphics.circle("fill", x + 8, y + 8, 6)
        
        -- 边缘
        love.graphics.setColor(0.1, 0.3, 0.5)
        love.graphics.circle("line", x + 8, y + 8, 6)
        
        -- 添加攻击动画（武器挥舞）
        local angle = i * math.pi / 2
        local wx = math.cos(angle) * 8
        local wy = math.sin(angle) * 8
        
        -- 武器
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.line(x + 8, y + 8, x + 8 + wx, y + 8 + wy)
        
        -- 攻击效果
        if i > 0 then
            love.graphics.setColor(1, 0.7, 0.2, 0.7 - i * 0.2)
            love.graphics.circle("line", x + 8 + wx * 1.2, y + 8 + wy * 1.2, 3 + i)
        end
    end
    
    love.graphics.setCanvas()
    
    -- 保存为文件
    local data = canvas:newImageData()
    data:encode("png", "assets/sprites/player_sheet.png")
end

-- 生成史莱姆精灵表
function PixelSprites.generateSlimeSheet()
    local sheetWidth, sheetHeight = 64, 32  -- 4x2帧，每帧16x16
    local canvas = love.graphics.newCanvas(sheetWidth, sheetHeight)
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    
    -- 绘制史莱姆空闲动画帧（第一行）
    for i = 0, 3 do
        local x, y = i * 16, 0
        
        -- 设置颜色 (绿色史莱姆)
        love.graphics.setColor(0.4, 0.8, 0.3)
        
        -- 基础形状
        local height = 5 + math.sin(i * math.pi / 2) * 1.5
        love.graphics.ellipse("fill", x + 8, y + 11, 6, height)
        
        -- 边缘
        love.graphics.setColor(0.2, 0.5, 0.1)
        love.graphics.ellipse("line", x + 8, y + 11, 6, height)
        
        -- 眼睛
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", x + 6, y + 9, 1.5)
        love.graphics.circle("fill", x + 10, y + 9, 1.5)
        
        -- 瞳孔
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", x + 6, y + 9, 0.7)
        love.graphics.circle("fill", x + 10, y + 9, 0.7)
    end
    
    -- 绘制史莱姆移动动画帧（第二行）
    for i = 0, 3 do
        local x, y = i * 16, 16
        
        -- 设置颜色
        love.graphics.setColor(0.4, 0.8, 0.3)
        
        -- 跳跃动画
        local jumpHeight = {2, 4, 2, 0}  -- 跳跃高度
        local squash = {1.2, 0.8, 1.0, 1.2}  -- 挤压系数
        
        -- 基础形状
        love.graphics.ellipse("fill", x + 8, y + 11 - jumpHeight[i+1], 6 * squash[i+1], 5 / squash[i+1])
        
        -- 边缘
        love.graphics.setColor(0.2, 0.5, 0.1)
        love.graphics.ellipse("line", x + 8, y + 11 - jumpHeight[i+1], 6 * squash[i+1], 5 / squash[i+1])
        
        -- 眼睛
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", x + 6, y + 9 - jumpHeight[i+1], 1.5)
        love.graphics.circle("fill", x + 10, y + 9 - jumpHeight[i+1], 1.5)
        
        -- 瞳孔
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", x + 6, y + 9 - jumpHeight[i+1], 0.7)
        love.graphics.circle("fill", x + 10, y + 9 - jumpHeight[i+1], 0.7)
    end
    
    love.graphics.setCanvas()
    
    -- 保存为文件
    local data = canvas:newImageData()
    data:encode("png", "assets/sprites/slime_sheet.png")
end

-- 生成哥布林精灵表
function PixelSprites.generateGoblinSheet()
    local sheetWidth, sheetHeight = 64, 32  -- 4x2帧，每帧16x16
    local canvas = love.graphics.newCanvas(sheetWidth, sheetHeight)
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    
    -- 绘制哥布林空闲动画帧（第一行）
    for i = 0, 3 do
        local x, y = i * 16, 0
        
        -- 身体
        love.graphics.setColor(0.5, 0.7, 0.3)
        love.graphics.rectangle("fill", x + 5, y + 7, 6, 7)
        
        -- 头
        love.graphics.setColor(0.5, 0.7, 0.3)
        love.graphics.circle("fill", x + 8, y + 5, 3)
        
        -- 耳朵
        love.graphics.setColor(0.5, 0.7, 0.3)
        love.graphics.polygon("fill", x + 5, y + 5, x + 3, y + 2, x + 4, y + 6)
        love.graphics.polygon("fill", x + 11, y + 5, x + 13, y + 2, x + 12, y + 6)
        
        -- 眼睛
        love.graphics.setColor(0.9, 0.1, 0.1)
        love.graphics.circle("fill", x + 7, y + 4, 0.8)
        love.graphics.circle("fill", x + 9, y + 4, 0.8)
        
        -- 轻微的呼吸动画
        if i % 2 == 0 then
            love.graphics.setColor(0.4, 0.6, 0.2)
            love.graphics.line(x + 6, y + 11, x + 10, y + 11)
        else
            love.graphics.setColor(0.4, 0.6, 0.2)
            love.graphics.line(x + 6, y + 10, x + 10, y + 10)
        end
        
        -- 手臂
        love.graphics.setColor(0.4, 0.6, 0.2)
        love.graphics.line(x + 5, y + 9, x + 3, y + 10 + i % 2)
        love.graphics.line(x + 11, y + 9, x + 13, y + 10 + i % 2)
        
        -- 腿部
        love.graphics.setColor(0.4, 0.6, 0.2)
        love.graphics.line(x + 6, y + 14, x + 5, y + 16)
        love.graphics.line(x + 10, y + 14, x + 11, y + 16)
    end
    
    -- 绘制哥布林移动动画帧（第二行）
    for i = 0, 3 do
        local x, y = i * 16, 16
        
        -- 身体
        love.graphics.setColor(0.5, 0.7, 0.3)
        love.graphics.rectangle("fill", x + 5, y + 7, 6, 7)
        
        -- 头
        love.graphics.setColor(0.5, 0.7, 0.3)
        love.graphics.circle("fill", x + 8, y + 5, 3)
        
        -- 耳朵
        love.graphics.setColor(0.5, 0.7, 0.3)
        love.graphics.polygon("fill", x + 5, y + 5, x + 3, y + 2, x + 4, y + 6)
        love.graphics.polygon("fill", x + 11, y + 5, x + 13, y + 2, x + 12, y + 6)
        
        -- 眼睛
        love.graphics.setColor(0.9, 0.1, 0.1)
        love.graphics.circle("fill", x + 7, y + 4, 0.8)
        love.graphics.circle("fill", x + 9, y + 4, 0.8)
        
        -- 跑步动画的手臂和腿部
        local legOffset = {0, 1, 0, -1}
        
        -- 手臂
        love.graphics.setColor(0.4, 0.6, 0.2)
        love.graphics.line(x + 5, y + 9, x + 3, y + 10 + legOffset[i+1])
        love.graphics.line(x + 11, y + 9, x + 13, y + 10 - legOffset[i+1])
        
        -- 腿部
        love.graphics.setColor(0.4, 0.6, 0.2)
        love.graphics.line(x + 6, y + 14, x + 5, y + 16 + legOffset[i+1])
        love.graphics.line(x + 10, y + 14, x + 11, y + 16 - legOffset[i+1])
    end
    
    love.graphics.setCanvas()
    
    -- 保存为文件
    local data = canvas:newImageData()
    data:encode("png", "assets/sprites/goblin_sheet.png")
end

-- 生成骷髅精灵表
function PixelSprites.generateSkeletonSheet()
    local sheetWidth, sheetHeight = 64, 48  -- 4x3帧，每帧16x16
    local canvas = love.graphics.newCanvas(sheetWidth, sheetHeight)
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    
    -- 绘制骷髅空闲动画帧（第一行）
    for i = 0, 3 do
        local x, y = i * 16, 0
        
        -- 骷髅身体
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle("fill", x + 6, y + 7, 4, 6)
        
        -- 骷髅头
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.circle("fill", x + 8, y + 5, 3)
        
        -- 眼窝
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", x + 7, y + 4, 0.8)
        love.graphics.circle("fill", x + 9, y + 4, 0.8)
        
        -- 头骨纹路
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.line(x + 8, y + 2, x + 8, y + 6)
        
        -- 轻微的晃动动画
        local sway = i % 2 == 0 and 0.5 or -0.5
        
        -- 手臂
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.line(x + 6, y + 9, x + 4, y + 11 + sway)
        love.graphics.line(x + 10, y + 9, x + 12, y + 11 + sway)
        
        -- 腿部
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.line(x + 7, y + 13, x + 6, y + 16)
        love.graphics.line(x + 9, y + 13, x + 10, y + 16)
    end
    
    -- 绘制骷髅移动动画帧（第二行）
    for i = 0, 3 do
        local x, y = i * 16, 16
        
        -- 骷髅身体
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle("fill", x + 6, y + 7, 4, 6)
        
        -- 骷髅头
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.circle("fill", x + 8, y + 5, 3)
        
        -- 眼窝
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", x + 7, y + 4, 0.8)
        love.graphics.circle("fill", x + 9, y + 4, 0.8)
        
        -- 头骨纹路
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.line(x + 8, y + 2, x + 8, y + 6)
        
        -- 行走动画
        local legOffset = {0, 1, 0, -1}
        
        -- 手臂
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.line(x + 6, y + 9, x + 4, y + 11 + legOffset[i+1])
        love.graphics.line(x + 10, y + 9, x + 12, y + 11 - legOffset[i+1])
        
        -- 腿部
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.line(x + 7, y + 13, x + 6, y + 16 + legOffset[i+1])
        love.graphics.line(x + 9, y + 13, x + 10, y + 16 - legOffset[i+1])
    end
    
    -- 绘制骷髅攻击动画帧（第三行）
    for i = 0, 3 do
        local x, y = i * 16, 32
        
        -- 骷髅身体
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle("fill", x + 6, y + 7, 4, 6)
        
        -- 骷髅头
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.circle("fill", x + 8, y + 5, 3)
        
        -- 眼窝（攻击时红光闪烁）
        love.graphics.setColor(0.8, 0, 0, 0.5 + i * 0.1)
        love.graphics.circle("fill", x + 7, y + 4, 0.8)
        love.graphics.circle("fill", x + 9, y + 4, 0.8)
        
        -- 头骨纹路
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.line(x + 8, y + 2, x + 8, y + 6)
        
        -- 攻击动画（右手挥舞骨刀）
        local attackAngle = i * math.pi / 4
        local wx = math.cos(-attackAngle) * 4
        local wy = math.sin(-attackAngle) * 4
        
        -- 左手
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.line(x + 6, y + 9, x + 4, y + 11)
        
        -- 右手（持武器的手）
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.line(x + 10, y + 9, x + 12 + wx/2, y + 11 + wy/2)
        
        -- 骨刀
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.line(x + 12 + wx/2, y + 11 + wy/2, x + 12 + wx, y + 11 + wy)
        
        -- 腿部
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.line(x + 7, y + 13, x + 6, y + 16)
        love.graphics.line(x + 9, y + 13, x + 10, y + 16)
        
        -- 攻击效果
        if i > 0 then
            love.graphics.setColor(0.8, 0, 0, 0.7 - i * 0.2)
            love.graphics.arc("line", x + 12 + wx * 1.2, y + 11 + wy * 1.2, 3 + i, attackAngle - 0.5, attackAngle + 0.5)
        end
    end
    
    love.graphics.setCanvas()
    
    -- 保存为文件
    local data = canvas:newImageData()
    data:encode("png", "assets/sprites/skeleton_sheet.png")
end

return PixelSprites 