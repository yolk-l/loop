-- 卡牌模型
local CardModel = {}
CardModel.__index = CardModel

-- 引入卡牌配置
local CardConfig = require('config/cards')

function CardModel:new()
    local self = setmetatable({}, CardModel)
    self.cards = {}  -- 玩家拥有的卡牌
    return self
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

function CardModel:getCardType(monsterType)
    if monsterType == "slime" then
        return CardConfig.CARD_TYPES.SLIME
    elseif monsterType == "goblin" then
        return CardConfig.CARD_TYPES.GOBLIN
    elseif monsterType == "skeleton" then
        return CardConfig.CARD_TYPES.SKELETON
    end
    return nil
end

return CardModel 