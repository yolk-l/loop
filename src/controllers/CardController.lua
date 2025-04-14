-- 卡牌控制器
local CardController = {}
CardController.__index = CardController

-- 引入卡牌模型和视图
local CardModel = require('src/models/CardModel')
local CardView = require('src/views/CardView')
local Card = require('src/systems/Card').Card
local cardConfig = require('config/cards')

function CardController:new()
    local mt = setmetatable({}, CardController)
    mt.model = CardModel:new()
    mt.view = CardView:new()
    mt.selectedCard = nil
    mt.selectedIndex = nil
    mt.hand = {}  -- 初始化手牌数组
    mt.handSize = 5  -- 最大手牌数量
    return mt
end

function CardController:addCard(cardType)
    -- 检查手牌是否已满
    if #self.hand >= self.handSize then
        return false
    end
    
    -- 判断卡牌类型的有效性
    if cardType < 1 or cardType > #cardConfig.CARD_TYPES then
        cardType = math.random(1, #cardConfig.CARD_TYPES)
    end
    
    -- 创建新卡牌
    local card = Card:new(cardType)
    
    -- 添加到手牌
    table.insert(self.hand, card)
    self.view:updateHandPositions(self.hand)
    return true
end

function CardController:removeCard(cardObject)
    -- 在手牌中查找卡牌
    for i, card in ipairs(self.hand) do
        if card == cardObject then
            table.remove(self.hand, i)
            self.view:updateHandPositions(self.hand)
            
            -- 清除选中状态
            self.selectedCard = nil
            self.selectedIndex = nil
            return true
        end
    end
    
    return false
end

function CardController:getBuildingType(cardIndex)
    if not cardIndex or not self.hand[cardIndex] then
        return nil
    end
    
    local card = self.hand[cardIndex]
    
    if card and card.config and card.config.buildingType then
        return card.config.buildingType
    end
    
    return nil
end

function CardController:getSelectedBuildingType()
    if not self.selectedIndex then return nil end
    return self:getBuildingType(self.selectedIndex)
end

function CardController:handleMouseClick(x, y)
    -- 检查是否点击在手牌区域
    if x >= self.view.handArea.x and x <= self.view.handArea.x + self.view.handArea.width and
       y >= self.view.handArea.y and y <= self.view.handArea.y + self.view.handArea.height then
        
        local cardSpacing = 20
        local totalCardWidth = (#self.hand * (100 + cardSpacing)) - cardSpacing
        local startX = self.view.handArea.x + (self.view.handArea.width - totalCardWidth) / 2
        
        -- 检查是否点击了某个卡牌
        for i, card in ipairs(self.hand) do
            local cardX = startX + (i-1) * (100 + cardSpacing)
            local cardY = self.view.handArea.y + 10
            
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
    self.view:drawHand(self.hand, self.selectedIndex)
end

return CardController 