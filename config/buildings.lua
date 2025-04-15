-- 建筑配置文件
local TypeDefines = require('config/type_defines')
local BUILDING_CONFIG = {
    -- 基础建筑
    [TypeDefines.BUILDING_TYPES.SLIME_NEST] = {
        name = "史莱姆巢穴",
        color = {0.5, 0.8, 0.5},
        monsterType = TypeDefines.MONSTER_TYPES.SLIME,
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
    
    [TypeDefines.BUILDING_TYPES.GOBLIN_HUT] = {
        name = "哥布林小屋",
        color = {0.8, 0.5, 0.3},
        monsterType = TypeDefines.MONSTER_TYPES.GOBLIN,
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
    
    [TypeDefines.BUILDING_TYPES.SKELETON_TOMB] = {
        name = "骷髅墓地",
        color = {0.8, 0.8, 0.8},
        monsterType = TypeDefines.MONSTER_TYPES.SKELETON,
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
    },
    
    -- 新增高级建筑
    [TypeDefines.BUILDING_TYPES.ZOMBIE_GRAVEYARD] = {
        name = "僵尸墓园",
        color = {0.2, 0.5, 0.2},
        monsterType = TypeDefines.MONSTER_TYPES.ZOMBIE,
        spriteColor = {0.2, 0.4, 0.2},  -- 深绿色
        attributes = {
            hp = 150,
            maxHp = 150,
            lifespan = 90,
            spawnRate = 18,  -- 生成较慢
            spawnRadius = 40,
            maxSpawns = 4,
            wanderRadius = 70
        }
    },
    
    [TypeDefines.BUILDING_TYPES.WOLF_DEN] = {
        name = "狼人巢穴",
        color = {0.6, 0.3, 0.1},
        monsterType = TypeDefines.MONSTER_TYPES.WOLF,
        spriteColor = {0.5, 0.25, 0.1},  -- 棕色
        attributes = {
            hp = 130,
            maxHp = 130,
            lifespan = 75,
            spawnRate = 16,
            spawnRadius = 35,
            maxSpawns = 3,
            wanderRadius = 120  -- 大游荡范围
        }
    },
    
    [TypeDefines.BUILDING_TYPES.GHOST_MANOR] = {
        name = "幽灵庄园",
        color = {0.7, 0.7, 1.0},
        monsterType = TypeDefines.MONSTER_TYPES.GHOST,
        spriteColor = {0.6, 0.6, 0.9},  -- 淡蓝色
        attributes = {
            hp = 120,
            maxHp = 120,
            lifespan = 100,  -- 长寿命
            spawnRate = 15,
            spawnRadius = 50,  -- 大生成范围
            maxSpawns = 4,
            wanderRadius = 100
        }
    },
    
    -- 精英建筑
    [TypeDefines.BUILDING_TYPES.GOLEM_FORGE] = {
        name = "巨人熔炉",
        color = {0.5, 0.5, 0.6},
        monsterType = TypeDefines.MONSTER_TYPES.GOLEM,
        spriteColor = {0.4, 0.4, 0.5},  -- 灰色
        attributes = {
            hp = 200,
            maxHp = 200,
            lifespan = 120,  -- 非常长的寿命
            spawnRate = 25,   -- 慢速生成
            spawnRadius = 30,
            maxSpawns = 2,    -- 少量生成
            wanderRadius = 60
        }
    },
    
    [TypeDefines.BUILDING_TYPES.WITCH_HUT] = {
        name = "女巫小屋",
        color = {0.8, 0.3, 0.8},
        monsterType = TypeDefines.MONSTER_TYPES.WITCH,
        spriteColor = {0.7, 0.2, 0.7},  -- 紫色
        attributes = {
            hp = 140,
            maxHp = 140,
            lifespan = 90,
            spawnRate = 22,
            spawnRadius = 45,
            maxSpawns = 2,
            wanderRadius = 110
        }
    },
    
    [TypeDefines.BUILDING_TYPES.DRAGON_CAVE] = {
        name = "龙之洞窟",
        color = {1.0, 0.3, 0.1},
        monsterType = TypeDefines.MONSTER_TYPES.DRAGON,
        spriteColor = {0.9, 0.2, 0.0},  -- 红色
        attributes = {
            hp = 250,
            maxHp = 250,
            lifespan = 150,   -- 极长寿命
            spawnRate = 30,   -- 非常慢的生成
            spawnRadius = 60,
            maxSpawns = 1,    -- 一次只生成一条龙
            wanderRadius = 150 -- 大游荡范围
        }
    }
}

return BUILDING_CONFIG