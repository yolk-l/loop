-- 建筑管理器
-- 用于管理所有建筑实例，符合MVC架构
local BuildingManager = {}
BuildingManager.__index = BuildingManager

local BuildingController = require('src/controllers/BuildingController')

function BuildingManager.new()
    local self = setmetatable({}, BuildingManager)
    self.buildingInstances = {}  -- 所有建筑实例
    return self
end

-- 创建新建筑
function BuildingManager:createBuilding(type, x, y)
    local building = BuildingController.new(type, x, y)
    table.insert(self.buildingInstances, building)
    return building
end

-- 更新所有建筑
function BuildingManager:updateAll(dt, player)
    for i = #self.buildingInstances, 1, -1 do
        local instance = self.buildingInstances[i]
        instance:update(dt, player)
        
        -- 移除已死亡的建筑
        if instance:isDead() then
            table.remove(self.buildingInstances, i)
        end
    end
end

-- 绘制所有建筑实例
function BuildingManager:drawAll()
    for _, instance in ipairs(self.buildingInstances) do
        instance:draw()
    end
end

-- 获取所有建筑实例
function BuildingManager:getInstances()
    return self.buildingInstances
end

-- 获取建筑数量
function BuildingManager:getCount()
    return #self.buildingInstances
end

-- 清除所有建筑
function BuildingManager:clearAll()
    self.buildingInstances = {}
end

-- 根据类型获取特定的建筑
function BuildingManager:getBuildingsByType(buildingType)
    local result = {}
    for _, building in ipairs(self.buildingInstances) do
        if building:getModel():getType() == buildingType then
            table.insert(result, building)
        end
    end
    return result
end

-- 检查是否有建筑存在于特定位置
function BuildingManager:hasBuildingAt(x, y, radius)
    radius = radius or 20  -- 默认检测半径
    
    for _, building in ipairs(self.buildingInstances) do
        local pos = building:getPosition()
        local dx = pos.x - x
        local dy = pos.y - y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= radius then
            return true, building
        end
    end
    
    return false, nil
end

-- 检查是否可以在指定位置放置建筑
function BuildingManager:canPlaceBuildingAt(x, y, buildingType, mapModel)
    -- 检查地图是否允许在该位置建筑
    if not mapModel:getTerrainAt(x, y) then
        return false -- 不在地图范围内
    end
    
    -- 调用地图控制器的方法检查地形是否适合建造
    local mapController = require('src/controllers/MapController').new()
    if not mapController:canBuildAt(x, y, buildingType) then
        return false -- 地形不适合建造
    end
    
    -- 检查是否已有建筑存在于该位置
    local hasBuildingAtLocation, _ = self:hasBuildingAt(x, y, 30)
    if hasBuildingAtLocation then
        return false -- 位置已被占用
    end
    
    return true -- 可以在该位置建造
end

return BuildingManager 