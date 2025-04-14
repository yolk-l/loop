-- 物品系统
local Item = {}
Item.__index = Item

-- 引入配置
local ItemConfig = require('config/items')
local Global = require('src/utils/global')

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

-- 创建新符文
function Item:newRune(setType, position, quality, x, y)
    local self = setmetatable({}, Item)
    self.id = Global.gen_id()
    self.x = x
    self.y = y
    self.size = 15
    self.pickupRange = 30
    
    -- 符文特有属性
    self.isRune = true
    self.setType = setType  -- 符文套装类型
    self.position = position  -- 符文位置
    self.quality = quality  -- 符文品质
    
    -- 获取套装信息
    self.setInfo = ItemConfig.RUNE_SET_EFFECTS[setType]
    
    -- 符文颜色
    self.color = ItemConfig.RUNE_SET_COLORS[setType]
    self.qualityColor = ItemConfig.RUNE_QUALITY_COLORS[quality]
    
    -- 生成符文主属性
    self.primaryStat = self:generatePrimaryStat(position, quality)
    
    -- 生成符文次属性 (数量根据品质)
    self.subStats = self:generateSubStats(quality)
    
    -- 构建符文名称
    local qualityNames = {
        [ItemConfig.RUNE_QUALITY.NORMAL] = "普通",
        [ItemConfig.RUNE_QUALITY.MAGIC] = "魔法",
        [ItemConfig.RUNE_QUALITY.RARE] = "稀有",
        [ItemConfig.RUNE_QUALITY.HERO] = "英雄",
        [ItemConfig.RUNE_QUALITY.LEGEND] = "传说",
        [ItemConfig.RUNE_QUALITY.ANCIENT] = "远古"
    }
    
    self.name = qualityNames[quality] .. self.setInfo.name .. "符文"
    
    initFonts()
    return self
end

