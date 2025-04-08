-- 卡牌控制器
local CardController = {}
CardController.__index = CardController

-- 引入卡牌模型和视图
local CardModel = require('src/models/CardModel')
local CardView = require('src/views/CardView')
local Card = require('src/systems/Card').Card

function CardController:new()
    local self = setmetatable({}, CardController)
    self.model = CardModel:new()
    self.view = CardView:new()
    self.selectedCard = nil
    self.selectedIndex = nil
    return self
end

function CardController:addCard(cardType)
    local index = self.model:addCard(cardType)
    return index
end

function CardController:removeCard(cardObject)
    if not self.selectedIndex then return false end
    
    -- 移除选中的卡牌
    self.model:removeCard(self.selectedIndex)
    
    -- 清除选中状态
    self.selectedCard = nil
    self.selectedIndex = nil
    
    return true
end

function CardController:getCardType(monsterType)
    return self.model:getCardType(monsterType)
end

function CardController:handleMouseClick(x, y)
    -- 检查是否点击在手牌区域
    if x >= self.view.handArea.x and x <= self.view.handArea.x + self.view.handArea.width and
       y >= self.view.handArea.y and y <= self.view.handArea.y + self.view.handArea.height then
        
        local cardSpacing = 20
        local totalCardWidth = (#self.model.cards * (100 + cardSpacing)) - cardSpacing
        local startX = self.view.handArea.x + (self.view.handArea.width - totalCardWidth) / 2
        
        -- 检查是否点击了某个卡牌
        for i, cardType in ipairs(self.model.cards) do
            local cardX = startX + (i-1) * (100 + cardSpacing)
            local cardY = self.view.handArea.y + 10
            local card = Card:new(cardType)
            
            if card:isMouseOver(x, y, cardX, cardY) then
                if self.selectedIndex == i then
                    -- 点击已选择的卡牌，取消选择
                    self.selectedCard = nil
                    self.selectedIndex = nil
                else
                    -- 选择新卡牌
                    self.selectedCard = card
                    self.selectedIndex = i
                end
                return true
            end
        end
        
        -- 如果点击了手牌区域但没有点击任何卡牌，取消选择
        self.selectedCard = nil
        self.selectedIndex = nil
        return true
    end
    
    return false
end

function CardController:draw()
    self.view:drawHand(self.model.cards, self.selectedIndex)
end

return CardController 