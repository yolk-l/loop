-- 玩家视图
local PlayerView = {}
PlayerView.__index = PlayerView

local AnimationSystem = require('src/utils/Animation')

-- 获取动画系统资源
local resources = AnimationSystem.getResources()

-- 字体缓存
local playerFont = nil

-- 初始化字体
local function initFont()
    if not playerFont then
        playerFont = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function PlayerView.new()
    initFont()
    local mt = setmetatable({}, PlayerView)
    mt.bulletImage = nil
    mt.playerFont = nil
    mt:loadResources()
    return mt
end

function PlayerView:loadResources()
    -- 加载子弹图片
    if not self.bulletImage then
        self.bulletImage = love.graphics.newImage("assets/sprites/bullets/normal_bullet.png")
    end
    
    -- 初始化字体
    if not self.playerFont then
        self.playerFont = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function PlayerView:draw(playerModel)
    -- 获取当前状态的动画
    local animation = nil
    if playerModel.status.isAttacking then
        animation = AnimationSystem.getAnimation(AnimationSystem.TYPES.PLAYER_ATTACK)
    else
        animation = AnimationSystem.getAnimation(AnimationSystem.TYPES.PLAYER_IDLE)
    end
    
    if animation then
        -- 设置颜色
        love.graphics.setColor(1, 1, 1)
        -- 绘制动画
        animation:draw(resources.images.player, playerModel.x, playerModel.y, 0, 1, 1, 8, 8)
    else
        -- 如果没有动画，使用默认绘制
        love.graphics.setColor(0.2, 0.6, 1.0)
        love.graphics.circle('fill', playerModel.x, playerModel.y, playerModel.size)
    end
    
    -- 绘制子弹
    self:drawBullets(playerModel.bullets)
    
    -- 绘制生命条
    local hpBarWidth = playerModel.size * 2
    local hpBarHeight = 3
    local hpPercentage = playerModel.attributes.hp / playerModel.attributes.maxHp
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', playerModel.x - hpBarWidth/2, playerModel.y - playerModel.size - 5, hpBarWidth, hpBarHeight)
    
    love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
    love.graphics.rectangle('fill', playerModel.x - hpBarWidth/2, playerModel.y - playerModel.size - 5, hpBarWidth * hpPercentage, hpBarHeight)
    
    -- 绘制AI状态指示器
    if playerModel.status.isAIControlled then
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.circle('fill', playerModel.x, playerModel.y - playerModel.size - 20, 3)
    end
    -- 如果处于攻击状态，绘制攻击效果
    if playerModel.status.isAttacking then
        love.graphics.setColor(1, 0.7, 0.2, 0.6)
        love.graphics.circle('line', playerModel.x, playerModel.y, playerModel.size * 1.5)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

-- 绘制所有子弹
function PlayerView:drawBullets(bullets)
    for _, bullet in ipairs(bullets) do
        if bullet.draw then
            bullet:draw()
        else
            -- 简单的默认子弹绘制逻辑
            love.graphics.setColor(1, 0.7, 0.3)
            love.graphics.circle('fill', bullet.x, bullet.y, 3)
        end
    end
end

return PlayerView 