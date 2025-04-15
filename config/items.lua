-- 物品配置文件
local TypeDefines = require('config/type_defines')

local ITEM_CONFIG = {}

-- 卡牌解锁等级要求
ITEM_CONFIG.CARD_LEVEL_REQUIREMENTS = {
    [TypeDefines.MONSTER_TIERS.BASIC] = 1,      -- 1级解锁基础卡牌
    [TypeDefines.MONSTER_TIERS.ADVANCED] = 2,   -- 2级解锁高级卡牌
    [TypeDefines.MONSTER_TIERS.ELITE] = 3       -- 3级解锁精英卡牌
}
ITEM_CONFIG.LEVEL2_CARD_TYPES = {
    [1] = TypeDefines.CARD_TYPES.BASIC,      -- 1级解锁基础卡牌
    [2] = TypeDefines.CARD_TYPES.ADVANCED,   -- 2级解锁高级卡牌
    [3] = TypeDefines.CARD_TYPES.ELITE       -- 3级解锁精英卡牌
}

return ITEM_CONFIG