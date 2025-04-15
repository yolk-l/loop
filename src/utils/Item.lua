-- 物品系统
local ItemModel = require('src/models/ItemModel')
local ItemConfig = require('config/items')
local MonsterConfig = require('config/monsters')
local TypeDefines = require('config/type_defines')

local ItemSystem = {}

-- 生成怪物掉落物品
function ItemSystem.generateDrops(monsterType, x, y)
    local drops = {}
    local monster = MonsterConfig[monsterType]
    
    if not monster then
        return drops
    end

    -- 检查是否触发掉落
    local roll = math.random()
    if roll > monster.dropRate then
        return drops
    end
    
    -- 移除符文掉落逻辑，现在只处理卡牌掉落
    
    -- 如果是精英怪，有机会掉落建筑卡牌
    if monster.tier == TypeDefines.MONSTER_TIERS.ELITE then
        local cardRoll = math.random()
        if cardRoll < 0.15 then  -- 15% 几率掉落卡牌
            local cardItem = ItemModel.new(x, y)
            cardItem.isCard = true
            cardItem.buildingCardType = math.random(1, 9)  -- 随机卡牌类型
            table.insert(drops, cardItem)
        end
    end
    
    return drops
end

return ItemSystem 