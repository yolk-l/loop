local InventoryController = {}
InventoryController.__index = InventoryController

-- 引入模型和视图
local InventoryModel = require('inventory_model')
local InventoryView = require('inventory_view')

function InventoryController:new()
    local self = setmetatable({}, InventoryController)
    self.model = InventoryModel:new()
    self.view = InventoryView:new()
    return self
end

function InventoryController:addItem(item)
    return self.model:addItem(item)
end

function InventoryController:removeItem(index)
    return self.model:removeItem(index)
end

function InventoryController:getSelectedItem()
    if self.model.selected then
        return self.model:getItem(self.model.selected)
    end
    return nil
end

function InventoryController:handleMouseClick(x, y)
    -- 检查是否在背包区域内
    if x < InventoryView.START_X or x > InventoryView.START_X + InventoryView.ITEMS_PER_ROW * (InventoryView.ITEM_SIZE + InventoryView.PADDING) or
       y < InventoryView.START_Y or y > InventoryView.START_Y + math.ceil(#self.model.items / InventoryView.ITEMS_PER_ROW) * (InventoryView.ITEM_SIZE + InventoryView.PADDING) then
        return false
    end
    
    -- 计算点击的物品索引
    local col = math.floor((x - InventoryView.START_X) / (InventoryView.ITEM_SIZE + InventoryView.PADDING))
    local row = math.floor((y - InventoryView.START_Y) / (InventoryView.ITEM_SIZE + InventoryView.PADDING))
    local index = row * InventoryView.ITEMS_PER_ROW + col + 1
    
    if index > 0 and index <= #self.model.items then
        -- 选中或取消选中物品
        if self.model.selected == index then
            self.model.selected = nil
        else
            self.model.selected = index
        end
        return true
    end
    return false
end

function InventoryController:draw()
    self.view:drawInventory(self.model)
end

return InventoryController 