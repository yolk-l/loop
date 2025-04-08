-- 物品配置文件

-- 物品类型
local ITEM_TYPES = {
    EQUIPMENT = 1,
    CARD = 2
}

-- 装备类型
local EQUIPMENT_TYPES = {
    WEAPON = 1,
    ARMOR = 2,
    ACCESSORY = 3
}

-- 装备配置
local EQUIPMENT_CONFIG = {
    -- 武器
    wooden_sword = {
        name = "木剑",
        type = EQUIPMENT_TYPES.WEAPON,
        color = {0.8, 0.6, 0.4},
        attributes = {
            attack = 8
        },
        description = "一把普通的木剑"
    },
    iron_sword = {
        name = "铁剑",
        type = EQUIPMENT_TYPES.WEAPON,
        color = {0.7, 0.7, 0.7},
        attributes = {
            attack = 15
        },
        description = "锋利的铁剑"
    },
    -- 护甲
    leather_armor = {
        name = "皮甲",
        type = EQUIPMENT_TYPES.ARMOR,
        color = {0.6, 0.4, 0.2},
        attributes = {
            defense = 5,
            maxHp = 30
        },
        description = "简单的皮革护甲"
    },
    iron_armor = {
        name = "铁甲",
        type = EQUIPMENT_TYPES.ARMOR,
        color = {0.6, 0.6, 0.6},
        attributes = {
            defense = 10,
            maxHp = 60
        },
        description = "结实的铁护甲"
    },
    -- 饰品
    speed_ring = {
        name = "迅捷戒指",
        type = EQUIPMENT_TYPES.ACCESSORY,
        color = {0.2, 0.8, 0.8},
        attributes = {
            speed = 50
        },
        description = "提升移动速度"
    },
    power_ring = {
        name = "力量戒指",
        type = EQUIPMENT_TYPES.ACCESSORY,
        color = {0.8, 0.2, 0.2},
        attributes = {
            attack = 5,
            defense = 3
        },
        description = "提升攻击和防御"
    }
}

-- 怪物掉落表
local DROP_TABLE = {
    slime = {
        equipment = {
            {id = "wooden_sword", chance = 0.2},  -- 20%
            {id = "leather_armor", chance = 0.2}, -- 20%
            {id = "speed_ring", chance = 0.1}     -- 10%
        },
        cardChance = 0.3  -- 30%概率掉落自己的卡牌
    },
    goblin = {
        equipment = {
            {id = "iron_sword", chance = 0.2},    -- 20%
            {id = "leather_armor", chance = 0.25}, -- 25%
            {id = "power_ring", chance = 0.1}     -- 10%
        },
        cardChance = 0.25  -- 25%
    },
    skeleton = {
        equipment = {
            {id = "iron_sword", chance = 0.25},   -- 25%
            {id = "iron_armor", chance = 0.2},    -- 20%
            {id = "power_ring", chance = 0.15}    -- 15%
        },
        cardChance = 0.2   -- 20%
    }
}

return {
    ITEM_TYPES = ITEM_TYPES,
    EQUIPMENT_TYPES = EQUIPMENT_TYPES,
    EQUIPMENT_CONFIG = EQUIPMENT_CONFIG,
    DROP_TABLE = DROP_TABLE
} 