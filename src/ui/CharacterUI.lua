-- 角色界面
local CharacterUI = {}
CharacterUI.__index = CharacterUI

-- 引入配置
local ItemConfig = require('config/items')

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
    self.width = 600        -- 界面宽度，从500增加到600
    self.height = 600       -- 界面高度，从500增加到600
    self.x = 100            -- 界面位置X，调整位置
    self.y = 100            -- 界面位置Y，调整位置
    
    -- 符文槽位置，更紧凑排列
    self.runeSlots = {
        -- 右侧三个符文槽
        [1] = { -- 右上
            x = self.x + self.width - 90,
            y = self.y + 150,
            width = 50,
            height = 50
        },
        [2] = { -- 右中
            x = self.x + self.width - 90,
            y = self.y + 210,
            width = 50,
            height = 50
        },
        [3] = { -- 右下
            x = self.x + self.width - 90,
            y = self.y + 270,
            width = 50,
            height = 50
        },
        -- 左侧三个符文槽
        [4] = { -- 左上
            x = self.x + 40,
            y = self.y + 150,
            width = 50,
            height = 50
        },
        [5] = { -- 左中
            x = self.x + 40,
            y = self.y + 210,
            width = 50,
            height = 50
        },
        [6] = { -- 左下
            x = self.x + 40,
            y = self.y + 270,
            width = 50,
            height = 50
        }
    }
    
    -- 符文套装效果区域
    self.setEffectArea = {
        x = self.x + 150,
        y = self.y + 150,
        width = 300,
        height = 180
    }
    
    initFonts()
    return self
end

function CharacterUI:toggleVisibility()
    self.visible = not self.visible
end

function CharacterUI:getSlotAt(mx, my)
    return self:getRuneSlotAt(mx, my)
end

function CharacterUI:getRuneSlotAt(mx, my)
    for slotNum, rect in pairs(self.runeSlots) do
        if mx >= rect.x and mx <= rect.x + rect.width and
           my >= rect.y and my <= rect.y + rect.height then
            return slotNum
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
    love.graphics.print("角色信息", self.x + 20, self.y + 15)
    
    -- 绘制角色属性，改为3列显示，更紧凑
    love.graphics.setFont(fonts.normal)
    local statsX = self.x + 30
    local statsY = self.y + 50
    local statsList = {
        {"等级", player.attributes.level},
        {"经验", player.attributes.exp .. "/" .. player.attributes.nextLevelExp},
        {"生命", math.floor(player.attributes.hp) .. "/" .. math.floor(player.attributes.maxHp)},
        {"攻击", math.floor(player.attributes.attack)},
        {"防御", math.floor(player.attributes.defense)},
        {"速度", math.floor(player.attributes.speed)},
        {"暴击率", player.attributes.critRate .. "%"},
        {"暴击伤害", player.attributes.critDamage .. "%"},
        {"命中率", player.attributes.accuracy .. "%"},
        {"抵抗", player.attributes.resistance .. "%"}
    }
    
    -- 改为每行4个属性，更紧凑排布
    for i, stat in ipairs(statsList) do
        local col = math.floor((i - 1) / 4)
        local row = (i - 1) % 4
        love.graphics.print(stat[1] .. ": " .. stat[2], statsX + col * 150, statsY + row * 20)
    end
    
    -- 绘制符文槽
    self:drawRuneSlots(player)
    
    -- 绘制套装效果
    self:drawRuneSetEffects(player)
    
    -- 绘制背包，调整位置以适应更大的背包
    if inventoryController then
        inventoryController:draw(self.x + 80, self.y + 370)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function CharacterUI:drawRuneSlots(player)
    love.graphics.setFont(fonts.normal)
    
    -- 绘制符文区域标题
    love.graphics.print("符文槽", self.x + 20, self.y + 130)
    
    -- 绘制符文槽位
    for position, slot in pairs(self.runeSlots) do
        self:drawRuneSlot(position, slot, player.runes[position])
    end
