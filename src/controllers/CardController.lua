-- 卡牌控制器
local CardController = {}
CardController.__index = CardController

-- 引入卡牌模型和视图
local CardModel = require('src/models/CardModel')
local CardView = require('src/views/CardView')
local TypeDefines = require('config/type_defines')

function CardController.new()
    local mt = setmetatable({}, CardController)
    mt.model = CardModel.new()
    mt.view = CardView.new()
    return mt
end

-- 直接代理到模型方法
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

-- 处理鼠标点击的控制器逻辑
function CardController:handleMouseClick(x, y)
    -- 检查是否点击在手牌区域
    if self.view:isHandAreaClicked(x, y) then
        -- 找出点击的是哪张卡牌
        local clickedIndex = self.view:getClickedCardIndex(self.model:getHand(), x, y)
        print("clickedIndex", clickedIndex)
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

-- 渲染相关的控制器方法
function CardController:draw()
    self.view:drawHand(self.model:getHand(), self.model:getSelectedIndex())
end

-- 代理到模型方法以获取数据
function CardController:getSelectedIndex()
    return self.model:getSelectedIndex()
end

function CardController:getHand()
    return self.model:getHand()
end

function CardController:getView()
    return self.view
end

-- 提供类型常量的访问
function CardController:getCardTypes()
    return TypeDefines.CARD_TYPES
end

function CardController:getSelectedCard()
    return self.model:getSelectedCard()
end

return CardController 