-- 卡牌模型
local CardModel = {}
CardModel.__index = CardModel

function CardModel:new()
    local mt = setmetatable({}, CardModel)
    mt.cards = {}  -- 玩家拥有的卡牌
    return mt
end

function CardModel:addCard(cardType)
    table.insert(self.cards, cardType)
    return #self.cards
end

function CardModel:removeCard(index)
    if index and index >= 1 and index <= #self.cards then
        table.remove(self.cards, index)
        return true
    end
    return false
end

return CardModel 