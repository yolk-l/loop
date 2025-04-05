local InventoryView = {}
InventoryView.__index = InventoryView

-- 背包显示配置
InventoryView.ITEM_SIZE = 50
InventoryView.ITEMS_PER_ROW = 5
InventoryView.PADDING = 10
InventoryView.START_X = 400
InventoryView.START_Y = 250  -- 调整背包起始位置，避免与装备栏重叠

function InventoryView:new()
    local self = setmetatable({}, InventoryView)
    return self
end

function InventoryView:drawItem(item, x, y, isSelected)
    if not item or not item.config then return end
    
    -- 绘制物品背景
    love.graphics.setColor(item.config.color or {0.5, 0.5, 0.5})
    love.graphics.rectangle('fill', x, y, InventoryView.ITEM_SIZE, InventoryView.ITEM_SIZE)
    
    -- 绘制物品边框
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('line', x, y, InventoryView.ITEM_SIZE, InventoryView.ITEM_SIZE)
    
    -- 如果物品被选中，绘制选中效果
    if isSelected then
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.rectangle('fill', x, y, InventoryView.ITEM_SIZE, InventoryView.ITEM_SIZE)
    end
    
    -- 绘制物品名称
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(item.config.name, x + 5, y + 5)
end

function InventoryView:drawInventory(model)
    -- 绘制背包背景
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    local width = InventoryView.ITEMS_PER_ROW * (InventoryView.ITEM_SIZE + InventoryView.PADDING) + InventoryView.PADDING
    local height = math.ceil(#model.items / InventoryView.ITEMS_PER_ROW) * (InventoryView.ITEM_SIZE + InventoryView.PADDING) + InventoryView.PADDING
    love.graphics.rectangle('fill', InventoryView.START_X - InventoryView.PADDING, 
        InventoryView.START_Y - InventoryView.PADDING, width, height)
    
    -- 绘制背包标题
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("背包", InventoryView.START_X, InventoryView.START_Y - 30)
    
    -- 绘制所有物品
    for i, item in ipairs(model.items) do
        local row = math.floor((i-1) / InventoryView.ITEMS_PER_ROW)
        local col = (i-1) % InventoryView.ITEMS_PER_ROW
        local x = InventoryView.START_X + col * (InventoryView.ITEM_SIZE + InventoryView.PADDING)
        local y = InventoryView.START_Y + row * (InventoryView.ITEM_SIZE + InventoryView.PADDING)
        
        self:drawItem(item, x, y, i == model.selected)
    end
end

return InventoryView 