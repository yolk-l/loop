-- 背包视图
local InventoryView = {}
InventoryView.__index = InventoryView

-- 字体缓存
local fonts = {
    title = nil,
    normal = nil,
    description = nil
}

-- 初始化字体
local function initFonts()
    if not fonts.title then
        fonts.title = love.graphics.newFont("assets/fonts/simsun.ttc", 16)
        fonts.normal = love.graphics.newFont("assets/fonts/simsun.ttc", 14)
        fonts.description = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function InventoryView.new()
    local mt = setmetatable({
        slotSize = 40,
        padding = 5,
        rows = 3,
        cols = 6,
        selectedItemInfo = nil
    }, InventoryView)
    
    initFonts()
    return mt
end

function InventoryView:draw(items, selected, x, y)
    -- 重置选中物品信息
    self.selectedItemInfo = nil
    
    love.graphics.setFont(fonts.normal)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("背包", x, y - 30)
    
    -- 绘制背包格子
    for row = 1, self.rows do
        for col = 1, self.cols do
            local index = (row-1) * self.cols + col
            local slotX = x + (col-1) * (self.slotSize + self.padding)
            local slotY = y + (row-1) * (self.slotSize + self.padding)
            
            -- 绘制格子
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle('fill', slotX, slotY, self.slotSize, self.slotSize)
            
            -- 绘制格子边框
            if selected == index then
                love.graphics.setColor(1, 1, 0)  -- 选中物品高亮
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.rectangle('line', slotX, slotY, self.slotSize, self.slotSize)
            
            -- 绘制物品（如果有）
            if items[index] then
                local item = items[index]
                

                -- 普通物品类型处理
                local AnimationSystem = require('src/utils/Animation')
                local image = nil
                
                -- 根据装备类型获取对应图像
                if item.config and item.config.image then
                    image = AnimationSystem.getWeaponImage(item.config.image)
                end
                
                if image then
                    -- 居中绘制图像
                    love.graphics.setColor(1, 1, 1)
                    local scale = 1.5  -- 缩放比例，根据需要调整
                    local imgWidth, imgHeight = image:getDimensions()
                    local imgX = slotX + self.slotSize/2 - (imgWidth * scale)/2
                    local imgY = slotY + self.slotSize/2 - (imgHeight * scale)/2
                    
                    love.graphics.draw(image, imgX, imgY, 0, scale, scale)
                else
                    -- 如果没有图像，使用圆形表示
                    if item.config and item.config.color then
                        love.graphics.setColor(item.config.color)
                    else
                        love.graphics.setColor(0.7, 0.7, 0.7)
                    end
                    love.graphics.circle('fill', slotX + self.slotSize/2, slotY + self.slotSize/2, self.slotSize/3)
                end
            end
            
            -- 保存选中物品信息，在外部最后绘制提示
            if selected == index then
                self.selectedItemInfo = {
                    item = item,
                    x = slotX,
                    y = slotY,
                    slotSize = self.slotSize
                }
            end
        end
    end

    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 在所有UI之上绘制物品提示
function InventoryView:drawItemTooltip()
    if not self.selectedItemInfo then return end
    
    local item = self.selectedItemInfo.item
    local slotX = self.selectedItemInfo.x
    local slotY = self.selectedItemInfo.y
    local slotSize = self.selectedItemInfo.slotSize
    
    -- 绘制物品名称提示
    love.graphics.setFont(fonts.description)
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)  -- 背景颜色
    
    -- 计算提示框的位置和大小
    local nameWidth
    local tooltipPadding = 5
    local tooltipHeight = 25  -- 基础高度
    -- 普通物品类型
    if not item.config then
        -- 如果没有config属性，绘制一个简单提示
        nameWidth = fonts.description:getWidth("未知物品")
        local tooltipWidth = nameWidth + tooltipPadding * 2
        local tooltipX = slotX + slotSize/2 - tooltipWidth/2
        local tooltipY = slotY - tooltipHeight - 5
        
        -- 绘制背景
        love.graphics.rectangle('fill', tooltipX, tooltipY, tooltipWidth, tooltipHeight, 5, 5)
        
        -- 绘制边框
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle('line', tooltipX, tooltipY, tooltipWidth, tooltipHeight, 5, 5)
        
        -- 绘制名称
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("未知物品", tooltipX + tooltipPadding, tooltipY + tooltipPadding)
        return
    end
    
    nameWidth = fonts.description:getWidth(item.config.name)
    
    -- 准备属性文本
    local attributeText = ""
    for stat, value in pairs(item.config.attributes or {}) do
        if attributeText ~= "" then attributeText = attributeText .. ", " end
        attributeText = attributeText .. stat .. "+" .. value
    end
    
    -- 如果有属性，增加高度
    local attributeWidth = 0
    if attributeText ~= "" then
        attributeWidth = fonts.description:getWidth(attributeText)
        tooltipHeight = tooltipHeight + 20
    end
    
    -- 如果有描述，增加高度
    if item.config.description then
        local descWidth = fonts.description:getWidth(item.config.description)
        attributeWidth = math.max(attributeWidth, descWidth)
        tooltipHeight = tooltipHeight + 20
    end
    
    -- 获取图像
    local hasImage = false
    local AnimationSystem = require('src/utils/Animation')
    local image = nil
    
    if item.config.image then
        image = AnimationSystem.getWeaponImage(item.config.image)
        if image then 
            hasImage = true
            tooltipHeight = tooltipHeight + 30
        end
    end
    
    -- 计算提示框宽度
    local tooltipWidth = math.max(nameWidth, attributeWidth) + tooltipPadding * 2
    
    -- 绘制提示框，确保不会超出窗口
    local tooltipX = slotX + slotSize/2 - tooltipWidth/2
    local tooltipY = slotY - tooltipHeight - 5
    
    -- 绘制背景
    love.graphics.rectangle('fill', tooltipX, tooltipY, tooltipWidth, tooltipHeight, 5, 5)
    
    -- 绘制边框
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle('line', tooltipX, tooltipY, tooltipWidth, tooltipHeight, 5, 5)
    
    -- 当前Y位置，用于垂直布局
    local currentY = tooltipY + tooltipPadding
    
    -- 绘制名称
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(item.config.name, tooltipX + tooltipPadding, currentY)
    currentY = currentY + 20
    
    -- 绘制图像
    if hasImage then
        local scale = 1.3
        local imgWidth, imgHeight = image:getDimensions()
        local imgX = tooltipX + tooltipWidth/2 - (imgWidth * scale)/2
        
        love.graphics.draw(image, imgX, currentY, 0, scale, scale)
        currentY = currentY + imgHeight * scale + 5
    end
    
    -- 绘制属性
    if attributeText ~= "" then
        love.graphics.print(attributeText, tooltipX + tooltipPadding, currentY)
        currentY = currentY + 20
    end
    
    -- 绘制描述
    if item.config.description then
        love.graphics.print(item.config.description, tooltipX + tooltipPadding, currentY)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function InventoryView:getSlotAtPosition(mx, my, x, y)
    for row = 1, self.rows do
        for col = 1, self.cols do
            local index = (row-1) * self.cols + col
            local slotX = x + (col-1) * (self.slotSize + self.padding)
            local slotY = y + (row-1) * (self.slotSize + self.padding)
            
            if mx >= slotX and mx <= slotX + self.slotSize and
               my >= slotY and my <= slotY + self.slotSize then
                return index
            end
        end
    end
    
    return nil
end

return InventoryView 