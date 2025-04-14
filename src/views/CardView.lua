-- 卡牌视图
local CardView = {}
CardView.__index = CardView

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

function CardView:new()
    initFonts()
    local mt = setmetatable({}, CardView)
    mt.handArea = {
        x = 0,
        y = love.graphics.getHeight() - 180,
        width = love.graphics.getWidth(),
        height = 180
    }
    return mt
end

-- 绘制单张卡牌
function CardView:drawCard(card, x, y, isSelected)
    -- 检查config是否存在
    if not card.config then
        -- 如果config为nil，绘制错误信息
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle('fill', x, y, card.width, card.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fonts.title)
        love.graphics.print("配置错误!", x + 10, y + 10)
        love.graphics.setFont(fonts.description)
        love.graphics.print("卡牌类型: " .. (card.type or "未知"), x + 10, y + 40)
        love.graphics.setColor(1, 1, 1)
        return
    end
    
    -- 绘制卡牌背景
    if isSelected then
        love.graphics.setColor(0.9, 0.9, 0.9)
    else
        love.graphics.setColor(0.8, 0.8, 0.8)
    end
    love.graphics.rectangle('fill', x, y, card.width, card.height)
    
    -- 绘制卡牌边框
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('line', x, y, card.width, card.height)
    
    -- 绘制卡牌颜色标识
    love.graphics.setColor(unpack(card.config.color))
    love.graphics.rectangle('fill', x + 5, y + 5, card.width - 10, 30)
    
    -- 绘制卡牌文字
    love.graphics.setColor(0, 0, 0)
    
    -- 使用标题字体绘制名称
    love.graphics.setFont(fonts.title)
    love.graphics.print(card.config.name, x + 10, y + 10)
    
    -- 使用描述字体绘制描述文字
    love.graphics.setFont(fonts.description)
    love.graphics.printf(card.config.description, x + 5, y + 50, card.width - 10)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 检查点击是否在卡牌上
function CardView:isCardClicked(card, mx, my, x, y)
    return mx >= x and mx <= x + card.width and
           my >= y and my <= y + card.height
end

-- 绘制手牌区域
function CardView:drawHand(hand, selectedIndex)
    -- 绘制手牌区域背景
    love.graphics.setColor(0.1, 0.1, 0.1, 0.7)
    love.graphics.rectangle('fill', self.handArea.x, self.handArea.y, self.handArea.width, self.handArea.height)
    
    -- 如果没有手牌，显示提示信息
    if #hand == 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fonts.normal)
        love.graphics.printf("没有可用的卡牌", self.handArea.x, self.handArea.y + 80, self.handArea.width, "center")
        return
    end
    
    -- 计算卡牌布局
    local cardSpacing = 20
    local totalCardWidth = (#hand * (100 + cardSpacing)) - cardSpacing
    local startX = self.handArea.x + (self.handArea.width - totalCardWidth) / 2
    
    -- 绘制每张卡牌
    for i, card in ipairs(hand) do
        local cardX = startX + (i-1) * (100 + cardSpacing)
        local cardY = self.handArea.y + 10
        
        -- 如果是选中的卡牌，稍微上移
        if i == selectedIndex then
            cardY = cardY - 20
        end
        
        self:drawCard(card, cardX, cardY, i == selectedIndex)
    end
end

-- 更新手牌位置（可用于动画效果）
function CardView:updateHandPositions(hand)
    -- 如果需要可以在这里实现卡牌位置的动态调整
end

-- 获取卡牌位置信息
function CardView:getCardPosition(index, handSize)
    local cardSpacing = 20
    local totalCardWidth = (handSize * (100 + cardSpacing)) - cardSpacing
    local startX = self.handArea.x + (self.handArea.width - totalCardWidth) / 2
    
    return {
        x = startX + (index-1) * (100 + cardSpacing),
        y = self.handArea.y + 10
    }
end

-- 检查点击是否在手牌区域中
function CardView:isHandAreaClicked(x, y)
    return x >= self.handArea.x and x <= self.handArea.x + self.handArea.width and
           y >= self.handArea.y and y <= self.handArea.y + self.handArea.height
end

-- 找出点击的卡牌索引
function CardView:getClickedCardIndex(hand, x, y)
    if not self:isHandAreaClicked(x, y) then
        return nil
    end
    
    local cardSpacing = 20
    local totalCardWidth = (#hand * (100 + cardSpacing)) - cardSpacing
    local startX = self.handArea.x + (self.handArea.width - totalCardWidth) / 2
    
    for i, card in ipairs(hand) do
        local cardX = startX + (i-1) * (100 + cardSpacing)
        local cardY = self.handArea.y + 10
        
        if self:isCardClicked(card, x, y, cardX, cardY) then
            return i
        end
    end
    
    return nil
end

return CardView 