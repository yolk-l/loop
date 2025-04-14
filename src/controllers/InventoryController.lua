-- 背包控制器
local InventoryController = {}
InventoryController.__index = InventoryController

-- 引入模型和视图
local InventoryModel = require('src/models/InventoryModel')
local InventoryView = require('src/views/InventoryView')

function InventoryController:new()
    local self = setmetatable({}, InventoryController)
    self.model = InventoryModel:new(10)  -- 创建10格的背包
    self.view = InventoryView:new()
    self.x = 0
    self.y = 0
    self.items = {}  -- 初始化物品列表
    return self
end

function InventoryController:addItem(item)
    return self.model:addItem(item)
end

function InventoryController:removeItem(index)
    return self.model:removeItem(index)
end

function InventoryController:getSelectedItem()
    return self.model:getSelectedItem()
end

function InventoryController:handleMouseClick(mx, my)
    local slotIndex = self.view:getSlotAtPosition(mx, my, self.x, self.y)
    if slotIndex then
        self.model:selectItem(slotIndex)
        return true
    end
    return false
end

function InventoryController:draw(x, y)
    self.x = x or self.x
    self.y = y or self.y
    self.view:draw(self.model.items, self.model.selected, self.x, self.y)
end

function InventoryController:pickupItems(player, items)
    if type(items) ~= 'table' then
        print('Error: items is not a table')
        return
    end
    for i = #items, 1, -1 do
        local item = items[i]
        if item:isInRange(player.x, player.y) then
            -- 将物品添加到背包
            if self:addItem(item) then
                table.remove(items, i)
            end
        end
    end
end

function InventoryController:drawItems()
    for _, item in ipairs(self.items) do
        item:draw()
    end
end

function InventoryController:addGroundItem(item)
    table.insert(self.items, item)
end

function InventoryController:updateItems(player)
    self:pickupItems(player, self.items)
end

function InventoryController:isOpen()
    return self.view.visible  -- 假设 view 有一个 visible 属性来表示可见性
end

return InventoryController 