-- 主入口文件
local Player = require('src/entities/Player')
local Map = require('src/systems/Map')
local Monster = require('src/entities/Monster')
local Building = require('src/entities/Building')
local ItemSystem = require('src/systems/Item')
local CardController = require('src/controllers/CardController')
local InventoryController = require('src/controllers/InventoryController')
local CharacterUI = require('src/ui/CharacterUI')
local Timer = require('lib/timer')  -- 引入timer库

-- 游戏状态
local player
local map
local monsters = {}
local buildings = {}  -- 存储地图上的建筑
local items = {}  -- 地上的掉落物
local cardController
local inventoryController
local characterUI
local gameFont
local gameTimer  -- 全局计时器实例
local attackEffects = {}  -- 攻击效果数组

function love.load()
    
    -- 初始化动画系统
    local AnimationSystem = require('src/systems/Animation')
    AnimationSystem.initialize()
    
    -- 使用默认字体
    gameFont = love.graphics.getFont()
    
    -- 设置窗口大小
    love.window.setMode(900, 800)
    
    -- 初始化计时器
    gameTimer = Timer.new()
    
    -- 初始化地图
    map = Map:new()
    
    -- 初始化玩家
    player = Player:new(0, 0)  -- 初始位置不重要，会在setMap中重新定位到地图中央
    player:setMap(map)
    player:setTimer(gameTimer)  -- 传递timer实例给Player对象
    player:setAttackEffects(attackEffects)  -- 传递攻击特效数组给玩家
    
    -- 初始化卡牌控制器
    cardController = CardController:new()
    
    -- 初始化背包控制器
    inventoryController = InventoryController:new()
    
    -- 初始化角色界面
    characterUI = CharacterUI:new()
    
    -- 初始化手牌
    for i = 1, 3 do
        local cardType = math.random(1, 3)
        cardController:addCard(cardType)
    end
end

function love.update(dt)
    -- 更新计时器
    gameTimer:update(dt)
    
    -- 更新游戏逻辑
    player:update(dt)
    
    -- 玩家自动攻击范围内的怪物
    player:autoAttack(monsters)
    
    -- 更新所有建筑
    for i = #buildings, 1, -1 do
        local building = buildings[i]
        building:update(dt, monsters)
        
        -- 如果建筑消失，从列表中移除
        if building.status.isDead then
            table.remove(buildings, i)
        end
    end
    
    -- 更新所有怪物并处理死亡
    for i = #monsters, 1, -1 do
        local monster = monsters[i]
        monster:update(dt, map)
        
        -- 如果怪物死亡
        if monster.status.isDead then
            -- 生成掉落物
            local drops = ItemSystem.Item.generateDrops(monster.type, monster.x, monster.y)
            for _, drop in ipairs(drops) do
                if drop.isCard then
                    -- 创建卡牌
                    local cardType = drop.buildingCardType or math.random(1, 3)
                    cardController:addCard(cardType)
                else
                    -- 添加装备掉落物
                    if not inventoryController:addItem(drop) then
                        -- 如果背包已满，将物品放在地上
                        table.insert(items, drop)
                    end
                end
            end
            
            -- 给玩家经验值
            player:gainExp(monster.attributes.exp)
            -- 移除怪物
            table.remove(monsters, i)
        else
            -- 设置玩家为目标
            monster:setTarget(player)
        end
    end
    
    -- 检查物品拾取
    for i = #items, 1, -1 do
        local item = items[i]
        if item:isInRange(player.x, player.y) then
            -- 将物品添加到背包
            if inventoryController:addItem(item) then
                table.remove(items, i)
            end
        end
    end
end

function love.draw()
    -- 绘制地图
    map:draw()
    
    -- 绘制所有建筑
    for _, building in ipairs(buildings) do
        building:draw()
    end
    
    -- 绘制所有掉落物
    for _, item in ipairs(items) do
        item:draw()
    end
    
    -- 绘制所有怪物
    for _, monster in ipairs(monsters) do
        monster:draw()
    end
    
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
    
    -- 重置颜色
    love.graphics.setColor(1, 1, 1)
end

