local vehDeleteMode = false
local vehDelPos = nil
local vehDelDist = 0.0
local LineDistance = 5
local isDrawingLine = false

function SetLineDistance(number)
    LineDistance = tonumber(number)
end

function ToggleDrawLine()
    isDrawingLine = not isDrawingLine
    if isDrawingLine then
        QBCore.Functions.Notify('Coords Line On', "success")
    else
        QBCore.Functions.Notify('Coords Line Off', "success")
    end
end

function CopyDrawLine(type)
    if isDrawingLine then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerHeading = GetEntityHeading(playerPed)
        local cameraRotation = GetGameplayCamRot(2)
        local camPitch = math.rad(cameraRotation.x)
        local camYaw = math.rad(cameraRotation.y)
        local lineLength = 10.0
        local forwardVector = vector3(
            math.sin(-playerHeading * math.pi / 180.0) * math.cos(camPitch),
            math.cos(-playerHeading * math.pi / 180.0) * math.cos(camPitch),
            math.sin(camPitch)
        )
        local lineEnd = playerCoords + forwardVector * lineLength
        local rayHandle = StartShapeTestRay(playerCoords.x, playerCoords.y, playerCoords.z, lineEnd.x, lineEnd.y,
            lineEnd.z, 7, playerPed, 0)
        local _, hit, hitCoords, _, _ = GetShapeTestResult(rayHandle)
        if hit then
            local coords = {
                x = hitCoords.x,
                y = hitCoords.y,
                z = hitCoords.z
            }
            local heading = playerHeading + 180.0
            if heading > 360.0 then
                heading = heading - 360.0
            end
            if type == '2' then
                QBCore.Functions.Notify(Lang:t("success.coords_copied"), "success")
                SendNUIMessage({
                    string = string.format('vec2(%.2f, %.2f)', coords.x, coords.z)
                })
            elseif type == '3' then
                QBCore.Functions.Notify(Lang:t("success.coords_copied"), "success")
                SendNUIMessage({
                    string = string.format('vec3(%.2f, %.2f, %.2f)', coords.x, coords.y, coords.z)
                })
            elseif type == '4' then
                QBCore.Functions.Notify(Lang:t("success.coords_copied"), "success")
                SendNUIMessage({
                    string = string.format('vec4(%.2f, %.2f, %.2f, %.2f)', coords.x, coords.y, coords.z, heading)
                })
            end
        end
    else
        QBCore.Functions.Notify('Coords Line Not Enabled', "success")
    end
end

local function round(input, decimalPlaces)
    return tonumber(string.format("%." .. (decimalPlaces or 0) .. "f", input))
end

local function CopyToClipboard(dataType)
    local ped = PlayerPedId()
    if dataType == 'coords2' then
        local coords = GetEntityCoords(ped)
        local x = coords.x
        local z = coords.z
        SendNUIMessage({
            string = string.format('vector2(%s, %s)', x, z)
        })
        QBCore.Functions.Notify(Lang:t("success.coords_copied"), "success")
    elseif dataType == 'coords3' then
        local coords = GetEntityCoords(ped)
        local x = round(coords.x, 2)
        local y = round(coords.y, 2)
        local z = round(coords.z, 2)
        SendNUIMessage({
            string = string.format('vector3(%s, %s, %s)', x, y, z)
        })
        QBCore.Functions.Notify(Lang:t("success.coords_copied"), "success")
    elseif dataType == 'coords4' then
        local coords = GetEntityCoords(ped)
        local x = round(coords.x, 2)
        local y = round(coords.y, 2)
        local z = round(coords.z, 2)
        local heading = GetEntityHeading(ped)
        local h = round(heading, 2)
        SendNUIMessage({
            string = string.format('vector4(%s, %s, %s, %s)', x, y, z, h)
        })
        QBCore.Functions.Notify(Lang:t("success.coords_copied"), "success")
    elseif dataType == 'heading' then
        local heading = GetEntityHeading(ped)
        local h = round(heading, 2)
        SendNUIMessage({
            string = h
        })
        QBCore.Functions.Notify(Lang:t("success.heading_copied"), "success")
    elseif dataType == 'freeaimEntity' then
        local entity = GetFreeAimEntity()

        if entity then
            local entityHash = GetEntityModel(entity)
            local entityName = Entities[entityHash] or "Unknown"
            local entityCoords = GetEntityCoords(entity)
            local entityHeading = GetEntityHeading(entity)
            local entityRotation = GetEntityRotation(entity)
            local x = QBCore.Shared.Round(entityCoords.x, 2)
            local y = QBCore.Shared.Round(entityCoords.y, 2)
            local z = QBCore.Shared.Round(entityCoords.z, 2)
            local rotX = QBCore.Shared.Round(entityRotation.x, 2)
            local rotY = QBCore.Shared.Round(entityRotation.y, 2)
            local rotZ = QBCore.Shared.Round(entityRotation.z, 2)
            local h = QBCore.Shared.Round(entityHeading, 2)
            SendNUIMessage({
                string = string.format('Model Name:\t%s\nModel Hash:\t%s\n\nHeading:\t%s\nCoords:\t\tvector3(%s, %s, %s)\nRotation:\tvector3(%s, %s, %s)', entityName, entityHash, h, x, y, z, rotX, rotY, rotZ)
            })
            QBCore.Functions.Notify(Lang:t("success.entity_copy"), "success")
        else
            QBCore.Functions.Notify(Lang:t("error.failed_entity_copy"), "error")
        end
    end
