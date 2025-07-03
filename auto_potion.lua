---@moveevent (Canary revscriptsys)

local ITEM_ID = 3154
local GOLD_ID = 3031
local AUTO_HEAL_STORAGE = 100024 -- unique storage key

-- Main auto heal function
local function autoGoldHeal(playerId)
    local player = Player(playerId)
    if not player then
        return
    end

    -- Check if item is still equipped in light slot
    local lightItem = player:getSlotItem(CONST_SLOT_AMMO)
    if not lightItem or lightItem:getId() ~= ITEM_ID then
        player:setStorageValue(AUTO_HEAL_STORAGE, -1)
        return
    end

    -- Mana heal if below 40%
    if (player:getMana() / player:getMaxMana()) * 100 < 40 then
        local cost = 51
        local healAmount = 135
        local removed = false

        -- Try remove from inventory
        if player:removeItem(GOLD_ID, cost) then
            removed = true
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You paid " .. cost .. " gold from inventory to restore " .. healAmount .. " mana.")
        -- If insufficient, try bank balance
        elseif player:getBankBalance() >= cost then
            player:setBankBalance(player:getBankBalance() - cost)
            removed = true
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You paid " .. cost .. " gold from your bank to restore " .. healAmount .. " mana.")
        end

        if removed then
            player:addMana(healAmount)
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You lack gold (inventory and bank) for mana heal.")
        end
    end

    -- Health heal if below 40%
    if (player:getHealth() / player:getMaxHealth()) * 100 < 40 then
        local cost = 45
        local healAmount = 200
        local removed = false

        if player:removeItem(GOLD_ID, cost) then
            removed = true
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You paid " .. cost .. " gold from inventory to restore " .. healAmount .. " health.")
        elseif player:getBankBalance() >= cost then
            player:setBankBalance(player:getBankBalance() - cost)
            removed = true
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You paid " .. cost .. " gold from your bank to restore " .. healAmount .. " health.")
        end

        if removed then
            player:addHealth(healAmount)
            player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You lack gold (inventory and bank) for health heal.")
        end
    end

    -- Repeat every second
    addEvent(autoGoldHeal, 1000, playerId)
end

-- MoveEvent on equip in light slot
local equipEvent = MoveEvent()

function equipEvent.onEquip(player, item, slot, pos)
    if item:getId() == ITEM_ID and slot == CONST_SLOT_AMMO then
        if player:getStorageValue(AUTO_HEAL_STORAGE) ~= 1 then
            player:setStorageValue(AUTO_HEAL_STORAGE, 1)
            autoGoldHeal(player:getId())
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Auto Gold Heal activated.")
        end
    end
    return true
end

equipEvent:type("equip")
equipEvent:id(ITEM_ID)
equipEvent:slot("ammo") -- light slot is ammo slot ID in Canary
equipEvent:register()

-- MoveEvent on de-equip to disable
local deequipEvent = MoveEvent()

function deequipEvent.onDeEquip(player, item, slot, pos)
    if item:getId() == ITEM_ID and slot == CONST_SLOT_AMMO then
        player:setStorageValue(AUTO_HEAL_STORAGE, -1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Auto Gold Heal deactivated.")
    end
    return true
end

deequipEvent:type("deequip")
deequipEvent:id(ITEM_ID)
deequipEvent:slot("ammo")
deequipEvent:register()