end

function CharacterUI:drawRuneSlot(position, slot, rune)
    local slotNames = {
        [1] = "右上 - 位置1",
        [2] = "右中 - 位置2",
        [3] = "右下 - 位置3",
        [4] = "左上 - 位置4",
        [5] = "左中 - 位置5",
        [6] = "左下 - 位置6"
    }
    
    local primaryStatTypes = {
        [1] = "固定值",
        [2] = "百分比",
        [3] = "固定值",
        [4] = "暴击",
        [5] = "固定值",
        [6] = "命抵"
    }
    
    -- 绘制槽位背景
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle('fill', slot.x, slot.y, slot.width, slot.height)
    
    -- 绘制槽位边框
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle('line', slot.x, slot.y, slot.width, slot.height)
    
    -- 绘制槽位名称
    love.graphics.setFont(fonts.description)
    love.graphics.setColor(1, 1, 1)
    local nameWidth = fonts.description:getWidth(slotNames[position])
    love.graphics.print(slotNames[position], slot.x + slot.width/2 - nameWidth/2, slot.y - 20)
    
    -- 显示主属性类型提示
    love.graphics.setColor(0.8, 0.8, 0.8, 0.7)
    local typeWidth = fonts.description:getWidth(primaryStatTypes[position])
    love.graphics.print(primaryStatTypes[position], slot.x + slot.width/2 - typeWidth/2, slot.y + slot.height + 5)
    
    -- 显示位置编号，便于用户识别符文位置
    love.graphics.setColor(1, 1, 0.5)
    love.graphics.setFont(fonts.normal)
    love.graphics.print(position, slot.x + slot.width/2 - 5, slot.y + slot.height/2 - 6)
    
    -- 如果有符文，绘制符文信息
    if rune then
        -- 绘制符文底色（套装颜色）
        love.graphics.setColor(unpack(rune.color))
        love.graphics.circle('fill', slot.x + slot.width/2, slot.y + slot.height/2, 20)
        
        -- 绘制品质边框
        love.graphics.setColor(unpack(rune.qualityColor))
        love.graphics.setLineWidth(2)
        love.graphics.circle('line', slot.x + slot.width/2, slot.y + slot.height/2, 20)
        
        -- 绘制符文位置标记
        local posMarks = {"↗", "→", "↘", "↖", "←", "↙"}  -- 使用箭头表示位置
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fonts.normal)
        love.graphics.print(posMarks[rune.position], slot.x + slot.width/2 - 5, slot.y + slot.height/2 - 6)
        
        -- 绘制符文名称
        love.graphics.setFont(fonts.description)
        love.graphics.setColor(unpack(rune.qualityColor))
        local runeNameWidth = fonts.description:getWidth(rune.name)
        love.graphics.print(rune.name, slot.x + slot.width/2 - runeNameWidth/2, slot.y + slot.height + 20)
    end
end

function CharacterUI:drawRuneSetEffects(player)
    if #player.activeRuneSets == 0 then return end
    
    love.graphics.setFont(fonts.normal)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("激活套装效果:", self.setEffectArea.x, self.setEffectArea.y)
    
    -- 绘制套装效果列表
    love.graphics.setFont(fonts.description)
    for i, setEffect in ipairs(player.activeRuneSets) do
        -- 绘制套装名称和效果
        love.graphics.setColor(0.8, 0.8, 0.2)  -- 金色
        love.graphics.print(setEffect.name .. "套装:", self.setEffectArea.x, self.setEffectArea.y + 25 + (i-1) * 40)
        
        -- 描述套装效果
        love.graphics.setColor(1, 1, 1)
        local effectDesc = self:getSetEffectDescription(setEffect.effect)
        love.graphics.print(effectDesc, self.setEffectArea.x + 10, self.setEffectArea.y + 40 + (i-1) * 40)
    end
end

function CharacterUI:getSetEffectDescription(effect)
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

return CharacterUI 