QBCore = exports['qb-core']:GetCoreObject()
banlength = nil
showCoords = false
vehicleDevMode = false
PlayerDetails = nil
banreason = 'Unknown'
kickreason = 'Unknown'
itemname = 'Unknown'
itemamount = 0
moneytype = 'Unknown'
moneyamount = 0
soundname = 'Unknown'
soundrange = 0
soundvolume = 0
menuLocation = 'topright' -- e.g. topright (default), topleft, bottomright, bottomleft
menuSize = 'size-125' -- e.g. 'size-100', 'size-110', 'size-125', 'size-150', 'size-175', 'size-200'
r, g, b = 255, 184, 226 -- red, green, blue values for the menu background https://www.w3schools.com/colors/colors_rgb.asp
title = "Maple Leaf" -- Config Banner Text
local inJail = false
local jailTime = 0
local isRunText = false

--false, Lang:t("menu.admin_menu")

MainMenu = MenuV:CreateMenu(title, "Maple Leaf Admin Menu", menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:mainmenu')
SelfMenu = MenuV:CreateMenu(title, Lang:t("menu.admin_options"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:selfmenu')
PlayerMenu = MenuV:CreateMenu(title, Lang:t("menu.online_players"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:playermenu')
PlayerDetailMenu = MenuV:CreateMenu(title, Lang:t("info.options"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:playerdetailmenu')
PlayerGeneralMenu = MenuV:CreateMenu(title, Lang:t("menu.player_general"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:playergeneral')
PlayerAdminMenu = MenuV:CreateMenu(title, Lang:t("menu.player_administration"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:playeradministration')
PlayerExtraMenu = MenuV:CreateMenu(title, Lang:t("menu.player_extra"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:playerextra')
BanMenu = MenuV:CreateMenu(title, Lang:t("menu.ban"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:banmenu')
KickMenu = MenuV:CreateMenu(title, Lang:t("menu.kick"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:kickmenu')
PermsMenu = MenuV:CreateMenu(title, Lang:t("menu.permissions"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:permsmenu')
GiveItemMenu = MenuV:CreateMenu(title, Lang:t("menu.give_item_menu"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:giveitemmenu')
GiveMoneyMenu = MenuV:CreateMenu(title, Lang:t("menu.give_money_menu"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:givemoneymenu')
SetMoneyMenu = MenuV:CreateMenu(title, Lang:t("menu.set_money_menu"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:setmoneymenu')
SoundMenu = MenuV:CreateMenu(title, Lang:t("menu.play_sound"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:soundmenu')
ServerMenu = MenuV:CreateMenu(title, Lang:t("menu.manage_server"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:servermenu')
WeatherMenu = MenuV:CreateMenu(title, Lang:t("menu.weather_conditions"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:weathermenu')
VehicleMenu = MenuV:CreateMenu(title, Lang:t("menu.vehicle_options"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:vehiclemenu')
VehCategorieMenu = MenuV:CreateMenu(title, Lang:t("menu.vehicle_categories"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:vehcategoriemenu')
VehNameMenu = MenuV:CreateMenu(title, Lang:t("menu.vehicle_models"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:vehnamemenu')
DealerMenu = MenuV:CreateMenu(title, Lang:t("menu.dealer_list"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:dealermenu')
DevMenu = MenuV:CreateMenu(title, Lang:t("menu.developer_options"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:devmenu')
EntityMenu = MenuV:CreateMenu(title, Lang:t("menu.entity_view_desc"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:entityviewmenu')
LineCoords = MenuV:CreateMenu(title, Lang:t("menu.entity_view_desc"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:linecoords')
local weaponMenu = MenuV:CreateMenu(title, "Weapon Menu", menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:weaponMenu')
local weaponSelect = MenuV:CreateMenu(title, Lang:t("menu.spawn_weapons"), menuLocation, r, g, b, menuSize, 'default', 'menuv', 'qb-admin:weaponSelect')

local MainMenuButton1 = MainMenu:AddButton({
    icon = '😃',
    label = Lang:t("menu.admin_options"),
    value = SelfMenu,
    description = Lang:t("desc.admin_options_desc")
})

local MainMenuButton2 = MainMenu:AddButton({
    icon = '🙍‍♂️',
    label = Lang:t("menu.player_management"),
    value = PlayerMenu,
    description = Lang:t("desc.player_management_desc")
})
MainMenuButton2:On('select', function(item)
    PlayerMenu:ClearItems()
    QBCore.Functions.TriggerCallback('qb-adminmenu:callback:getplayers', function(players)
        for k, v in pairs(players) do
            local PlayerMenuButton = PlayerMenu:AddButton({
                label = Lang:t("info.id") .. v["id"] .. ' | ' .. v["name"],
                value = v,
                description = Lang:t("info.player_name"),
                select = function(btn)
                    PlayerDetails = btn.Value
                    OpenPlayerMenus()
                end
            })
        end
    end)
end)

local MainMenuButton3 = MainMenu:AddButton({
    icon = '🎮',
    label = Lang:t("menu.server_management"),
    value = ServerMenu,
    description = Lang:t("desc.server_management_desc")
})
local MainMenuButton4 = MainMenu:AddButton({
    icon = '🚗',
    label = Lang:t("menu.vehicles"),
    value = VehicleMenu,
    description = Lang:t("desc.vehicles_desc")
})
local MainMenuButton5 = MainMenu:AddButton({
    icon = '🔫',
    label = Lang:t("menu.spawn_weapons"),
    value = weaponSelect,
    description = Lang:t("desc.spawn_weapons_desc")
})
local MainMenuButton6 = MainMenu:AddButton({
    icon = '🔧',
    label = Lang:t("menu.developer_options"),
    value = DevMenu,
    description = Lang:t("desc.developer_desc")
})

for _,v in pairs(QBCore.Shared.Weapons) do
    weaponSelect:AddButton({icon = '🔫',
        label = v.label ,
        value = v.value ,
        description = Lang:t("desc.spawn_weapons_desc"),
        select = function(_)
            TriggerServerEvent('qb-admin:server:giveWeapon', v.name)
            QBCore.Functions.Notify(Lang:t("success.spawn_weapon"))
        end
    })
end

local function EscapePrevention(curPos)
	local distanceFromJail = GetDistanceBetweenCoords(Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z, curPos.x, curPos.y, curPos.z, true)

	if Config.PreventEscapeMod.on then
		if distanceFromJail > Config.PreventEscapeMod.distance then
			return true
		else
			return false

		end
	end
end

-- RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
-- 	QBCore.Functions.GetPlayerData(function(cPlayerData)
-- 		PlayerData = cPlayerData
-- 		if cPlayerData.metadata["oocjail"] > 0 then
-- 			TriggerEvent("qb-adminmenu:client:SendToJail", cPlayerData.metadata["oocjail"])
-- 		end
-- 	end)
-- end)

RegisterNetEvent("qb-adminmenu:client:AdminJail", function(time)
    inJail = true
    ClearPedTasks(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
    TriggerEvent("qb-adminmenu:client:SendToJail", time)
end)

RegisterNetEvent("qb-adminmenu:client:SendToJail", function(time)
	DoScreenFadeOut(500)
	while not IsScreenFadedOut() do
		Wait(10)
	end
	local JailPosition = Config.JailLocation
	SetEntityCoords(PlayerPedId(), JailPosition.x, JailPosition.y, JailPosition.z - 0.9, 0, 0, 0, false)
    SetEntityInvincible(PlayerPedId(), true)
	Wait(500)

	inJail = true
	jailTime = time
	TriggerServerEvent("qb-adminmenu:server:SetJailTime", jailTime)
	if not isRunText then
		TriggerEvent('qb-adminmenu:client:showTime')
	end
	TriggerServerEvent("qb-adminmenu:server:CheckJailTime", jailTime)
	TriggerServerEvent("qb-adminmenu:server:ClearInv")
	TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.5)
	Wait(2000)
	DoScreenFadeIn(1000)
end)

RegisterNetEvent('qb-adminmenu:client:UnJailOOC', function()
	if jailTime > 0 then
		MBNotify(Lang:t("notify.title"), Lang:t("success.you_are_free"), 'success')
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Wait(10)
		end
		TriggerEvent('qb-adminmenu:client:Leave')
		Wait(500)
		DoScreenFadeIn(1000)
	end
end)

RegisterNetEvent('qb-adminmenu:client:Leave', function()
	if inJail then
		jailTime = 0
		inJail = false
		TriggerServerEvent("qb-adminmenu:server:SetJailTime", 0)
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Wait(10)
		end

		SetEntityCoords(PlayerPedId(), Config.OutJailLocation.x, Config.OutJailLocation.y, Config.OutJailLocation.z, 0, 0, 0, 0)
		SetEntityInvincible(PlayerPedId(), false)

		Wait(500)

		DoScreenFadeIn(1000)
	end
end)

RegisterNetEvent('qb-adminmenu:client:showTime', function()
	isRunText = true
	TriggerEvent('qb-adminmenu:client:checkTime')
	while not inJail and jailTime > 0 do
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('qb-adminmenu:client:checkTime', function()
	while inJail and jailTime > 0 do
		Citizen.Wait(60 * 1000)
		if inJail and jailTime > 0 then
			jailTime = jailTime - 1
			if jailTime <= 0 then jailTime = 0 end
			TriggerServerEvent("qb-adminmenu:server:SetJailTime", jailTime)
			TriggerServerEvent("qb-adminmenu:server:CheckJailTime", jailTime)
		end
	end
	TriggerEvent("qb-adminmenu:client:Leave")
	isRunText = false
end)



RegisterNetEvent('qb-admin:client:openMenu', function()
    TriggerServerEvent('qb-admin:server:check')
    MenuV:OpenMenu(MainMenu)
end)

RegisterNetEvent('qb-admin:client:ToggleCoords', function()
    TriggerServerEvent('qb-admin:server:check')
    ToggleShowCoordinates()
end)

RegisterNetEvent('qb-admin:client:openSoundMenu', function(data)
    soundname = data.name
end)

RegisterNetEvent('qb-admin:client:playsound', function(name, volume, radius)
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', radius, name, volume)
end)

local blockedPeds = {
    "mp_m_freemode_01",
    "mp_f_freemode_01",
    "tony",
    "g_m_m_chigoon_02_m",
    "u_m_m_jesus_01",
    "a_m_y_stbla_m",
    "ig_terry_m",
    "a_m_m_ktown_m",
    "a_m_y_skater_m",
    "u_m_y_coop",
    "ig_car3guy1_m",
}

local lastSpectateCoord = nil
local isSpectating = false

AddEventHandler('qb-admin:client:inventory', function(targetPed, source)
    local myPed = PlayerId()
    TriggerServerEvent('qb-admin:server:logAction', 'Open Inventory', string.format('%s opened %s\'s inventory', GetPlayerName(myPed), myPed, targetPed))
    TriggerServerEvent('qb-admin:server:check')
    TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", targetPed)
end)

RegisterNetEvent('qb-admin:client:spectate', function(targetPed, coords)
    local myPed = PlayerPedId()
    local targetplayer = GetPlayerFromServerId(targetPed)
    local target = GetPlayerPed(targetplayer)
    if not isSpectating then
        isSpectating = true
        SetEntityVisible(myPed, false) -- Set invisible
        SetEntityInvincible(myPed, true) -- set godmode
        lastSpectateCoord = GetEntityCoords(myPed) -- save my last coords
        SetEntityCoords(myPed, coords) -- Teleport To Player
        NetworkSetInSpectatorMode(true, target) -- Enter Spectate Mode
    else
        isSpectating = false
        NetworkSetInSpectatorMode(false, target) -- Remove From Spectate Mode
        SetEntityCoords(myPed, lastSpectateCoord) -- Return Me To My Coords
        SetEntityVisible(myPed, true) -- Remove invisible
        SetEntityInvincible(myPed, false) -- Remove godmode
        lastSpectateCoord = nil -- Reset Last Saved Coords
    end
end)

RegisterNetEvent('qb-admin:client:SendReport', function(name, src, msg)
    TriggerServerEvent('qb-admin:server:SendReport', name, src, msg)
end)

RegisterNetEvent('qb-admin:client:SaveCar', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)

    if veh ~= nil and veh ~= 0 then
        local plate = QBCore.Functions.GetPlate(veh)
        local props = QBCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        local vehname = GetDisplayNameFromVehicleModel(hash):lower()
        TriggerServerEvent('qb-admin:server:SaveCar', props, vehname, GetHashKey(veh), plate)
        -- if QBCore.Shared.Vehicles[vehname] ~= nil and next(QBCore.Shared.Vehicles[vehname]) ~= nil then
        -- else
        --     QBCore.Functions.Notify(Lang:t("error.no_store_vehicle_garage"), 'error')
        -- end
    else
        QBCore.Functions.Notify(Lang:t("error.no_vehicle"), 'error')
    end
end)

local function LoadPlayerModel(skin)
    RequestModel(skin)
    while not HasModelLoaded(skin) do
      Wait(0)
    end
end

local function isPedAllowedRandom(skin)
    local retval = false
    for k, v in pairs(blockedPeds) do
        if v ~= skin then
            retval = true
        end
    end
    return retval
end

RegisterNetEvent('qb-admin:client:SetModel', function(skin)
    local ped = PlayerPedId()
    local model = GetHashKey(skin)
    SetEntityInvincible(ped, true)

    if IsModelInCdimage(model) and IsModelValid(model) then
        LoadPlayerModel(model)
        SetPlayerModel(PlayerId(), model)

        if isPedAllowedRandom(skin) then
            SetPedRandomComponentVariation(ped, true)
        end

		SetModelAsNoLongerNeeded(model)
	end
	SetEntityInvincible(ped, false)
end)

RegisterNetEvent('qb-admin:client:SetSpeed', function(speed)
    local ped = PlayerId()
    if speed == "fast" then
        SetRunSprintMultiplierForPlayer(ped, 1.49)
        SetSwimMultiplierForPlayer(ped, 1.49)
    else
        SetRunSprintMultiplierForPlayer(ped, 1.0)
        SetSwimMultiplierForPlayer(ped, 1.0)
    end
end)

RegisterNetEvent('qb-weapons:client:SetWeaponAmmoManual', function(weapon, ammo)
    local ped = PlayerPedId()
    if weapon ~= "current" then
        local weapon = weapon:upper()
        SetPedAmmo(ped, GetHashKey(weapon), ammo)
        QBCore.Functions.Notify(Lang:t("info.ammoforthe", {value = ammo, weapon = QBCore.Shared.Weapons[weapon]["label"]}), 'success')
    else
        local weapon = GetSelectedPedWeapon(ped)
        if weapon ~= nil then
            SetPedAmmo(ped, weapon, ammo)
            QBCore.Functions.Notify(Lang:t("info.ammoforthe", {value = ammo, weapon = QBCore.Shared.Weapons[weapon]["label"]}), 'success')
        else
            QBCore.Functions.Notify(Lang:t("error.no_weapon"), 'error')
        end
    end
end)

RegisterNetEvent('qb-admin:client:GiveNuiFocus', function(focus, mouse)
    SetNuiFocus(focus, mouse)
end)

RegisterNetEvent('qb-admin:client:getsounds', function(sounds)
    local soundMenu = {
        {
            header = Lang:t('menu.choose_sound'),
            isMenuHeader = true
        }
    }

    for i = 1, #sounds do
        soundMenu[#soundMenu + 1] = {
            header = sounds[i],
            txt = "",
            params = {
                event = "qb-admin:client:openSoundMenu",
                args = {
                    name = sounds[i]
                }
            }
        }
    end

    exports['qb-menu']:openMenu(soundMenu)
end)


Citizen.CreateThread(function()
	while true do
		if inJail and jailTime > 0 then
			local curPos = GetEntityCoords(PlayerPedId())
			if EscapePrevention(curPos) then
				QBCore.Functions.GetPlayerData(function(PlayerData)
					if PlayerData.metadata["oocjail"] > 0 then
						TriggerEvent("qb-adminmenu:client:SendToJail", PlayerData.metadata["oocjail"])
					end
				end)
			end
		end
		Wait(3000)
	end
end)