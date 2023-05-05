-- Variables
QBCore = exports['qb-core']:GetCoreObject()
local SoundScriptName = 'interact-sound'
local SoundPath = '/client/html/sounds'
local Sounds = {}
local IsFrozen = {}
local permissions = { -- What should each permission be able to do
    ['kill'] = 'mod',
    ['revive'] = 'mod',
    ['freeze'] = 'mod',
    ['spectate'] = 'mod',
    ['goto'] = 'mod',
    ['bring'] = 'mod',
    ['intovehicle'] = 'mod',
    ['kick'] = 'mod',
    ['ban'] = 'mod',
    ['setPermissions'] = 'admin',
    ['cloth'] = 'mod',
    ['spawnVehicle'] = 'admin',
    ['savecar'] = 'admin',
    ['playsound'] = 'admin',
    ['usemenu'] = 'mod',
}
local PermissionOrder = { -- Permission hierarchy order from top to bottom
    'god',
    'admin',
    'mod'
}

-- Functions
local function PermOrder(source)
    for i = 1, #PermissionOrder do
        if IsPlayerAceAllowed(source, PermissionOrder[i]) then
            return i
        end
    end
end

-- Events

RegisterNetEvent('qb-admin:server:logAction', function(type, string)
    TriggerEvent('qb-log:server:CreateLog', 'staff', 'Staff '..type, 'red', string, false)
end)

RegisterNetEvent('qb-admin:server:GetPlayersForBlips', function()
    local src = source
    local players = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local targetped = GetPlayerPed(v)
        local ped = QBCore.Functions.GetPlayer(v)
        players[#players+1] = {
            name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname .. ' | ' .. GetPlayerName(v),
            id = v,
            coords = GetEntityCoords(targetped),
            cid = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname,
            citizenid = ped.PlayerData.citizenid,
            sources = GetPlayerPed(ped.PlayerData.source),
            sourceplayer = ped.PlayerData.source
        }
    end
    TriggerClientEvent('qb-admin:client:Show', src, players)
end)

RegisterNetEvent('qb-admin:server:kill', function(player)
    local src = source
    local target = player.id

    if not (QBCore.Functions.HasPermission(src, permissions['kill'])) then return end
    --if PermOrder(src) > PermOrder(target) then return end

    TriggerEvent('qb-log:server:CreateLog', 'staff', 'Staff Kill', 'red', string.format('%s has killed %s (%s)', GetPlayerName(src), GetPlayerName(player.id), player.id), false)
    TriggerClientEvent('hospital:client:KillPlayer', target)
end)

RegisterNetEvent('qb-admin:server:revive', function(player)
    local src = source

    if not (QBCore.Functions.HasPermission(src, permissions['revive'])) then return end
    
    TriggerEvent('qb-log:server:CreateLog', 'staff', 'Staff Revive', 'red', string.format('%s is reviving %s (%s)', GetPlayerName(src), GetPlayerName(player.id), player.id), false)
    TriggerClientEvent('hospital:client:Revive', player.id)
end)

RegisterNetEvent('qb-admin:server:freeze', function(player)
    local src = source
    local target = GetPlayerPed(player.id)
    
    if not (QBCore.Functions.HasPermission(src, permissions['freeze'])) then return end
    --if PermOrder(src) > PermOrder(player.id) then return end
    if IsFrozen[target] == nil then IsFrozen[target] = false end

    if IsFrozen[target] then
        FreezeEntityPosition(target, false)
        TriggerEvent('qb-log:server:CreateLog', 'staff', 'Staff Freeze', 'red', string.format('%s is unfreezing %s (%s)', GetPlayerName(src), GetPlayerName(player.id), player.id), false)
        IsFrozen[target] = false
    else
        FreezeEntityPosition(target, true)
        IsFrozen[target] = true
        TriggerEvent('qb-log:server:CreateLog', 'staff', 'Staff Freeze', 'red', string.format('%s is freezing %s (%s)', GetPlayerName(src), GetPlayerName(player.id), player.id), false)
    end
end)

RegisterNetEvent('qb-admin:server:spectate', function(player)
    local src = source
    local targetped = GetPlayerPed(player.id)
    local coords = GetEntityCoords(targetped)

    if not (QBCore.Functions.HasPermission(src, permissions['spectate'])) then return end
    
    TriggerEvent('qb-log:server:CreateLog', 'staff', 'Staff Spectate', 'red', string.format('%s is spectating %s (%s)', GetPlayerName(src), GetPlayerName(player.id), player.id), false)
    TriggerClientEvent('qb-admin:client:spectate', src, player.id, coords)
end)

