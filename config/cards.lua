-- 卡牌配置文件

-- 定义卡牌类型
local CARD_TYPES = {
    SLIME_NEST = 1,    -- 史莱姆巢穴
    GOBLIN_HUT = 2,    -- 哥布林小屋
    SKELETON_TOMB = 3  -- 骷髅墓地
}

-- 卡牌配置
local CARD_CONFIG = {
    [CARD_TYPES.SLIME_NEST] = {
        name = "史莱姆巢穴",
        cost = 1,
        description = "建造一个史莱姆巢穴，会定时生成史莱姆怪物",
        color = {0.5, 0.8, 0.5},
        buildingType = "slime_nest",
        lifespan = 60,  -- 持续时间(秒)
        spawnRate = 10  -- 生成怪物的速率(秒/只)
    },
    [CARD_TYPES.GOBLIN_HUT] = {
        name = "哥布林小屋",
        cost = 2,
        description = "建造一个哥布林小屋，会定时生成哥布林怪物",
        color = {0.8, 0.5, 0.3},
        buildingType = "goblin_hut",
        lifespan = 45,  -- 持续时间(秒)
        spawnRate = 15  -- 生成怪物的速率(秒/只)
    },
    [CARD_TYPES.SKELETON_TOMB] = {
        name = "骷髅墓地",
        cost = 3,
        description = "建造一个骷髅墓地，会定时生成骷髅怪物",
        color = {0.8, 0.8, 0.8},
        buildingType = "skeleton_tomb",
        lifespan = 30,  -- 持续时间(秒)
        spawnRate = 20  -- 生成怪物的速率(秒/只)
    }
}

return {
    CARD_TYPES = CARD_TYPES,
    CARD_CONFIG = CARD_CONFIG
} 