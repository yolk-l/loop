-- 卡牌控制器
local CardController = {}
CardController.__index = CardController

-- 引入卡牌模型和视图
local CardModel = require('src/models/CardModel')
local CardView = require('src/views/CardView')
local Card = require('src/systems/Card').Card

-- 卡牌类型定义
local cardTypes = {
    {
        name = "史莱姆巢穴",
        description = "生成一个史莱姆巢穴，会持续生成史莱姆",
        buildingType = "slime_nest",
        color = {0.3, 0.8, 0.3}
    },
    {
        name = "哥布林小屋",
        description = "生成一个哥布林小屋，会持续生成哥布林",
        buildingType = "goblin_hut",
        color = {0.8, 0.5, 0.3}
    },
    {
        name = "骷髅墓地",
        description = "生成一个骷髅墓地，会持续生成骷髅",
        buildingType = "skeleton_tomb",
        color = {0.8, 0.8, 0.8}
    },
    {
        name = "僵尸墓园",
        description = "生成一个僵尸墓园，会持续生成僵尸",
        buildingType = "zombie_graveyard",
        color = {0.2, 0.5, 0.2}
    },
    {
        name = "狼人巢穴",
        description = "生成一个狼人巢穴，会持续生成狼人",
        buildingType = "wolf_den",
        color = {0.6, 0.3, 0.1}
    },
    {
        name = "幽灵庄园",
        description = "生成一个幽灵庄园，会持续生成幽灵",
        buildingType = "ghost_manor",
        color = {0.7, 0.7, 1.0}
    },
    {
        name = "巨人熔炉",
        description = "生成一个巨人熔炉，会生成强大的石巨人",
        buildingType = "golem_forge",
        color = {0.5, 0.5, 0.6}
    },
    {
        name = "女巫小屋",
        description = "生成一个女巫小屋，会生成强大的女巫",
        buildingType = "witch_hut",
        color = {0.8, 0.3, 0.8}
    },
    {
        name = "龙之洞窟",
        description = "生成一个龙之洞窟，会生成危险的小龙",
        buildingType = "dragon_cave",
        color = {1.0, 0.3, 0.1}
    }
}

function CardController:new()
    local self = setmetatable({}, CardController)
    self.model = CardModel:new()
    self.view = CardView:new()
    self.selectedCard = nil
    self.selectedIndex = nil
    self.hand = {}  -- 初始化手牌数组
    self.handSize = 5  -- 最大手牌数量
    return self
end

function CardController:addCard(cardType)
    -- 检查手牌是否已满
    if #self.hand >= self.handSize then
        return false
    end
    
    -- 判断卡牌类型的有效性
    if cardType < 1 or cardType > #cardTypes then
        cardType = math.random(1, #cardTypes)
    end
    
    -- 创建新卡牌
    local cardConfig = cardTypes[cardType]
    local card = Card:new({
        name = cardConfig.name,
        description = cardConfig.description,
        buildingType = cardConfig.buildingType,
        color = cardConfig.color,
        type = cardType
    })
    
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