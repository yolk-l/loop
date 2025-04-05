local CardController = {}
CardController.__index = CardController

-- 引入模型和视图
local CardModel = require('card_model')
local CardView = require('card_view')

function CardController:new()
    local self = setmetatable({}, CardController)
    self.model = CardModel  -- 存储模型类
    self.view = CardView:new()
    self.cards = {}
    self.selectedCard = nil
    self.handArea = {
        x = 10,
        y = 550,
        spacing = 110
    }
    return self
end

-- 添加一个方法来获取卡牌类型
function CardController:getCardType(monsterType)
    if monsterType == "slime" then
        return self.model.CARD_TYPES.SLIME
    elseif monsterType == "goblin" then
        return self.model.CARD_TYPES.GOBLIN
    elseif monsterType == "skeleton" then
        return self.model.CARD_TYPES.SKELETON
    end
    return nil
end

function CardController:addCard(cardType)
    if #self.cards >= 5 then return false end
    local card = self.model:new(cardType)
    table.insert(self.cards, card)
    return true
end

function CardController:removeCard(card)
    for i, c in ipairs(self.cards) do
        if c == card then
            table.remove(self.cards, i)
            if self.selectedCard == card then
                self.selectedCard = nil
            end
            return true
        end
    end
    return false
end

function CardController:handleMouseClick(x, y)
    for i, card in ipairs(self.cards) do
        local cardX = self.handArea.x + (i-1) * self.handArea.spacing
        if self.view:isMouseOver(card, x, y, cardX, self.handArea.y) then
            if self.selectedCard == card then
                self.selectedCard = nil
            else
                self.selectedCard = card
            end
            return true
        end
    end
    return false
end

function CardController:draw()
    for i, card in ipairs(self.cards) do
        local x = self.handArea.x + (i-1) * self.handArea.spacing
        self.view:drawCard(card, x, self.handArea.y)
        
        -- 如果卡牌被选中，绘制选中效果
        if card == self.selectedCard then
            love.graphics.setColor(1, 1, 0, 0.5)
            love.graphics.rectangle('fill', x, self.handArea.y, 
                CardView.CARD_WIDTH, CardView.CARD_HEIGHT)
        end
    end
end

return CardController 