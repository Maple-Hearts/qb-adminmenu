local SelfMenuButton1 = SelfMenu:AddCheckbox({
    icon = '🎥',
    label = Lang:t("menu.noclip"),
    description = Lang:t("desc.noclip_desc")
})
SelfMenuButton1:On('change', function(item, newValue, oldValue)
    ToggleNoClip()
    local myPed = PlayerId()
    TriggerServerEvent('qb-admin:server:logAction', 'NoClip', string.format('%s toggled noclip', GetPlayerName(myPed)))
end)

local SelfMenuButton2 = SelfMenu:AddButton({
    icon = '🏥',
    label = Lang:t("menu.revive"),
    description = Lang:t("desc.revive_desc")
})
SelfMenuButton2:On('select', function(item)
    TriggerEvent('hospital:client:Revive')
    local myPed = PlayerId()
    TriggerServerEvent('qb-admin:server:logAction', 'Revive', string.format('%s Revived', GetPlayerName(myPed)))
end)

local SelfMenuButton3 = SelfMenu:AddButton({
    icon = '🔫',
    label = Lang:t("menu.armour"),
    description = Lang:t("desc.armour")
})

SelfMenuButton3:On('select', function()
    local ped = PlayerPedId()
    SetPedArmour(ped, 100)
    local myPed = PlayerId()
    TriggerServerEvent('qb-admin:server:logAction', 'Max Armor', string.format('%s Set Max Armor', GetPlayerName(myPed)))
end)

local SelfMenuButton4 = SelfMenu:AddCheckbox({
    icon = '👻',
    label = Lang:t("menu.invisible"),
    description = Lang:t("desc.invisible_desc")
})
local invisible = false
SelfMenuButton4:On('change', function(item, newValue, oldValue)
    invisible = not invisible
    local myPed = PlayerId()
    if invisible then
        while invisible do
            Wait(0)
            SetEntityVisible(PlayerPedId(), false, 0)
        end
        SetEntityVisible(PlayerPedId(), true, 0)
        TriggerServerEvent('qb-admin:server:logAction', 'Toggle Invis', string.format('%s Invisable', GetPlayerName(myPed)))
    else
        TriggerServerEvent('qb-admin:server:logAction', 'Toggle Invis', string.format('%s Uninvisable', GetPlayerName(myPed)))
    end
end)

local SelfMenuButton5 = SelfMenu:AddCheckbox({
    icon = '⚡',
    label = Lang:t("menu.god"),
    description = Lang:t("desc.god_desc")
})
local godmode = false
SelfMenuButton5:On('change', function(item, newValue, oldValue)
    godmode = not godmode
    local myPed = PlayerId()
    if godmode then 
        SetPlayerInvincible(PlayerId(), true)
        TriggerServerEvent('qb-admin:server:logAction', 'Toggle God', string.format('%s God Enabled', GetPlayerName(myPed)))
    else 
        SetPlayerInvincible(PlayerId(), false) 
        TriggerServerEvent('qb-admin:server:logAction', 'Toggle God', string.format('%s God Disabled', GetPlayerName(myPed)))
    end
end)

local SelfMenuButton6 = SelfMenu:AddCheckbox({
    icon = '📋',
    label = Lang:t("menu.names"),
    description = Lang:t("desc.names_desc")
})
SelfMenuButton6:On('change', function()
    TriggerEvent('qb-admin:client:toggleNames')

    local myPed = PlayerId()
    TriggerServerEvent('qb-admin:server:logAction', 'Names', string.format('%s toggled names', GetPlayerName(myPed)))
end)

local SelfMenuButton7 = SelfMenu:AddCheckbox({
    icon = '📍',
    label = Lang:t("menu.blips"),
    description = Lang:t("desc.blips_desc")
})
SelfMenuButton7:On('change', function()
    TriggerEvent('qb-admin:client:toggleBlips')
    local myPed = PlayerId()
    TriggerServerEvent('qb-admin:server:logAction', 'Blips', string.format('%s toggled blips', GetPlayerName(myPed)))
end)

local SelfMenuButton8 = SelfMenu:AddCheckbox({
    icon = '🚔',
    label = Lang:t("menu.vehicle_godmode"),
    description = Lang:t("desc.vehicle_godmode")
})
local vehiclegodmode = false
SelfMenuButton8:On('change', function()
    vehiclegodmode = not vehiclegodmode
    local myPed = PlayerId()
    TriggerServerEvent('qb-admin:server:logAction', 'Vehicle Godmode', string.format('%s toggled vehicle god mode', GetPlayerName(myPed)))
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehiclegodmode then
        SetEntityInvincible(vehicle, true)
        SetEntityCanBeDamaged(vehicle, false)
        while vehiclegodmode do
            local vehicle = GetVehiclePedIsIn(ped, false)
            SetVehicleBodyHealth(vehicle, 1000.0)
            SetVehicleFixed(vehicle)
            SetVehicleEngineHealth(vehicle, 1000.0)
            Wait(250)
        end
    else
        SetEntityInvincible(vehicle, false)
        SetEntityCanBeDamaged(vehicle, true)
    end
end)

local SelfMenuButton9 = SelfMenu:AddSlider({
    icon = '📍',
    label = Lang:t("menu.ped"),
    value = '',
    values = {{
        label = Lang:t("menu.ped"),
        value = 'ped',
        description = Lang:t("desc.ped")
    }, {
        label = Lang:t("menu.reset_ped"),
        value ='reset',
        description = Lang:t("desc.reset_ped")
    }},
    select = function(btn, newValue, oldValue)
        if newValue == "ped" then
            local dialog = exports['qb-input']:ShowInput({
                header = Lang:t("desc.ped"),
                submitText = "Confirm",
                inputs = {
                    {
                        text = "a_m_m_salton_03",
                        name = "model",
                        type = "text",
                        isRequired = true
                    }
                }
            })
            if dialog then
                TriggerServerEvent('QBCore:CallCommand', "setmodel", {dialog.model})
            end
        else
            ExecuteCommand('refreshskin')
        end
    end
})


local SelfMenuButton10 = SelfMenu:AddCheckbox({
    icon = '🔫',
    label = Lang:t("menu.ammo"),
    description = Lang:t("desc.ammo")
})
local infiniteammo = false
SelfMenuButton10:On('change', function()
    infiniteammo = not infiniteammo
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    local myPed = PlayerId()
    TriggerServerEvent('qb-admin:server:logAction', 'Infinite Ammo', string.format('%s toggled infinite ammo', GetPlayerName(myPed)))
    if infiniteammo then
        if GetAmmoInPedWeapon(ped, weapon) < 6 then SetAmmoInClip(ped, weapon, 10) Wait(50) end
        while infiniteammo do
            local weapon = GetSelectedPedWeapon(ped)
            SetPedInfiniteAmmo(ped, true, weapon)
            RefillAmmoInstantly(ped)
            Wait(250)
        end
    else
        SetPedInfiniteAmmo(ped, false, weapon)
    end
end)

local SelfMenuButton11 = SelfMenu:AddButton({
    icon = '🔫',
    label = Lang:t("menu.maxammo"),
    description = Lang:t("desc.maxammo")
})

SelfMenuButton11:On('select', function()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    local total = GetAmmoInPedWeapon(ped, weapon)
    local found, maxAmmo = GetMaxAmmo(ped, weapon)
    local myPed = PlayerId()
    TriggerServerEvent('qb-admin:server:logAction', 'Max Ammo', string.format('%s toggled max ammo', GetPlayerName(myPed)))

    SetPedAmmo(ped, weapon, maxAmmo)
end)