function drawUI()
    -- 绘制玩家属性
    local statsY = 10
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("等级: %d", player.attributes.level), 10, statsY)
    love.graphics.print(string.format("经验: %d/%d", player.attributes.exp, player.attributes.nextLevelExp), 10, statsY + 20)
    love.graphics.print(string.format("攻击: %d", player.attributes.attack), 10, statsY + 40)
    love.graphics.print(string.format("防御: %d", player.attributes.defense), 10, statsY + 60)
    
    -- 绘制建筑和怪物数量
    love.graphics.print(string.format("建筑: %d", #buildings), 10, statsY + 80)
    love.graphics.print(string.format("怪物: %d", #monsters), 10, statsY + 100)
    
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
                    -- 检查物品类型是否匹配装备槽
                    local canEquip = false
                    if slot == "weapon" and selectedItem.config.type == ItemSystem.EQUIPMENT_TYPES.WEAPON then
                        canEquip = true
                    elseif slot == "armor" and selectedItem.config.type == ItemSystem.EQUIPMENT_TYPES.ARMOR then
                        canEquip = true
                    elseif slot == "accessory" and selectedItem.config.type == ItemSystem.EQUIPMENT_TYPES.ACCESSORY then
                        canEquip = true
                    end
                    
                    if canEquip then
                        -- 尝试装备物品
                        local oldEquipment = player:equip(selectedItem)
                        if oldEquipment then
                            -- 将旧装备放回背包
                            inventoryController:addItem(oldEquipment)
                        end
                        -- 从背包移除已装备的物品
                        inventoryController:removeItem(inventoryController.model.selected)
                    end
                    return
                end
            end
            
            -- 检查是否点击了已装备的物品（卸下装备）
            local slot = characterUI:getSlotAt(x, y)
            if slot and player.equipment[slot] then
                local equipment = player.equipment[slot]
                if inventoryController:addItem(equipment) then
                    player.equipment[slot] = nil
                end
                return
            end
        end
        
        -- 检查是否点击了手牌
        if cardController:handleMouseClick(x, y) then
            return
        end
        
        -- 如果有选中的卡牌，尝试在点击位置放置建筑
        if cardController.selectedCard and cardController.selectedCard.config then
            -- 检查点击位置是否在地图范围内且不在手牌区域
            if y < cardController.view.handArea.y then
                local tileX = math.floor(x / map.tileSize) * map.tileSize + map.tileSize/2
                local tileY = math.floor(y / map.tileSize) * map.tileSize + map.tileSize/2

                -- 获取地形类型并进行判断
                local terrain = map:getTerrainAt(tileX, tileY)
                print("尝试在 x=" .. tileX .. ", y=" .. tileY .. " 放置建筑，地形类型: " .. (terrain or "nil"))
                
                -- 检查是否在玩家防御区域外
                if not player:canBuildAt(tileX, tileY) then
                    print("无法在玩家防御区域内建造建筑")
                    return
                end
                
                -- 防止放置在水上（水的地形类型是2，参考config/terrain.lua）
                if terrain and terrain ~= 2 then  -- TerrainConfig.TERRAIN_TYPES.WATER = 2
                    -- 创建新建筑
                    local buildingType = cardController.selectedCard.config.buildingType
                    print("建筑类型: " .. (buildingType or "nil"))
                    
                    if buildingType then
                        local building = Building:new(buildingType, tileX, tileY)
                        
                        -- 应用卡牌中的自定义属性到建筑
                        if cardController.selectedCard.config.lifespan then
                            building.attributes.lifespan = cardController.selectedCard.config.lifespan
                            building.attributes.remainingTime = building.attributes.lifespan
                        end
                        
                        if cardController.selectedCard.config.spawnRate then
                            building.attributes.spawnRate = cardController.selectedCard.config.spawnRate
                            building.status.timeToNextSpawn = building.attributes.spawnRate
                        end
                        
                        -- 添加建筑到列表中
                        table.insert(buildings, building)
                        print("成功创建建筑，当前建筑数量: " .. #buildings)
                        
                        -- 使用卡牌
                        cardController:removeCard(cardController.selectedCard)
                    end
                end
            end
        end
    elseif button == 2 then  -- 右键点击
        -- 检查是否点击了怪物（尝试攻击）
        for _, monster in ipairs(monsters) do
            local dx = x - monster.x
            local dy = y - monster.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance <= monster.config.size then
                player:attack(monster)
                return
            end
        end
        
        -- 检查是否点击了建筑（尝试攻击或拆除）
        for _, building in ipairs(buildings) do
            local dx = x - building.x
            local dy = y - building.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance <= building.size * 1.5 then
                -- 攻击建筑
                building:takeDamage(player.attributes.attack)
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
        -- 重新生成地图
        map:generate()
    elseif key == 'a' then
        -- 切换AI控制
        player:setAIControl(not player.status.isAIControlled)
    elseif key == 'd' then
        -- 抽一张牌
        local cardType = math.random(1, 3)
        cardController:addCard(cardType)
    end
end 