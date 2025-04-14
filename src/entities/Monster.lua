-- 怪物类
local Monster = {}
Monster.__index = Monster

-- 引入配置
local MONSTER_CONFIG = require('config/monsters')

-- 引入动画系统
local AnimationSystem = require('src/systems/Animation')

-- 引入像素精灵生成器
local PixelSprites = require('src/utils/PixelSprites')

-- 引入子弹类
local Bullet = require('src/entities/Bullet')

-- 获取动画系统资源
local resources = AnimationSystem.getResources()

-- 字体缓存
local monsterFont = nil
local bullets = {}  -- 怪物发射的子弹数组

-- 子弹图片缓存
local bulletImage = nil

-- 加载子弹图片
local function loadBulletImage()
    bulletImage = love.graphics.newImage("assets/sprites/bullets/normal_bullet.png")
end

-- 初始化字体
local function initFont()
    if not monsterFont then
        monsterFont = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function Monster:new(type, x, y)
    local self = setmetatable({}, Monster)
    self.type = type
    self.config = MONSTER_CONFIG[type]
    self.x = x
    self.y = y
    
    -- 复制属性，这样每个实例都有自己的属性副本
    self.attributes = {}
    for k, v in pairs(self.config.attributes) do
        self.attributes[k] = v
    end
    self.attributes.hp = self.attributes.maxHp  -- 初始化当前生命值
    
    -- 状态系统
    self.status = {
        isAttacking = false,
        lastAttackTime = 0,
        target = nil,
        isDead = false,
        state = "idle",       -- AI状态：idle（空闲）, move（移动）, attack（攻击）
        homeBuilding = nil,   -- 怪物所属的建筑
        animTime = 0,         -- 用于简单动画效果
        directionX = 1,       -- 面向方向（1为右，-1为左）
        bobOffset = 0,        -- 上下移动偏移量
        stunDuration = 0      -- 眩晕持续时间
    }
    
    -- 初始化动画
    self.animations = {
        idle = AnimationSystem.getMonsterAnimation(self.type, "idle"),
        move = AnimationSystem.getMonsterAnimation(self.type, "move"),
        attack = AnimationSystem.getMonsterAnimation(self.type, "attack")
    }
    
    -- 创建像素精灵作为备用
    if self.type == "slime" then
        self.pixelSprite = PixelSprites.generateMonsterSprite(16, PixelSprites.COLORS.GREEN)
    elseif self.type == "goblin" then
        self.pixelSprite = PixelSprites.generateMonsterSprite(16, PixelSprites.COLORS.ORANGE)
    elseif self.type == "skeleton" then
        self.pixelSprite = PixelSprites.generateMonsterSprite(16, PixelSprites.COLORS.GRAY)
    else
        -- 默认随机颜色
        local randomColor = {
            math.random(0.5, 1.0),
            math.random(0.5, 1.0),
            math.random(0.5, 1.0)
        }
        self.pixelSprite = PixelSprites.generateMonsterSprite(16, randomColor)
    end
    
    -- 加载子弹图片
    if not bulletImage then
        loadBulletImage()
    end
    
    initFont()
    return self
end

function Monster:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.attributes.defense)
    self.attributes.hp = math.max(0, self.attributes.hp - actualDamage)
    
    if self.attributes.hp <= 0 then
        self.status.isDead = true
    end
    
    return actualDamage
end

function Monster:attack(target)
    local currentTime = love.timer.getTime()
    if currentTime - self.status.lastAttackTime < 1.5 then  -- 1.5秒攻击冷却
        return false
    end
    
    -- 计算与目标的距离
    local dx = target.x - self.x
    local dy = target.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- 设置面向方向
    self.status.directionX = dx < 0 and -1 or 1
    
    if distance <= self.attributes.attackRange then
        self.status.isAttacking = true
        self.status.lastAttackTime = currentTime
        
        -- 根据攻击类型执行不同的攻击方式
        if self.config.attackType == "melee" then
            -- 近战攻击直接造成伤害
            local damage = self.attributes.attack
            return target:takeDamage(damage)
        else
            -- 远程攻击发射子弹
            local bullet = Bullet:new(
                self.x, self.y,           -- 起始位置
                target.x, target.y,       -- 目标位置
                self.config.bulletSpeed,  -- 子弹速度
                self.attributes.attack,    -- 伤害
                self.type                 -- 发射者类型
            )
            table.insert(bullets, bullet)
            return true
        end
    end
    
    return false
end

function Monster:moveTowards(target, dt)
    if not target then return end
    
    local targetX = type(target) == "table" and target.x or target
    local targetY = type(target) == "table" and target.y or target
    
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- 设置面向方向
    if dx ~= 0 then
        self.status.directionX = dx < 0 and -1 or 1
    end
    
    if distance > 0 then
        local speed = self.attributes.speed * dt
        self.x = self.x + (dx / distance) * speed
        self.y = self.y + (dy / distance) * speed
    end
