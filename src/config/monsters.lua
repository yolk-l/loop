-- 怪物配置文件

-- 怪物配置
local MONSTER_CONFIG = {
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
    }
}

return MONSTER_CONFIG 