end

local function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

local function ToggleShowCoordinates()
    local x = 0.4
    local y = 0.025
    showCoords = not showCoords
    CreateThread(function()
        while showCoords do
            local coords = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading(PlayerPedId())
            local c = {}
            c.x = round(coords.x, 2)
            c.y = round(coords.y, 2)
            c.z = round(coords.z, 2)
            heading = round(heading, 2)
            Wait(0)
            Draw2DText(string.format('~w~'..Lang:t("info.ped_coords") .. '~b~ vector4(~w~%s~b~, ~w~%s~b~, ~w~%s~b~, ~w~%s~b~)', c.x, c.y, c.z, heading), 4, {66, 182, 245}, 0.4, x + 0.0, y + 0.0)
        end
    end)
end

local function ToggleVehicleDeveloperMode()
    local x = 0.2
    local y = 0.818
    vehicleDevMode = not vehicleDevMode
    CreateThread(function()
        while vehicleDevMode do
            local ped = PlayerPedId()
            Wait(0)
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local netID = VehToNet(vehicle)
                local hash = GetEntityModel(vehicle)
                local modelName = GetLabelText(GetDisplayNameFromVehicleModel(hash))
                local eHealth = GetVehicleEngineHealth(vehicle)
                local bHealth = GetVehicleBodyHealth(vehicle)
                Draw2DText(Lang:t("info.vehicle_dev_data"), 4, {66, 182, 245}, 0.4, x + 0.0, y + 0.0)
                Draw2DText(string.format(Lang:t("info.ent_id") .. '~b~%s~s~ | ' .. Lang:t("info.net_id") .. '~b~%s~s~', vehicle, netID), 4, {255, 255, 255}, 0.4, x + 0.0, y + 0.025)
                Draw2DText(string.format(Lang:t("info.model") .. '~b~%s~s~ | ' .. Lang:t("info.hash") .. '~b~%s~s~', modelName, hash), 4, {255, 255, 255}, 0.4, x + 0.0, y + 0.050)
                Draw2DText(string.format(Lang:t("info.eng_health") .. '~b~%s~s~ | ' .. Lang:t("info.body_health") .. '~b~%s~s~', round(eHealth, 2), round(bHealth, 2)), 4, {255, 255, 255}, 0.4, x + 0.0, y + 0.075)
            end
        end
    end)
end

local DevMenuButton0 = DevMenu:AddButton({
    icon = '📋',
    label = Lang:t("menu.copy_vector2"),
    value = 'coords',
    description = Lang:t("desc.vector2_desc")
})
DevMenuButton0:On("select", function()
    CopyToClipboard('coords2')
end)

local DevMenuButton1 = DevMenu:AddButton({
    icon = '📋',
    label = Lang:t("menu.copy_vector3"),
    value = 'coords',
    description = Lang:t("desc.vector3_desc")
})
DevMenuButton1:On("select", function()
    CopyToClipboard('coords3')
end)

