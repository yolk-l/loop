-- 物品配置文件

-- 物品类型
local ITEM_TYPES = {
    RUNE = 1,
    CARD = 2
}

-- 符文位置类型
local RUNE_POSITIONS = {
    SLOT_1 = 1, -- 右上
    SLOT_2 = 2, -- 右中
    SLOT_3 = 3, -- 右下
    SLOT_4 = 4, -- 左上
    SLOT_5 = 5, -- 左中
    SLOT_6 = 6  -- 左下
}

-- 符文品质
local RUNE_QUALITY = {
    NORMAL = 1,    -- 普通（白色）
    MAGIC = 2,     -- 魔法（绿色）
    RARE = 3,      -- 稀有（蓝色）
    HERO = 4,      -- 英雄（紫色）
    LEGEND = 5,    -- 传说（橙色）
    ANCIENT = 6    -- 远古（红色）
}

-- 符文主属性类型
local RUNE_PRIMARY_STATS = {
    HP_FLAT = 1,           -- 固定生命值
    HP_PERCENT = 2,        -- 生命值百分比
    ATK_FLAT = 3,          -- 固定攻击力
    ATK_PERCENT = 4,       -- 攻击力百分比
    DEF_FLAT = 5,          -- 固定防御力
    DEF_PERCENT = 6,       -- 防御力百分比
    SPEED_FLAT = 7,        -- 固定速度
    CRIT_RATE = 8,         -- 暴击率
    CRIT_DMG = 9,          -- 暴击伤害
    ACCURACY = 10,         -- 命中率
    RESISTANCE = 11        -- 抵抗率
}

-- 符文次属性类型（与主属性相同，但值较小）
local RUNE_SUB_STATS = RUNE_PRIMARY_STATS

-- 符文类型（位置1、3、5的可能类型）
local RUNE_SET_TYPES = {
    ENERGY = 1,      -- 能量：攻击+15%
    BLADE = 2,       -- 刀刃：暴击率+12%
    SWIFT = 3,       -- 迅速：速度+25%
    FOCUS = 4,       -- 集中：命中+20%
    GUARD = 5,       -- 守护：防御+15%
    ENDURE = 6,      -- 忍耐：抵抗+20%
    VIOLENT = 7,     -- 暴怒：攻击后有22%几率额外回合
    RAGE = 8,        -- 愤怒：暴击伤害+40%
    FATAL = 9,       -- 致命：攻击+35%
    DESPAIR = 10,    -- 绝望：攻击时有25%几率眩晕
    VAMPIRE = 11,    -- 吸血：攻击时回复35%伤害
    BLESSING = 12    -- 祝福：所有属性+5%
}

