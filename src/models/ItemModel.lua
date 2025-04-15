-- ItemModel类
local ItemModel = {}
ItemModel.__index = ItemModel

-- 引入配置
local Global = require('src/utils/global')

-- 创建新物品模型
function ItemModel.new(x, y)
    local mt = setmetatable({}, ItemModel)
    mt.id = Global.gen_id()
    mt.x = x or 0
    mt.y = y or 0
    mt.size = 24  -- 物品默认尺寸
    mt.pickupRange = 50  -- 拾取范围

    return mt
end

-- 符文系统已移除

-- 检查物品是否在拾取范围内
function ItemModel:isInRange(playerX, playerY)
    local dx = self.x - playerX
    local dy = self.y - playerY
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance <= self.pickupRange
end

-- 创建卡片物品
function ItemModel.newCard(buildingCardType, x, y)
    local card = ItemModel.new(x, y)
    card.isCard = true
    card.buildingCardType = buildingCardType
    return card
end

-- 创建装备物品
function ItemModel.newEquipment(config, x, y)
    local equipment = ItemModel.new(x, y)
    equipment.config = config
    equipment.isEquipment = true
    return equipment
end

return ItemModel 