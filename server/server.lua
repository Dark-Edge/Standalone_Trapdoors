local openTraps = {
    [1] = { coords = vector3(1326.0380859375, -1326.38330078125, 76.91000366210938), isOpen = false}, 	-- Rhodes Gunsmith trapdoor
	[2] = { coords = vector3(2858.86279296875, -1194.91650390625, 47.9914436340332), isOpen = false}, 	-- st deni's market bookshell
	[3] = { coords = vector3(-1790.739990234375, -390.15, 159.27999877929688), isOpen = false}, 	-- st deni's market bookshell
}  -- Store the current state of all traps

RegisterNetEvent("trap:toggle")
AddEventHandler("trap:toggle", function(trapId)
    local _source = source
    if openTraps[trapId] == nil then
        openTraps[trapId].isOpen = false
    end
    openTraps[trapId].isOpen = not openTraps[trapId].isOpen
    -- Notify all clients about the state change
    TriggerClientEvent("trap:update", -1, trapId, openTraps[trapId].isOpen)
end)

-- When a player joins, send them the current state of all traps
AddEventHandler("playerConnecting", function()
    local _source = source
    TriggerClientEvent("trap:initialize", openTraps)
end)

-- When the resource starts, initialize the traps state for all clients
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        for _, playerId in ipairs(GetPlayers()) do
            TriggerClientEvent("trap:initialize", playerId, openTraps)
        end
    end
end)

-- When the resource starts, initialize the traps state for all clients
AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        for _, playerId in ipairs(GetPlayers()) do
            TriggerClientEvent("trap:initialize", playerId, openTraps)
        end
    end
end)
--]]


RegisterServerEvent('myScript:sendEntityModels')
AddEventHandler('myScript:sendEntityModels', function(entitiesData)
    local _source = source
	--print(json.encode(entitiesData))
    for _, data in pairs(entitiesData) do
        print(string.format("Le joueur %d a signalé une entité avec le hash %s et le nom %s", _source, data.hash, data.name))
        -- Vous pouvez traiter ou stocker les données comme nécessaire
    end
end)
