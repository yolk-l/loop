-- 主入口文件
local PlayerController = require('src/controllers/PlayerController')
local MapController = require('src/controllers/MapController')
local MonsterManager = require('src.managers.MonsterManager')  -- 引入怪物管理器
local BuildingController = require('src/controllers/BuildingController')
local BuildingManager = require('src.managers.BuildingManager')  -- 引入建筑管理器
local CardController = require('src/controllers/CardController')
local InventoryController = require('src/controllers/InventoryController')
local CharacterUI = require('src/ui/CharacterUI')
local Timer = require('lib/timer')  -- 引入timer库
local CombatManager = require('src.managers.CombatManager')
local TypeDefines = require('config/type_defines')

-- 游戏状态
local player
local mapController
local gameFont
local gameOverFont -- 游戏结束字体
local gameOverStatsFont -- 游戏结束统计信息字体
local gameOverRestartFont -- 游戏结束重新开始提示字体
local gameTimer  -- 全局计时器实例
local attackEffects = {}  -- 攻击效果数组
local buildingPreviewX, buildingPreviewY
local buildingPreviewColor = {0.5, 1, 0.5, 0.5}  -- 可建造用绿色表示
local monsterManager  -- 怪物管理器实例
local buildingManager  -- 建筑管理器实例

function love.load()
    
    -- 初始化动画系统
    local AnimationSystem = require('src/utils/Animation')
    AnimationSystem.initialize()
    
    -- 使用中文字体
    gameFont = love.graphics.newFont("assets/fonts/simsun.ttc", 14)
    love.graphics.setFont(gameFont)
    
    -- 预加载游戏结束界面字体
    gameOverFont = love.graphics.newFont("assets/fonts/simsun.ttc", 36)
    gameOverStatsFont = love.graphics.newFont("assets/fonts/simsun.ttc", 20)
    gameOverRestartFont = love.graphics.newFont("assets/fonts/simsun.ttc", 16)
    
    -- 设置窗口大小
    love.window.setMode(800, 700)
    
    -- 初始化计时器
    gameTimer = Timer.new()
    
    -- 初始化地图控制器
    mapController = MapController.new()
    
    -- 初始化玩家控制器
    player = PlayerController.new(0, 0)  -- 初始位置不重要，会在setMap中重新定位到地图中央
    player:setMap(mapController.model)
    
    -- 初始化怪物管理器
    monsterManager = MonsterManager.new()
    
    -- 初始化建筑管理器
    buildingManager = BuildingManager.new()
    
    -- 初始化卡牌控制器
    cardController = CardController.new()
    
    -- 初始化背包控制器
    inventoryController = InventoryController.new(30)  -- 明确指定30格容量
    
    -- 初始化角色界面
    characterUI = CharacterUI.new()
    
    -- 初始化手牌
    local initCardTypes = {
        TypeDefines.CARD_TYPES.SLIME_NEST,
        TypeDefines.CARD_TYPES.GOBLIN_HUT,
        TypeDefines.CARD_TYPES.SKELETON_TOMB,
    }
    for _ = 1, 3 do
        local idx = math.random(1, 3)  -- 改为1-9，包含所有9种建筑卡牌
        cardController:addCard(initCardTypes[idx])
    end
    
    -- 将monsterManager设置到BuildingController中
    BuildingController.monsterManager = monsterManager
    
    -- 重置游戏状态
    CombatManager:resetGameState()
end

function love.update(dt)
    -- 更新计时器
    gameTimer:update(dt)
    
    -- 检查玩家是否死亡
    if CombatManager:handlePlayerDeath(player) then
        return  -- 停止其他更新
    end
    
    -- 更新玩家控制器
    player:update(dt, monsterManager:getInstances())
    
    -- 更新游戏逻辑
    player:update(dt)
    
    -- 玩家自动攻击范围内的怪物
    player:autoAttack(monsterManager:getInstances())
    
    -- 更新所有建筑
    buildingManager:updateAll(dt, player)
    
    -- 让所有怪物将玩家设为目标
    monsterManager:setTargetForAll(player)
    
    -- 更新所有怪物
    monsterManager:updateAll(dt, mapController.model)
    
    -- 处理怪物攻击逻辑 (新增)
    CombatManager:handleMonsterAttacks(monsterManager, player)
    
    -- 处理怪物死亡和移除
    CombatManager:processDeadMonsters(monsterManager, player, inventoryController, cardController)
    
    -- 处理子弹碰撞
    CombatManager:handleBulletCollisions(player, monsterManager)
    
    -- 更新物品
    inventoryController:updateItems(player)
end

