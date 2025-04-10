-- 物品系统
local Item = {}
Item.__index = Item

-- 引入配置
local ItemConfig = require('config/items')
local Global = require('src/utils/global')

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

function Item:new(itemId, x, y)
    local self = setmetatable({}, Item)
    self.itemId = itemId
    self.id = Global.gen_id()
    self.x = x
    self.y = y
    self.size = 15
    self.config = ItemConfig.EQUIPMENT_CONFIG[itemId]
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
    
    -- 获取怪物的掉落表配置
    local dropConfig = ItemConfig.DROP_TABLE[monsterType]
    
    -- 如果没有为该怪物类型定义掉落表，返回空列表
    if not dropConfig then
        return drops
    end
    
    -- 处理装备掉落
    if dropConfig.equipment then
        for _, equipData in ipairs(dropConfig.equipment) do
            -- 根据概率判断是否掉落该装备
            if math.random() < equipData.chance then
                local item = Item:new(equipData.id, x, y)
                table.insert(drops, item)
            end
        end
    end
    
    -- 处理卡牌掉落
    if dropConfig.cardChance and math.random() < dropConfig.cardChance then
        -- 使用配置文件中的映射表获取建筑卡牌类型
        local buildingCardType = ItemConfig.MONSTER_TO_CARD_TYPE[monsterType]
        
        if buildingCardType then
            local card = {
                isCard = true,
                buildingCardType = buildingCardType
            }
            table.insert(drops, card)
        end
    end
    
    return drops
end

return {
    Item = Item,
    ITEM_TYPES = ItemConfig.ITEM_TYPES,
    EQUIPMENT_TYPES = ItemConfig.EQUIPMENT_TYPES
} 