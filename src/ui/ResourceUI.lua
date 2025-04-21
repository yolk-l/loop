-- 资源UI
local ResourceUI = {}
ResourceUI.__index = ResourceUI

local ResourceModel = require('src/models/ResourceModel')

-- 资源图标（简单使用文本表示）
ResourceUI.ICONS = {
    [ResourceModel.TYPES.WOOD] = "🪵", -- 木材
    [ResourceModel.TYPES.FOOD] = "🌾", -- 食物
    [ResourceModel.TYPES.FISH] = "🐟", -- 鱼类
    [ResourceModel.TYPES.STONE] = "🪨", -- 石头
}

-- 创建资源UI
function ResourceUI.new()
    local self = setmetatable({}, ResourceUI)
    self.visible = true
    return self
end

-- 绘制资源UI
function ResourceUI:draw(player)
    if not self.visible or not player then return end
    
    -- 获取资源
    local resources = player:getResources()
    if not resources then return end
    
    -- 字体设置
    local font = love.graphics.getFont()
    local lineHeight = font:getHeight() + 5
    
    -- 设置绘制位置（右上角）
    local screenWidth = love.graphics.getWidth()
    local x = screenWidth - 150
    local y = 10
    
    -- 绘制背景
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x - 10, y - 5, 140, #ResourceModel.TYPES * lineHeight + 10)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", x - 10, y - 5, 140, #ResourceModel.TYPES * lineHeight + 10)
    
    -- 绘制标题
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("资源", x + 45, y)
    y = y + lineHeight
    
    -- 绘制各类资源
    for resourceType, amount in pairs(resources) do
        local icon = ResourceUI.ICONS[resourceType] or "?"
        local color = {1, 1, 1, 1} -- 默认白色
        
        -- 根据资源类型设置颜色
        if resourceType == ResourceModel.TYPES.WOOD then
            color = {0.6, 0.3, 0.1, 1} -- 棕色
        elseif resourceType == ResourceModel.TYPES.FOOD then
            color = {0.1, 0.8, 0.1, 1} -- 绿色
        elseif resourceType == ResourceModel.TYPES.FISH then
            color = {0.1, 0.5, 0.9, 1} -- 蓝色
        elseif resourceType == ResourceModel.TYPES.STONE then
            color = {0.7, 0.7, 0.7, 1} -- 灰色
        end
        
        -- 设置颜色绘制图标
        love.graphics.setColor(color)
        love.graphics.print(icon, x, y)
        
        -- 绘制资源类型名称和数量
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(resourceType .. ": " .. amount, x + 30, y)
        
        y = y + lineHeight
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 切换可见性
function ResourceUI:toggleVisibility()
    self.visible = not self.visible
end

return ResourceUI 