-- 角色界面
local CharacterUI = {}
CharacterUI.__index = CharacterUI

-- 字体缓存

-- 初始化字体
local function initFonts(fonts)
    if not fonts.title then
        fonts.title = love.graphics.newFont("assets/fonts/simsun.ttc", 18)
        fonts.subtitle = love.graphics.newFont("assets/fonts/simsun.ttc", 16)
        fonts.normal = love.graphics.newFont("assets/fonts/simsun.ttc", 14)
        fonts.description = love.graphics.newFont("assets/fonts/simsun.ttc", 12)
    end
end

function CharacterUI.new()
    local self = setmetatable({}, CharacterUI)
    self.visible = false    -- 界面是否可见
    self.width = 600        -- 界面宽度
    self.height = 600       -- 界面高度
    
    -- 计算以窗口中心为基准的位置
    local windowWidth, windowHeight = love.graphics.getDimensions()
    self.x = math.floor((windowWidth - self.width) / 2)
    self.y = math.floor((windowHeight - self.height) / 2)
    
    -- 添加字体引用
    self.fonts = {
        title = nil,
        subtitle = nil,
        normal = nil,
        description = nil
    }
    
    -- 添加关闭按钮区域
    self.closeBtn = {
        x = self.x + self.width - 40,
        y = self.y + 15,
        width = 25,
        height = 25
    }
    
    -- 初始化字体
    initFonts(self.fonts)
    
    -- 角色属性分类
    self.categories = {
        {name = "基本属性", color = {0.2, 0.7, 1.0}},
        {name = "战斗属性", color = {1.0, 0.6, 0.2}}
    }
    
    return self
end

function CharacterUI:toggleVisibility()
    self.visible = not self.visible
    
    -- 重新计算位置，以确保总是在窗口中心
    if self.visible then
        local windowWidth, windowHeight = love.graphics.getDimensions()
        self.x = math.floor((windowWidth - self.width) / 2)
        self.y = math.floor((windowHeight - self.height) / 2)
        
        -- 更新关闭按钮位置
        self.closeBtn.x = self.x + self.width - 40
        self.closeBtn.y = self.y + 15
    end
end

-- 根据鼠标位置判断是否点击到关闭按钮
function CharacterUI:isCloseButtonClicked(mx, my)
    if not self.visible then return false end
    
    return mx >= self.closeBtn.x and mx <= self.closeBtn.x + self.closeBtn.width and
           my >= self.closeBtn.y and my <= self.closeBtn.y + self.closeBtn.height
end

-- 绘制进度条函数
local function drawProgressBar(x, y, width, height, value, maxValue, color, backgroundColor)
    local percentage = value / maxValue
    
    -- 绘制背景
    love.graphics.setColor(backgroundColor or {0.2, 0.2, 0.2, 0.7})
    love.graphics.rectangle('fill', x, y, width, height, 4, 4)
    
    -- 绘制进度条
    love.graphics.setColor(color or {0.2, 0.7, 1.0})
    love.graphics.rectangle('fill', x, y, width * percentage, height, 4, 4)
    
    -- 绘制边框
    love.graphics.setColor(0.8, 0.8, 0.8, 0.5)
    love.graphics.rectangle('line', x, y, width, height, 4, 4)
end

