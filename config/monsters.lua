-- 怪物配置文件

-- 怪物配置
local MONSTER_CONFIG = {
    slime = {
        name = "史莱姆",
        color = {0.5, 0.8, 0.5},
        size = 20,
        attributes = {
            maxHp = 10,
            attack = 5,
            defense = 2,
            speed = 50,
            exp = 10,     -- 击杀获得经验
            attackRange = 30,  -- 攻击范围
            detectRange = 100  -- 检测范围
        }
    },
    goblin = {
        name = "哥布林",
        color = {0.8, 0.5, 0.3},
        size = 25,
        attributes = {
            maxHp = 20,
            attack = 8,
            defense = 3,
            speed = 80,
            exp = 20,
            attackRange = 40,
            detectRange = 150
        }
    },
    skeleton = {
        name = "骷髅",
        color = {0.8, 0.8, 0.8},
        size = 30,
        attributes = {
            maxHp = 30,
            attack = 12,
            defense = 5,
            speed = 60,
            exp = 30,
            attackRange = 50,
            detectRange = 200
        }
    }
}

return MONSTER_CONFIG 