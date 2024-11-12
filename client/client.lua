Core = exports.vorp_core:GetCore()

local traps = {
    [1] = { coords = vector3(1326.0380859375, -1326.38330078125, 76.91000366210938), isOpen = false, entity = nil, model = "" },  -- Rhodes Gunsmith trapdoor
	[2] = { coords = vector3(2858.86279296875, -1194.91650390625, 47.9914436340332), isOpen = false, entity = nil, model = "" },
	[3] = { coords = vector3(-1790.739990234375, -390.15, 159.27999877929688), isOpen = false, entity = nil, model = "" },

}
--================================================================================================
local radius =1.0 -- Ajustez le rayon selon vos besoins
local modelNames = {}

Citizen.CreateThread(function()
    modelNames = LoadResourceFile(GetCurrentResourceName(), "data/rdr3/model_names.lua")
    modelNames = load(modelNames)()
    -- Pré-calculer les hashes
    for model, name in pairs(modelNames) do
        modelNames[GetHashKey(model)] = name
        --modelNames[model] = nil
    end
end)

local reportedEntities = {}

function GetEntitiesInArea(coords, radius)
    local entities = {}
    local radiusSquared = radius * radius -- Calculer une fois
    local handle, entity = FindFirstObject()
    local success
    if handle ~= -1 then
        repeat
            local entityCoords = GetEntityCoords(entity)
            local delta = entityCoords - coords
            local distanceSquared = delta.x * delta.x + delta.y * delta.y + delta.z * delta.z
            if distanceSquared <= radiusSquared then
                table.insert(entities, entity)
            end
            success, entity = FindNextObject(handle)
        until not success
        EndFindObject(handle)
    end
    return entities
end

function GetModelNameFromHash(hash)
    return modelNames[hash] -- Retourne le nom si trouvé, sinon nil
end

--===============================================================================================

-- Function to toggle the trap animation
local function toggleTrap(trapId, isOpen)
	local trap = traps[trapId]
	print(json.encode(trap))
    if trap then
        trap.isOpen = isOpen
        if not isOpen then
            --print("Opening trap " .. trapId) -- debug
            if trap.entity then -- Ensure entity is dynamic and can be moved
                FreezeEntityPosition(trap.entityName, false)
                SetEntityAsMissionEntity(trap.entityName, true, true)
                SetEntityDynamic(trap.entityName, true)
                local targetCoords = vector3(trap.coords.x, trap.coords.y, trap.coords.z) -- Adjust to move upwards
				if trap.model == "Trappe" then
					local i = 0.0
					while i < 90.0 do
						i = i+1.0
						SetEntityRotation(trap.entityName,-i,0.0,165.0,2,true)
					  --SetEntityRotation(entity,pitch,roll,yaw,rotationOrder,bDeadCheck)
						Wait(0)		
					end
				elseif trap.model == "Bibliothèque" then
					local i = 94.0
					while i < 185.0 do
						i = i+1.0
						SetEntityRotation(trap.entityName,0.0,0.0,i,2,true)
						Wait(0)	
					end
				elseif trap.model == "Petite trappe" then
					local i = 0.0
					while i < 90.0 do
						i = i+1.0
						SetEntityRotation(trap.entityName,-i,0.0,145.0,2,true)
						Wait(0)	
					end
				end
            else
                print("Trap entity not found for " .. trapId)
            end           
            --local playerPed = PlayerPedId() -- Play player animation to simulate moving the trap
            --RequestAnimDict("mini@repair")
            --while not HasAnimDictLoaded("mini@repair") do
            --    Citizen.Wait(0)
            --end
            --TaskPlayAnim(playerPed, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 1, 0, false, false, false)
        else
            --print("Closing trap " .. trapId) -- debug
            if trap.entity then
                FreezeEntityPosition(trap.entityName, false) -- Ensure entity is dynamic and can be moved
                SetEntityAsMissionEntity(trap.entityName, true, true)
                SetEntityDynamic(trap.entityName, true)
                local targetCoords = vector3(trap.coords.x, trap.coords.y, trap.coords.z) -- Adjust to move downwards
				if trap.model == "Trappe" then
					local i = -90.0
					while i < 0 do
						i = i+1.0
						SetEntityRotation(trap.entityName,i,0.0,165.0,2,true)
					  --SetEntityRotation(entity,pitch,roll,yaw,rotationOrder,bDeadCheck)
						Wait(0)
					end			
				elseif trap.model == "Bibliothèque" then
					local i = 185.0
					while i > 94.0 do
						i = i-1.0
						SetEntityRotation(trap.entityName,0.0,0.0,i,2,true)
						Wait(0)
					end
				elseif trap.model == "Petite trappe" then
					local i = -90.0
					while i < 0 do
						i = i+1.0
						SetEntityRotation(trap.entityName,i,0.0,145.0,2,true)
						Wait(0)	
					end
				end
            else
                print("Trap entity not found for " .. trapId)
            end
            --local playerPed = PlayerPedId() -- Play player animation to simulate moving the trap
            --RequestAnimDict("mini@repair")
            --while not HasAnimDictLoaded("mini@repair") do
            --    Citizen.Wait(0)
            --end
            --TaskPlayAnim(playerPed, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 1, 0, false, false, false)
        end
    end
