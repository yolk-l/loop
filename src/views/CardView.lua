-- 卡牌视图
local CardView = {}
CardView.__index = CardView

-- 引入卡牌配置和卡牌类
local CardConfig = require('config/cards')
local Card = require('src/systems/Card').Card

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
    local self = setmetatable({}, CardView)
    self.handArea = {x = 0, y = 570, width = 800, height = 130}
    initFonts()
    return self
end

function CardView:drawHand(cards, selectedIndex)
    love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
    love.graphics.rectangle('fill', self.handArea.x, self.handArea.y, self.handArea.width, self.handArea.height)
    
    local cardSpacing = 20
    local totalCardWidth = (#cards * (100 + cardSpacing)) - cardSpacing
    local startX = self.handArea.x + (self.handArea.width - totalCardWidth) / 2
    
    for i, cardType in ipairs(cards) do
        local card = Card:new(cardType)
        card.selected = (i == selectedIndex)
        card:draw(startX + (i-1) * (100 + cardSpacing), self.handArea.y + 10)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return CardView 