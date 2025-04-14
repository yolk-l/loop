-- 物品配置文件
local ItemConfig = {}

-- 符文品质定义
ItemConfig.RUNE_QUALITY = {
    NORMAL = 1,  -- 普通（白色）
    MAGIC = 2,   -- 魔法（绿色）
    RARE = 3,    -- 稀有（蓝色）
    HERO = 4,    -- 英雄（紫色）
    LEGEND = 5,  -- 传说（橙色）
    ANCIENT = 6  -- 远古（红色）
}

-- 符文品质对应颜色
ItemConfig.RUNE_QUALITY_COLORS = {
    [ItemConfig.RUNE_QUALITY.NORMAL] = {r=255, g=255, b=255},  -- 白色
    [ItemConfig.RUNE_QUALITY.MAGIC] = {r=0, g=255, b=0},       -- 绿色
    [ItemConfig.RUNE_QUALITY.RARE] = {r=0, g=170, b=255},      -- 蓝色
    [ItemConfig.RUNE_QUALITY.HERO] = {r=170, g=0, b=255},      -- 紫色
    [ItemConfig.RUNE_QUALITY.LEGEND] = {r=255, g=170, b=0},    -- 橙色
    [ItemConfig.RUNE_QUALITY.ANCIENT] = {r=255, g=0, b=0}      -- 红色
}

-- 符文位置定义
ItemConfig.RUNE_POSITIONS = {
    SLOT_1 = 1,  -- 右上
    SLOT_2 = 2,  -- 右中
    SLOT_3 = 3,  -- 右下
    SLOT_4 = 4,  -- 左上
    SLOT_5 = 5,  -- 左中
    SLOT_6 = 6   -- 左下
}

-- 符文主属性类型
ItemConfig.RUNE_PRIMARY_STATS = {
    HP_FLAT = "hp_flat",           -- 固定生命值
    HP_PERCENT = "hp_percent",     -- 生命值百分比
    ATK_FLAT = "atk_flat",         -- 固定攻击力
    ATK_PERCENT = "atk_percent",   -- 攻击力百分比
    DEF_FLAT = "def_flat",         -- 固定防御力
    DEF_PERCENT = "def_percent",   -- 防御力百分比
    SPEED_FLAT = "speed_flat",     -- 速度值
    CRIT_RATE = "crit_rate",       -- 暴击率
    CRIT_DMG = "crit_dmg",         -- 暴击伤害
    ACCURACY = "accuracy",         -- 命中率
    RESISTANCE = "resistance"      -- 抵抗
}

-- 符文次属性类型
ItemConfig.RUNE_SUB_STATS = {
    HP_FLAT = "hp_flat",
    HP_PERCENT = "hp_percent",
    ATK_FLAT = "atk_flat",
    ATK_PERCENT = "atk_percent",
    DEF_FLAT = "def_flat",
    DEF_PERCENT = "def_percent",
    SPEED_FLAT = "speed_flat",
    CRIT_RATE = "crit_rate",
    CRIT_DMG = "crit_dmg",
    ACCURACY = "accuracy",
    RESISTANCE = "resistance"
}

-- 符文套装类型
ItemConfig.RUNE_SET_TYPES = {
    ENERGY = 1,    -- 能量套装
    SWIFT = 2,     -- 迅捷套装
    FATAL = 3,     -- 暴怒套装
    BLADE = 4,     -- 刀锋套装
    FOCUS = 5,     -- 专注套装
    GUARD = 6,     -- 守护套装
    ENDURE = 7,    -- 忍耐套装
    REVENGE = 8,   -- 复仇套装
    VIOLENT = 9,   -- 暴力套装
    VAMPIRE = 10,  -- 吸血套装
    WILL = 11,     -- 意志套装
    NEMESIS = 12,  -- 复仇套装
    RAGE = 13,     -- 狂暴套装
    DESPAIR = 14,  -- 绝望套装
    HARMONY = 15   -- 和谐套装
}

-- 符文套装颜色
ItemConfig.RUNE_SET_COLORS = {
    [ItemConfig.RUNE_SET_TYPES.ENERGY] = {r=0, g=255, b=0},      -- 绿色
    [ItemConfig.RUNE_SET_TYPES.SWIFT] = {r=0, g=255, b=255},     -- 青色
    [ItemConfig.RUNE_SET_TYPES.FATAL] = {r=255, g=50, b=50},     -- 红色
    [ItemConfig.RUNE_SET_TYPES.BLADE] = {r=190, g=190, b=190},   -- 银色
    [ItemConfig.RUNE_SET_TYPES.FOCUS] = {r=255, g=255, b=0},     -- 黄色
    [ItemConfig.RUNE_SET_TYPES.GUARD] = {r=255, g=140, b=0},     -- 橙色
    [ItemConfig.RUNE_SET_TYPES.ENDURE] = {r=150, g=75, b=0},     -- 棕色
    [ItemConfig.RUNE_SET_TYPES.REVENGE] = {r=165, g=42, b=42},   -- 暗红色
    [ItemConfig.RUNE_SET_TYPES.VIOLENT] = {r=170, g=0, b=170},   -- 紫色
    [ItemConfig.RUNE_SET_TYPES.VAMPIRE] = {r=139, g=0, b=0},     -- 深红色
    [ItemConfig.RUNE_SET_TYPES.WILL] = {r=255, g=192, b=203},    -- 粉色
    [ItemConfig.RUNE_SET_TYPES.NEMESIS] = {r=255, g=215, b=0},   -- 金色
    [ItemConfig.RUNE_SET_TYPES.RAGE] = {r=0, g=0, b=139},        -- 深蓝色
    [ItemConfig.RUNE_SET_TYPES.DESPAIR] = {r=75, g=0, b=130},    -- 靛蓝色
    [ItemConfig.RUNE_SET_TYPES.HARMONY] = {r=0, g=128, b=0}      -- 深绿色
}

