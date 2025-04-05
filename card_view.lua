local CardView = {}
CardView.__index = CardView

-- 卡牌显示配置
CardView.CARD_WIDTH = 100
CardView.CARD_HEIGHT = 150
CardView.CARD_PADDING = 10

function CardView:new()
    local self = setmetatable({}, CardView)
    return self
end

function CardView:drawCard(card, x, y)
    if not card or not card.config then return end
    
    -- 绘制卡牌背景
    love.graphics.setColor(card.config.color)
    love.graphics.rectangle('fill', x, y, CardView.CARD_WIDTH, CardView.CARD_HEIGHT)
    
    -- 绘制卡牌边框
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('line', x, y, CardView.CARD_WIDTH, CardView.CARD_HEIGHT)
    
    -- 绘制卡牌名称
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(card.config.name, x + CardView.CARD_PADDING, y + CardView.CARD_PADDING)
    
    -- 绘制卡牌描述
    love.graphics.print(card.config.description, 
        x + CardView.CARD_PADDING, 
        y + CardView.CARD_HEIGHT/2)
end

function CardView:isMouseOver(card, mouseX, mouseY, cardX, cardY)
    return mouseX >= cardX and mouseX <= cardX + CardView.CARD_WIDTH and
           mouseY >= cardY and mouseY <= cardY + CardView.CARD_HEIGHT
end

return CardView 