-- 怪物视图
local MonsterView = {}
MonsterView.__index = MonsterView

-- 引入动画系统
local AnimationSystem = require('src/utils/Animation')
local resources = AnimationSystem.getResources()

-- 字体缓存
local monsterFont = nil

-- 初始化字体
local function initFont()
    if not monsterFont then
        monsterFont = love.graphics.newFont("assets/fonts/simsun.ttc", 10)
    end
end

function MonsterView.new()
    initFont()
    local mt = setmetatable({
        animations = {}, -- 存储各个怪物的当前动画
        animationStates = {}, -- 存储各个怪物的当前动画状态
    }, MonsterView)
    return mt
end

-- 添加更新方法，用于更新怪物的动画状态
function MonsterView:update(dt, monsterModel)
    -- 如果怪物已死亡，不更新
    if monsterModel:isDead() then
        return
    end
    
    local monsterId = monsterModel.id
    if self.animations[monsterId] then
        self.animations[monsterId]:update(dt)
    end
end

function MonsterView:draw(monsterModel)
    -- 如果怪物已死亡，不绘制
    if monsterModel:isDead() then
        return
    end
    
    -- 获取必要的模型数据
    local status = monsterModel:getStatus()
    local position = monsterModel:getPosition()
    local config = monsterModel:getConfig()
    local attributes = monsterModel:getAttributes()
    local monsterType = monsterModel:getType()
    local size = monsterModel:getSize()
    local debug = monsterModel:getDebugMode()
    
    -- 获取动画状态
    local animationState
    if status.isAttacking then
        animationState = "attack"
    elseif status.isMoving then
        animationState = "move"
    else
        animationState = "idle"
    end
    
    -- 获取怪物ID
    local monsterId = monsterModel.id
    
    -- 检查是否需要更新动画（状态变化或首次加载）
    if not self.animations[monsterId] or self.animationStates[monsterId] ~= animationState then
        -- 使用正确的获取怪物动画的方法
        self.animations[monsterId] = AnimationSystem.getMonsterAnimation(monsterType, animationState)
        self.animationStates[monsterId] = animationState
    end
    
    -- 获取当前动画
    local animation = self.animations[monsterId]
    
    -- 设置朝向
    local scaleX = 1
    if status.direction == "left" then
        scaleX = -1
    end
    
    -- 绘制怪物
    if animation then
        -- 使用动画
        love.graphics.setColor(1, 1, 1)
        
        -- 获取精灵图
        local spriteImage = resources.images[monsterType] or resources.images.monster
        
        -- 获取精灵图的实际尺寸(每个精灵帧的尺寸是16x16)
        local frameWidth = 16  -- 精灵图帧宽度
        local frameHeight = 16  -- 精灵图帧高度
        
        -- 计算缩放比例以适应怪物size
        local scale = config.size / 12  -- 基础大小为12
        
        -- 计算锚点，X轴居中，Y轴在底部
        local offsetX = frameWidth / 2
        local offsetY = frameHeight - 1  -- 稍微往上偏移1像素，使阴影位于脚下
        
        animation:draw(
            spriteImage, 
            position.x, position.y, 
            0, scaleX * scale, scale, 
            offsetX, offsetY
        )
    else
        -- 没有动画时使用简单图形
        if config.color then
            love.graphics.setColor(unpack(config.color))
        else
            -- 根据怪物类型设置不同的颜色
            if monsterType == "slime" then
                love.graphics.setColor(0.2, 0.8, 0.2)
            elseif monsterType == "skeleton" then
                love.graphics.setColor(0.8, 0.8, 0.7)
            elseif monsterType == "goblin" then
                love.graphics.setColor(0.6, 0.3, 0.1)
            elseif monsterType == "zombie" then
                love.graphics.setColor(0.5, 0.7, 0.3)
            elseif monsterType == "ghost" then
                love.graphics.setColor(0.6, 0.6, 1.0, 0.7)
            else
                love.graphics.setColor(1.0, 0.2, 0.2)
            end
        end
        
        -- 绘制圆形表示怪物
        love.graphics.circle('fill', position.x, position.y, size)
        
        -- 绘制方向指示
        local dirX, dirY = 0, 0
        if status.direction == "right" then
            dirX = 1
        elseif status.direction == "left" then
            dirX = -1
        elseif status.direction == "down" then
            dirY = 1
        elseif status.direction == "up" then
            dirY = -1
        end
        
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle('fill', 
            position.x + dirX * size * 0.6, 
            position.y + dirY * size * 0.6, 
            size * 0.3
        )
    end
    
    -- 绘制生命条
    local hpBarWidth = size * 2
    local hpBarHeight = 3
    local hpRatio = attributes.hp / attributes.maxHp
    
    -- 背景
    love.graphics.setColor(0.3, 0.3, 0.3, 0.7)
    love.graphics.rectangle('fill', 
        position.x - hpBarWidth/2, 
        position.y - size - 8, 
        hpBarWidth, 
        hpBarHeight
    )
    
    -- 生命值
    love.graphics.setColor(1 - hpRatio, hpRatio, 0.2)
    love.graphics.rectangle('fill', 
        position.x - hpBarWidth/2, 
        position.y - size - 8, 
        hpBarWidth * hpRatio, 
        hpBarHeight
    )
    
    -- 如果怪物被眩晕，绘制眩晕效果
    if status.stunned then
        love.graphics.setColor(1, 1, 0, 0.7)
        love.graphics.circle('line', position.x, position.y, size + 5)
        love.graphics.circle('line', position.x, position.y, size + 8)
    end
    
    -- 如果处于攻击状态，绘制攻击效果
    if status.isAttacking then
        love.graphics.setColor(1, 0.5, 0.5, 0.5)
        love.graphics.circle('line', position.x, position.y, attributes.attackRange)
    end
    
    -- 调试模式：显示检测范围
    if debug then
        love.graphics.setColor(0.5, 0.5, 1, 0.2)
        love.graphics.circle('line', position.x, position.y, attributes.detectRange)
    end
    
    -- 绘制怪物名称或等级
    if config.name then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(monsterFont)
        local textWidth = monsterFont:getWidth(config.name)
        love.graphics.print(
            config.name, 
            position.x - textWidth/2, 
            position.y - size - 15
        )
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 绘制所有子弹
function MonsterView:drawBullets(bullets)
    for _, bullet in ipairs(bullets) do
        if bullet.draw then
            bullet:draw()
        else
            -- 默认子弹绘制
            love.graphics.setColor(0.8, 0.3, 0.3)
            love.graphics.circle('fill', bullet.x, bullet.y, 4)
        end
    end
end

return MonsterView 