end

-- Register to receive updates from the server
RegisterNetEvent("trap:update")
AddEventHandler("trap:update", function(trapId, isOpen)
	traps[trapId].isOpen = isOpen
end) --]]

-- Handle player interaction to toggle traps
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for trapId, trap in pairs(traps) do
            local distance = #(playerCoords - trap.coords)
            if distance < 2.0 then  -- Adjust distance as needed
				local nearbyEntities = GetEntitiesInArea(trap.coords, radius)
				local entitiesData = {}
				for _, entity in pairs(nearbyEntities) do
					local modelHash = GetEntityModel(entity)
					if not reportedEntities[entity] then
						local modelName = GetModelNameFromHash(modelHash)
						if modelName then
							table.insert(entitiesData, {hash = modelHash, name = modelName})
							traps[trapId].model = modelName
							traps[trapId].entity = modelHash
							SetEntityCoords(modelHash, trap.coords.x, trap.coords.y, trap.coords.z, false, false, false, true)
							traps[trapId].entityName = GetClosestObjectOfType(trap.coords.x, trap.coords.y, trap.coords.z, radius, modelHash, false, false, false)
							trapModel = traps[trapId].model
							reportedEntities[entity] = true	
						end
					end
				end
				--[[
			    if #entitiesData > 0 then
					TriggerServerEvent('myScript:sendEntityModels', entitiesData)
				end --]]  -- debug
                DrawText3D(trap.coords, "[E] pour activer la "..trapModel, trapModel)
				
                if IsControlJustReleased(0, 0xCEFD9220) then  -- Key 'E'
					toggleTrap(trapId,traps[trapId].isOpen)
                    TriggerServerEvent("trap:toggle", trapId)
                end
				--Citizen.Wait(10000) -- debug
            end
        end
    end
end)


-- Utility function to draw text in 3D space
function DrawText3D(coords, text, trapModel)
local x = coords.x
local y = coords.y
local z = coords.z
if trapModel == "Trappe" then
    x = coords.x
    y = coords.y+1.0
    z = coords.z+1.0
elseif trapModel == "Bibliothèque" then
    x = coords.x+1.0
    y = coords.y-0.6
    z = coords.z+1.5
elseif trapModel == "Petite trappe" then
    x = coords.x+0.5
    y = coords.y+0.5
    z = coords.z+1.0
end
    local r, g, b, a = 255, 255, 255, 255
    if color then
        r, g, b, a = table.unpack(color)
    end
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    local str = VarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    if onScreen then
        SetTextScale(0.4, 0.4)
        SetTextFontForCurrentCommand(25) -- font style
        SetTextColor(r, g, b, a)
        SetTextCentre(1)
        DisplayText(str, _x, _y)
        local factor = (string.len(text)) / 100 -- draw sprite size
        DrawSprite("feeds", "toast_bg", _x, _y + 0.0125, 0.015 + factor, 0.03, 0.1, 0, 0, 0, 200, false)
    end
end
