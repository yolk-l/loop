-- 卡牌管理器
-- 用于管理卡牌、手牌和牌库，符合MVC架构
local CardManager = {}
CardManager.__index = CardManager

local CardController = require('src/controllers/CardController')
local TypeDefines = require('config/type_defines')
local CardConfig = require('config/cards')

function CardManager.new()
    local self = setmetatable({}, CardManager)
    self.cardController = CardController.new()
    self.deck = {}  -- 玩家牌库
    self.maxHandSize = 5  -- 最大手牌数量
    return self
end

-- 初始化起始手牌
function CardManager:initStartingHand(cardTypes)
    for _, cardType in ipairs(cardTypes) do
        self:addCardToHand(cardType)
    end
end

-- 添加卡牌到手牌
function CardManager:addCardToHand(cardType)
    return self.cardController:addCard(cardType)
end

-- 从手牌中移除卡牌
function CardManager:removeCardFromHand(cardObject)
    return self.cardController:removeCard(cardObject)
end

-- 添加卡牌到牌库
function CardManager:addCardToDeck(cardType)
    table.insert(self.deck, cardType)
    return #self.deck
end

-- 从牌库抽一张卡牌到手中
function CardManager:drawCardFromDeck()
    if #self.deck > 0 and #self.cardController:getHand() < self.maxHandSize then
        local randomIndex = math.random(1, #self.deck)
        local cardType = self.deck[randomIndex]
        table.remove(self.deck, randomIndex)
        return self:addCardToHand(cardType)
    end
    return false
end

-- 抽随机卡牌（不从牌库抽）
function CardManager:drawRandomCard(tierLimit)
    -- 创建可用卡牌类型列表
    local availableCardTypes = {}
    for cardType, cardInfo in pairs(CardConfig) do
        if not tierLimit or cardInfo.tier <= tierLimit then
            table.insert(availableCardTypes, cardType)
        end
    end
    
    -- 随机选择一个卡牌类型
    if #availableCardTypes > 0 and #self.cardController:getHand() < self.maxHandSize then
        local randomIndex = math.random(1, #availableCardTypes)
        local cardType = availableCardTypes[randomIndex]
        return self:addCardToHand(cardType)
    end
    
    return false
end

-- 抽取指定等级的随机卡牌
function CardManager:drawRandomCardOfTier(tier)
    -- 创建指定等级的可用卡牌类型列表
    local availableCardTypes = {}
    for cardType, cardInfo in pairs(CardConfig) do
        if cardInfo.tier == tier then
            table.insert(availableCardTypes, cardType)
        end
    end
    
    -- 随机选择一个卡牌类型
    if #availableCardTypes > 0 and #self.cardController:getHand() < self.maxHandSize then
        local randomIndex = math.random(1, #availableCardTypes)
        local cardType = availableCardTypes[randomIndex]
        return self:addCardToHand(cardType)
    end
    
    return false
end

-- 获取手牌
function CardManager:getHand()
    return self.cardController:getHand()
end

-- 获取手牌数量
function CardManager:getHandCount()
    return #self.cardController:getHand()
end

-- 获取牌库数量
function CardManager:getDeckCount()
    return #self.deck
end

-- 获取选中的卡牌
function CardManager:getSelectedCard()
    return self.cardController:getSelectedCard()
end

-- 获取选中的卡牌索引
function CardManager:getSelectedIndex()
    return self.cardController:getSelectedIndex()
end

-- 获取选中的建筑类型
function CardManager:getSelectedBuildingType()
    return self.cardController:getSelectedBuildingType()
end

-- 处理鼠标点击
function CardManager:handleMouseClick(x, y)
    return self.cardController:handleMouseClick(x, y)
end

-- 绘制手牌
function CardManager:draw()
    self.cardController:draw()
end

-- 清空手牌
function CardManager:clearHand()
    local hand = self.cardController:getHand()
    for i = #hand, 1, -1 do
        self.cardController:removeCard(hand[i])
    end
end

-- 清空牌库
function CardManager:clearDeck()
    self.deck = {}
end

-- 重置所有卡牌状态（手牌和牌库）
function CardManager:resetAll()
    self:clearHand()
    self:clearDeck()
end

-- 获取卡牌视图
function CardManager:getView()
    return self.cardController:getView()
end

-- 获取手牌区域的Y坐标
function CardManager:getHandAreaY()
    local view = self.cardController:getView()
    if view and view.handArea then
        return view.handArea.y
    end
    -- 默认值，避免nil错误
    return love.graphics.getHeight() - 180
end

return CardManager 