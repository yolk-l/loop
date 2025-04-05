-- 背包系统
local Inventory = {}
Inventory.__index = Inventory

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

function Inventory:new()
    local self = setmetatable({}, Inventory)
    self.items = {}  -- 存储装备
    self.maxSize = 20  -- 背包最大容量
    self.selected = nil  -- 当前选中的物品索引
    self.visible = false  -- 背包是否可见
    
    -- 背包UI配置
    self.ui = {
        x = 450,  -- 修改背包位置到角色界面右侧
        y = 50,
        width = 300,  -- 增加背包宽度
        height = 400,
        slotSize = 40,  -- 每个格子的大小
        padding = 5,    -- 格子间距
        columns = 4     -- 每行显示的格子数
    }
    
    initFonts()
    return self
end

function Inventory:addItem(item)
    if #self.items >= self.maxSize then
        return false
    end
    table.insert(self.items, item)
    return true
end

function Inventory:removeItem(index)
    if index <= #self.items then
        return table.remove(self.items, index)
    end
    return nil
end

function Inventory:toggleVisibility()
    self.visible = not self.visible
end

function Inventory:getItemAt(x, y)
    if not self.visible then return nil end
    
    -- 背包内容区域从标题下方开始
    local contentY = self.ui.y + 40  -- 减小标题区域的高度
    
    -- 计算相对于背包内容区域的坐标
    local relX = x - self.ui.x
    local relY = y - contentY
    
    -- 背包格子配置
    local slotSize = self.ui.slotSize
    local padding = self.ui.padding
    local columns = self.ui.columns
    
    -- 计算背包内容区域的大小
    local contentWidth = columns * (slotSize + padding) - padding
    local rows = math.ceil(self.maxSize / columns)
    local contentHeight = rows * (slotSize + padding) - padding
    
    -- 检查是否在背包内容区域内
    if relX < 0 or relX > contentWidth or 
       relY < 0 or relY > contentHeight then
        return nil
    end
    
    -- 计算格子索引
    local col = math.floor(relX / (slotSize + padding))
    local row = math.floor(relY / (slotSize + padding))
    local index = row * columns + col + 1
    
    if index <= #self.items then
        return index, self.items[index]
    end
    return nil
end

function Inventory:draw()
    if not self.visible then return end
    
    -- 绘制背包标题
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("背包", self.ui.x, self.ui.y + 10)
    
    -- 绘制物品格子
    local contentY = self.ui.y + 40  -- 从标题下方开始绘制格子
    local slotSize = self.ui.slotSize
    local padding = self.ui.padding
    local columns = self.ui.columns
    
    for i = 1, self.maxSize do
        local col = (i-1) % columns
        local row = math.floor((i-1) / columns)
        local x = self.ui.x + col * (slotSize + padding)
        local y = contentY + row * (slotSize + padding)
        
        -- 绘制格子背景
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle('line', x, y, slotSize, slotSize)
        
        -- 如果格子中有物品，绘制物品
        if self.items[i] then
            local item = self.items[i]
            -- 绘制物品颜色块
            love.graphics.setColor(unpack(item.config.color))
            love.graphics.rectangle('fill', x + 2, y + 2, 
                slotSize - 4, slotSize - 4)
            
            -- 如果是选中的物品，绘制高亮边框
            if i == self.selected then
                love.graphics.setColor(1, 1, 0)
                love.graphics.rectangle('line', x, y, slotSize, slotSize)
            end
        end
    end
    
    -- 如果有选中的物品，显示其详细信息
    if self.selected and self.items[self.selected] then
        local item = self.items[self.selected]
        local infoX = self.ui.x
        local infoY = contentY + 250
        
        love.graphics.setFont(fonts.normal)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(item.config.name, infoX, infoY)
        
        love.graphics.setFont(fonts.description)
        love.graphics.print(item.config.description, infoX, infoY + 20)
        
        -- 显示属性加成
        if item.config.attributes then
            local attrY = infoY + 40
            for attr, value in pairs(item.config.attributes) do
                local attrText = string.format("%s: +%d", attr, value)
                love.graphics.print(attrText, infoX, attrY)
                attrY = attrY + 15
            end
        end
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return Inventory 