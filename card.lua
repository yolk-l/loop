-- 卡牌类
local Card = {}
Card.__index = Card

-- 定义卡牌类型
local CARD_TYPES = {
    SLIME = 1,
    GOBLIN = 2,
    SKELETON = 3
}

-- 字体缓存
local fonts = {
    title = nil,
    normal = nil,
    description = nil
}

-- 卡牌配置
local CARD_CONFIG = {
    [CARD_TYPES.SLIME] = {
        name = "史莱姆",
        cost = 1,
        description = "召唤一只史莱姆",
        color = {0.5, 0.8, 0.5},
        monsterType = "slime"
    },
    [CARD_TYPES.GOBLIN] = {
        name = "哥布林",
        cost = 2,
        description = "召唤一只哥布林",
        color = {0.8, 0.5, 0.3},
        monsterType = "goblin"
    },
    [CARD_TYPES.SKELETON] = {
        name = "骷髅",
        cost = 3,
        description = "召唤一只骷髅",
        color = {0.8, 0.8, 0.8},
        monsterType = "skeleton"
    }
}

-- 初始化字体
local function initFonts()
    if not fonts.title then
        fonts.title = love.graphics.newFont("assets/fonts/simsun.ttc", 16)
        fonts.normal = love.graphics.newFont("assets/fonts/simsun.ttc", 14)
        fonts.description = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function Card:new(cardType)
    local self = setmetatable({}, Card)
    self.type = cardType
    self.config = CARD_CONFIG[cardType]
    self.width = 100
    self.height = 150
    self.selected = false
    initFonts()  -- 确保字体已加载
    return self
end

function Card:draw(x, y)
    -- 绘制卡牌背景
    if self.selected then
        love.graphics.setColor(0.9, 0.9, 0.9)
    else
        love.graphics.setColor(0.8, 0.8, 0.8)
    end
    love.graphics.rectangle('fill', x, y, self.width, self.height)
    
    -- 绘制卡牌边框
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('line', x, y, self.width, self.height)
    
    -- 绘制卡牌颜色标识
    love.graphics.setColor(unpack(self.config.color))
    love.graphics.rectangle('fill', x + 5, y + 5, self.width - 10, 30)
    
    -- 绘制卡牌文字
    love.graphics.setColor(0, 0, 0)
    
    -- 使用标题字体绘制名称
    love.graphics.setFont(fonts.title)
    love.graphics.print(self.config.name, x + 10, y + 10)
    
    -- 使用普通字体绘制消耗
    love.graphics.setFont(fonts.normal)
    love.graphics.print("消耗: " .. self.config.cost, x + 10, y + 40)
    
    -- 使用描述字体绘制描述文字
    love.graphics.setFont(fonts.description)
    love.graphics.printf(self.config.description, x + 5, y + 70, self.width - 10)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function Card:isMouseOver(mx, my, x, y)
    return mx >= x and mx <= x + self.width and
           my >= y and my <= y + self.height
end

return {
    Card = Card,
    CARD_TYPES = CARD_TYPES
} 