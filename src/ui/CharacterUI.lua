-- 角色界面
local CharacterUI = {}
CharacterUI.__index = CharacterUI

-- 字体缓存
local fonts = {
    title = nil,
    normal = nil,
    description = nil
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
    self.visible = false    -- 界面是否可见
    self.width = 500        -- 界面宽度
    self.height = 400       -- 界面高度
    self.x = 150            -- 界面位置X
    self.y = 150            -- 界面位置Y
    
    -- 装备栏位置
    self.slots = {
        weapon = {
            x = self.x + 50,
            y = self.y + 200,
            width = 60,
            height = 60
        },
        armor = {
            x = self.x + self.width/2 - 30,
            y = self.y + 200,
            width = 60,
            height = 60
        },
        accessory = {
            x = self.x + self.width - 110,
            y = self.y + 200,
            width = 60,
            height = 60
        }
    }
    
    initFonts()
    return self
end

function CharacterUI:toggleVisibility()
    self.visible = not self.visible
end

function CharacterUI:getSlotAt(mx, my)
    for slot, rect in pairs(self.slots) do
        if mx >= rect.x and mx <= rect.x + rect.width and
           my >= rect.y and my <= rect.y + rect.height then
            return slot
        end
    end
    return nil
end

function CharacterUI:draw(player, inventoryController)
    if not self.visible then return end
    
    -- 绘制背景
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    -- 绘制边框
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    
    -- 绘制标题
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("角色信息", self.x + 20, self.y + 20)
    
    -- 绘制角色属性
    love.graphics.setFont(fonts.normal)
    local statsX = self.x + 30
    local statsY = self.y + 60
    local statsList = {
        {"等级", player.attributes.level},
        {"经验", player.attributes.exp .. "/" .. player.attributes.nextLevelExp},
        {"生命", player.attributes.hp .. "/" .. player.attributes.maxHp},
        {"攻击", player.attributes.attack},
        {"防御", player.attributes.defense},
        {"速度", player.attributes.speed}
    }
    
    for i, stat in ipairs(statsList) do
        love.graphics.print(stat[1] .. ": " .. stat[2], statsX, statsY + (i-1) * 25)
    end
    
    -- 绘制装备槽
    self:drawEquipmentSlots(player)
    
    -- 绘制背包
    if inventoryController then
        inventoryController:draw(self.x + 50, self.y + 280)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function CharacterUI:drawEquipmentSlots(player)
    love.graphics.setFont(fonts.normal)
    
    -- 绘制装备区域标题
    love.graphics.print("装备", self.x + 20, self.y + 170)
    
    -- 绘制武器槽
    self:drawEquipmentSlot("武器", self.slots.weapon, player.equipment.weapon)
    
    -- 绘制护甲槽
    self:drawEquipmentSlot("护甲", self.slots.armor, player.equipment.armor)
    
    -- 绘制饰品槽
    self:drawEquipmentSlot("饰品", self.slots.accessory, player.equipment.accessory)
end

function CharacterUI:drawEquipmentSlot(name, slot, equipment)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('fill', slot.x, slot.y, slot.width, slot.height)
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle('line', slot.x, slot.y, slot.width, slot.height)
    
    -- 绘制槽位名称
    love.graphics.setFont(fonts.description)
    love.graphics.setColor(1, 1, 1)
    local nameWidth = fonts.description:getWidth(name)
    love.graphics.print(name, slot.x + slot.width/2 - nameWidth/2, slot.y - 20)
    
    -- 如果有装备，绘制装备信息
    if equipment then
        love.graphics.setColor(1, 1, 1)  -- 设置为白色以正常显示图像
        
        -- 获取装备图像
        local AnimationSystem = require('src/systems/Animation')
        local image = nil
        
        -- 根据装备类型获取对应图像
        if equipment.config.image then
            image = AnimationSystem.getWeaponImage(equipment.config.image)
        end
        
        if image then
            -- 居中绘制图像
            local scale = 2  -- 缩放比例，根据需要调整
            local imgWidth, imgHeight = image:getDimensions()
            local x = slot.x + slot.width/2 - (imgWidth * scale)/2
            local y = slot.y + slot.height/2 - (imgHeight * scale)/2
            
            love.graphics.draw(image, x, y, 0, scale, scale)
        else
            -- 如果没有图像，退回到原来的圆形显示
            love.graphics.setColor(equipment.config.color)
            love.graphics.circle('fill', slot.x + slot.width/2, slot.y + slot.height/2, 20)
            
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.circle('line', slot.x + slot.width/2, slot.y + slot.height/2, 20)
        end
        
        -- 绘制装备名称
        love.graphics.setFont(fonts.description)
        love.graphics.setColor(1, 1, 1)
        local nameWidth = fonts.description:getWidth(equipment.config.name)
        love.graphics.print(equipment.config.name, slot.x + slot.width/2 - nameWidth/2, slot.y + slot.height + 5)
    end
end

return CharacterUI 