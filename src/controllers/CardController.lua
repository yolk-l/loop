-- 卡牌控制器
local CardController = {}
CardController.__index = CardController

-- 引入卡牌模型和视图
local CardModel = require('src/models/CardModel')
local CardView = require('src/views/CardView')
local cardConfig = require('config/cards')

function CardController:new()
    local mt = setmetatable({}, CardController)
    mt.model = CardModel:new()
    mt.view = CardView:new()
    return mt
end

function CardController:addCard(cardType)
    return self.model:addCardToHand(cardType)
end

function CardController:removeCard(cardObject)
    return self.model:removeCardFromHand(cardObject)
end

function CardController:getBuildingType(cardIndex)
    return self.model:getBuildingType(cardIndex)
end

function CardController:getSelectedBuildingType()
    return self.model:getSelectedBuildingType()
end

function CardController:handleMouseClick(x, y)
    -- 检查是否点击在手牌区域
    if self.view:isHandAreaClicked(x, y) then
        -- 找出点击的是哪张卡牌
        local clickedIndex = self.view:getClickedCardIndex(self.model:getHand(), x, y)
        
        if clickedIndex then
            -- 选择或取消选择卡牌
            self.model:selectCard(clickedIndex)
        else
            -- 点击了手牌区域但没有点中任何卡牌，取消选择
            self.model:selectCard(nil)
        end
        
        return true
    end
    
    return false
end

function CardController:draw()
    self.view:drawHand(self.model:getHand(), self.model:getSelectedIndex())
end

-- 获取当前选中的卡牌索引
function CardController:getSelectedIndex()
    return self.model:getSelectedIndex()
end

-- 获取手牌
function CardController:getHand()
    return self.model:getHand()
end

-- 获取视图对象
function CardController:getView()
    return self.view
end

-- 外部接口以访问 CARD_TYPES
function CardController:getCardTypes()
    return cardConfig.CARD_TYPES
end

return CardController 