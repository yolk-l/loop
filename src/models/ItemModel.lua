-- ItemModel类
local ItemModel = {}
ItemModel.__index = ItemModel

-- 引入配置
local ItemConfig = require('config/items')
local Global = require('src/utils/global')

-- 创建新物品模型
function ItemModel:new(x, y)
    local self = setmetatable({}, ItemModel)
    self.id = Global.generateUUID()
    self.x = x or 0
    self.y = y or 0
    self.size = 24  -- 物品默认尺寸
    self.pickupRange = 50  -- 拾取范围
    self.isRune = false
    
    return self
end

-- 创建新符文
function ItemModel:newRune(setType, position, quality, x, y)
    local self = ItemModel:new(x, y)
    
    -- 符文特有属性
    self.isRune = true
    self.setType = setType or ItemConfig.RUNE_SET_TYPES.ENERGY
    self.position = position or ItemConfig.RUNE_POSITIONS.SLOT_1
    self.quality = quality or ItemConfig.RUNE_QUALITY.NORMAL
    self.level = 1
    self.maxLevel = 15
    
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
    
    return self
end

-- 生成符文主属性
function ItemModel:generatePrimaryStat(position, quality)
    local validStats = {}
    
    -- 根据位置决定可能的主属性
    if position == ItemConfig.RUNE_POSITIONS.SLOT_1 then
        -- 1号位只能是固定攻击
        return {
            type = ItemConfig.RUNE_PRIMARY_STATS.ATK_FLAT,
            value = Global.randomRange(
                ItemConfig.RUNE_PRIMARY_STAT_RANGES[ItemConfig.RUNE_PRIMARY_STATS.ATK_FLAT][quality].min,
                ItemConfig.RUNE_PRIMARY_STAT_RANGES[ItemConfig.RUNE_PRIMARY_STATS.ATK_FLAT][quality].max
            )
        }
    elseif position == ItemConfig.RUNE_POSITIONS.SLOT_3 then
        -- 3号位只能是固定防御
        return {
            type = ItemConfig.RUNE_PRIMARY_STATS.DEF_FLAT,
            value = Global.randomRange(
                ItemConfig.RUNE_PRIMARY_STAT_RANGES[ItemConfig.RUNE_PRIMARY_STATS.DEF_FLAT][quality].min,
                ItemConfig.RUNE_PRIMARY_STAT_RANGES[ItemConfig.RUNE_PRIMARY_STATS.DEF_FLAT][quality].max
            )
        }
    elseif position == ItemConfig.RUNE_POSITIONS.SLOT_5 then
        -- 5号位只能是固定生命
        return {
            type = ItemConfig.RUNE_PRIMARY_STATS.HP_FLAT,
            value = Global.randomRange(
                ItemConfig.RUNE_PRIMARY_STAT_RANGES[ItemConfig.RUNE_PRIMARY_STATS.HP_FLAT][quality].min,
                ItemConfig.RUNE_PRIMARY_STAT_RANGES[ItemConfig.RUNE_PRIMARY_STATS.HP_FLAT][quality].max
            )
        }
    elseif position == ItemConfig.RUNE_POSITIONS.SLOT_2 then
        -- 2号位可以是速度、百分比攻击、百分比防御、百分比生命
        validStats = {
            ItemConfig.RUNE_PRIMARY_STATS.SPEED_FLAT,
            ItemConfig.RUNE_PRIMARY_STATS.ATK_PERCENT,
            ItemConfig.RUNE_PRIMARY_STATS.DEF_PERCENT,
            ItemConfig.RUNE_PRIMARY_STATS.HP_PERCENT
        }
    elseif position == ItemConfig.RUNE_POSITIONS.SLOT_4 then
        -- 4号位可以是暴击率、暴击伤害、百分比攻击、百分比防御、百分比生命
        validStats = {
            ItemConfig.RUNE_PRIMARY_STATS.CRIT_RATE,
            ItemConfig.RUNE_PRIMARY_STATS.CRIT_DMG,
            ItemConfig.RUNE_PRIMARY_STATS.ATK_PERCENT,
            ItemConfig.RUNE_PRIMARY_STATS.DEF_PERCENT,
            ItemConfig.RUNE_PRIMARY_STATS.HP_PERCENT
        }
    elseif position == ItemConfig.RUNE_POSITIONS.SLOT_6 then
        -- 6号位可以是命中率、抵抗、百分比攻击、百分比防御、百分比生命
        validStats = {
            ItemConfig.RUNE_PRIMARY_STATS.ACCURACY,
            ItemConfig.RUNE_PRIMARY_STATS.RESISTANCE,
            ItemConfig.RUNE_PRIMARY_STATS.ATK_PERCENT,
            ItemConfig.RUNE_PRIMARY_STATS.DEF_PERCENT,
            ItemConfig.RUNE_PRIMARY_STATS.HP_PERCENT
        }
    end
    
    -- 随机选择一个主属性
    local statType = validStats[Global.randomRange(1, #validStats)]
    
    return {
        type = statType,
        value = Global.randomRange(
            ItemConfig.RUNE_PRIMARY_STAT_RANGES[statType][quality].min,
            ItemConfig.RUNE_PRIMARY_STAT_RANGES[statType][quality].max
        )
    }
end

-- 生成符文次属性
function ItemModel:generateSubStats(quality)
    local subStats = {}
    
    -- 根据品质决定次属性数量
    local statCount = 0
    if quality == ItemConfig.RUNE_QUALITY.NORMAL then
        statCount = 0
    elseif quality == ItemConfig.RUNE_QUALITY.MAGIC then
        statCount = 1
    elseif quality == ItemConfig.RUNE_QUALITY.RARE then
        statCount = 2
    elseif quality == ItemConfig.RUNE_QUALITY.HERO then
        statCount = 3
    elseif quality == ItemConfig.RUNE_QUALITY.LEGEND then
        statCount = 4
    elseif quality == ItemConfig.RUNE_QUALITY.ANCIENT then
        statCount = 4
    end
    
    -- 副属性类型列表
    local possibleTypes = {
        ItemConfig.RUNE_SUB_STATS.HP_FLAT,
        ItemConfig.RUNE_SUB_STATS.HP_PERCENT,
        ItemConfig.RUNE_SUB_STATS.ATK_FLAT,
        ItemConfig.RUNE_SUB_STATS.ATK_PERCENT,
        ItemConfig.RUNE_SUB_STATS.DEF_FLAT,
        ItemConfig.RUNE_SUB_STATS.DEF_PERCENT,
        ItemConfig.RUNE_SUB_STATS.SPEED_FLAT,
        ItemConfig.RUNE_SUB_STATS.CRIT_RATE,
        ItemConfig.RUNE_SUB_STATS.CRIT_DMG,
        ItemConfig.RUNE_SUB_STATS.ACCURACY,
        ItemConfig.RUNE_SUB_STATS.RESISTANCE
    }
    
    -- 随机生成副属性
    local selectedTypes = {}
    for i = 1, statCount do
        local statType
        repeat
            local index = Global.randomRange(1, #possibleTypes)
            statType = possibleTypes[index]
        until not selectedTypes[statType]
        
        selectedTypes[statType] = true
        
        local value = 0
        if statType == ItemConfig.RUNE_SUB_STATS.HP_FLAT then
            value = Global.randomRange(30, 100 + 20 * quality)
        elseif statType == ItemConfig.RUNE_SUB_STATS.HP_PERCENT then
            value = Global.randomRange(2, 4 + quality)
        elseif statType == ItemConfig.RUNE_SUB_STATS.ATK_FLAT then
            value = Global.randomRange(2, 5 + quality)
        elseif statType == ItemConfig.RUNE_SUB_STATS.ATK_PERCENT then
            value = Global.randomRange(2, 4 + quality)
        elseif statType == ItemConfig.RUNE_SUB_STATS.DEF_FLAT then
            value = Global.randomRange(2, 5 + quality)
        elseif statType == ItemConfig.RUNE_SUB_STATS.DEF_PERCENT then
            value = Global.randomRange(2, 4 + quality)
        elseif statType == ItemConfig.RUNE_SUB_STATS.SPEED_FLAT then
            value = Global.randomRange(1, 2 + quality // 2)
        elseif statType == ItemConfig.RUNE_SUB_STATS.CRIT_RATE then
            value = Global.randomRange(1, 3 + quality)
        elseif statType == ItemConfig.RUNE_SUB_STATS.CRIT_DMG then
            value = Global.randomRange(2, 4 + quality)
        elseif statType == ItemConfig.RUNE_SUB_STATS.ACCURACY then
            value = Global.randomRange(2, 4 + quality)
        elseif statType == ItemConfig.RUNE_SUB_STATS.RESISTANCE then
            value = Global.randomRange(2, 4 + quality)
        end
        
        table.insert(subStats, {
            type = statType,
            value = value
        })
    end
    
    return subStats
end

-- 检查物品是否在拾取范围内
function ItemModel:isInRange(playerX, playerY)
    local dx = self.x - playerX
    local dy = self.y - playerY
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance <= self.pickupRange
end

-- 创建卡片物品
function ItemModel:newCard(buildingCardType, x, y)
    local self = ItemModel:new(x, y)
    self.isCard = true
    self.buildingCardType = buildingCardType
    return self
end

-- 创建装备物品
function ItemModel:newEquipment(config, x, y)
    local self = ItemModel:new(x, y)
    self.config = config
    self.isEquipment = true
    return self
end

-- 获取符文属性描述（用于提示）
function ItemModel:getRuneDescription()
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
function ItemModel:getSetEffectDescription(effect)
    local typeDescriptions = {
        ["hp_percent"] = "生命值增加",
        ["speed"] = "速度增加",
        ["atk_percent"] = "攻击力增加",
        ["crit_rate"] = "暴击率增加",
        ["accuracy"] = "命中率增加",
        ["def_percent"] = "防御力增加",
        ["resistance"] = "抵抗增加",
        ["counter_attack"] = "反击几率",
        ["extra_turn"] = "额外回合几率",
        ["lifesteal"] = "生命偷取",
        ["immunity"] = "回合开始时获得免疫",
        ["atb_boost"] = "受到伤害时行动条提升",
        ["crit_dmg"] = "暴击伤害增加",
        ["stun_chance"] = "攻击时眩晕几率",
        ["all_stats"] = "所有属性增加"
    }
    
    local description = typeDescriptions[effect.type] or effect.type
    
    if effect.type == "immunity" then
        return description .. " " .. effect.value .. "回合"
    else
        return description .. " " .. effect.value .. "%"
    end
end

-- 获取属性描述
function ItemModel:getStatDescription(stat)
    local typeDescriptions = {
        ["hp_flat"] = "生命值",
        ["hp_percent"] = "生命值",
        ["atk_flat"] = "攻击力",
        ["atk_percent"] = "攻击力",
        ["def_flat"] = "防御力",
        ["def_percent"] = "防御力",
        ["speed_flat"] = "速度",
        ["crit_rate"] = "暴击率",
        ["crit_dmg"] = "暴击伤害",
        ["accuracy"] = "命中率",
        ["resistance"] = "抵抗"
    }
    
    local description = typeDescriptions[stat.type] or stat.type
    
    if string.find(stat.type, "percent") or stat.type == "crit_rate" 
       or stat.type == "crit_dmg" or stat.type == "accuracy" 
       or stat.type == "resistance" then
        return description .. " +" .. stat.value .. "%"
    else
        return description .. " +" .. stat.value
    end
end

return ItemModel 