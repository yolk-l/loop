-- 卡牌模型
local CardModel = {}
CardModel.__index = CardModel

-- 引入配置
local CardConfig = require('config/cards')
local TypeDefines = require('config/type_defines')

function CardModel.new()
    local mt = setmetatable({}, CardModel)
    mt.cards = {}  -- 玩家拥有的卡牌
    mt.hand = {}   -- 玩家手牌
    mt.handSize = 5  -- 最大手牌数量
    mt.selectedCard = nil  -- 当前选中的卡牌
    mt.selectedIndex = nil  -- 当前选中的卡牌索引
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

-- 添加卡牌到手牌
function CardModel:addCardToHand(cardType)
    -- 检查手牌是否已满
    if #self.hand >= self.handSize then
        return false
    end
    -- 创建新卡牌数据
    local card = {
        type = cardType,
        config = CardConfig[cardType],
        width = 100,
        height = 150,
        selected = false
    }
    
    -- 添加到手牌
    table.insert(self.hand, card)
    return true
end

-- 从手牌中移除卡牌
function CardModel:removeCardFromHand(cardObject)
    -- 在手牌中查找卡牌
    for i, card in ipairs(self.hand) do
        if card == cardObject then
            table.remove(self.hand, i)
            
            -- 清除选中状态
            if self.selectedCard == cardObject then
                self.selectedCard = nil
                self.selectedIndex = nil
            end
            return true
        end
    end
    
    return false
end

-- 获取卡牌对应的建筑类型
function CardModel:getBuildingType(cardIndex)
    if not cardIndex or not self.hand[cardIndex] then
        return nil
    end
    
    local card = self.hand[cardIndex]
    
    if card and card.config and card.config.buildingType then
        return card.config.buildingType
    end
    
    return nil
end

-- 获取当前选中卡牌的建筑类型
function CardModel:getSelectedBuildingType()
    if not self.selectedIndex then return nil end
    return self:getBuildingType(self.selectedIndex)
end

-- 选择卡牌
function CardModel:selectCard(index)
    if index and self.hand[index] then
        print("selectCard", index, self.hand[index], self.selectedIndex)
        if self.selectedIndex == index then
            -- 取消选择
            self.selectedCard = nil
            self.selectedIndex = nil
        else
            -- 选择新卡牌
            self.selectedCard = self.hand[index]
            self.selectedIndex = index
        end
        print("selectedCard", self.selectedCard, self.selectedIndex)
        return true
    end
    
    -- 取消选择
    self.selectedCard = nil
    self.selectedIndex = nil
    return false
end

-- 获取所有手牌
function CardModel:getHand()
    return self.hand
end

-- 获取选中的卡牌索引
function CardModel:getSelectedIndex()
    return self.selectedIndex
end

function CardModel:getSelectedCard()
    return self.selectedCard
end

return CardModel 