-- 符文套装效果
ItemConfig.RUNE_SET_EFFECTS = {
    [ItemConfig.RUNE_SET_TYPES.ENERGY] = {
        name = "能量",
        count = 2,
        effect = {
            type = "hp_percent",
            value = 15
        }
    },
    [ItemConfig.RUNE_SET_TYPES.SWIFT] = {
        name = "迅捷",
        count = 4,
        effect = {
            type = "speed",
            value = 25
        }
    },
    [ItemConfig.RUNE_SET_TYPES.FATAL] = {
        name = "暴怒",
        count = 4,
        effect = {
            type = "atk_percent",
            value = 35
        }
    },
    [ItemConfig.RUNE_SET_TYPES.BLADE] = {
        name = "刀锋",
        count = 2,
        effect = {
            type = "crit_rate",
            value = 12
        }
    },
    [ItemConfig.RUNE_SET_TYPES.FOCUS] = {
        name = "专注",
        count = 2,
        effect = {
            type = "accuracy",
            value = 20
        }
    },
    [ItemConfig.RUNE_SET_TYPES.GUARD] = {
        name = "守护",
        count = 2,
        effect = {
            type = "def_percent",
            value = 15
        }
    },
    [ItemConfig.RUNE_SET_TYPES.ENDURE] = {
        name = "忍耐",
        count = 2,
        effect = {
            type = "resistance",
            value = 20
        }
    },
    [ItemConfig.RUNE_SET_TYPES.REVENGE] = {
        name = "复仇",
        count = 2,
        effect = {
            type = "counter_attack",
            value = 15
        }
    },
    [ItemConfig.RUNE_SET_TYPES.VIOLENT] = {
        name = "暴力",
        count = 4,
        effect = {
            type = "extra_turn",
            value = 22
        }
    },
    [ItemConfig.RUNE_SET_TYPES.VAMPIRE] = {
        name = "吸血",
        count = 4,
        effect = {
            type = "lifesteal",
            value = 35
        }
    },
    [ItemConfig.RUNE_SET_TYPES.WILL] = {
        name = "意志",
        count = 2,
        effect = {
            type = "immunity",
            value = 1
        }
    },
    [ItemConfig.RUNE_SET_TYPES.NEMESIS] = {
        name = "宿敌",
        count = 2,
        effect = {
            type = "atb_boost",
            value = 4
        }
    },
    [ItemConfig.RUNE_SET_TYPES.RAGE] = {
        name = "狂暴",
        count = 4,
        effect = {
            type = "crit_dmg",
            value = 40
        }
    },
    [ItemConfig.RUNE_SET_TYPES.DESPAIR] = {
        name = "绝望",
        count = 4,
        effect = {
            type = "stun_chance",
            value = 25
        }
    },
    [ItemConfig.RUNE_SET_TYPES.HARMONY] = {
        name = "和谐",
        count = 4,
        effect = {
            type = "all_stats",
            value = 8
        }
    }
}

-- 符文主属性值范围（按品质）
ItemConfig.RUNE_PRIMARY_STAT_RANGES = {
    [ItemConfig.RUNE_PRIMARY_STATS.HP_FLAT] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 100, max = 200},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 200, max = 400},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 400, max = 600},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 600, max = 900},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 900, max = 1200},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 1200, max = 1600}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.HP_PERCENT] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 50, max = 63}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.ATK_FLAT] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 5, max = 15},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 15, max = 25},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 25, max = 35},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 35, max = 50},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 50, max = 70},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 70, max = 90}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.ATK_PERCENT] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 50, max = 63}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.DEF_FLAT] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 5, max = 15},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 15, max = 25},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 25, max = 35},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 35, max = 50},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 50, max = 70},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 70, max = 90}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.DEF_PERCENT] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 50, max = 63}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.SPEED_FLAT] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 1, max = 3},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 3, max = 5},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 5, max = 7},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 7, max = 10},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 10, max = 15},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 15, max = 20}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.CRIT_RATE] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 50, max = 58}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.CRIT_DMG] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 10, max = 20},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 20, max = 35},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 35, max = 50},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 50, max = 65},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 65, max = 80},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 80, max = 90}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.ACCURACY] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 50, max = 60}
    },
    [ItemConfig.RUNE_PRIMARY_STATS.RESISTANCE] = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = {min = 5, max = 10},
        [ItemConfig.RUNE_QUALITY.MAGIC] = {min = 10, max = 20},
        [ItemConfig.RUNE_QUALITY.RARE] = {min = 20, max = 30},
        [ItemConfig.RUNE_QUALITY.HERO] = {min = 30, max = 40},
        [ItemConfig.RUNE_QUALITY.LEGEND] = {min = 40, max = 50},
        [ItemConfig.RUNE_QUALITY.ANCIENT] = {min = 50, max = 60}
    }
}

return ItemConfig 