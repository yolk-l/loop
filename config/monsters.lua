-- 怪物配置文件

local MONSTER_TYPES = {
    SLIME = 1,
    GOBLIN = 2,
    SKELETON = 3,
    ZOMBIE = 4,
    WOLF = 5,
    GHOST = 6,
    GOLEM = 7,
    WITCH = 8,
    DRAGON = 9,
}

-- 怪物等级分类
local MONSTER_TIERS = {
    BASIC = 1,
    ADVANCED = 2,
    ELITE = 3
}

-- 怪物配置
local MONSTER_CONFIG = {
    -- 基础怪物
    slime = {
        name = "史莱姆",
        color = {0.2, 0.8, 0.2},
        size = 12,
        attackType = "melee",  -- 近战攻击
        bulletSpeed = 0,       -- 近战怪物不需要子弹速度
        tier = MONSTER_TIERS.BASIC,
        attributes = {
            maxHp = 30,
            hp = 30,
            attack = 5,
            defense = 2,
            speed = 60,
            attackRange = 40,  -- 近战攻击范围提高
            detectRange = 80
        },
        animations = {
            idle = "monster_slime_idle",
            move = "monster_slime_move",
            attack = "monster_slime_idle" -- 史莱姆没有攻击动画，用idle代替
        },
        dropRate = 0.3,
        expValue = 10
    },
    goblin = {
        name = "哥布林",
        color = {0.8, 0.4, 0.0},
        size = 14,
        attackType = "melee",  -- 近战攻击
        bulletSpeed = 0,
        tier = MONSTER_TIERS.BASIC,
        attributes = {
            maxHp = 40,
            hp = 40,
            attack = 8,
            defense = 3,
            speed = 80,
            attackRange = 45,  -- 近战攻击范围提高
            detectRange = 100
        },
        animations = {
            idle = "monster_goblin_idle",
            move = "monster_goblin_move",
            attack = "monster_goblin_move" -- 哥布林没有攻击动画，用move代替
        },
        dropRate = 0.4,
        expValue = 15
    },
    skeleton = {
        name = "骷髅",
        color = {0.7, 0.7, 0.7},
        size = 16,
        attackType = "ranged",  -- 远程攻击
        bulletSpeed = 200,      -- 子弹速度
        tier = MONSTER_TIERS.BASIC,
        attributes = {
            maxHp = 50,
            hp = 50,
            attack = 10,
            defense = 4,
            speed = 70,
            attackRange = 80,  -- 远程攻击范围
            detectRange = 120
        },
        animations = {
            idle = "monster_skeleton_idle",
            move = "monster_skeleton_move",
            attack = "monster_skeleton_attack"
        },
        dropRate = 0.5,
        expValue = 20
    },
    
    -- 新增高级怪物
    zombie = {
        name = "僵尸",
        color = {0.3, 0.6, 0.3},
        size = 18,
        attackType = "melee",  -- 近战攻击
        bulletSpeed = 0,
        tier = MONSTER_TIERS.ADVANCED,
        attributes = {
            maxHp = 80,
            hp = 80,
            attack = 12,
            defense = 6,
            speed = 50,  -- 较慢
            attackRange = 50,  -- 近战攻击范围提高
            detectRange = 90
        },
        animations = {
            idle = "monster_zombie_idle",
            move = "monster_zombie_move",
            attack = "monster_zombie_attack"
        },
        dropRate = 0.6,
        expValue = 30
    },
    
    wolf = {
        name = "狼人",
        color = {0.5, 0.2, 0.0},
        size = 20,
        attackType = "melee",  -- 近战攻击
        bulletSpeed = 0,
        tier = MONSTER_TIERS.ADVANCED,
        attributes = {
            maxHp = 100,
            hp = 100,
            attack = 15,
            defense = 8,
            speed = 90,  -- 非常快
            attackRange = 55,  -- 近战攻击范围提高
            detectRange = 150
        },
        animations = {
            idle = "monster_wolf_idle",
            move = "monster_wolf_move",
            attack = "monster_wolf_attack"
        },
        dropRate = 0.7,
        expValue = 40
    },
    
    ghost = {
        name = "幽灵",
        color = {0.7, 0.7, 0.9},
        size = 16,
        attackType = "ranged",  -- 远程攻击
        bulletSpeed = 200,      -- 子弹速度
        tier = MONSTER_TIERS.ADVANCED,
        attributes = {
            maxHp = 70,
            hp = 70,
            attack = 12,
            defense = 3,
            speed = 100,
            attackRange = 85,  -- 远程攻击范围
            detectRange = 130
        },
        animations = {
            idle = "monster_ghost_idle",
            move = "monster_ghost_move",
            attack = "monster_ghost_attack"
        },
        dropRate = 0.7,
        expValue = 35
    },
    
    -- 精英怪物
    golem = {
        name = "石巨人",
        color = {0.4, 0.4, 0.4},
        size = 24,
        attackType = "melee",  -- 近战攻击
        bulletSpeed = 0,
        tier = MONSTER_TIERS.ELITE,
        attributes = {
            maxHp = 150,
            hp = 150,
            attack = 20,
            defense = 15,
            speed = 40,  -- 非常慢
            attackRange = 60,  -- 近战攻击范围提高
            detectRange = 110
        },
        animations = {
            idle = "monster_golem_idle",
            move = "monster_golem_move",
            attack = "monster_golem_attack"
        },
        dropRate = 0.8,
        expValue = 50
    },
    
    witch = {
        name = "女巫",
        color = {0.8, 0.2, 0.8},
        size = 18,
        attackType = "ranged",  -- 远程攻击
        bulletSpeed = 250,      -- 子弹速度
        tier = MONSTER_TIERS.ELITE,
        attributes = {
            maxHp = 90,
            hp = 90,
            attack = 18,  -- 高攻击
            defense = 5,
            speed = 60,
            attackRange = 90,  -- 远程攻击范围
            detectRange = 140
        },
        animations = {
            idle = "monster_witch_idle",
            move = "monster_witch_move",
            attack = "monster_witch_attack"
        },
        dropRate = 0.8,
        expValue = 45
    },
    
    dragon = {
        name = "小龙",
        color = {0.8, 0.2, 0.2},
        size = 22,
        attackType = "ranged",  -- 远程攻击
        bulletSpeed = 300,      -- 子弹速度
        tier = MONSTER_TIERS.ELITE,
        attributes = {
            maxHp = 120,
            hp = 120,
            attack = 25,
            defense = 10,
            speed = 80,
            attackRange = 75,  -- 远程攻击范围
            detectRange = 160
        },
        animations = {
            idle = "monster_dragon_idle",
            move = "monster_dragon_move",
            attack = "monster_dragon_attack"
        },
        dropRate = 0.9,
        expValue = 60
    }
}

return {
    MONSTER_CONFIG = MONSTER_CONFIG,
    MONSTER_TYPES = MONSTER_TYPES
}