local DevMenuButton2 = DevMenu:AddButton({
    icon = '📋',
    label = Lang:t("menu.copy_vector4"),
    value = 'coords',
    description = Lang:t("desc.vector4_desc")
})
DevMenuButton2:On("select", function()
    CopyToClipboard('coords4')
end)

local DevMenuButton3 = DevMenu:AddCheckbox({
    icon = '📍',
    label = Lang:t("menu.display_coords"),
    value = nil,
    description = Lang:t("desc.display_coords_desc")
})
DevMenuButton3:On('change', function()
    ToggleShowCoordinates()
end)

local DevMenuButton4 = DevMenu:AddButton({
    icon = '📋',
    label = Lang:t("menu.copy_heading"),
    value = 'heading',
    description = Lang:t("desc.copy_heading_desc")
})
DevMenuButton4:On("select", function()
    CopyToClipboard('heading')
end)

local DevMenuButton5 = DevMenu:AddButton({
    icon = '🚘',
    label = Lang:t("menu.vehicle_dev_mode"),
    value = nil,
    description = Lang:t("desc.vehicle_dev_mode_desc")
})
DevMenuButton5:On('select', function()
    ToggleVehicleDeveloperMode()
end)

local DevMenuButton6 = DevMenu:AddCheckbox({
    icon = '⚫',
    label = Lang:t("menu.hud_dev_mode"),
    value = DevMenu,
    description = Lang:t("desc.hud_dev_mode_desc")
})
local dev = false
DevMenuButton6:On('change', function(item, newValue, oldValue)
    dev = not dev
    TriggerEvent('qb-admin:client:ToggleDevmode')
    if dev then
        SetPlayerInvincible(PlayerId(), true)
        while dev do
            TriggerServerEvent("QBCore:Server:SetMetaData", "hunger", QBCore.Functions.GetPlayerData().metadata["hunger"] + 10)
            TriggerServerEvent("QBCore:Server:SetMetaData", "thirst", QBCore.Functions.GetPlayerData().metadata["thirst"] + 10)
            TriggerServerEvent("QBCore:Server:SetMetaData", "armor", QBCore.Functions.GetPlayerData().metadata["armor"] + 10)
            Wait(20000)
        end
        SetPlayerInvincible(PlayerId(), false)
    end
end)

local DevMenuButton7 = DevMenu:AddCheckbox({
    icon = '🔫',
    label = Lang:t("menu.delete_laser"),
    value = DevMenu,
    description = Lang:t("desc.delete_laser_desc")
})
local deleteLazer = false
DevMenuButton7:On('change', function(item, newValue, oldValue)
    deleteLazer = not deleteLazer
end)

local DevMenuButton8 = DevMenu:AddCheckbox({
    icon = '🎥',
    label = Lang:t("menu.noclip"),
    value = DevMenu,
    description = Lang:t("desc.noclip_desc")
})
DevMenuButton8:On('change', function(item, newValue, oldValue)
    ToggleNoClip()
end)

local DevMenuButton9 = DevMenu:AddButton({
    icon = '🔑',
    label = 'Get Vehicle Keys',
    value = 'vehiclekeys',
    description = 'Give yourself vehicle keys'
})
DevMenuButton9:On('change', function(item, newValue, oldValue)
    ForceGiveKeys()
end)

local DevMenuButton10 = DevMenu:AddCheckbox({
    icon = '🗨',
    label = 'Change Plate',
    value = DevMenu,
    description = 'Change Vehicle Plate'
})
DevMenuButton10:On('change', function(item, newValue, oldValue)
    ChangePlate()
end)

local DevMenuButton11 = DevMenu:AddButton({
    icon = '👀',
    label = 'Entity View',
    value = EntityMenu,
    description = 'Entity View'
})

local DevMenuButton12 = DevMenu:AddButton({
    icon = '👀',
    label = 'Line Coords',
    value = LineCoords,
    description = 'Get Coords At The End Of A Line'
})

local LineCoordsButton1 = LineCoords:AddCheckbox({
    icon = '🔦',
    label = 'Toggle Coords Line',
    value = LineCoords,
    description = 'Toggle a line for viewing coords at the end of it'
})
LineCoordsButton1:On('change', function(item, newValue, oldValue)
    ToggleDrawLine()
end)

