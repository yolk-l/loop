-- 怪物类
-- 已被MVC架构替代，此文件仅保留以兼容旧代码
-- 请改用：
-- MonsterModel - src/models/MonsterModel.lua
-- MonsterView - src/views/MonsterView.lua
-- MonsterController - src/controllers/MonsterController.lua

local Monster = {}
Monster.__index = Monster

local MonsterConfig = require('config/monsters')

function Monster:new(type, x, y)
    print("警告：使用了旧版Monster实体，请改用MonsterController")
    
    local self = setmetatable({}, Monster)
    self.type = type
    self.x = x
    self.y = y
    
    -- 获取怪物配置
    self.config = MonsterConfig.MONSTER_CONFIG[type] or MonsterConfig.MONSTER_CONFIG.slime
    
    -- 怪物属性
    self.attributes = {
        maxHp = self.config.hp or 100,
        hp = self.config.hp or 100,
        attack = self.config.attack or 10,
        defense = self.config.defense or 5,
        speed = self.config.speed or 40,
        attackRange = self.config.attackRange or 50,
        detectRange = self.config.detectRange or 200,
        attackCooldown = self.config.attackCooldown or 1.5,
        lastAttackTime = 0
    }
    
    -- 怪物状态
    self.status = {
        isDead = false,
        isMoving = false,
        isAttacking = false,
        direction = "right",
        homeBuilding = nil -- 生成此怪物的建筑引用
    }
    
    -- 目标
    self.target = nil
    
    -- 徘徊相关
    self.wanderTimer = 0
    self.wanderX = nil
    self.wanderY = nil
    self.wanderRadius = 100
    
    -- 其他属性
    self.size = self.config.size or 15
    self.color = self.config.color or {1, 0, 0}
    self.spritesheet = nil
    
    -- 加载动画数据（如果有）
    self:loadAnimations()
    
    return self
end

function Monster:loadAnimations()
    -- 怪物类型到精灵表的映射
    local spriteMap = {
        slime = "slime",
        goblin = "goblin",
        skeleton = "skeleton",
        zombie = "zombie",
        wolf = "wolf",
        ghost = "ghost",
        golem = "golem",
        witch = "witch",
        dragon = "dragon"
    }
    
    -- 尝试加载对应的精灵表
    local spriteName = spriteMap[self.type] or "default_monster"
    local imagePath = "assets/sprites/monsters/" .. spriteName .. ".png"
    
    if love.filesystem.getInfo(imagePath) then
        self.spritesheet = love.graphics.newImage(imagePath)
        
        -- 设置动画帧
        if self.spritesheet then
            local frameWidth = self.spritesheet:getWidth() / 4  -- 假设每行4帧
            local frameHeight = self.spritesheet:getHeight() / 4  -- 假设每列4帧，对应4个方向
            
            self.animations = {
                down = {},
                left = {},
                right = {},
                up = {}
            }
            
            -- 创建四个方向的动画帧
            for i = 0, 3 do
                table.insert(self.animations.down, love.graphics.newQuad(i * frameWidth, 0, frameWidth, frameHeight, self.spritesheet:getDimensions()))
                table.insert(self.animations.left, love.graphics.newQuad(i * frameWidth, frameHeight, frameWidth, frameHeight, self.spritesheet:getDimensions()))
                table.insert(self.animations.right, love.graphics.newQuad(i * frameWidth, frameHeight * 2, frameWidth, frameHeight, self.spritesheet:getDimensions()))
                table.insert(self.animations.up, love.graphics.newQuad(i * frameWidth, frameHeight * 3, frameWidth, frameHeight, self.spritesheet:getDimensions()))
            end
            
            -- 动画属性
            self.currentFrame = 1
            self.animationTimer = 0
            self.animationSpeed = 0.2  -- 每帧持续时间
        end
    end
end

