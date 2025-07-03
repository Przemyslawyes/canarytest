local logoutEvent = CreatureEvent("ManaDrainCancel")

function logoutEvent.onLogout(player)
    local playerId = player:getId()
    if activeDrainEvents and activeDrainEvents[playerId] then
        stopEvent(activeDrainEvents[playerId])
        activeDrainEvents[playerId] = nil
    end
    return true
end

logoutEvent:register()