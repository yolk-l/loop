-- 怪物配置文件

-- 怪物配置
local MONSTER_CONFIG = {
    -- 基础怪物
    slime = {
        name = "史莱姆",
        color = {0.5, 0.8, 0.5},
        size = 10,
        attributes = {
            maxHp = 10,
            attack = 5,
            defense = 2,
            speed = 50,
            exp = 10,     -- 击杀获得经验
            attackRange = 20,
            detectRange = 80
        }
    },
    goblin = {
        name = "哥布林",
        color = {0.8, 0.5, 0.3},
        size = 12,
        attributes = {
            maxHp = 20,
            attack = 8,
            defense = 3,
            speed = 80,
            exp = 20,
            attackRange = 25,
            detectRange = 100
        }
    },
    skeleton = {
        name = "骷髅",
        color = {0.8, 0.8, 0.8},
        size = 15,
        attributes = {
            maxHp = 30,
            attack = 12,
            defense = 5,
            speed = 60,
            exp = 30,
            attackRange = 30,
            detectRange = 120
        }
    },
    
    -- 新增高级怪物
    zombie = {
        name = "僵尸",
        color = {0.2, 0.5, 0.2},
        size = 14,
        attributes = {
            maxHp = 45,
            attack = 10,
            defense = 8,
            speed = 40,  -- 较慢
            exp = 35,
            attackRange = 25,
            detectRange = 90
        }
    },
    
    werewolf = {
        name = "狼人",
        color = {0.6, 0.3, 0.1},
        size = 16,
        attributes = {
            maxHp = 35,
            attack = 15,
            defense = 4,
            speed = 100,  -- 非常快
            exp = 40,
            attackRange = 30,
            detectRange = 150
        }
    },
    
    ghost = {
        name = "幽灵",
        color = {0.7, 0.7, 1.0},
        size = 13,
        attributes = {
            maxHp = 25,
            attack = 12,
            defense = 10,  -- 高防御
            speed = 70,
            exp = 38,
            attackRange = 40,  -- 远程攻击
            detectRange = 130
        }
    },
    
    -- 精英怪物
    golem = {
        name = "石巨人",
        color = {0.5, 0.5, 0.6},
        size = 20,
        attributes = {
            maxHp = 80,
            attack = 18,
            defense = 15,
            speed = 35,  -- 非常慢
            exp = 60,
            attackRange = 35,
            detectRange = 110
        }
    },
    
    witch = {
        name = "女巫",
        color = {0.8, 0.3, 0.8},
        size = 15,
        attributes = {
            maxHp = 40,
            attack = 22,  -- 高攻击
            defense = 6,
            speed = 65,
            exp = 55,
            attackRange = 50,  -- 远程攻击
            detectRange = 140
        }
    },
    
    dragon = {
        name = "小龙",
        color = {1.0, 0.3, 0.1},
        size = 25,
        attributes = {
            maxHp = 100,
            attack = 25,
            defense = 12,
            speed = 80,
            exp = 100,  -- 高经验值
            attackRange = 45,
            detectRange = 160
        }
    }
}

return MONSTER_CONFIG 