function Monster:update(dt, map)
    -- 如果已死亡，不更新
    if self.status.isDead then
        return
    end
    
    -- 更新动画
    if self.animations then
        self.animationTimer = self.animationTimer + dt
        if self.animationTimer >= self.animationSpeed then
            self.animationTimer = self.animationTimer - self.animationSpeed
            self.currentFrame = (self.currentFrame % #self.animations.down) + 1
        end
    end
    
    -- 更新攻击冷却
    if self.attributes.lastAttackTime > 0 then
        local currentTime = love.timer.getTime()
        if currentTime - self.attributes.lastAttackTime >= self.attributes.attackCooldown then
            self.attributes.lastAttackTime = 0
        end
    end
    
    -- 更新AI行为
    if self.target then
        -- 目标追踪
        local dx = self.target.x - self.x
        local dy = self.target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        -- 设置方向
        if math.abs(dx) > math.abs(dy) then
            self.status.direction = dx > 0 and "right" or "left"
        else
            self.status.direction = dy > 0 and "down" or "up"
        end
        
        -- 如果在攻击范围内，尝试攻击
        if distance <= self.attributes.attackRange then
            self:attack(self.target)
        else
            -- 否则向目标移动
            self.status.isMoving = true
            local moveSpeed = self.attributes.speed * dt
            
            -- 检查是否可以移动
            local newX = self.x + dx / distance * moveSpeed
            local newY = self.y + dy / distance * moveSpeed
            
            -- 如果有地图，检查碰撞
            if map and not self:canMoveTo(newX, newY, map) then
                -- 尝试只在X方向移动
                if self:canMoveTo(newX, self.y, map) then
                    self.x = newX
                -- 尝试只在Y方向移动
                elseif self:canMoveTo(self.x, newY, map) then
                    self.y = newY
                end
            else
                self.x = newX
                self.y = newY
            end
        end
    else
        -- 没有目标，随机漫步或返回家园
        self:wander(dt, map)
    end
end

function Monster:wander(dt, map)
    -- 更新徘徊计时器
    if self.wanderTimer > 0 then
        self.wanderTimer = self.wanderTimer - dt
    end
    
    -- 如果计时器到期或没有目标点，选择新的目标
    if self.wanderTimer <= 0 or not self.wanderX then
        -- 如果有归属建筑，在其周围随机漫步
        if self.status.homeBuilding then
            local building = self.status.homeBuilding
            local angle = math.random() * math.pi * 2
            local distance = math.random(10, self.wanderRadius or 100)
            self.wanderX = building.x + math.cos(angle) * distance
            self.wanderY = building.y + math.sin(angle) * distance
        else
            -- 否则在当前位置周围随机漫步
            local angle = math.random() * math.pi * 2
            local distance = math.random(30, 100)
            self.wanderX = self.x + math.cos(angle) * distance
            self.wanderY = self.y + math.sin(angle) * distance
        end
        
        -- 如果有地图，确保目标点可达
        if map then
            local isValid = self:canMoveTo(self.wanderX, self.wanderY, map)
            if not isValid then
                -- 不断尝试找到可行的点
                for i = 1, 10 do
                    local angle = math.random() * math.pi * 2
                    local distance = math.random(30, 100)
                    self.wanderX = self.x + math.cos(angle) * distance
                    self.wanderY = self.y + math.sin(angle) * distance
                    if self:canMoveTo(self.wanderX, self.wanderY, map) then
                        break
                    end
                end
            end
        end
        
        -- 设置新的徘徊时间
        self.wanderTimer = math.random(2, 5)
    end
    
    -- 向目标点移动
    if self.wanderX and self.wanderY then
        local dx = self.wanderX - self.x
        local dy = self.wanderY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        -- 设置方向
        if math.abs(dx) > math.abs(dy) then
            self.status.direction = dx > 0 and "right" or "left"
        else
            self.status.direction = dy > 0 and "down" or "up"
        end
        
        -- 如果已经接近目标点，停止移动
        if distance < 5 then
            self.status.isMoving = false
            self.wanderTimer = 0
        else
            -- 向目标点移动
            self.status.isMoving = true
            local moveSpeed = self.attributes.speed * 0.5 * dt  -- 徘徊速度减半
            
            -- 计算新位置
            local newX = self.x + dx / distance * moveSpeed
            local newY = self.y + dy / distance * moveSpeed
            
            -- 如果有地图，检查碰撞
            if map and not self:canMoveTo(newX, newY, map) then
                -- 尝试只在X方向移动
                if self:canMoveTo(newX, self.y, map) then
                    self.x = newX
                -- 尝试只在Y方向移动
                elseif self:canMoveTo(self.x, newY, map) then
                    self.y = newY
                else
                    -- 重置徘徊计时器，迫使选择新目标
                    self.wanderTimer = 0
                end
            else
                self.x = newX
                self.y = newY
            end
        end
    end
end

function Monster:canMoveTo(x, y, map)
    if not map then return true end
    
    -- 检查地形是否可通过
    local terrain = map:getTerrainAt(x, y)
    if not terrain then return false end  -- 地图外不可通行
    
    -- 水面不能通过（水的地形类型是2）
    if terrain == 2 then
        return false
    end
    
    return true
end

function Monster:attack(target)
    -- 如果在冷却中，不能攻击
    if self.attributes.lastAttackTime > 0 then
        return false
    end
    
    -- 设置攻击状态
    self.status.isAttacking = true
    self.attributes.lastAttackTime = love.timer.getTime()
    
    return {
        type = "melee",
        damage = self.attributes.attack,
        source = self
    }
end

function Monster:takeDamage(damage)
    -- 计算实际伤害
    local actualDamage = math.max(1, damage - self.attributes.defense)
    
    -- 减少生命值
    self.attributes.hp = math.max(0, self.attributes.hp - actualDamage)
    
    -- 检查是否死亡
    if self.attributes.hp <= 0 then
        self.status.isDead = true
    end
    
    return actualDamage
end

function Monster:draw()
    if self.status.isDead then
        return
    end
    
    if self.spritesheet and self.animations then
        -- 使用精灵动画绘制
        local direction = self.status.direction
        local frame = self.currentFrame
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            self.spritesheet,
            self.animations[direction][frame],
            self.x,
            self.y,
            0,              -- 旋转
            1,              -- X缩放
            1,              -- Y缩放
            16,             -- X偏移（中心点）
            16              -- Y偏移（中心点）
        )
    else
        -- 简单图形绘制
        love.graphics.setColor(self.color)
        love.graphics.circle("fill", self.x, self.y, self.size)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", self.x, self.y, self.size)
    end
    
    -- 绘制生命条
    local hpBarWidth = self.size * 2
    local hpBarHeight = 4
    local hpPercentage = self.attributes.hp / self.attributes.maxHp
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.size - 10, hpBarWidth, hpBarHeight)
    
    love.graphics.setColor(1 - hpPercentage, hpPercentage, 0.2)
    love.graphics.rectangle('fill', self.x - hpBarWidth/2, self.y - self.size - 10, hpBarWidth * hpPercentage, hpBarHeight)
    
    -- 绘制怪物类型名称
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local text = self.config.name or self.type
    local textWidth = font:getWidth(text)
    love.graphics.print(text, self.x - textWidth/2, self.y - self.size - 20)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function Monster:setTarget(target)
    self.target = target
end

return Monster 