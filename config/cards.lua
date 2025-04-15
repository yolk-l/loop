-- 卡牌配置文件
local TypeDefines = require('config/type_defines')


-- 卡牌配置
local CARD_CONFIG = {
    [TypeDefines.CARD_TYPES.SLIME_NEST] = {
        name = "史莱姆巢穴",
        cost = 1,
        description = "建造一个史莱姆巢穴，会定时生成史莱姆怪物",
        color = {0.5, 0.8, 0.5},
        buildingType = TypeDefines.BUILDING_TYPES.SLIME_NEST
    },
    [TypeDefines.CARD_TYPES.GOBLIN_HUT] = {
        name = "哥布林小屋",
        cost = 2,
        description = "建造一个哥布林小屋，会定时生成哥布林怪物",
        color = {0.8, 0.5, 0.3},
        buildingType = TypeDefines.BUILDING_TYPES.GOBLIN_HUT
    },
    [TypeDefines.CARD_TYPES.SKELETON_TOMB] = {
        name = "骷髅墓地",
        cost = 3,
        description = "建造一个骷髅墓地，会定时生成骷髅怪物",
        color = {0.8, 0.8, 0.8},
        buildingType = TypeDefines.BUILDING_TYPES.SKELETON_TOMB
    },
    [TypeDefines.CARD_TYPES.ZOMBIE_GRAVEYARD] = {
        name = "僵尸墓园",
        cost = 4,
        description = "建造一个僵尸墓园，会定时生成僵尸怪物",
        color = {0.2, 0.5, 0.2},
        buildingType = TypeDefines.BUILDING_TYPES.ZOMBIE_GRAVEYARD
    },
    [TypeDefines.CARD_TYPES.WOLF_DEN] = {
        name = "狼人巢穴",
        cost = 5,
        description = "建造一个狼人巢穴，会定时生成狼人怪物",
        color = {0.6, 0.3, 0.1},
        buildingType = TypeDefines.BUILDING_TYPES.WOLF_DEN
    },
    [TypeDefines.CARD_TYPES.GHOST_MANOR] = {
        name = "幽灵庄园",
        cost = 5,
        description = "建造一个幽灵庄园，会定时生成幽灵怪物",
        color = {0.7, 0.7, 1.0},
        buildingType = TypeDefines.BUILDING_TYPES.GHOST_MANOR
    },
    [TypeDefines.CARD_TYPES.GOLEM_FORGE] = {
        name = "巨人熔炉",
        cost = 7,
        description = "建造一个巨人熔炉，会定时生成石巨人怪物",
        color = {0.5, 0.5, 0.6},
        buildingType = TypeDefines.BUILDING_TYPES.GOLEM_FORGE
    },
    [TypeDefines.CARD_TYPES.WITCH_HUT] = {
        name = "女巫小屋",
        cost = 6,
        description = "建造一个女巫小屋，会定时生成女巫怪物",
        color = {0.8, 0.3, 0.8},
        buildingType = TypeDefines.BUILDING_TYPES.WITCH_HUT
    },
    [TypeDefines.CARD_TYPES.DRAGON_CAVE] = {
        name = "龙之洞窟",
        cost = 8,
        description = "建造一个龙之洞窟，会定时生成小龙怪物",
        color = {1.0, 0.3, 0.1},
        buildingType = TypeDefines.BUILDING_TYPES.DRAGON_CAVE
    }
}

return CARD_CONFIG