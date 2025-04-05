-- 主入口文件
local Player = require('player')
local Map = require('map')
local Monster = require('monster')
local ItemSystem = require('item')
local CardController = require('card_controller')
local InventoryController = require('inventory_controller')
local CharacterUI = require('character_ui')

-- 游戏状态
local player
local map
local monsters = {}
local items = {}  -- 地上的掉落物
local cardController
local inventoryController
local characterUI
local gameFont

function love.load()
    -- 加载字体
    gameFont = love.graphics.newFont("assets/fonts/simsun.ttc", 14)
    love.graphics.setFont(gameFont)
    
    -- 设置窗口大小
    love.window.setMode(800, 700)
    
    -- 初始化地图
    map = Map:new()
    
    -- 初始化玩家
    player = Player:new(100, 100)
    player:setMap(map)
    
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
    -- 更新游戏逻辑
    player:update(dt)
    player:updateAI(dt, monsters)
    
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
                    local cardType = cardController:getCardType(drop.monsterType)
                    if cardType then
                        cardController:addCard(cardType)
                    end
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
    
    -- 绘制UI
    drawUI()
    
    -- 绘制角色界面
    if characterUI.visible then
        characterUI:draw(player, inventoryController)
    end
    
    -- 绘制卡牌
    cardController:draw()
end

function drawUI()
    -- 绘制玩家属性
    local statsY = 10
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("等级: %d", player.attributes.level), 10, statsY)
    love.graphics.print(string.format("经验: %d/%d", player.attributes.exp, player.attributes.nextLevelExp), 10, statsY + 20)
    love.graphics.print(string.format("攻击: %d", player.attributes.attack), 10, statsY + 40)
    love.graphics.print(string.format("防御: %d", player.attributes.defense), 10, statsY + 60)
    
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
        
        -- 如果有选中的卡牌，尝试在点击位置召唤怪物
        if cardController.selectedCard and cardController.selectedCard.config then
            -- 检查点击位置是否在地图范围内
            local tileX = math.floor(x / map.tileSize) * map.tileSize + map.tileSize/2
            local tileY = math.floor(y / map.tileSize) * map.tileSize + map.tileSize/2
            
            if y < cardController.handArea.y then  -- 确保不会在手牌区域召唤
                -- 创建新怪物
                local monster = Monster:new(cardController.selectedCard.config.monsterType, tileX, tileY)
                if monster and monster.config then
                    table.insert(monsters, monster)
                    cardController:removeCard(cardController.selectedCard)
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
                break
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