function love.draw()
    -- 绘制地图
    mapController:draw()
    
    -- 绘制所有建筑
    buildingManager:drawAll()
    
    -- 绘制所有掉落物
    inventoryController:drawItems()
    
    -- 绘制所有怪物和子弹
    monsterManager:drawAll()
    
    -- 绘制玩家
    player:draw()
    
    -- 绘制攻击特效
    for _, effect in ipairs(attackEffects) do
        love.graphics.setColor(effect.color[1], effect.color[2], effect.color[3], effect.alpha or 1)
        love.graphics.circle("fill", effect.x, effect.y, effect.size)
    end
    
    -- 绘制UI
    drawUI()
    
    -- 绘制角色界面
    if characterUI.visible then
        characterUI:draw(player, inventoryController)
    end
    
    -- 绘制卡牌
    cardController:draw()
    
    -- 在最上层绘制物品提示（如果有）
    if characterUI.visible and inventoryController and inventoryController.view.selectedItemInfo then
        inventoryController.view:drawItemTooltip()
    end
    
    -- 游戏结束界面
    if CombatManager:isGameOver() then
        -- 半透明黑色背景
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- 游戏结束文字
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.setFont(gameOverFont)
        local text = "游戏结束"
        local textWidth = gameOverFont:getWidth(text)
        love.graphics.print(text, love.graphics.getWidth()/2 - textWidth/2, love.graphics.getHeight()/2 - 50)
        
        -- 统计信息
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(gameOverStatsFont)
        local playerModel = player:getModel()
        local statsText = string.format("等级: %d", playerModel.attributes.level)
        textWidth = gameOverStatsFont:getWidth(statsText)
        love.graphics.print(statsText, love.graphics.getWidth()/2 - textWidth/2, love.graphics.getHeight()/2 + 10)
        
        -- 重新开始提示
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.setFont(gameOverRestartFont)
        local restartText = "按 R 键重新开始"
        textWidth = gameOverRestartFont:getWidth(restartText)
        love.graphics.print(restartText, love.graphics.getWidth()/2 - textWidth/2, love.graphics.getHeight()/2 + 60)
        
        -- 恢复默认字体
        love.graphics.setFont(gameFont)
    end
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function drawUI()
    -- 绘制玩家属性
    local playerModel = player:getModel()
    local statsY = 10
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("等级: %d", playerModel.attributes.level), 10, statsY)
    love.graphics.print(string.format("经验: %d/%d", playerModel.attributes.exp, playerModel.attributes.nextLevelExp), 10, statsY + 20)
    love.graphics.print(string.format("攻击: %d", playerModel.attributes.attack), 10, statsY + 40)
    love.graphics.print(string.format("防御: %d", playerModel.attributes.defense), 10, statsY + 60)
    
    -- 绘制建筑和怪物数量
    love.graphics.print(string.format("建筑: %d", buildingManager:getCount()), 10, statsY + 80)
    love.graphics.print(string.format("怪物: %d", #monsterManager:getInstances()), 10, statsY + 100)
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function love.mousepressed(x, y, button)
    if button == 1 then  -- 左键点击
        -- 检查是否点击了背包物品
        if characterUI.visible then
            if inventoryController:handleMouseClick(x, y) then
                return
            end
            
            -- 如果有选中的物品，检查是否点击了装备槽
            local selectedItem = inventoryController:getSelectedItem()
            if selectedItem then
                local slot = characterUI:getSlotAt(x, y)
                if slot then
                    -- 符文系统已移除，不再处理符文装备
                    print("符文系统已移除")
                    return
                end
            end
            
            -- 检查是否点击了已装备的物品（卸下装备）
            local slot = characterUI:getSlotAt(x, y)
            if slot then
                -- 符文系统已移除，不再处理符文卸下
                print("符文系统已移除")
                return
            end
        end
        
       -- 检查是否点击了手牌
        if cardController:handleMouseClick(x, y) then
            return
        end
        local selectedCard = cardController:getSelectedCard()
        -- 添加nil检查，防止访问nil值
        if selectedCard then
            print("mousepressed2", selectedCard, selectedCard.config)
            -- 如果有选中的卡牌，尝试在点击位置放置建筑
            if selectedCard.config then
                -- 检查点击位置是否在地图范围内且不在手牌区域
                if y < cardController.view.handArea.y then
                    local tileX = math.floor(x / mapController.model.tileSize) * mapController.model.tileSize + mapController.model.tileSize/2
                    local tileY = math.floor(y / mapController.model.tileSize) * mapController.model.tileSize + mapController.model.tileSize/2

                    -- 获取地形类型并进行判断
                    local terrain = mapController:getTerrainAt(tileX, tileY)
                    print("尝试在 x=" .. tileX .. ", y=" .. tileY .. " 放置建筑，地形类型: " .. (terrain or "nil"))
                    
                    -- 检查是否在玩家防御区域外
                    if not player:canBuildAt(tileX, tileY) then
                        print("无法在玩家防御区域内建造建筑")
                        return
                    end
                    
                    -- 检查地形是否适合该类型建筑
                    local buildingType = selectedCard.config.buildingType
                    if mapController:canBuildAt(tileX, tileY, buildingType) then
                        -- 创建新建筑
                        print("建筑类型: " .. (buildingType or "nil"))
                        
                        if buildingType then
                            -- 使用BuildingManager创建建筑
                            buildingManager:createBuilding(buildingType, tileX, tileY)
                            print("成功创建建筑，当前建筑数量: " .. buildingManager:getCount())
                            
                            -- 使用卡牌
                            cardController:removeCard(selectedCard)
                        end
                    else
                        print("当前地形不适合建造此类型建筑")
                    end
                end
            end
        end
    elseif button == 2 then  -- 右键点击
        -- 检查是否点击了怪物（尝试攻击）
        for _, monster in ipairs(monsterManager:getInstances()) do
            if not monster:isDead() then
                local monsterPos = monster:getPosition()
                local monsterModel = monster:getModel()
                local dx = x - monsterPos.x
                local dy = y - monsterPos.y
                local distance = math.sqrt(dx * dx + dy * dy)
                
                if distance <= monsterModel.size then
                    player:attack(monster)
                    return
                end
            end
        end
        
        -- 检查是否点击了建筑（尝试攻击或拆除）
        local buildings = buildingManager:getInstances()
        for _, building in ipairs(buildings) do
            local bx, by = building:getPosition()
            local dx = x - bx
            local dy = y - by
            local distance = math.sqrt(dx * dx + dy * dy)
            local buildingModel = building:getModel()
            
            if distance <= buildingModel.size * 1.5 then
                -- 攻击建筑
                building:takeDamage(player:getModel().attributes.attack)
                return
            end
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'c' then
        -- 同时切换背包和角色界面的可见性
        characterUI:toggleVisibility()
    elseif key == 'r' then
        -- 如果游戏结束，按R键重新开始
        if CombatManager:isGameOver() then
            -- 重新初始化游戏
            CombatManager:resetGameState()
            
            -- 清除所有建筑
            buildingManager:clearAll()
            
            -- 重新初始化玩家
            player = PlayerController.new(0, 0)
            player:setMap(mapController.model)
            
            -- 重新初始化卡牌
            cardController = CardController.new()
            for i = 1, 3 do
                -- 新游戏只给基础卡牌
                local cardType = math.random(1, 3)  -- 只用基础卡牌 1-3
                cardController:addCard(cardType)
            end
            
            -- 重新初始化背包
            inventoryController = InventoryController.new(30)  -- 明确指定30格容量
            
            -- 重新生成地图
            mapController:regenerate()
            
            -- 清除所有怪物
            monsterManager:clearAll()
            
            -- 将monsterManager重新设置到BuildingController
            BuildingController.monsterManager = monsterManager
            
            return
        end
        
        -- 在游戏中按R重新生成地图
        mapController:regenerate()
    elseif key == 'a' then
        -- 切换AI控制
        player:setAIControl(not player.model.status.isAIControlled)
    elseif key == 'd' then
        -- 抽一张牌，根据玩家等级决定可以抽取的卡牌类型
        local cardTypes = {
            TypeDefines.CARD_TYPES.SLIME_NEST,
            TypeDefines.CARD_TYPES.GOBLIN_HUT,
            TypeDefines.CARD_TYPES.SKELETON_TOMB,
        }
        local idx = math.random(1, #cardTypes)
        cardController:addCard(cardTypes[idx])
    end
end

-- 鼠标移动
function love.mousemoved(x, y)
    -- 更新建筑预览位置
    if cardController:getSelectedIndex() and not inventoryController:isOpen() then
        local buildingType = cardController:getSelectedBuildingType()
        if buildingType then
            -- 检查是否可以在当前位置建造
            local canBuild = player:canBuildAt(x, y) and mapController:canBuildAt(x, y, buildingType)
            -- 保存预览颜色
            if canBuild then
                buildingPreviewColor = {0.5, 1, 0.5, 0.5}  -- 可建造用绿色表示
            else
                buildingPreviewColor = {1, 0.5, 0.5, 0.5}  -- 不可建造用红色表示
            end
            
            -- 更新预览位置
            buildingPreviewX = x
            buildingPreviewY = y
        end
    end
end 