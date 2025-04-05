-- 物品类
local Item = {}
Item.__index = Item

-- 物品类型
local ITEM_TYPES = {
    EQUIPMENT = 1,
    CARD = 2
}

-- 装备类型
local EQUIPMENT_TYPES = {
    WEAPON = 1,
    ARMOR = 2,
    ACCESSORY = 3
}

-- 装备配置
local EQUIPMENT_CONFIG = {
    -- 武器
    wooden_sword = {
        name = "木剑",
        type = EQUIPMENT_TYPES.WEAPON,
        color = {0.8, 0.6, 0.4},
        attributes = {
            attack = 8
        },
        description = "一把普通的木剑"
    },
    iron_sword = {
        name = "铁剑",
        type = EQUIPMENT_TYPES.WEAPON,
        color = {0.7, 0.7, 0.7},
        attributes = {
            attack = 15
        },
        description = "锋利的铁剑"
    },
    -- 护甲
    leather_armor = {
        name = "皮甲",
        type = EQUIPMENT_TYPES.ARMOR,
        color = {0.6, 0.4, 0.2},
        attributes = {
            defense = 5,
            maxHp = 30
        },
        description = "简单的皮革护甲"
    },
    iron_armor = {
        name = "铁甲",
        type = EQUIPMENT_TYPES.ARMOR,
        color = {0.6, 0.6, 0.6},
        attributes = {
            defense = 10,
            maxHp = 60
        },
        description = "结实的铁护甲"
    },
    -- 饰品
    speed_ring = {
        name = "迅捷戒指",
        type = EQUIPMENT_TYPES.ACCESSORY,
        color = {0.2, 0.8, 0.8},
        attributes = {
            speed = 50
        },
        description = "提升移动速度"
    },
    power_ring = {
        name = "力量戒指",
        type = EQUIPMENT_TYPES.ACCESSORY,
        color = {0.8, 0.2, 0.2},
        attributes = {
            attack = 5,
            defense = 3
        },
        description = "提升攻击和防御"
    }
}

-- 怪物掉落表
local DROP_TABLE = {
    slime = {
        equipment = {
            {id = "wooden_sword", chance = 0.2},  -- 20%
            {id = "leather_armor", chance = 0.2}, -- 20%
            {id = "speed_ring", chance = 0.1}     -- 10%
        },
        cardChance = 0.3  -- 30%概率掉落自己的卡牌
    },
    goblin = {
        equipment = {
            {id = "iron_sword", chance = 0.2},    -- 20%
            {id = "leather_armor", chance = 0.25}, -- 25%
            {id = "power_ring", chance = 0.1}     -- 10%
        },
        cardChance = 0.25  -- 25%
    },
    skeleton = {
        equipment = {
            {id = "iron_sword", chance = 0.25},   -- 25%
            {id = "iron_armor", chance = 0.2},    -- 20%
            {id = "power_ring", chance = 0.15}    -- 15%
        },
        cardChance = 0.2   -- 20%
    }
}

-- 字体缓存
local fonts = {
    name = nil,
    description = nil
}

-- 初始化字体
local function initFonts()
    if not fonts.name then
        fonts.name = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
        fonts.description = love.graphics.newFont("assets/fonts/simsun.ttc", 10)
    end
end

function Item:new(itemType, id, x, y)
    local self = setmetatable({}, Item)
    self.itemType = itemType
    self.id = id
    self.x = x
    self.y = y
    self.size = 15
    self.config = EQUIPMENT_CONFIG[id]
    self.pickupRange = 30
    
    initFonts()
    return self
end

function Item:isInRange(playerX, playerY)
    local dx = playerX - self.x
    local dy = playerY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance <= self.pickupRange
end

function Item:draw()
    -- 绘制物品外观
    love.graphics.setColor(unpack(self.config.color))
    love.graphics.circle('fill', self.x, self.y, self.size)
    
    -- 绘制边框
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.circle('line', self.x, self.y, self.size)
    
    -- 绘制物品名称
    love.graphics.setFont(fonts.name)
    love.graphics.setColor(1, 1, 1)
    local nameWidth = fonts.name:getWidth(self.config.name)
    love.graphics.print(self.config.name, self.x - nameWidth/2, self.y - self.size - 15)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 生成掉落物
function Item.generateDrops(monsterType, x, y)
    local drops = {}
    local dropConfig = DROP_TABLE[monsterType]
    
    if not dropConfig then return drops end
    
    -- 检查装备掉落
    for _, equipment in ipairs(dropConfig.equipment) do
        if math.random() < equipment.chance then
            table.insert(drops, Item:new(ITEM_TYPES.EQUIPMENT, equipment.id, 
                x + math.random(-20, 20), y + math.random(-20, 20)))
        end
    end
    
    -- 检查卡牌掉落
    if math.random() < dropConfig.cardChance then
        -- 这里需要创建卡牌物品，具体实现依赖于卡牌系统
        -- 暂时返回一个标记，让main.lua处理卡牌的创建
        table.insert(drops, {
            isCard = true,
            monsterType = monsterType,
            x = x + math.random(-20, 20),
            y = y + math.random(-20, 20)
        })
    end
    
    return drops
end

return {
    Item = Item,
    ITEM_TYPES = ITEM_TYPES,
    EQUIPMENT_TYPES = EQUIPMENT_TYPES
} 