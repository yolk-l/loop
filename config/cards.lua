-- 卡牌配置文件

-- 定义卡牌类型
local CARD_TYPES = {
    SLIME = 1,
    GOBLIN = 2,
    SKELETON = 3
}

-- 卡牌配置
local CARD_CONFIG = {
    [CARD_TYPES.SLIME] = {
        name = "史莱姆",
        cost = 1,
        description = "召唤一只史莱姆",
        color = {0.5, 0.8, 0.5},
        monsterType = "slime"
    },
    [CARD_TYPES.GOBLIN] = {
        name = "哥布林",
        cost = 2,
        description = "召唤一只哥布林",
        color = {0.8, 0.5, 0.3},
        monsterType = "goblin"
    },
    [CARD_TYPES.SKELETON] = {
        name = "骷髅",
        cost = 3,
        description = "召唤一只骷髅",
        color = {0.8, 0.8, 0.8},
        monsterType = "skeleton"
    }
}

return {
    CARD_TYPES = CARD_TYPES,
    CARD_CONFIG = CARD_CONFIG
} 