local LineCoordsButton2 = LineCoords:AddButton({
    icon = '2️⃣',
    label = 'Copy Coords Line Vec2',
    value = LineCoords,
    description = 'Copy the coords at the end of the line'
})
LineCoordsButton2:On('select', function(item, newValue, oldValue)
    CopyDrawLine('2')
end)

local LineCoordsButton3 = LineCoords:AddButton({
    icon = '3️⃣',
    label = 'Copy Coords Line Vec3',
    value = LineCoords,
    description = 'Copy the coords at the end of the line'
})
LineCoordsButton3:On('select', function(item, newValue, oldValue)
    CopyDrawLine('3')
end)

local LineCoordsButton4 = LineCoords:AddButton({
    icon = '4️⃣',
    label = 'Copy Coords Line Vec4',
    value = LineCoords,
    description = 'Copy the coords at the end of the line'
})
LineCoordsButton4:On('select', function(item, newValue, oldValue)
    CopyDrawLine('4')
end)

local LineCoordsButton5 = LineCoords:AddSlider({
    icon = '📏',
    label = 'Line Length',
    value = GetCurrentEntityViewDistance(),
    values = {{
        label = '5',
        value = '5',
        description = 'Line Length'
    }, {
        label = '10',
        value = '10',
        description = 'Line Length'
    }, {
        label = '15',
        value = '15',
        description = 'Line Length'
    }, {
        label = '20',
        value = '20',
        description = 'Line Length'
    }, {
        label = '25',
        value = '25',
        description = 'Line Length'
    }, {
        label = '30',
        value = '30',
        description = 'Line Length'
    }, {
        label = '35',
        value = '35',
        description = 'Line Length'
    }, {
        label = '40',
        value = '40',
        description = 'Line Length'
    }, {
        label = '45',
        value = '45',
        description = 'Line Length'
    }, {
        label = '50',
        value = '50',
        description = 'Line Length'
    }}
})

LineCoordsButton5:On("select", function(_, value)
    SetLineDistance(value)
    QBCore.Functions.Notify('Set Line Distance To '..tostring(value))
end)


local EntityMenuButton0 = EntityMenu:AddCheckbox({
    icon = '💡',
    label = 'Toggle Entity View',
    value = DevMenu,
    description = 'Toggles Entity View'
})
EntityMenuButton0:On('change', function(item, newValue, oldValue)
    ToggleEntityFreeView()
end)

local EntityMenuButton1 = EntityMenu:AddCheckbox({
    icon = '👀',
    label = 'Toggle Entity Object View',
    value = DevMenu,
    description = 'Toggles Entity Object View'
})
EntityMenuButton1:On('change', function(item, newValue, oldValue)
    ToggleEntityObjectView()
end)


local EntityMenuButton2 = EntityMenu:AddCheckbox({
    icon = '👀',
    label = 'Toggle Entity Vehicle View',
    value = DevMenu,
    description = 'Toggles Entity Vehicle View'
})
EntityMenuButton2:On('change', function(item, newValue, oldValue)
    ToggleEntityVehicleView()
end)

local EntityMenuButton3 = EntityMenu:AddCheckbox({
    icon = '👀',
    label = 'Toggle Entity Ped View',
    value = DevMenu,
    description = 'Toggles Entity Ped View'
})
EntityMenuButton3:On('change', function(item, newValue, oldValue)
    ToggleEntityPedView()
end)

local EntityMenuButton4 = EntityMenu:AddButton({
    icon = '📋',
    label = Lang:t("menu.entity_view_freeaim_copy"),
    value = 'freeaimEntity',
    description = Lang:t("desc.entity_view_freeaim_copy_desc")
})

EntityMenuButton4:On("select", function()
    CopyToClipboard('freeaimEntity')
end)