function CharacterUI:draw(player)
    if not self.visible then return end
    
    -- 获取玩家模型数据
    local playerModel = player:getModel()
    
    -- 半透明黑色背景遮罩
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 绘制主背景面板（带有渐变效果）
    local colors = {
        {0.18, 0.18, 0.22, 0.95}, -- 顶部颜色
        {0.12, 0.12, 0.15, 0.95}  -- 底部颜色
    }
    
    -- 绘制渐变背景
    for i = 0, self.height, 1 do
        local t = i / self.height
        local r = colors[1][1] * (1 - t) + colors[2][1] * t
        local g = colors[1][2] * (1 - t) + colors[2][2] * t
        local b = colors[1][3] * (1 - t) + colors[2][3] * t
        local a = colors[1][4] * (1 - t) + colors[2][4] * t
        
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle('fill', self.x, self.y + i, self.width, 1)
    end
    
    -- 绘制边框
    love.graphics.setColor(0.4, 0.4, 0.5, 0.8)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height, 10, 10)
    
    -- 绘制顶部标题栏
    love.graphics.setColor(0.2, 0.2, 0.25, 0.9)
    love.graphics.rectangle('fill', self.x, self.y, self.width, 40, 10, 10)
    
    -- 绘制标题
    love.graphics.setFont(self.fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("角色信息", self.x + 20, self.y + 10)
    
    -- 绘制关闭按钮
    love.graphics.setColor(0.8, 0.2, 0.2, 0.7)
    love.graphics.rectangle('fill', self.closeBtn.x, self.closeBtn.y, self.closeBtn.width, self.closeBtn.height, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.closeBtn.x + 5, self.closeBtn.y + 5, self.closeBtn.x + self.closeBtn.width - 5, self.closeBtn.y + self.closeBtn.height - 5)
    love.graphics.line(self.closeBtn.x + self.closeBtn.width - 5, self.closeBtn.y + 5, self.closeBtn.x + 5, self.closeBtn.y + self.closeBtn.height - 5)
    love.graphics.setLineWidth(1)
    
    -- 绘制角色形象区域
    local portraitX = self.x + 30
    local portraitY = self.y + 60
    local portraitSize = 100
    
    -- 角色头像背景
    love.graphics.setColor(0.3, 0.3, 0.35, 0.7)
    love.graphics.rectangle('fill', portraitX, portraitY, portraitSize, portraitSize, 8, 8)
    
    -- 绘制角色（可以是动画或静态图像）
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle('fill', portraitX + portraitSize/2, portraitY + portraitSize/2, portraitSize/2 - 10)
    
    -- 角色等级显示
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.circle('fill', portraitX + portraitSize - 20, portraitY + portraitSize - 20, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.fonts.subtitle)
    local levelText = tostring(playerModel.attributes.level)
    local levelTextWidth = self.fonts.subtitle:getWidth(levelText)
    love.graphics.print(levelText, portraitX + portraitSize - 20 - levelTextWidth/2, portraitY + portraitSize - 28)
    
    -- 绘制角色名称
    love.graphics.setFont(self.fonts.subtitle)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("角色", portraitX, portraitY + portraitSize + 10)
    
    -- 绘制经验条
    local expWidth = 160
    local expHeight = 15
    local expX = portraitX
    local expY = portraitY + portraitSize + 40
    local expPercentage = playerModel.attributes.exp / playerModel.attributes.nextLevelExp
    
    -- 经验数值
    love.graphics.setFont(self.fonts.description)
    love.graphics.setColor(0.7, 0.7, 1)
    love.graphics.print("经验: " .. playerModel.attributes.exp .. "/" .. playerModel.attributes.nextLevelExp, 
                      expX, expY - 20)
    
    -- 绘制经验进度条
    drawProgressBar(expX, expY, expWidth, expHeight, playerModel.attributes.exp, playerModel.attributes.nextLevelExp, 
                    {0.4, 0.4, 1.0}, {0.2, 0.2, 0.4, 0.7})
    
    -- 开始绘制属性面板
    local statsPanelX = self.x + 180
    local statsPanelY = self.y + 60
    local statsPanelWidth = self.width - 210
    local statsPanelHeight = 150
    
    -- 统计分类 - 基本属性
    love.graphics.setColor(0.25, 0.25, 0.3, 0.8)
    love.graphics.rectangle('fill', statsPanelX, statsPanelY, statsPanelWidth, statsPanelHeight, 8, 8)
    
    -- 分类标题
    love.graphics.setFont(self.fonts.subtitle)
    love.graphics.setColor(self.categories[1].color)
    love.graphics.print(self.categories[1].name, statsPanelX + 10, statsPanelY + 10)
    
    -- 绘制基本属性
    love.graphics.setFont(self.fonts.normal)
    
    -- 生命值
    local hpY = statsPanelY + 40
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.print("生命: " .. math.floor(playerModel.attributes.hp) .. "/" .. math.floor(playerModel.attributes.maxHp),
                      statsPanelX + 10, hpY)
    
    -- 生命条
    drawProgressBar(statsPanelX + 10, hpY + 25, statsPanelWidth - 20, 15, 
                    playerModel.attributes.hp, playerModel.attributes.maxHp, 
                    {0.8, 0.2, 0.2}, {0.3, 0.1, 0.1, 0.7})
    
    -- 攻击和防御
    love.graphics.setColor(1, 0.7, 0.2)
    love.graphics.print("攻击: " .. math.floor(playerModel.attributes.attack), statsPanelX + 10, hpY + 50)
    
    love.graphics.setColor(0.2, 0.7, 1.0)
    love.graphics.print("防御: " .. math.floor(playerModel.attributes.defense), statsPanelX + statsPanelWidth/2, hpY + 50)
    
    -- 速度
    love.graphics.setColor(0.2, 1.0, 0.5)
    love.graphics.print("速度: " .. math.floor(playerModel.attributes.speed), statsPanelX + 10, hpY + 80)
    
    -- 统计分类 - 战斗属性
    local combatPanelY = statsPanelY + statsPanelHeight + 20
    love.graphics.setColor(0.25, 0.25, 0.3, 0.8)
    love.graphics.rectangle('fill', statsPanelX, combatPanelY, statsPanelWidth, statsPanelHeight, 8, 8)
    
    -- 分类标题
    love.graphics.setFont(self.fonts.subtitle)
    love.graphics.setColor(self.categories[2].color)
    love.graphics.print(self.categories[2].name, statsPanelX + 10, combatPanelY + 10)
    
    -- 绘制战斗属性
    love.graphics.setFont(self.fonts.normal)
    
    -- 暴击相关
    local critY = combatPanelY + 40
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.print("暴击率: " .. playerModel.attributes.critRate .. "%", statsPanelX + 10, critY)
    
    love.graphics.setColor(1, 0.3, 0)
    love.graphics.print("暴击伤害: " .. playerModel.attributes.critDamage .. "%", statsPanelX + statsPanelWidth/2, critY)
    
    -- 命中和抵抗
    love.graphics.setColor(0.4, 0.8, 1.0)
    love.graphics.print("命中率: " .. playerModel.attributes.accuracy .. "%", statsPanelX + 10, critY + 30)
    
    love.graphics.setColor(0.7, 0.4, 1.0)
    love.graphics.print("抵抗: " .. playerModel.attributes.resistance .. "%", statsPanelX + statsPanelWidth/2, critY + 30)
    
    -- 分隔线
    love.graphics.setColor(0.4, 0.4, 0.5, 0.4)
    love.graphics.rectangle('fill', self.x + 20, self.y + 350, self.width - 40, 2)
    
    -- 绘制背包标题
    love.graphics.setFont(self.fonts.subtitle)
    love.graphics.setColor(0.9, 0.8, 0.3)
    love.graphics.print("背包", self.x + 20, self.y + 370)
    
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

return CharacterUI 