-- 符文套装效果映射
local RUNE_SET_EFFECTS = {
    [RUNE_SET_TYPES.ENERGY] = {
        name = "能量",
        count = 2,  -- 需要2个符文触发效果
        effect = {
            type = "atk_percent",
            value = 15  -- 15% 攻击力
        }
    },
    [RUNE_SET_TYPES.BLADE] = {
        name = "刀刃",
        count = 2,
        effect = {
            type = "crit_rate",
            value = 12  -- 12% 暴击率
        }
    },
    [RUNE_SET_TYPES.SWIFT] = {
        name = "迅速",
        count = 4,
        effect = {
            type = "speed",
            value = 25  -- 25% 速度
        }
    },
    [RUNE_SET_TYPES.FOCUS] = {
        name = "集中",
        count = 2,
        effect = {
            type = "accuracy",
            value = 20  -- 20% 命中率
        }
    },
    [RUNE_SET_TYPES.GUARD] = {
        name = "守护",
        count = 2,
        effect = {
            type = "def_percent",
            value = 15  -- 15% 防御
        }
    },
    [RUNE_SET_TYPES.ENDURE] = {
        name = "忍耐",
        count = 2,
        effect = {
            type = "resistance",
            value = 20  -- 20% 抵抗
        }
    },
    [RUNE_SET_TYPES.VIOLENT] = {
        name = "暴怒",
        count = 4,
        effect = {
            type = "extra_turn",
            value = 22  -- 22% 几率额外回合
        }
    },
    [RUNE_SET_TYPES.RAGE] = {
        name = "愤怒",
        count = 4,
        effect = {
            type = "crit_dmg",
            value = 40  -- 40% 暴击伤害
        }
    },
    [RUNE_SET_TYPES.FATAL] = {
        name = "致命",
        count = 4,
        effect = {
            type = "atk_percent",
            value = 35  -- 35% 攻击力
        }
    },
    [RUNE_SET_TYPES.DESPAIR] = {
        name = "绝望",
        count = 4,
        effect = {
            type = "stun_chance",
            value = 25  -- 25% 眩晕几率
        }
    },
    [RUNE_SET_TYPES.VAMPIRE] = {
        name = "吸血",
        count = 4,
        effect = {
            type = "lifesteal",
            value = 35  -- 35% 伤害吸血
        }
    },
    [RUNE_SET_TYPES.BLESSING] = {
        name = "祝福",
        count = 2,
        effect = {
            type = "all_stats",
            value = 5  -- 5% 所有属性
        }
    }
}

