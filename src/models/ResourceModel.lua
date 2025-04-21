-- 资源模型
local ResourceModel = {}
ResourceModel.__index = ResourceModel

-- 资源类型
ResourceModel.TYPES = {
    WOOD = "wood",         -- 木材 (山脉/森林)
    FOOD = "food",         -- 食物 (草地)
    FISH = "fish",         -- 鱼类 (水域)
    STONE = "stone",       -- 石头和沙子 (沙地)
}

-- 初始化资源模型
function ResourceModel.new()
    local self = setmetatable({}, ResourceModel)
    
    -- 初始化资源
    self.resources = {
        [ResourceModel.TYPES.WOOD] = 0,
        [ResourceModel.TYPES.FOOD] = 0,
        [ResourceModel.TYPES.FISH] = 0,
        [ResourceModel.TYPES.STONE] = 0,
    }
    
    -- 资源收集冷却时间
    self.collectCooldown = {
        [ResourceModel.TYPES.WOOD] = 0,
        [ResourceModel.TYPES.FOOD] = 0,
        [ResourceModel.TYPES.FISH] = 0,
        [ResourceModel.TYPES.STONE] = 0,
    }
    
    -- 采集配置
    self.collectConfig = {
        -- 资源类型 => {冷却时间, 每次收集量, 最大量}
        [ResourceModel.TYPES.WOOD] = {cooldown = 3, amount = 1, maxAmount = 100},
        [ResourceModel.TYPES.FOOD] = {cooldown = 2, amount = 1, maxAmount = 100},
        [ResourceModel.TYPES.FISH] = {cooldown = 4, amount = 1, maxAmount = 100},
        [ResourceModel.TYPES.STONE] = {cooldown = 5, amount = 1, maxAmount = 100},
    }
    
    return self
end

-- 更新资源冷却时间
function ResourceModel:update(dt)
    for type, cooldown in pairs(self.collectCooldown) do
        if cooldown > 0 then
            self.collectCooldown[type] = cooldown - dt
            if self.collectCooldown[type] < 0 then
                self.collectCooldown[type] = 0
            end
        end
    end
end

-- 收集资源
function ResourceModel:collect(resourceType)
    -- 检查冷却时间
    if self.collectCooldown[resourceType] > 0 then
        return false
    end
    
    -- 检查是否达到最大值
    if self.resources[resourceType] >= self.collectConfig[resourceType].maxAmount then
        return false
    end
    
    -- 增加资源
    self.resources[resourceType] = self.resources[resourceType] + self.collectConfig[resourceType].amount
    
    -- 设置冷却时间
    self.collectCooldown[resourceType] = self.collectConfig[resourceType].cooldown
    
    return true
end

-- 消耗资源
function ResourceModel:consume(resourceType, amount)
    if self.resources[resourceType] >= amount then
        self.resources[resourceType] = self.resources[resourceType] - amount
        return true
    end
    return false
end

-- 获取资源数量
function ResourceModel:getAmount(resourceType)
    return self.resources[resourceType]
end

-- 获取所有资源
function ResourceModel:getAllResources()
    return self.resources
end

-- 获取某个资源的采集冷却状态
function ResourceModel:getCollectCooldown(resourceType)
    return self.collectCooldown[resourceType]
end

return ResourceModel 