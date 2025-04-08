-- 物品系统
local Item = {}
Item.__index = Item

-- 引入配置
local ItemConfig = require('config/items')

-- 字体缓存
local fonts = {
    name = nil,
    description = nil
}

-- 初始化字体
local function initFonts()
    if not fonts.name then
        fonts.name = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
        fonts.description = love.graphics.newFont("assets/fonts/simsun.ttc", 10)
    end
end

function Item:new(itemType, id, x, y)
    local self = setmetatable({}, Item)
    self.itemType = itemType
    self.id = id
    self.x = x
    self.y = y
    self.size = 15
    self.config = ItemConfig.EQUIPMENT_CONFIG[id]
    self.pickupRange = 30
    
    initFonts()
    return self
end

function Item:isInRange(playerX, playerY)
    local dx = playerX - self.x
    local dy = playerY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance <= self.pickupRange
end

function Item:draw()
    -- 绘制物品外观
    love.graphics.setColor(unpack(self.config.color))
    love.graphics.circle('fill', self.x, self.y, self.size)
    
    -- 绘制边框
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.circle('line', self.x, self.y, self.size)
    
    -- 绘制物品名称
    love.graphics.setFont(fonts.name)
    love.graphics.setColor(1, 1, 1)
    local nameWidth = fonts.name:getWidth(self.config.name)
    love.graphics.print(self.config.name, self.x - nameWidth/2, self.y - self.size - 15)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 生成掉落物
function Item.generateDrops(monsterType, x, y)
    local drops = {}
    local dropConfig = ItemConfig.DROP_TABLE[monsterType]
    
    if not dropConfig then return drops end
    
    -- 检查装备掉落
    for _, equipment in ipairs(dropConfig.equipment) do
        if math.random() < equipment.chance then
            table.insert(drops, Item:new(ItemConfig.ITEM_TYPES.EQUIPMENT, equipment.id, 
                x + math.random(-20, 20), y + math.random(-20, 20)))
        end
    end
    
    -- 检查卡牌掉落
    if math.random() < dropConfig.cardChance then
        -- 这里需要创建卡牌物品，具体实现依赖于卡牌系统
        -- 暂时返回一个标记，让main.lua处理卡牌的创建
        table.insert(drops, {
            isCard = true,
            monsterType = monsterType,
            x = x + math.random(-20, 20),
            y = y + math.random(-20, 20)
        })
    end
    
    return drops
end

return {
    Item = Item,
    ITEM_TYPES = ItemConfig.ITEM_TYPES,
    EQUIPMENT_TYPES = ItemConfig.EQUIPMENT_TYPES
} 