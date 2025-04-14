-- 背包模型
local InventoryModel = {}
InventoryModel.__index = InventoryModel

function InventoryModel:new(capacity)
    local self = setmetatable({}, InventoryModel)
    self.items = {}       -- 物品列表
    self.capacity = capacity or 30  -- 默认容量，从20增加到30
    self.selected = nil   -- 当前选中的物品索引
    return self
end

function InventoryModel:addItem(item)
    if #self.items >= self.capacity then
        return false
    end
    
    table.insert(self.items, item)
    return true
end

function InventoryModel:removeItem(index)
    if index and index >= 1 and index <= #self.items then
        table.remove(self.items, index)
        
        -- 如果删除的是被选中的物品，清除选中状态
        if self.selected == index then
            self.selected = nil
        elseif self.selected and self.selected > index then
            -- 调整选中索引
            self.selected = self.selected - 1
        end
        
        return true
    end
    return false
end

function InventoryModel:getItem(index)
    if index and index >= 1 and index <= #self.items then
        return self.items[index]
    end
    return nil
end

function InventoryModel:selectItem(index)
    if index and index >= 1 and index <= #self.items then
        if self.selected == index then
            self.selected = nil  -- 点击已选中的物品取消选择
        else
            self.selected = index
        end
        return true
    elseif not index then
        self.selected = nil
        return true
    end
    return false
end

function InventoryModel:getSelectedItem()
    if self.selected then
        return self.items[self.selected]
    end
    return nil
end

return InventoryModel 