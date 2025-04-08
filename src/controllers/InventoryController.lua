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

return InventoryController 