RegisterNetEvent('qb-admin:server:goto', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(GetPlayerPed(player.id))
    
    if not (QBCore.Functions.HasPermission(src, permissions['goto'])) then return end

    TriggerEvent('qb-log:server:CreateLog', 'staff', 'Staff TP', 'red', string.format('%s teleported to %s (%s)', GetPlayerName(src), GetPlayerName(player.id), player.id), false)
    SetEntityCoords(admin, coords)
end)

RegisterNetEvent('qb-admin:server:bring', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(admin)
    local target = GetPlayerPed(player.id)
    
    if not (QBCore.Functions.HasPermission(src, permissions['bring'])) then return end
    
    TriggerEvent('qb-log:server:CreateLog', 'staff', 'Player Teleported', 'red', string.format('%s brought %s to themselves (%s)', GetPlayerName(src), GetPlayerName(target), player.id), false)
    SetEntityCoords(target, coords)
end)

RegisterNetEvent('qb-admin:server:intovehicle', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local targetPed = GetPlayerPed(player.id)
    local vehicle = GetVehiclePedIsIn(targetPed, false)
    local seat = -1
    
    if not (QBCore.Functions.HasPermission(src, permissions['intovehicle'])) then return end
    if vehicle == 0 then TriggerClientEvent('QBCore:Notify', src, Lang:t("error.player_no_vehicle"), 'error', 4000) return end
    for i = 0, 8, 1 do if GetPedInVehicleSeat(vehicle, i) == 0 then seat = i break end end
    if seat == -1 then TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_free_seats"), 'error', 4000) return end
    
    SetPedIntoVehicle(admin, vehicle, seat)
    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.entered_vehicle"), 'success', 5000)
end)

RegisterNetEvent('qb-admin:server:kick', function(player, reason)
    local src = source
    local target = player.id
    
    if not (QBCore.Functions.HasPermission(src, permissions['kick'])) then return end
    if PermOrder(src) > PermOrder(target) then return end
    
    TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Kicked', 'red', string.format('%s was kicked by %s for %s', GetPlayerName(target), GetPlayerName(src), reason), false)
    DropPlayer(target, Lang:t("info.kicked_server") .. ':\n' .. reason .. '\n\n' .. Lang:t("info.check_discord") .. QBCore.Config.Server.discord)
end)

RegisterServerEvent('qb-admin:server:giveWeapon', function(weapon)
    local src = source
    if QBCore.Functions.HasPermission(src, 'admin') then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddItem(weapon, 1)
        TriggerEvent('qb-log:server:CreateLog', 'staff', 'Weapon Spawned', 'red', string.format('%s spawned in %s', GetPlayerName(src), weapon), false)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You can not spawn this.', 'error', 5000)
        BanPlayer(src)
    end
end)

RegisterNetEvent('qb-admin:server:ban', function(player, time, reason)
    local src = source
    local target = player.id
    local banTime = tonumber(os.time() + tonumber(time))
    if banTime > 2147483647 then banTime = 2147483647 end
    local timeTable = os.date('*t', banTime)
    
    if not (QBCore.Functions.HasPermission(src, permissions['ban'])) then return end
    if PermOrder(src) > PermOrder(target) then return end

    MySQL.Async.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(target),
        QBCore.Functions.GetIdentifier(target, 'license'),
        QBCore.Functions.GetIdentifier(target, 'discord'),
        QBCore.Functions.GetIdentifier(target, 'ip'),
        reason,
        banTime,
        GetPlayerName(src)
    })
    TriggerClientEvent('chat:addMessage', -1, {
        template = "<div class=chat-message server'><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>",
        args = {GetPlayerName(target), reason}
    })
    TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(target), GetPlayerName(src), reason), true)
    if banTime >= 2147483647 then
        DropPlayer(target, Lang:t("info.banned") .. '\n' .. reason .. Lang:t("info.ban_perm") .. QBCore.Config.Server.discord)
    else
        DropPlayer(target, Lang:t("info.banned") .. '\n' .. reason .. Lang:t("info.ban_expires") .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. '\n🔸 Check our Discord for more information: ' .. QBCore.Config.Server.discord)
    end
end)

RegisterNetEvent('qb-admin:server:setPermissions', function(targetId, group)
    local src = source

    if not (QBCore.Functions.HasPermission(src, permissions['setPermissions'])) then return end
    if PermOrder(src) > PermOrder(targetId) then return end

    QBCore.Functions.AddPermission(targetId, group[1].rank)
    TriggerClientEvent('QBCore:Notify', targetId, Lang:t("info.rank_level")..group[1].label)
    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.changed_perm")..' : '..group[1].label)
end)

