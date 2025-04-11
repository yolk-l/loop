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

-- 怪物类型到建筑卡牌类型的映射表
local MONSTER_TO_CARD_TYPE = {
    slime = 1,      -- 史莱姆 -> 史莱姆巢穴
    goblin = 2,     -- 哥布林 -> 哥布林小屋
    skeleton = 3,   -- 骷髅 -> 骷髅墓地
    zombie = 4,     -- 僵尸 -> 僵尸墓园
    wolf = 5,   -- 狼人 -> 狼人巢穴
    ghost = 6,      -- 幽灵 -> 幽灵庄园
    golem = 7,      -- 石巨人 -> 巨人熔炉
    witch = 8,      -- 女巫 -> 女巫小屋
    dragon = 9      -- 小龙 -> 龙之洞窟
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
    fire_sword = {
        name = "烈焰剑",
        type = EQUIPMENT_TYPES.WEAPON,
        color = {0.9, 0.3, 0.1},
        attributes = {
            attack = 25
        },
        description = "散发着火焰的魔剑"
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
    steel_armor = {
        name = "钢甲",
        type = EQUIPMENT_TYPES.ARMOR,
        color = {0.4, 0.4, 0.5},
        attributes = {
            defense = 18,
            maxHp = 100
        },
        description = "高级钢铁护甲"
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
    },
    magic_amulet = {
        name = "魔法护符",
        type = EQUIPMENT_TYPES.ACCESSORY,
        color = {0.6, 0.2, 0.8},
        attributes = {
            attack = 8,
            maxHp = 50
        },
        description = "提升攻击力和生命"
    },
    dragon_scale = {
        name = "龙鳞护符",
        type = EQUIPMENT_TYPES.ACCESSORY,
        color = {1.0, 0.5, 0.0},
        attributes = {
            attack = 10,
            defense = 10,
            maxHp = 80
        },
        description = "由龙鳞制成的强力护符"
    }
}

-- 怪物掉落表
local DROP_TABLE = {
    -- 基础怪物
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
    },
    
    -- 高级怪物
    zombie = {
        equipment = {
            {id = "iron_sword", chance = 0.2},    -- 20%
            {id = "iron_armor", chance = 0.3},    -- 30%
            {id = "power_ring", chance = 0.1}     -- 10%
        },
        cardChance = 0.2   -- 20%
    },
    wolf = {
        equipment = {
            {id = "iron_sword", chance = 0.3},    -- 30%
            {id = "leather_armor", chance = 0.2}, -- 20%
            {id = "speed_ring", chance = 0.2}     -- 20%
        },
        cardChance = 0.15  -- 15%
    },
    ghost = {
        equipment = {
            {id = "magic_amulet", chance = 0.25}, -- 25%
            {id = "power_ring", chance = 0.2},    -- 20%
            {id = "iron_armor", chance = 0.1}     -- 10%
        },
        cardChance = 0.25  -- 25%
    },
    
    -- 精英怪物
    golem = {
        equipment = {
            {id = "steel_armor", chance = 0.3},   -- 30%
            {id = "iron_sword", chance = 0.2},    -- 20%
            {id = "power_ring", chance = 0.15}    -- 15%
        },
        cardChance = 0.1   -- 10%
    },
    witch = {
        equipment = {
            {id = "magic_amulet", chance = 0.3},  -- 30%
            {id = "fire_sword", chance = 0.2},    -- 20%
            {id = "power_ring", chance = 0.15}    -- 15%
        },
        cardChance = 0.15  -- 15%
    },
    dragon = {
        equipment = {
            {id = "fire_sword", chance = 0.3},     -- 30%
            {id = "steel_armor", chance = 0.25},   -- 25%
            {id = "dragon_scale", chance = 0.2}    -- 20%
        },
        cardChance = 0.05  -- 仅5%，龙卡牌很稀有
    }
}

return {
    ITEM_TYPES = ITEM_TYPES,
    EQUIPMENT_TYPES = EQUIPMENT_TYPES,
    EQUIPMENT_CONFIG = EQUIPMENT_CONFIG,
    DROP_TABLE = DROP_TABLE,
    MONSTER_TO_CARD_TYPE = MONSTER_TO_CARD_TYPE
} 