end

function Monster:update(dt, map)
    if self.status.isDead then return end
    
    -- 更新动画时间
    self.status.animTime = self.status.animTime + dt
    
    -- 更新上下移动偏移量（用于像素精灵动画）
    if self.status.state == "move" then
        self.status.bobOffset = math.sin(self.status.animTime * 8) * 2
    else
        self.status.bobOffset = math.sin(self.status.animTime * 3) * 1
    end
    
    -- 处理眩晕状态
    if self.status.stunDuration > 0 then
        self.status.stunDuration = self.status.stunDuration - dt
        return  -- 眩晕状态下不执行其他行为
    end
    
    -- 更新攻击状态
    if self.status.isAttacking then
        if love.timer.getTime() - self.status.lastAttackTime > 0.2 then
            self.status.isAttacking = false
        end
    end
    
    -- 获取地图中心（玩家所在位置）
    local centerX = map.gridWidth * map.tileSize / 2
    local centerY = map.gridHeight * map.tileSize / 2
    
    -- 根据状态执行不同的行为
    if self.status.target then
        -- 有玩家目标时的行为
        local dx = self.status.target.x - self.x
        local dy = self.status.target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= self.attributes.attackRange then
            -- 在攻击范围内
            self.status.state = "attack"
            self:attack(self.status.target)
        else
            -- 向目标移动
            self.status.state = "move"
            self:moveTowards(self.status.target, dt)
        end
    else
        -- 没有玩家目标时，向地图中心（玩家位置）移动
        local dx = centerX - self.x
        local dy = centerY - self.y
        local distanceToCenter = math.sqrt(dx * dx + dy * dy)
        
        if distanceToCenter > self.attributes.attackRange then
            self.status.state = "move"
            self:moveTowards({x = centerX, y = centerY}, dt)
        else
            self.status.state = "idle"
        end
    end
    
    -- 更新当前状态的动画
    local currentAnimation = self.animations[self.status.state]
    if currentAnimation then
        currentAnimation:update(dt)
    end
end

function Monster:setTarget(target)
    self.status.target = target
end

function Monster:draw()
    -- 获取当前状态的动画
    local currentAnimation = self.animations[self.status.state]
    
    if currentAnimation and resources.images[self.type] then
        -- 设置颜色
        love.graphics.setColor(1, 1, 1)
        -- 绘制动画
        currentAnimation:draw(resources.images[self.type], self.x, self.y, 0, 1, 1, 8, 8)
    else
        -- 使用像素精灵绘制
        love.graphics.setColor(self.config.color[1], self.config.color[2], self.config.color[3])
        
        -- 添加攻击效果（缩放和颜色变化）
        local scale = 1.0
        if self.status.isAttacking then
            scale = 1.2
            love.graphics.setColor(1, 0.7, 0.7)
        end
        
        -- 绘制像素精灵，应用面向方向和上下移动效果
        love.graphics.draw(
            self.pixelSprite,
            self.x,
            self.y + self.status.bobOffset,
            0,                           -- 旋转
            scale * self.status.directionX, -- X缩放（处理朝向）
            scale,                       -- Y缩放
            self.pixelSprite:getWidth()/2,  -- 中心X
            self.pixelSprite:getHeight()/2  -- 中心Y
        )
    end
    
    -- 绘制生命条
    local hpBarWidth = self.config.size * 2
    local hpBarHeight = 3
    local hpPercentage = self.attributes.hp / self.attributes.maxHp
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.config.size - 5, hpBarWidth, hpBarHeight)
    
    love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.config.size - 5, hpBarWidth * hpPercentage, hpBarHeight)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
    
    -- 如果处于眩晕状态，绘制眩晕效果
    if self.status.stunDuration > 0 then
        love.graphics.setColor(1, 1, 0, 0.7)
        love.graphics.circle('line', self.x, self.y, self.config.size + 5)
        
        -- 绘制星星效果
        for i = 1, 3 do
            local angle = self.status.animTime * 2 + i * (2 * math.pi / 3)
            local starX = self.x + math.cos(angle) * (self.config.size + 10)
            local starY = self.y + math.sin(angle) * (self.config.size + 10) - 5
            love.graphics.setColor(1, 1, 0, 0.8)
            love.graphics.print("✦", starX - 4, starY - 4)
        end
    end
end

-- 获取所有子弹
function Monster.getBullets()
    return bullets
end

-- 更新所有子弹
function Monster.updateBullets(dt)
    for i = #bullets, 1, -1 do
        bullets[i]:update(dt)
        if not bullets[i].status.isActive then
            table.remove(bullets, i)
        end
    end
end

-- 绘制所有子弹
function Monster.drawBullets()
    for _, bullet in ipairs(bullets) do
        love.graphics.draw(bulletImage, bullet.x, bullet.y, bullet.angle, 1, 1,
            bulletImage:getWidth()/2, bulletImage:getHeight()/2)
    end
end

return Monster 