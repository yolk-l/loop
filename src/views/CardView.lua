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
    
    -- 计算手牌区域：地图高度为30*20=600，窗口高度为700
    -- 因此手牌区域y坐标为600，高度为100
    self.handArea = {x = 0, y = 600, width = 800, height = 100}
    
    initFonts()
    return self
end

function CardView:drawHand(cards, selectedIndex)
    love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
    love.graphics.rectangle('fill', self.handArea.x, self.handArea.y, self.handArea.width, self.handArea.height)
    
    if #cards == 0 then
        -- 如果没有卡牌，只显示提示文字
        love.graphics.setColor(0.7, 0.7, 0.7)
        local text = "无卡牌"
        love.graphics.print(text, self.handArea.x + self.handArea.width/2 - 30, self.handArea.y + self.handArea.height/2 - 10)
        return
    end
    
    local cardSpacing = 20
    local totalCardWidth = (#cards * (100 + cardSpacing)) - cardSpacing
    local startX = self.handArea.x + (self.handArea.width - totalCardWidth) / 2
    
    for i, card in ipairs(cards) do
        local cardX = startX + (i-1) * (100 + cardSpacing)
        local cardY = self.handArea.y + 10
        
        -- 如果是选中的卡牌，稍微上移
        if selectedIndex == i then
            cardY = cardY - 15
        end
        
        card:draw(cardX, cardY)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function CardView:updateHandPositions(cards)
    -- 只是用于在卡牌添加或移除后触发UI更新，具体实现待添加
end

return CardView 