-- 角色界面系统
local CharacterUI = {}
CharacterUI.__index = CharacterUI

-- 字体缓存
local fonts = {
    title = nil,
    normal = nil,
    description = nil
}

-- 装备槽配置
local SLOT_CONFIG = {
    weapon = {x = 300, y = 100, width = 50, height = 50},
    armor = {x = 300, y = 160, width = 50, height = 50},
    accessory = {x = 300, y = 220, width = 50, height = 50}
}

-- 初始化字体
local function initFonts()
    if not fonts.title then
        fonts.title = love.graphics.newFont("assets/fonts/simsun.ttc", 16)
        fonts.normal = love.graphics.newFont("assets/fonts/simsun.ttc", 14)
        fonts.description = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function CharacterUI:new()
    local self = setmetatable({}, CharacterUI)
    self.visible = false
    
    -- 界面配置
    self.ui = {
        x = 50,  -- 角色界面位置
        y = 50,
        width = 700,  -- 增加宽度以容纳装备栏
        height = 500,
        slotSize = 50,  -- 装备槽大小
        padding = 10,    -- 间距
        equipmentPanelX = 450  -- 装备面板起始位置
    }
    
    initFonts()
    return self
end

function CharacterUI:toggleVisibility()
    self.visible = not self.visible
end

function CharacterUI:getSlotAt(x, y)
    if not self.visible then return nil end
    
    for slot, config in pairs(SLOT_CONFIG) do
        if x >= config.x and x <= config.x + config.width and
           y >= config.y and y <= config.y + config.height then
            return slot
        end
    end
    return nil
end

function CharacterUI:draw(player, inventoryController)
    if not self.visible then return end
    
    -- 绘制背景
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle('fill', self.ui.x, self.ui.y, self.ui.width, self.ui.height)
    
    -- 绘制标题
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("角色与装备", self.ui.x + 10, self.ui.y + 10)
    
    -- 绘制角色属性
    love.graphics.setFont(fonts.normal)
    local statsX = self.ui.x + 20
    local statsY = self.ui.y + 50
    local actualAttrs = player:getActualAttributes()
    
    -- 基础属性
    love.graphics.print(string.format("等级: %d", player.attributes.level), statsX, statsY)
    love.graphics.print(string.format("经验: %d/%d", player.attributes.exp, player.attributes.nextLevelExp), 
        statsX, statsY + 25)
    
    -- 战斗属性
    love.graphics.print(string.format("生命: %d/%d", player.attributes.hp, actualAttrs.maxHp), 
        statsX, statsY + 60)
    love.graphics.print(string.format("攻击: %d (+%d)", player.attributes.attack, 
        actualAttrs.attack - player.attributes.attack), statsX, statsY + 85)
    love.graphics.print(string.format("防御: %d (+%d)", player.attributes.defense, 
        actualAttrs.defense - player.attributes.defense), statsX, statsY + 110)
    love.graphics.print(string.format("速度: %d (+%d)", player.attributes.speed, 
        actualAttrs.speed - player.attributes.speed), statsX, statsY + 135)
    
    -- 绘制装备槽标题
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("装备栏", SLOT_CONFIG.weapon.x, SLOT_CONFIG.weapon.y - 30)
    
    -- 绘制装备槽
    for slot, config in pairs(SLOT_CONFIG) do
        -- 绘制槽位背景
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle('fill', config.x, config.y, config.width, config.height)
        
        -- 绘制槽位边框
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle('line', config.x, config.y, config.width, config.height)
        
        -- 绘制槽位名称
        love.graphics.setColor(1, 1, 1)
        local slotName = ""
        if slot == "weapon" then slotName = "武器"
        elseif slot == "armor" then slotName = "护甲"
        elseif slot == "accessory" then slotName = "饰品" end
        love.graphics.print(slotName, config.x + 5, config.y + 5)
        
        -- 绘制已装备的物品
        if player.equipment[slot] then
            local item = player.equipment[slot]
            if item.config then
                love.graphics.setColor(item.config.color or {0.5, 0.5, 0.5})
                love.graphics.rectangle('fill', config.x + 5, config.y + 20, 
                    config.width - 10, config.height - 25)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(item.config.name, config.x + 5, config.y + 25)
            end
        end
    end
    
    -- 绘制背包
    inventoryController:draw()
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return CharacterUI 