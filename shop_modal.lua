---@talkaction !shop

local shopItems = {
    -- {name, itemId, price}
    {"Blank Rune", 2260, 10},
    {"Mana Potion", 268, 50},
    {"Health Potion", 266, 45},
    {"Backpack", 2854, 10}
}

local SHOP_MODAL_ID = 1001

local shopTalkAction = TalkAction("!shop")

function shopTalkAction.onSay(player, words, param)
    local window = ModalWindow {
        title = "Shop",
        message = "Select an item to buy:"
    }

    -- Add items as choices
    for i, item in ipairs(shopItems) do
        local text = string.format("%s - %d gold", item[1], item[3])
        window:addChoice(text)
    end

    window:addButton("Buy")
    window:addButton("Cancel")

    window:setDefaultEnterButton(0)
    window:setDefaultEscapeButton(1)

    window:sendToPlayer(player, SHOP_MODAL_ID, function(player, choiceText, buttonText)
        if buttonText == "Buy" then
            -- Extract item index from choice text
            local index = nil
            for i, item in ipairs(shopItems) do
                if choiceText:find(item[1]) then
                    index = i
                    break
                end
            end

            if not index then
                player:sendCancelMessage("Invalid selection.")
                return
            end

            local selectedItem = shopItems[index]
            local itemName, itemId, price = table.unpack(selectedItem)

            if player:removeMoneyBank(price) then
                player:addItem(itemId, 1)
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You bought %s for %d gold.", itemName, price))
                player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
            else
                player:sendCancelMessage("You do not have enough money.")
                player:getPosition():sendMagicEffect(CONST_ME_POFF)
            end
        else
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Shop closed.")
        end
    end)

    return false
end

shopTalkAction:groupType("normal")
shopTalkAction:register()