RegisterNetEvent('qb-admin:server:cloth', function(player)
    local src = source

    if not (QBCore.Functions.HasPermission(src, permissions['cloth'])) then return end

    TriggerEvent('qb-log:server:CreateLog', 'staff', 'Staff Clothing Menu', 'red', string.format('%s has given clothing menu to %s (%s)', GetPlayerName(src), GetPlayerName(player.id), player.id), false)
    TriggerClientEvent('qb-clothing:client:openMenu', player.id)
end)

RegisterNetEvent('qb-admin:server:spawnVehicle', function(model)
    local src = source
    local hash = GetHashKey(model)
    local player = GetPlayerPed(src)
    local coords = GetEntityCoords(player)
    local heading = GetEntityHeading(player)
    local vehicle = GetVehiclePedIsIn(player, false)

    if not (QBCore.Functions.HasPermission(src, permissions['spawnVehicle'])) then return end
    if vehicle ~= 0 then DeleteEntity(vehicle) end

    local vehicle = CreateVehicle(hash, coords, true, true)
    while not DoesEntityExist(vehicle) do
        Wait(100)
    end
    SetEntityHeading(vehicle, heading)
    TaskWarpPedIntoVehicle(player, vehicle, -1)
    TriggerClientEvent('vehiclekeys:client:SetOwner', src, GetVehicleNumberPlateText(vehicle))
    TriggerEvent('qb-log:server:CreateLog', 'staff', 'Staff Spawn Vehicle', 'red', string.format('%s has spawned a vehicle named %s (%s)', GetPlayerName(src), GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(hash), hash), false)
end)

RegisterNetEvent('qb-admin:server:SaveCar', function(mods, vehicle, hash, plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.Sync.fetchAll('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    
    if result[1] ~= nil then TriggerClientEvent('QBCore:Notify', src, Lang:t("error.failed_vehicle_owner"), 'error', 3000) return end
    if not (QBCore.Functions.HasPermission(src, permissions['savecar'])) then return end
    
    MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.license,
        Player.PlayerData.citizenid,
        vehicle,
        hash,
        json.encode(mods),
        plate,
        0
    })
    TriggerClientEvent('QBCore:Notify', src, Lang:t("success.success_vehicle_owner"), 'success', 5000)
end)

RegisterNetEvent('qb-admin:server:getsounds', function()
    local src = source
    print(Sounds)
    if not (QBCore.Functions.HasPermission(src, permissions['playsound'])) then return end
    print(Sounds)
    
    TriggerClientEvent('qb-admin:client:getsounds', src, Sounds)
end)

RegisterNetEvent('qb-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    if QBCore.Functions.HasPermission(src, 'mod') then
        if QBCore.Functions.IsOptin(src) then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {Lang:t("info.admin_report")..name..' ('..targetSrc..')', msg}
            })
        end
    end
end)

AddEventHandler('qb-admin:server:Staffchat:addMessage', function(name, msg)
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        if QBCore.Functions.IsOptin(v) then
            TriggerClientEvent('chat:addMessage', v, {
                color = {255, 0, 0},
                multiline = true,
                args = {Lang:t("info.staffchat")..name, msg}
            })
        end
	end
end)

RegisterNetEvent('qb-admin:server:playsound', function(target, soundname, soundvolume, soundradius)
    local src = source

    if not (QBCore.Functions.HasPermission(src, permissions['playsound'])) then return end

    TriggerClientEvent('qb-admin:client:playsound', target, soundname, soundvolume, soundradius)
end)

RegisterNetEvent('qb-admin:server:check', function()
    local src = source
    
    if QBCore.Functions.HasPermission(src, permissions['usemenu']) then return end

    DropPlayer(src, Lang:t("info.dropped"))
end)

QBCore.Functions.CreateCallback('qb-adminmenu:callback:getdealers', function(source, cb)
    cb(exports['qb-drugs']:GetDealers())
end)

QBCore.Functions.CreateCallback('qb-adminmenu:callback:getplayers', function(source, cb)
    if not QBCore.Functions.HasPermission(source, permissions['usemenu']) then return end

    local players = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local targetped = GetPlayerPed(v)
        local ped = QBCore.Functions.GetPlayer(v)
        players[#players+1] = {
            id = v,
            name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(v) .. ')',
            food = ped.PlayerData.metadata['hunger'],
            water = ped.PlayerData.metadata['thirst'],
            stress = ped.PlayerData.metadata['stress'],
            armor = ped.PlayerData.metadata['armor'],
            phone =  exports["lb-phone"]:GetEquippedPhoneNumber(v) or '000-000-000',
            craftingrep = ped.PlayerData.metadata['craftingrep'],
            dealerrep = ped.PlayerData.metadata['dealerrep'],
            cash = ped.PlayerData.money['cash'],
            bank = ped.PlayerData.money['bank'],
            job = ped.PlayerData.job.label .. ' | ' .. ped.PlayerData.job.grade.level,
            gang = ped.PlayerData.gang.label,
        }
    end
        -- Sort players list by source ID (1,2,3,4,5, etc) --
        table.sort(players, function(a, b)
            return a.id < b.id
        end)
        ------
    cb(players)
end)

