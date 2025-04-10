-- 卡牌系统
local Card = {}
Card.__index = Card

-- 引入配置
local CardConfig = require('config/cards')

-- 字体缓存
local fonts = {
    title = nil,
    normal = nil,
    description = nil
}

-- 初始化字体
local function initFonts()
    if not fonts.title then
        fonts.title = love.graphics.newFont("assets/fonts/simsun.ttc", 16)
        fonts.normal = love.graphics.newFont("assets/fonts/simsun.ttc", 14)
        fonts.description = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function Card:new(cardOrType)
    local self = setmetatable({}, Card)
    
    -- 检查参数是否为table，支持直接传入配置
    if type(cardOrType) == "table" then
        self.config = cardOrType
        self.type = cardOrType.type or 1  -- 默认类型为1
        
        -- 确保config中包含必要的属性
        if not self.config.color then
            self.config.color = {0.8, 0.8, 0.8}  -- 默认颜色
        end
    else
        -- 按照原来的方式，通过cardType查找配置
        self.type = cardOrType
        self.config = CardConfig.CARD_CONFIG[cardOrType]
    end
    
    self.width = 100
    self.height = 150
    self.selected = false
    initFonts()  -- 确保字体已加载
    return self
end

function Card:draw(x, y)
    -- 检查config是否存在
    if not self.config then
        -- 如果config为nil，绘制错误信息
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle('fill', x, y, self.width, self.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fonts.title)
        love.graphics.print("配置错误!", x + 10, y + 10)
        love.graphics.setFont(fonts.description)
        love.graphics.print("卡牌类型: " .. (self.type or "未知"), x + 10, y + 40)
        love.graphics.setColor(1, 1, 1)
        return
    end
    
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
    
    -- 使用描述字体绘制描述文字
    love.graphics.setFont(fonts.description)
    love.graphics.printf(self.config.description, x + 5, y + 50, self.width - 10)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function Card:isMouseOver(mx, my, x, y)
    return mx >= x and mx <= x + self.width and
           my >= y and my <= y + self.height
end

return {
    Card = Card,
    CARD_TYPES = CardConfig.CARD_TYPES
} 