local EntityMenuButton5 = EntityMenu:AddSlider({
    icon = '📏',
    label = Lang:t("menu.entity_view_distance"),
    value = GetCurrentEntityViewDistance(),
    values = {{
        label = '5',
        value = '5',
        description = Lang:t("menu.entity_view_distance")
    }, {
        label = '10',
        value = '10',
        description = Lang:t("menu.entity_view_distance")
    }, {
        label = '15',
        value = '15',
        description = Lang:t("menu.entity_view_distance")
    }, {
        label = '20',
        value = '20',
        description = Lang:t("menu.entity_view_distance")
    }, {
        label = '25',
        value = '25',
        description = Lang:t("menu.entity_view_distance")
    }, {
        label = '30',
        value = '30',
        description = Lang:t("menu.entity_view_distance")
    }, {
        label = '35',
        value = '35',
        description = Lang:t("menu.entity_view_distance")
    }, {
        label = '40',
        value = '40',
        description = Lang:t("menu.entity_view_distance")
    }, {
        label = '45',
        value = '45',
        description = Lang:t("menu.entity_view_distance")
    }, {
        label = '50',
        value = '50',
        description = Lang:t("menu.entity_view_distance")
    }}
})

EntityMenuButton5:On("select", function(_, value)
    SetEntityViewDistance(value)
    QBCore.Functions.Notify(Lang:t("info.entity_view_distance", {distance = value}))
end)



function int2float(integer)
    return integer + 0.0
end

local slider = DevMenu:AddSlider({ icon = '🚓', label = 'Vehicle Area Delete', value = '0', values = {
    { label = 'Off', value = '0.0', description = 'Off' },
    { label = 'Low', value = '8.0', description = '8 Meters' },
    { label = 'Medium', value = '15.0', description = '15 Meters' },
    { label = 'High', value = '25.0', description = '25 Meters' },
    { label = 'Insane', value = '30.0', description = '30 Meters' }
}})

slider:On('select', function(item, value)
    local position = GetEntityCoords(PlayerPedId())
    print(('YOU SELECTED %s'):format(value))
    if tonumber(value) == 0 then
        vehDelDist = int2float(value)
        vehDelPos = 0
        vehDeleteMode = false
    elseif tonumber(value) > 4 then
        vehDelDist = int2float(value)
        vehDelPos = position
        vehDeleteMode = true
    end
end)



function ForceGiveKeys()
    local veh = GetVehiclePedIsIn(PlayerPedId(), true)
    exports['cdn-fuel']:SetFuel(veh, 100.0)
    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
    return QBCore.Functions.Notify("Gave Vehicle Keys", "success")
end


function ChangePlate()
    local veh = GetVehiclePedIsIn(PlayerPedId(), true)
    local oldplate = tostring(QBCore.Functions.GetPlate(veh))
    print("Chaning Plate")
    -- if IsPedInAnyVehicle(ped) then
    --     print("Chaning Plate - In Vehicle")
        local dialog = exports['qb-input']:ShowInput({
            header = "Test",
            submitText = "Plate Change",
            inputs = {
                {
                    text = "New Plate", -- text you want to be displayed as a place holder
                    name = "plate", -- name of the input should be unique otherwise it might override
                    type = "text", -- type of the input
                    isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                    -- default = "CID-1234", -- Default text option, this is optional
                },
            },
        })

        if dialog ~= nil then
            for k,v in pairs(dialog) do
                print(k .. " : " .. v)
                if k == 'plate' then
                    -- TriggerServerEvent('qb-admin:server:logVehiclePlate', PlayerPedId(), vehicle, oldplate, v)
                    TriggerServerEvent('qb-admin:getPlate', v:upper(), GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)):match( "^%s*(.-)%s*$" ))
                    SetVehicleNumberPlateText(vehicle, v)
                    SetVehicleNumberPlateTextIndex(vehicle, 0)
                    SetVehicleFixed(vehicle)
                    Wait(500)
                    QBCore.Functions.TriggerCallback('qb-vehiclekeys:server:GetVehicleKeys', function(keysList)
                        TriggerEvent('qb-vehiclekeys:client:AddKeys', v:upper())
                    end)
                    QBCore.Functions.Notify("Changing Plate From ".. oldplate .." To " .. v)
                end
            end
        -- end
    end
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Delete Lazer
local function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