RegisterNetEvent('qb-admin:readyname')
AddEventHandler('qb-admin:readyname', function(newname, newlast , adminid)
    local src = source
    local fnew = tostring(newname)
    local lnew = tostring(newlast)
    local license = QBCore.Functions.GetIdentifier(src, 'license')
    local Player = QBCore.Functions.GetPlayer(src)
    local admin = adminid
    print("^3New name received Changing in DATABASE FN: ^0" ..tostring(fnew) .. "^3 LN: ^0" .. tostring(lnew) .. "^3 CitID: ^0"..Player.PlayerData.citizenid)
    local playerActualData = {}
    local result = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid})
    local PlayerData = result[1]
    local charinfo = json.decode(PlayerData.charinfo)
    print("^1Current Name: ^0" .. charinfo.firstname .. "^1 Current last name: ^0" .. charinfo.lastname)
    local oldname = charinfo.firstname
    local oldlname = charinfo.lastname
    charinfo.firstname = fnew
    charinfo.lastname = lnew
    charinfo = json.encode(charinfo)
    TriggerEvent('qb-log:server:CreateLog', 'staff', 'Name Change', 'red', string.format('%s has changed a player\'s name %s (%s)\nOld Name: %s %s\nNew Name: %s %s', GetPlayerName(src), GetPlayerName(Player.id), Player.id, oldname, oldlname, fnew, lnew), false)
    DropPlayer(src ,'Your Name has been successfully changed, Login again to the server')
    MySQL.Async.execute('UPDATE players SET charinfo = @charinfo WHERE citizenid = @senderId',
    { ['charinfo'] =  charinfo, ['senderId'] = Player.PlayerData.citizenid },
    function(affectedRows)
     -- print(affectedRows)
    end
    )
end)

RegisterNetEvent('qb-admin:getPlate', function(plate, currentPlate)
    local source <const> = source
    local xPlayer = QBCore.Functions.GetPlayer(source)
    print('1')
    if xPlayer then
        if GetVehiclePedIsIn(GetPlayerPed(source)) == 0 or not currentPlate then
            return TriggerClientEvent('QBCore:Notify', source, 'You somehow left your vehicle!')
        elseif plate:len() > 8 then
            return TriggerClientEvent('QBCore:Notify', source, 'Somehow you passed more than 8 chars')
        end
        exports.oxmysql:fetch('SELECT plate FROM player_vehicles WHERE plate = @plate AND citizenid = @citizenid', {
            ['plate'] = currentPlate,
            ['citizenid'] = xPlayer.PlayerData.citizenid
        }, function(result)
            if result[1] then
                print('2')
                exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE plate = @plate', {
                    ['plate'] = plate
                }, function(exist)
                    if not exist[1] then
                        exports.oxmysql:fetch('SELECT plate, mods FROM player_vehicles WHERE plate = @plate', {
                            ['plate'] = currentPlate
                        },function(currentVehicle)
                            if currentVehicle[1] then
                                print('3')
                                local vehicle = json.decode(currentVehicle[1].mods)
                                if not vehicle.plate then
                                    return TriggerClientEvent('QBCore:Notify', source, 'Your vehicle appears to be missing a real plate')
                                end
                                local oldPlate = vehicle.plate
                                vehicle.plate = plate
                                exports.oxmysql:execute('UPDATE player_vehicles SET plate = @newplate, mods = @vehicle WHERE plate = @oldplate AND citizenid=@citizenid', {
                                    ['newplate'] = plate,
                                    ['oldplate'] = oldPlate,
                                    ['citizenid'] = xPlayer.PlayerData.citizenid,
                                    ['vehicle'] = json.encode(vehicle)
                                })
                                SetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(source)), plate)
                                TriggerClientEvent('QBCore:Notify', source, 'Your new plate has been set!')
                                return
                            end
                        end)
                    else
                        TriggerClientEvent('QBCore:Notify', source, 'Plate already exists')
                    end
                end)
            else
                TriggerClientEvent('QBCore:Notify', source, 'This is not your vehicle')
            end
        end)
    end
end)

CreateThread(function()
    local path = GetResourcePath(SoundScriptName)
    local directory = path:gsub('//', '/')..SoundPath
    for filename in io.popen('dir "'..directory..'" /b'):lines() do
        Sounds[#Sounds + 1] = filename:match("(.+)%..+$")
    end
end)
