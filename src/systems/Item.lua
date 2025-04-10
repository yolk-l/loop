-- 物品系统
local Item = {}
Item.__index = Item

-- 引入配置
local ItemConfig = require('config/items')

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
    self.config = ItemConfig.EQUIPMENT_CONFIG[id]
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
    
    -- 根据怪物类型生成不同掉落物
    if monsterType == "slime" then
        -- 10%几率掉落史莱姆巢穴卡牌
        if math.random() < 0.1 then
            local card = {
                isCard = true,
                buildingCardType = 1
            }
            table.insert(drops, card)
        end
        
        -- 5%几率掉落装备
        if math.random() < 0.05 then
            local item = Item:new("weapon", x, y)
            table.insert(drops, item)
        end
    elseif monsterType == "goblin" then
        -- 8%几率掉落哥布林小屋卡牌
        if math.random() < 0.08 then
            local card = {
                isCard = true,
                buildingCardType = 2
            }
            table.insert(drops, card)
        end
        
        -- 10%几率掉落装备
        if math.random() < 0.1 then
            local itemType = math.random(1, 2) == 1 and "weapon" or "armor"
            local item = Item:new(itemType, x, y)
            table.insert(drops, item)
        end
    elseif monsterType == "skeleton" then
        -- 6%几率掉落骷髅墓地卡牌
        if math.random() < 0.06 then
            local card = {
                isCard = true,
                buildingCardType = 3
            }
            table.insert(drops, card)
        end
        
        -- 15%几率掉落装备
        if math.random() < 0.15 then
            local itemType = math.random(1, 3)
            if itemType == 1 then
                local item = Item:new("weapon", x, y)
                table.insert(drops, item)
            elseif itemType == 2 then
                local item = Item:new("armor", x, y)
                table.insert(drops, item)
            else
                local item = Item:new("accessory", x, y)
                table.insert(drops, item)
            end
        end
    elseif monsterType == "zombie" then
        -- 7%几率掉落僵尸墓园卡牌
        if math.random() < 0.07 then
            local card = {
                isCard = true,
                buildingCardType = 4
            }
            table.insert(drops, card)
        end
        
        -- 12%几率掉落装备
        if math.random() < 0.12 then
            local itemType = math.random(1, 2) == 1 and "armor" or "accessory"
            local item = Item:new(itemType, x, y)
            table.insert(drops, item)
        end
    elseif monsterType == "werewolf" then
        -- 6%几率掉落狼人巢穴卡牌
        if math.random() < 0.06 then
            local card = {
                isCard = true,
                buildingCardType = 5
            }
            table.insert(drops, card)
        end
        
        -- 15%几率掉落高级装备
        if math.random() < 0.15 then
            local itemType = math.random(1, 3)
            local item = Item:new(itemType == 1 and "weapon" or itemType == 2 and "armor" or "accessory", x, y)
            item.rarity = math.random(1, 2) == 1 and "rare" or "uncommon"
            table.insert(drops, item)
        end
    elseif monsterType == "ghost" then
        -- 8%几率掉落幽灵庄园卡牌
        if math.random() < 0.08 then
            local card = {
                isCard = true,
                buildingCardType = 6
            }
            table.insert(drops, card)
        end
        
        -- 18%几率掉落幽灵专属装备
        if math.random() < 0.18 then
            local item = Item:new("accessory", x, y)
            item.rarity = "rare"
            table.insert(drops, item)
        end
    elseif monsterType == "golem" then
        -- 5%几率掉落巨人熔炉卡牌
        if math.random() < 0.05 then
            local card = {
                isCard = true,
                buildingCardType = 7
            }
            table.insert(drops, card)
        end
        
        -- 25%几率掉落高级装备
        if math.random() < 0.25 then
            local item = Item:new("armor", x, y)
            item.rarity = "rare"
            table.insert(drops, item)
        end
    elseif monsterType == "witch" then
        -- 6%几率掉落女巫小屋卡牌
        if math.random() < 0.06 then
            local card = {
                isCard = true,
                buildingCardType = 8
            }
            table.insert(drops, card)
        end
        
        -- 20%几率掉落魔法装备
        if math.random() < 0.2 then
            local item = Item:new(math.random(1, 2) == 1 and "weapon" or "accessory", x, y)
            item.rarity = "rare"
            table.insert(drops, item)
        end
    elseif monsterType == "dragon" then
        -- 3%几率掉落龙之洞窟卡牌
        if math.random() < 0.03 then
            local card = {
                isCard = true,
                buildingCardType = 9
            }
            table.insert(drops, card)
        end
        
        -- 40%几率掉落龙级装备
        if math.random() < 0.4 then
            local itemType = math.random(1, 3)
            local item = Item:new(itemType == 1 and "weapon" or itemType == 2 and "armor" or "accessory", x, y)
            item.rarity = "epic"
            table.insert(drops, item)
        end
    end
    
    return drops
end

return {
    Item = Item,
    ITEM_TYPES = ItemConfig.ITEM_TYPES,
    EQUIPMENT_TYPES = ItemConfig.EQUIPMENT_TYPES
} 