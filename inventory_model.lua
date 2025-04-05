local InventoryModel = {}
InventoryModel.__index = InventoryModel

-- 背包配置
InventoryModel.MAX_ITEMS = 20

function InventoryModel:new()
    local self = setmetatable({}, InventoryModel)
    self.items = {}
    self.selected = nil
    return self
end

function InventoryModel:addItem(item)
    if #self.items >= InventoryModel.MAX_ITEMS then
        return false
    end
    table.insert(self.items, item)
    return true
end

function InventoryModel:removeItem(index)
    if index and index > 0 and index <= #self.items then
        table.remove(self.items, index)
        if self.selected == index then
            self.selected = nil
        elseif self.selected and self.selected > index then
            self.selected = self.selected - 1
        end
        return true
    end
    return false
end

function InventoryModel:getItem(index)
    return self.items[index]
end

return InventoryModel 