local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("qb-bong:server:effects", function(entity, coords)
    for _, player in pairs(QBCore.Functions.GetPlayers()) do
	TriggerClientEvent("qb-bong:client:effects", player, entity, coords)
    end
end)

RegisterNetEvent('qb-bong:server:setdata', function(citizenid, data, amount)
    if data == "time" then
        amount = os.time() + amount
    end
    MySQL.Sync.execute('UPDATE bongs SET '..data..' = ? WHERE citizenid = ?', {amount, citizenid})
end)

QBCore.Functions.CreateCallback("qb-bong:server:ostime", function(source,cb)
    cb(os.time())
end)

QBCore.Functions.CreateCallback("qb-bong:server:getdata", function(source, cb)
    local citizenid = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local result = MySQL.Sync.fetchAll('SELECT * FROM bongs WHERE citizenid = ?', {citizenid})
    if result[1] == nil then
        MySQL.Sync.insert('INSERT INTO bongs (citizenid, tolerance, amount, high, time)VALUES(?,?,?,?,?)', {citizenid,0,0,0,0})
    else
        cb(result[1])
    end
end)

QBCore.Functions.CreateUseableItem("bong", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    local weed = nil
    if Player.Functions.GetItemByName("lighter") then
        for k, v in pairs(Config.Strains) do
            weed = Player.Functions.GetItemByName(v)
            if weed and Player.Functions.RemoveItem(v, 1) then
                TriggerClientEvent("qb-bong:client:use", source, v)
                break
            end
        end
    else
        TriggerClientEvent("QBCore:Notify", source, "You don't have a lighter", "error")
    end
    if not weed then TriggerClientEvent("QBCore:Notify", source, "You don't have weed", "error") end
end)