-- 符文主属性值范围（根据符文品质和星级）
local RUNE_PRIMARY_STAT_RANGES = {
    -- HP_FLAT（根据品质和星级的范围）
    [RUNE_PRIMARY_STATS.HP_FLAT] = {
        [RUNE_QUALITY.NORMAL] = {min = 100, max = 200},
        [RUNE_QUALITY.MAGIC] = {min = 200, max = 400},
        [RUNE_QUALITY.RARE] = {min = 400, max = 600},
        [RUNE_QUALITY.HERO] = {min = 600, max = 800},
        [RUNE_QUALITY.LEGEND] = {min = 800, max = 1000},
        [RUNE_QUALITY.ANCIENT] = {min = 1000, max = 1200}
    },
    -- HP_PERCENT
    [RUNE_PRIMARY_STATS.HP_PERCENT] = {
        [RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [RUNE_QUALITY.ANCIENT] = {min = 50, max = 63}
    },
    -- ATK_FLAT
    [RUNE_PRIMARY_STATS.ATK_FLAT] = {
        [RUNE_QUALITY.NORMAL] = {min = 10, max = 20},
        [RUNE_QUALITY.MAGIC] = {min = 20, max = 30},
        [RUNE_QUALITY.RARE] = {min = 30, max = 40},
        [RUNE_QUALITY.HERO] = {min = 40, max = 50},
        [RUNE_QUALITY.LEGEND] = {min = 50, max = 60},
        [RUNE_QUALITY.ANCIENT] = {min = 60, max = 80}
    },
    -- ATK_PERCENT
    [RUNE_PRIMARY_STATS.ATK_PERCENT] = {
        [RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [RUNE_QUALITY.ANCIENT] = {min = 50, max = 63}
    },
    -- DEF_FLAT
    [RUNE_PRIMARY_STATS.DEF_FLAT] = {
        [RUNE_QUALITY.NORMAL] = {min = 10, max = 20},
        [RUNE_QUALITY.MAGIC] = {min = 20, max = 30},
        [RUNE_QUALITY.RARE] = {min = 30, max = 40},
        [RUNE_QUALITY.HERO] = {min = 40, max = 50},
        [RUNE_QUALITY.LEGEND] = {min = 50, max = 60},
        [RUNE_QUALITY.ANCIENT] = {min = 60, max = 80}
    },
    -- DEF_PERCENT
    [RUNE_PRIMARY_STATS.DEF_PERCENT] = {
        [RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [RUNE_QUALITY.ANCIENT] = {min = 50, max = 63}
    },
    -- SPEED_FLAT
    [RUNE_PRIMARY_STATS.SPEED_FLAT] = {
        [RUNE_QUALITY.NORMAL] = {min = 3, max = 5},
        [RUNE_QUALITY.MAGIC] = {min = 5, max = 10},
        [RUNE_QUALITY.RARE] = {min = 10, max = 15},
        [RUNE_QUALITY.HERO] = {min = 15, max = 20},
        [RUNE_QUALITY.LEGEND] = {min = 20, max = 25},
        [RUNE_QUALITY.ANCIENT] = {min = 25, max = 30}
    },
    -- CRIT_RATE
    [RUNE_PRIMARY_STATS.CRIT_RATE] = {
        [RUNE_QUALITY.NORMAL] = {min = 3, max = 5},
        [RUNE_QUALITY.MAGIC] = {min = 5, max = 10},
        [RUNE_QUALITY.RARE] = {min = 10, max = 15},
        [RUNE_QUALITY.HERO] = {min = 15, max = 20},
        [RUNE_QUALITY.LEGEND] = {min = 20, max = 30},
        [RUNE_QUALITY.ANCIENT] = {min = 30, max = 40}
    },
    -- CRIT_DMG
    [RUNE_PRIMARY_STATS.CRIT_DMG] = {
        [RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [RUNE_QUALITY.RARE] = {min = 20, max = 40},
        [RUNE_QUALITY.HERO] = {min = 40, max = 60},
        [RUNE_QUALITY.LEGEND] = {min = 60, max = 80},
        [RUNE_QUALITY.ANCIENT] = {min = 80, max = 100}
    },
    -- ACCURACY
    [RUNE_PRIMARY_STATS.ACCURACY] = {
        [RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [RUNE_QUALITY.ANCIENT] = {min = 50, max = 60}
    },
    -- RESISTANCE
    [RUNE_PRIMARY_STATS.RESISTANCE] = {
        [RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [RUNE_QUALITY.ANCIENT] = {min = 50, max = 60}
    }
}

-- 符文次属性值范围（通常比主属性值低）
local RUNE_SUB_STAT_RANGES = {
    -- 简化起见，次属性值为主属性值的30%-60%
    [RUNE_SUB_STATS.HP_FLAT] = {
        [RUNE_QUALITY.NORMAL] = {min = 30, max = 100},
        [RUNE_QUALITY.MAGIC] = {min = 60, max = 200},
        [RUNE_QUALITY.RARE] = {min = 120, max = 300},
        [RUNE_QUALITY.HERO] = {min = 180, max = 400},
        [RUNE_QUALITY.LEGEND] = {min = 240, max = 500},
        [RUNE_QUALITY.ANCIENT] = {min = 300, max = 600}
    },
    -- HP_PERCENT
    [RUNE_SUB_STATS.HP_PERCENT] = {
        [RUNE_QUALITY.NORMAL] = {min = 1, max = 3},
        [RUNE_QUALITY.MAGIC] = {min = 3, max = 6},
        [RUNE_QUALITY.RARE] = {min = 6, max = 9},
        [RUNE_QUALITY.HERO] = {min = 9, max = 12},
        [RUNE_QUALITY.LEGEND] = {min = 12, max = 15},
        [RUNE_QUALITY.ANCIENT] = {min = 15, max = 18}
    },
    -- 以下类似，根据每种次属性和品质定义其范围
    -- 为简洁起见，此处省略其他次属性的范围定义...
}

-- 符文套装掉落配置
local RUNE_DROP_CONFIG = {
    -- 基础怪物
    slime = {
        runes = {
            -- 套装类型, 位置, 品质, 概率
            {set = RUNE_SET_TYPES.ENERGY, position = "random", quality = RUNE_QUALITY.NORMAL, chance = 0.4},
            {set = RUNE_SET_TYPES.ENERGY, position = "random", quality = RUNE_QUALITY.MAGIC, chance = 0.1}
        }
    },
    goblin = {
        runes = {
            {set = RUNE_SET_TYPES.BLADE, position = "random", quality = RUNE_QUALITY.NORMAL, chance = 0.3},
            {set = RUNE_SET_TYPES.BLADE, position = "random", quality = RUNE_QUALITY.MAGIC, chance = 0.15}
        }
    },
    skeleton = {
        runes = {
            {set = RUNE_SET_TYPES.GUARD, position = "random", quality = RUNE_QUALITY.NORMAL, chance = 0.3},
            {set = RUNE_SET_TYPES.GUARD, position = "random", quality = RUNE_QUALITY.MAGIC, chance = 0.15},
            {set = RUNE_SET_TYPES.ENDURE, position = "random", quality = RUNE_QUALITY.MAGIC, chance = 0.1}
        }
    },
    
    -- 高级怪物
    zombie = {
        runes = {
            {set = RUNE_SET_TYPES.ENDURE, position = "random", quality = RUNE_QUALITY.MAGIC, chance = 0.25},
            {set = RUNE_SET_TYPES.ENDURE, position = "random", quality = RUNE_QUALITY.RARE, chance = 0.1}
        }
    },
    wolf = {
        runes = {
            {set = RUNE_SET_TYPES.SWIFT, position = "random", quality = RUNE_QUALITY.MAGIC, chance = 0.25},
            {set = RUNE_SET_TYPES.SWIFT, position = "random", quality = RUNE_QUALITY.RARE, chance = 0.1}
        }
    },
    ghost = {
        runes = {
            {set = RUNE_SET_TYPES.DESPAIR, position = "random", quality = RUNE_QUALITY.MAGIC, chance = 0.2},
            {set = RUNE_SET_TYPES.DESPAIR, position = "random", quality = RUNE_QUALITY.RARE, chance = 0.1}
        }
    },
    
    -- 精英怪物
    golem = {
        runes = {
            {set = RUNE_SET_TYPES.GUARD, position = "random", quality = RUNE_QUALITY.RARE, chance = 0.2},
            {set = RUNE_SET_TYPES.GUARD, position = "random", quality = RUNE_QUALITY.HERO, chance = 0.05}
        }
    },
    witch = {
        runes = {
            {set = RUNE_SET_TYPES.FOCUS, position = "random", quality = RUNE_QUALITY.RARE, chance = 0.2},
            {set = RUNE_SET_TYPES.DESPAIR, position = "random", quality = RUNE_QUALITY.RARE, chance = 0.15},
            {set = RUNE_SET_TYPES.DESPAIR, position = "random", quality = RUNE_QUALITY.HERO, chance = 0.05}
        }
    },
    dragon = {
        runes = {
            {set = RUNE_SET_TYPES.VIOLENT, position = "random", quality = RUNE_QUALITY.RARE, chance = 0.15},
            {set = RUNE_SET_TYPES.RAGE, position = "random", quality = RUNE_QUALITY.RARE, chance = 0.15},
            {set = RUNE_SET_TYPES.FATAL, position = "random", quality = RUNE_QUALITY.HERO, chance = 0.1},
            {set = RUNE_SET_TYPES.BLESSING, position = "random", quality = RUNE_QUALITY.HERO, chance = 0.05},
            {set = RUNE_SET_TYPES.BLESSING, position = "random", quality = RUNE_QUALITY.LEGEND, chance = 0.01}
        }
    }
}

-- 怪物类型到建筑卡牌类型的映射表
local MONSTER_TO_CARD_TYPE = {
    slime = 1,      -- 史莱姆 -> 史莱姆巢穴
    goblin = 2,     -- 哥布林 -> 哥布林小屋
    skeleton = 3,   -- 骷髅 -> 骷髅墓地
    zombie = 4,     -- 僵尸 -> 僵尸墓园
    wolf = 5,       -- 狼人 -> 狼人巢穴
    ghost = 6,      -- 幽灵 -> 幽灵庄园
    golem = 7,      -- 石巨人 -> 巨人熔炉
    witch = 8,      -- 女巫 -> 女巫小屋
    dragon = 9      -- 小龙 -> 龙之洞窟
}

-- 卡牌解锁等级要求
local CARD_LEVEL_REQUIREMENTS = {
    basic = 1,      -- 1级解锁基础卡牌
    advanced = 2,   -- 2级解锁高级卡牌
    elite = 3       -- 3级解锁精英卡牌
}

-- 定义符文品质对应的颜色
local RUNE_QUALITY_COLORS = {
    [RUNE_QUALITY.NORMAL] = {1.0, 1.0, 1.0},      -- 白色
    [RUNE_QUALITY.MAGIC] = {0.0, 0.8, 0.0},       -- 绿色
    [RUNE_QUALITY.RARE] = {0.0, 0.5, 1.0},        -- 蓝色
    [RUNE_QUALITY.HERO] = {0.7, 0.0, 1.0},        -- 紫色
    [RUNE_QUALITY.LEGEND] = {1.0, 0.5, 0.0},      -- 橙色
    [RUNE_QUALITY.ANCIENT] = {1.0, 0.0, 0.0}      -- 红色
}

-- 符文套装对应的颜色
local RUNE_SET_COLORS = {
    [RUNE_SET_TYPES.ENERGY] = {0.8, 0.8, 0.2},     -- 黄色
    [RUNE_SET_TYPES.BLADE] = {0.7, 0.7, 0.7},      -- 银色
    [RUNE_SET_TYPES.SWIFT] = {0.2, 0.8, 0.8},      -- 青色
    [RUNE_SET_TYPES.FOCUS] = {0.6, 0.4, 0.1},      -- 棕色
    [RUNE_SET_TYPES.GUARD] = {0.1, 0.4, 0.8},      -- 蓝色
    [RUNE_SET_TYPES.ENDURE] = {0.5, 0.5, 0.5},     -- 灰色
    [RUNE_SET_TYPES.VIOLENT] = {0.8, 0.0, 0.8},    -- 紫色
    [RUNE_SET_TYPES.RAGE] = {1.0, 0.0, 0.0},       -- 红色
    [RUNE_SET_TYPES.FATAL] = {0.0, 0.0, 0.0},      -- 黑色
    [RUNE_SET_TYPES.DESPAIR] = {0.3, 0.0, 0.5},    -- 深紫色
    [RUNE_SET_TYPES.VAMPIRE] = {0.8, 0.0, 0.2},    -- 暗红色
    [RUNE_SET_TYPES.BLESSING] = {1.0, 0.8, 0.0}    -- 金色
}

return {
    ITEM_TYPES = ITEM_TYPES,
    RUNE_POSITIONS = RUNE_POSITIONS,
    RUNE_QUALITY = RUNE_QUALITY,
    RUNE_PRIMARY_STATS = RUNE_PRIMARY_STATS,
    RUNE_SUB_STATS = RUNE_SUB_STATS,
    RUNE_SET_TYPES = RUNE_SET_TYPES,
    RUNE_SET_EFFECTS = RUNE_SET_EFFECTS,
    RUNE_PRIMARY_STAT_RANGES = RUNE_PRIMARY_STAT_RANGES,
    RUNE_SUB_STAT_RANGES = RUNE_SUB_STAT_RANGES,
    RUNE_DROP_CONFIG = RUNE_DROP_CONFIG,
    MONSTER_TO_CARD_TYPE = MONSTER_TO_CARD_TYPE,
    MONSTER_TIERS = MONSTER_TIERS,
    CARD_LEVEL_REQUIREMENTS = CARD_LEVEL_REQUIREMENTS,
    RUNE_QUALITY_COLORS = RUNE_QUALITY_COLORS,
    RUNE_SET_COLORS = RUNE_SET_COLORS
} 