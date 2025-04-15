local TypeDefines = {}

TypeDefines.MONSTER_TYPES = {
    SLIME = "slime",
    GOBLIN = "goblin",
    SKELETON = "skeleton",
    ZOMBIE = "zombie",
    WOLF = "wolf",
    GHOST = "ghost",
    GOLEM = "golem",
    WITCH = "witch",
    DRAGON = "dragon",
}

-- 怪物等级分类
TypeDefines.MONSTER_TIERS = {
    BASIC = 1,
    ADVANCED = 2,
    ELITE = 3
}

-- 物品类型
TypeDefines.ITEM_TYPES = {
    RUNE = 1,
    CARD = 2
}

-- 定义卡牌类型
TypeDefines.CARD_TYPES = {
    SLIME_NEST = "slime_nest",    -- 史莱姆巢穴
    GOBLIN_HUT = "goblin_hut",    -- 哥布林小屋
    SKELETON_TOMB = "skeleton_tomb", -- 骷髅墓地
    ZOMBIE_GRAVEYARD = "zombie_graveyard", -- 僵尸墓园
    WOLF_DEN = "wolf_den",      -- 狼人巢穴
    GHOST_MANOR = "ghost_manor",   -- 幽灵庄园
    GOLEM_FORGE = "golem_forge",   -- 巨人熔炉
    WITCH_HUT = "witch_hut",     -- 女巫小屋
    DRAGON_CAVE = "dragon_cave"    -- 龙之洞窟
}

-- 建筑类型
TypeDefines.BUILDING_TYPES = {
    SLIME_NEST = "slime_nest",    -- 史莱姆巢穴
    GOBLIN_HUT = "goblin_hut",    -- 哥布林小屋
    SKELETON_TOMB = "skeleton_tomb", -- 骷髅墓地
    ZOMBIE_GRAVEYARD = "zombie_graveyard", -- 僵尸墓园
    WOLF_DEN = "wolf_den",      -- 狼人巢穴
    GHOST_MANOR = "ghost_manor",   -- 幽灵庄园
    GOLEM_FORGE = "golem_forge",   -- 巨人熔炉
    WITCH_HUT = "witch_hut",     -- 女巫小屋
    DRAGON_CAVE = "dragon_cave"    -- 龙之洞窟
}

-- 怪物类型到建筑卡牌类型的映射表
TypeDefines.MONSTER_TO_CARD_TYPE = {
    [TypeDefines.MONSTER_TYPES.SLIME] = TypeDefines.CARD_TYPES.SLIME_NEST,      -- 史莱姆 -> 史莱姆巢穴
    [TypeDefines.MONSTER_TYPES.GOBLIN] = TypeDefines.CARD_TYPES.GOBLIN_HUT,     -- 哥布林 -> 哥布林小屋
    [TypeDefines.MONSTER_TYPES.SKELETON] = TypeDefines.CARD_TYPES.SKELETON_TOMB,   -- 骷髅 -> 骷髅墓地
    [TypeDefines.MONSTER_TYPES.ZOMBIE] = TypeDefines.CARD_TYPES.ZOMBIE_GRAVEYARD,     -- 僵尸 -> 僵尸墓园
    [TypeDefines.MONSTER_TYPES.WOLF] = TypeDefines.CARD_TYPES.WOLF_DEN,       -- 狼人 -> 狼人巢穴
    [TypeDefines.MONSTER_TYPES.GHOST] = TypeDefines.CARD_TYPES.GHOST_MANOR,      -- 幽灵 -> 幽灵庄园
    [TypeDefines.MONSTER_TYPES.GOLEM] = TypeDefines.CARD_TYPES.GOLEM_FORGE,      -- 石巨人 -> 巨人熔炉
    [TypeDefines.MONSTER_TYPES.WITCH] = TypeDefines.CARD_TYPES.WITCH_HUT,      -- 女巫 -> 女巫小屋
    [TypeDefines.MONSTER_TYPES.DRAGON] = TypeDefines.CARD_TYPES.DRAGON_CAVE      -- 小龙 -> 龙之洞窟
}

return TypeDefines
