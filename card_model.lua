local CardModel = {}
CardModel.__index = CardModel

-- 卡牌类型
CardModel.CARD_TYPES = {
    SLIME = 1,
    GOBLIN = 2,
    SKELETON = 3
}

-- 卡牌配置
CardModel.CARD_CONFIGS = {
    [CardModel.CARD_TYPES.SLIME] = {
        name = "史莱姆卡",
        description = "召唤一只史莱姆",
        monsterType = "slime",
        color = {0.2, 0.8, 0.2}
    },
    [CardModel.CARD_TYPES.GOBLIN] = {
        name = "哥布林卡",
        description = "召唤一只哥布林",
        monsterType = "goblin",
        color = {0.8, 0.2, 0.2}
    },
    [CardModel.CARD_TYPES.SKELETON] = {
        name = "骷髅卡",
        description = "召唤一只骷髅",
        monsterType = "skeleton",
        color = {0.8, 0.8, 0.8}
    }
}

function CardModel:new(cardType)
    local self = setmetatable({}, CardModel)
    self.type = cardType
    self.config = CardModel.CARD_CONFIGS[cardType]
    return self
end

return CardModel 