-- 生成符文主属性
function Item:generatePrimaryStat(position, quality)
    local statTypeOptions = {}
    -- 根据位置确定可选的主属性类型
    if position == ItemConfig.RUNE_POSITIONS.SLOT_1 or position == ItemConfig.RUNE_POSITIONS.SLOT_3 or position == ItemConfig.RUNE_POSITIONS.SLOT_5 then
        -- 奇数槽位（右上、右下、左中）
        statTypeOptions = {
            ItemConfig.RUNE_PRIMARY_STATS.HP_FLAT,
            ItemConfig.RUNE_PRIMARY_STATS.ATK_FLAT,
            ItemConfig.RUNE_PRIMARY_STATS.DEF_FLAT
        }
    elseif position == ItemConfig.RUNE_POSITIONS.SLOT_2 then
        -- 右中槽位
        statTypeOptions = {
            ItemConfig.RUNE_PRIMARY_STATS.ATK_PERCENT,
            ItemConfig.RUNE_PRIMARY_STATS.HP_PERCENT,
            ItemConfig.RUNE_PRIMARY_STATS.DEF_PERCENT
        }
    elseif position == ItemConfig.RUNE_POSITIONS.SLOT_4 then
        -- 左上槽位
        statTypeOptions = {
            ItemConfig.RUNE_PRIMARY_STATS.SPEED_FLAT,
            ItemConfig.RUNE_PRIMARY_STATS.CRIT_RATE,
            ItemConfig.RUNE_PRIMARY_STATS.CRIT_DMG
        }
    elseif position == ItemConfig.RUNE_POSITIONS.SLOT_6 then
        -- 左下槽位
        statTypeOptions = {
            ItemConfig.RUNE_PRIMARY_STATS.ACCURACY,
            ItemConfig.RUNE_PRIMARY_STATS.RESISTANCE,
            ItemConfig.RUNE_PRIMARY_STATS.HP_PERCENT
        }
    end
    
    -- 随机选择一个主属性类型
    local statType = statTypeOptions[math.random(1, #statTypeOptions)]
    
    -- 获取该属性对应品质的值范围
    local range = ItemConfig.RUNE_PRIMARY_STAT_RANGES[statType][quality]
    
    -- 随机生成属性值
    local value = math.random(range.min, range.max)
    
    return {
        type = statType,
        value = value
    }
end

-- 生成符文次属性
function Item:generateSubStats(quality)
    local subStats = {}
    
    -- 根据品质决定次属性数量
    local subStatCount = 0
    if quality == ItemConfig.RUNE_QUALITY.NORMAL then
        subStatCount = 0  -- 普通符文没有次属性
    elseif quality == ItemConfig.RUNE_QUALITY.MAGIC then
        subStatCount = 1  -- 魔法符文1个次属性
    elseif quality == ItemConfig.RUNE_QUALITY.RARE then
        subStatCount = 2  -- 稀有符文2个次属性
    elseif quality == ItemConfig.RUNE_QUALITY.HERO then
        subStatCount = 3  -- 英雄符文3个次属性
    elseif quality == ItemConfig.RUNE_QUALITY.LEGEND or quality == ItemConfig.RUNE_QUALITY.ANCIENT then
        subStatCount = 4  -- 传说和远古符文4个次属性
    end
    
    -- 避免主属性与次属性重复
    local availableStatTypes = {}
    for statType, _ in pairs(ItemConfig.RUNE_SUB_STATS) do
        if statType ~= self.primaryStat.type then
            table.insert(availableStatTypes, statType)
        end
    end
    
    -- 随机选择次属性
    for i = 1, subStatCount do
        if #availableStatTypes == 0 then break end
        
        -- 随机选择一个次属性类型
        local index = math.random(1, #availableStatTypes)
        local statType = availableStatTypes[index]
        
        -- 从可用列表中移除已选择的属性
        table.remove(availableStatTypes, index)
        
        -- 简化起见，使用固定的次属性值范围
        local value = 0
        if statType == ItemConfig.RUNE_SUB_STATS.HP_FLAT then
            value = math.random(100, 300)
        elseif statType == ItemConfig.RUNE_SUB_STATS.HP_PERCENT or
               statType == ItemConfig.RUNE_SUB_STATS.ATK_PERCENT or
               statType == ItemConfig.RUNE_SUB_STATS.DEF_PERCENT then
            value = math.random(3, 8)
        elseif statType == ItemConfig.RUNE_SUB_STATS.ATK_FLAT or
               statType == ItemConfig.RUNE_SUB_STATS.DEF_FLAT then
            value = math.random(5, 15)
        elseif statType == ItemConfig.RUNE_SUB_STATS.SPEED_FLAT then
            value = math.random(1, 5)
        elseif statType == ItemConfig.RUNE_SUB_STATS.CRIT_RATE or
               statType == ItemConfig.RUNE_SUB_STATS.ACCURACY or
               statType == ItemConfig.RUNE_SUB_STATS.RESISTANCE then
            value = math.random(3, 10)
        elseif statType == ItemConfig.RUNE_SUB_STATS.CRIT_DMG then
            value = math.random(5, 15)
        end
        
        table.insert(subStats, {
            type = statType,
            value = value
        })
    end
    
    return subStats
end

function Item:isInRange(playerX, playerY)
    local dx = playerX - self.x
    local dy = playerY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance <= self.pickupRange
end

function Item:draw()
    -- 绘制符文外观
    if self.isRune then
        -- 绘制符文底色（套装颜色）
        love.graphics.setColor(unpack(self.color))
        love.graphics.circle('fill', self.x, self.y, self.size)
        
        -- 绘制品质边框
        love.graphics.setColor(unpack(self.qualityColor))
        love.graphics.setLineWidth(2)
        love.graphics.circle('line', self.x, self.y, self.size)
        
        -- 绘制位置标记（符文槽位）
        local posMarks = {"↗", "→", "↘", "↖", "←", "↙"}  -- 使用箭头表示位置
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fonts.name)
        love.graphics.print(posMarks[self.position], self.x - 5, self.y - 6)
        
        -- 绘制符文名称
        love.graphics.setFont(fonts.name)
        love.graphics.setColor(unpack(self.qualityColor))
        local nameWidth = fonts.name:getWidth(self.name)
        love.graphics.print(self.name, self.x - nameWidth/2, self.y - self.size - 15)
    else
        -- 保留原始物品绘制代码
        local AnimationSystem = require('src/systems/Animation')
        local image = nil
        
        -- 根据装备类型获取对应图像
        if self.config and self.config.image then
            image = AnimationSystem.getWeaponImage(self.config.image)
        end
        
        if image then
            -- 绘制物品图像
            love.graphics.setColor(1, 1, 1)
            local scale = 1.5  -- 缩放比例，根据需要调整
            local imgWidth, imgHeight = image:getDimensions()
            local x = self.x - (imgWidth * scale)/2
            local y = self.y - (imgHeight * scale)/2
            
            love.graphics.draw(image, x, y, 0, scale, scale)
        else
            -- 如果没有图像，使用圆形表示
            love.graphics.setColor(unpack(self.config.color))
            love.graphics.circle('fill', self.x, self.y, self.size)
            
            -- 绘制边框
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.circle('line', self.x, self.y, self.size)
        end
        
        -- 绘制物品名称
        love.graphics.setFont(fonts.name)
        love.graphics.setColor(1, 1, 1)
        local nameWidth = fonts.name:getWidth(self.config.name)
        love.graphics.print(self.config.name, self.x - nameWidth/2, self.y - self.size - 15)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 获取符文属性描述（用于提示）
function Item:getRuneDescription()
    if not self.isRune then return "" end
    
    local desc = self.name .. "\n"
    
    -- 添加套装信息
    desc = desc .. "[".. self.setInfo.name .. "套装]\n"
    desc = desc .. "(" .. self.setInfo.count .. "件套): " .. self:getSetEffectDescription(self.setInfo.effect) .. "\n"
    
    -- 添加主属性信息
    desc = desc .. "主属性: " .. self:getStatDescription(self.primaryStat) .. "\n"
    
    -- 添加次属性信息
    if #self.subStats > 0 then
        desc = desc .. "次属性:\n"
        for _, stat in ipairs(self.subStats) do
            desc = desc .. "  " .. self:getStatDescription(stat) .. "\n"
        end
    end
    
    return desc
end

-- 获取套装效果描述
function Item:getSetEffectDescription(effect)
    local effectDesc = ""
    
    if effect.type == "atk_percent" then
        effectDesc = "攻击力+" .. effect.value .. "%"
    elseif effect.type == "crit_rate" then
        effectDesc = "暴击率+" .. effect.value .. "%"
    elseif effect.type == "speed" then
        effectDesc = "速度+" .. effect.value .. "%"
    elseif effect.type == "accuracy" then
        effectDesc = "命中率+" .. effect.value .. "%"
    elseif effect.type == "def_percent" then
        effectDesc = "防御力+" .. effect.value .. "%"
    elseif effect.type == "resistance" then
        effectDesc = "抵抗+" .. effect.value .. "%"
    elseif effect.type == "extra_turn" then
        effectDesc = effect.value .. "%几率获得额外回合"
    elseif effect.type == "crit_dmg" then
        effectDesc = "暴击伤害+" .. effect.value .. "%"
    elseif effect.type == "stun_chance" then
        effectDesc = effect.value .. "%几率眩晕目标"
    elseif effect.type == "lifesteal" then
        effectDesc = "伤害" .. effect.value .. "%吸血"
    elseif effect.type == "all_stats" then
        effectDesc = "所有属性+" .. effect.value .. "%"
    end
    
    return effectDesc
end

-- 获取属性描述
function Item:getStatDescription(stat)
    local statNames = {
        [ItemConfig.RUNE_PRIMARY_STATS.HP_FLAT] = "生命值",
        [ItemConfig.RUNE_PRIMARY_STATS.HP_PERCENT] = "生命值",
        [ItemConfig.RUNE_PRIMARY_STATS.ATK_FLAT] = "攻击力",
        [ItemConfig.RUNE_PRIMARY_STATS.ATK_PERCENT] = "攻击力",
        [ItemConfig.RUNE_PRIMARY_STATS.DEF_FLAT] = "防御力",
        [ItemConfig.RUNE_PRIMARY_STATS.DEF_PERCENT] = "防御力",
        [ItemConfig.RUNE_PRIMARY_STATS.SPEED_FLAT] = "速度",
        [ItemConfig.RUNE_PRIMARY_STATS.CRIT_RATE] = "暴击率",
        [ItemConfig.RUNE_PRIMARY_STATS.CRIT_DMG] = "暴击伤害",
        [ItemConfig.RUNE_PRIMARY_STATS.ACCURACY] = "命中率",
        [ItemConfig.RUNE_PRIMARY_STATS.RESISTANCE] = "抵抗"
    }
    
    local desc = statNames[stat.type] or "未知属性"
    
    if stat.type == ItemConfig.RUNE_PRIMARY_STATS.HP_PERCENT or
       stat.type == ItemConfig.RUNE_PRIMARY_STATS.ATK_PERCENT or
       stat.type == ItemConfig.RUNE_PRIMARY_STATS.DEF_PERCENT or
       stat.type == ItemConfig.RUNE_PRIMARY_STATS.CRIT_RATE or
       stat.type == ItemConfig.RUNE_PRIMARY_STATS.CRIT_DMG or
       stat.type == ItemConfig.RUNE_PRIMARY_STATS.ACCURACY or
       stat.type == ItemConfig.RUNE_PRIMARY_STATS.RESISTANCE then
        desc = desc .. " +" .. stat.value .. "%"
    else
        desc = desc .. " +" .. stat.value
    end
    
    return desc
end

-- 生成掉落物
function Item.generateDrops(monsterType, x, y)
    local drops = {}
    
    -- 获取怪物的符文掉落配置
    local dropConfig = ItemConfig.RUNE_DROP_CONFIG[monsterType]
    
    -- 如果没有为该怪物类型定义掉落配置，返回空列表
    if not dropConfig then
        return drops
    end
    
    -- 处理符文掉落
    if dropConfig.runes then
        for _, runeData in ipairs(dropConfig.runes) do
            -- 根据概率判断是否掉落该符文
            if math.random() < runeData.chance then
                -- 确定符文位置
                local position = runeData.position
                if position == "random" then
                    position = math.random(1, 6)  -- 随机选择一个位置
                end
                
                -- 创建符文
                local rune = Item:newRune(runeData.set, position, runeData.quality, x, y)
                table.insert(drops, rune)
            end
        end
    end
    
    -- 处理卡牌掉落（保留原有逻辑）
    local cardChance = 0.2  -- 默认掉落概率
    if math.random() < cardChance then
        -- 使用配置文件中的映射表获取建筑卡牌类型
        local buildingCardType = ItemConfig.MONSTER_TO_CARD_TYPE[monsterType]
        
        if buildingCardType then
            local card = {
                isCard = true,
                buildingCardType = buildingCardType
            }
            table.insert(drops, card)
        end
    end
    
    return drops
end

return {
    Item = Item,
    ITEM_TYPES = ItemConfig.ITEM_TYPES,
    RUNE_POSITIONS = ItemConfig.RUNE_POSITIONS,
    RUNE_SET_TYPES = ItemConfig.RUNE_SET_TYPES,
    RUNE_QUALITY = ItemConfig.RUNE_QUALITY,
    MONSTER_TIERS = ItemConfig.MONSTER_TIERS,
    CARD_LEVEL_REQUIREMENTS = ItemConfig.CARD_LEVEL_REQUIREMENTS
} 