local function DrawEntityBoundingBox(entity, color)
    local model = GetEntityModel(entity)
    local min, max = GetModelDimensions(model)
    local rightVector, forwardVector, upVector, position = GetEntityMatrix(entity)

    -- Calculate size
    local dim =
	{
		x = 0.5*(max.x - min.x),
		y = 0.5*(max.y - min.y),
		z = 0.5*(max.z - min.z)
	}

    local FUR =
    {
		x = position.x + dim.y*rightVector.x + dim.x*forwardVector.x + dim.z*upVector.x,
		y = position.y + dim.y*rightVector.y + dim.x*forwardVector.y + dim.z*upVector.y,
		z = 0
    }

    local FUR_bool, FUR_z = GetGroundZFor_3dCoord(FUR.x, FUR.y, 1000.0, 0)
    FUR.z = FUR_z
    FUR.z = FUR.z + 2 * dim.z

    local BLL =
    {
        x = position.x - dim.y*rightVector.x - dim.x*forwardVector.x - dim.z*upVector.x,
        y = position.y - dim.y*rightVector.y - dim.x*forwardVector.y - dim.z*upVector.y,
        z = 0
    }
    local BLL_bool, BLL_z = GetGroundZFor_3dCoord(FUR.x, FUR.y, 1000.0, 0)
    BLL.z = BLL_z

    -- DEBUG
    local edge1 = BLL
    local edge5 = FUR

    local edge2 =
    {
        x = edge1.x + 2 * dim.y*rightVector.x,
        y = edge1.y + 2 * dim.y*rightVector.y,
        z = edge1.z + 2 * dim.y*rightVector.z
    }

    local edge3 =
    {
        x = edge2.x + 2 * dim.z*upVector.x,
        y = edge2.y + 2 * dim.z*upVector.y,
        z = edge2.z + 2 * dim.z*upVector.z
    }

    local edge4 =
    {
        x = edge1.x + 2 * dim.z*upVector.x,
        y = edge1.y + 2 * dim.z*upVector.y,
        z = edge1.z + 2 * dim.z*upVector.z
    }

    local edge6 =
    {
        x = edge5.x - 2 * dim.y*rightVector.x,
        y = edge5.y - 2 * dim.y*rightVector.y,
        z = edge5.z - 2 * dim.y*rightVector.z
    }

    local edge7 =
    {
        x = edge6.x - 2 * dim.z*upVector.x,
        y = edge6.y - 2 * dim.z*upVector.y,
        z = edge6.z - 2 * dim.z*upVector.z
    }

    local edge8 =
    {
        x = edge5.x - 2 * dim.z*upVector.x,
        y = edge5.y - 2 * dim.z*upVector.y,
        z = edge5.z - 2 * dim.z*upVector.z
    }

    DrawLine(edge1.x, edge1.y, edge1.z, edge2.x, edge2.y, edge2.z, color.r, color.g, color.b, color.a)
    DrawLine(edge1.x, edge1.y, edge1.z, edge4.x, edge4.y, edge4.z, color.r, color.g, color.b, color.a)
    DrawLine(edge2.x, edge2.y, edge2.z, edge3.x, edge3.y, edge3.z, color.r, color.g, color.b, color.a)
    DrawLine(edge3.x, edge3.y, edge3.z, edge4.x, edge4.y, edge4.z, color.r, color.g, color.b, color.a)
    DrawLine(edge5.x, edge5.y, edge5.z, edge6.x, edge6.y, edge6.z, color.r, color.g, color.b, color.a)
    DrawLine(edge5.x, edge5.y, edge5.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge6.x, edge6.y, edge6.z, edge7.x, edge7.y, edge7.z, color.r, color.g, color.b, color.a)
    DrawLine(edge7.x, edge7.y, edge7.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge1.x, edge1.y, edge1.z, edge7.x, edge7.y, edge7.z, color.r, color.g, color.b, color.a)
    DrawLine(edge2.x, edge2.y, edge2.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge3.x, edge3.y, edge3.z, edge5.x, edge5.y, edge5.z, color.r, color.g, color.b, color.a)
    DrawLine(edge4.x, edge4.y, edge4.z, edge6.x, edge6.y, edge6.z, color.r, color.g, color.b, color.a)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isDrawingLine then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerHeading = GetEntityHeading(playerPed)
            local cameraRotation = GetGameplayCamRot(2)
            local camPitch = math.rad(cameraRotation.x)
            local camYaw = math.rad(cameraRotation.y)
            local lineLength = LineDistance
            local forwardVector = vector3(
                math.sin(-playerHeading * math.pi / 180.0) * math.cos(camPitch),
                math.cos(-playerHeading * math.pi / 180.0) * math.cos(camPitch),
                math.sin(camPitch)
            )
            local lineEnd = playerCoords + forwardVector * lineLength
            local rayHandle = StartShapeTestRay(playerCoords.x, playerCoords.y, playerCoords.z, lineEnd.x, lineEnd.y,
                lineEnd.z, 7, playerPed, 0)
            local _, hit, hitCoords, _, _ = GetShapeTestResult(rayHandle)
            DrawLine(playerCoords.x, playerCoords.y, playerCoords.z, lineEnd.x, lineEnd.y, lineEnd.z, 255, 0, 0, 255)
            if hit then
                local roundedCoords = {
                    x = string.format("%.2f", hitCoords.x),
                    y = string.format("%.2f", hitCoords.y),
                    z = string.format("%.2f", hitCoords.z)
                }
                local heading = playerHeading + 180.0
                if heading > 360.0 then
                    heading = heading - 360.0
                end
                DrawText3D(hitCoords.x, hitCoords.y, hitCoords.z + 1.0,
                    string.format('~r~Collision~n~X: %.2f Y: %.2f Z: %.2f~n~Heading: %.2f', hitCoords.x, hitCoords.y,
                        hitCoords.z, heading))
            end
        end
    end
