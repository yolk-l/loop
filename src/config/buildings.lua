-- 建筑配置文件
local BuildingConfig = {}

-- 所有建筑类型的配置
BuildingConfig.types = {
    slime_nest = {
        name = "史莱姆巢穴",
        color = {0.5, 0.8, 0.5},
        monsterType = "slime",
        spriteColor = {0.3, 0.8, 0.3},  -- 绿色
        attributes = {
            hp = 100,
            maxHp = 100,
            lifespan = 60,
            spawnRate = 10,
            spawnRadius = 30,
            maxSpawns = 5,
            wanderRadius = 80
        }
    },
    
    goblin_hut = {
        name = "哥布林小屋",
        color = {0.8, 0.5, 0.3},
        monsterType = "goblin",
        spriteColor = {0.8, 0.5, 0.3},  -- 褐色
        attributes = {
            hp = 100,
            maxHp = 100,
            lifespan = 60,
            spawnRate = 15,
            spawnRadius = 30,
            maxSpawns = 3,
            wanderRadius = 80
        }
    },
    
    skeleton_tomb = {
        name = "骷髅墓地",
        color = {0.8, 0.8, 0.8},
        monsterType = "skeleton",
        spriteColor = {0.6, 0.6, 0.7},  -- 灰色
        attributes = {
            hp = 100,
            maxHp = 100,
            lifespan = 60,
            spawnRate = 20,
            spawnRadius = 30,
            maxSpawns = 2,
            wanderRadius = 80
        }
    }
}

-- 默认配置，当请求的建筑类型不存在时使用
BuildingConfig.default = {
    name = "未知建筑",
    color = {0.7, 0.7, 0.7},
    monsterType = "slime",
    spriteColor = {0.7, 0.7, 0.7},
    attributes = {
        hp = 100,
        maxHp = 100,
        lifespan = 60,
        spawnRate = 10,
        spawnRadius = 30,
        maxSpawns = 5,
        wanderRadius = 80
    }
}

-- 获取建筑配置的函数
function BuildingConfig.get(type)
    return BuildingConfig.types[type] or BuildingConfig.default
end

return BuildingConfig 