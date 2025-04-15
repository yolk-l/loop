-- 角色界面
local CharacterUI = {}
CharacterUI.__index = CharacterUI

-- 字体缓存

-- 初始化字体
local function initFonts(fonts)
    if not fonts.title then
        fonts.title = love.graphics.newFont("assets/fonts/simsun.ttc", 16)
        fonts.normal = love.graphics.newFont("assets/fonts/simsun.ttc", 14)
        fonts.description = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function CharacterUI.new()
    local self = setmetatable({}, CharacterUI)
    self.visible = false    -- 界面是否可见
    self.width = 600        -- 界面宽度，从500增加到600
    self.height = 600       -- 界面高度，从500增加到600
    self.x = 100            -- 界面位置X，调整位置
    self.y = 100            -- 界面位置Y，调整位置
    -- 添加字体引用
    self.fonts = {
        title = nil,
        normal = nil,
        description = nil
    }
    initFonts(self.fonts)
    return self
end

function CharacterUI:toggleVisibility()
    self.visible = not self.visible
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
    love.graphics.setFont(self.fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("角色信息", self.x + 20, self.y + 15)
    
    -- 获取玩家模型数据
    local playerModel = player:getModel()
    
    -- 绘制角色属性，改为3列显示，更紧凑
    love.graphics.setFont(self.fonts.normal)
    local statsX = self.x + 30
    local statsY = self.y + 50
    local statsList = {
        {"等级", playerModel.attributes.level},
        {"经验", playerModel.attributes.exp .. "/" .. playerModel.attributes.nextLevelExp},
        {"生命", math.floor(playerModel.attributes.hp) .. "/" .. math.floor(playerModel.attributes.maxHp)},
        {"攻击", math.floor(playerModel.attributes.attack)},
        {"防御", math.floor(playerModel.attributes.defense)},
        {"速度", math.floor(playerModel.attributes.speed)},
        {"暴击率", playerModel.attributes.critRate .. "%"},
        {"暴击伤害", playerModel.attributes.critDamage .. "%"},
        {"命中率", playerModel.attributes.accuracy .. "%"},
        {"抵抗", playerModel.attributes.resistance .. "%"}
    }
    
    -- 改为每行4个属性，更紧凑排布
    for i, stat in ipairs(statsList) do
        local col = math.floor((i - 1) / 4)
        local row = (i - 1) % 4
        love.graphics.print(stat[1] .. ": " .. stat[2], statsX + col * 150, statsY + row * 20)
    end
    -- 绘制背包，调整位置以适应更大的背包
    if inventoryController then
        inventoryController:draw(self.x + 80, self.y + 370)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return CharacterUI 