end)

CreateThread(function()	-- While loop needed for delete lazer
	while true do
		sleep = 1000
		if deleteLazer then
		    sleep = 5
		    local color = {r = 255, g = 50, b = 50, a = 200} -- Changes the color of the lines (currently red)
		    local position = GetEntityCoords(PlayerPedId())
		    local hit, coords, entity = RayCastGamePlayCamera(1000.0)
		    -- If entity is found then verifie entity
		    if hit and (IsEntityAVehicle(entity) or IsEntityAPed(entity) or IsEntityAnObject(entity)) then
                local entityCoord = GetEntityCoords(entity)
                DrawEntityBoundingBox(entity, color)
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                Draw2DText(Lang:t("info.health") .. ': ~g~'..GetEntityHealth(entity)..' ~w~' .. Lang:t("info.speed") .. ': ~b~'..GetEntitySpeed(entity)..'~w~', 4, {255, 255, 255}, 0.4, 0.55, 0.888 - 0.050)
                Draw2DText(Lang:t("info.networked") .. ': ~b~'..tostring(NetworkGetEntityIsNetworked(entity))..' ~w~' .. Lang:t("info.networked_owner_id") ..': ~b~'..GetPlayerServerId(NetworkGetEntityOwner(entity))..'~w~', 4, {255, 255, 255}, 0.4, 0.55, 0.888 - 0.025)
                Draw2DText(Lang:t("info.obj") .. ': ~b~' .. entity .. '~w~ ' .. Lang:t("info.model") .. ': ~b~' .. GetEntityModel(entity), 4, {255, 255, 255}, 0.4, 0.55, 0.888)
                Draw2DText(Lang:t("info.delete_object_info"), 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.025)

                if IsControlJustReleased(0, 38) then -- When E pressed then remove targeted entity
                    SetEntityAsMissionEntity(entity, true, true) -- Set as missionEntity so the object can be remove (Even map objects)
                    NetworkRequestControlOfEntity(entity) -- Request Network control so we own the object
                    Wait(250) -- Safety Wait
                    DeleteEntity(entity) -- Delete the object
                    DeleteObject(entity) -- Delete the object (failsafe)
                    SetEntityAsNoLongerNeeded(entity) -- Tells the engine this prop isnt needed anymore
                end
		    -- Only draw of not center of map
		    elseif coords.x ~= 0.0 and coords.y ~= 0.0 then
			    -- Draws line to targeted position
			    DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
			    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
            end
		end
        if vehDeleteMode then
            print("Clearing Vehicles")
            print(vehDelDist)
            ClearAreaOfVehicles(vehDelPos.x, vehDelPos.y, vehDelPos.z, vehDelDist, false, false, false, false, false)
        end
		Wait(sleep)
	end
end)

