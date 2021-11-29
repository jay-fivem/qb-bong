local QBCore = exports['qb-core']:GetCoreObject()
local smoking = false
local citizenid = nil

CreateThread(function()
	while true do
		local sleep = 1000
		if LocalPlayer.state['isLoggedIn'] then
			sleep = 60000
			citizenid = QBCore.Functions.GetPlayerData().citizenid
			QBCore.Functions.TriggerCallback('qb-bong:server:getdata', function(data)
				if data.high == 1 then TriggerEvent("qb-bong:client:high", citizenid, PlayerPedId()) end		
				QBCore.Functions.TriggerCallback('qb-bong:server:ostime', function(time)
					if (data.time - time) < 0 and (data.tolerance-1) ~= -1 then
						TriggerServerEvent("qb-bong:server:setdata", citizenid, "tolerance", data.tolerance-1)
					end
					if (data.time - time) < 1800 and (data.amount-1) ~= -1 then
						TriggerServerEvent("qb-bong:server:setdata", citizenid, "amount", data.amount-1)
					end
				end)
			end)
		end
		Wait(sleep)
	end
end)

RegisterNetEvent("qb-bong:client:use", function(strain)
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local ad = "anim@safehouse@bong" 
	local anim = "bong_stage3"
	if (DoesEntityExist(ped) and not IsEntityDead(ped)) and not smoking then
		smoking = true
		while not HasAnimDictLoaded(ad) do
			RequestAnimDict(ad)
			Wait(1)
		end
		bong = CreateObject(GetHashKey(Config.Bong), coords.x, coords.y, coords.z+0.2,  true,  true, true)
		AttachEntityToEntity(bong, ped, GetPedBoneIndex(ped, 18905), 0.10,-0.25,0.0,95.0,190.0,180.0, true, true, false, true, 1, true)
		TaskPlayAnim(ped, ad, anim, 8.00, -8.00, -1, (2 + 16 + 32), 0.00, 0, 0, 0)
		Wait(8000)
		TriggerServerEvent("qb-bong:server:effects", PedToNet(ped), coords)
		Wait(2000)
		DeleteObject(bong)
		StopAnimTask(ped, ad, anim, 1.0)
		smoking = false
		TriggerServerEvent('hud:server:RelieveStress', math.random(2, 4))
		QBCore.Functions.TriggerCallback('qb-bong:server:getdata', function(data)
			TriggerServerEvent("qb-bong:server:setdata", citizenid, "tolerance", data.tolerance+1)
			TriggerServerEvent("qb-bong:server:setdata", citizenid, "amount", data.amount+1)
			TriggerServerEvent("qb-bong:server:setdata", citizenid, "time", 3600)
			for k, v in pairs(Config.Tolerance) do
				if data.tolerance <= k then
					if data.amount == v.high then
						if data.high == 0 then
							TriggerEvent("qb-bong:client:high", citizenid, ped)
						end
					elseif data.amount >= v.sick then 
						if data.high == 1 then 
							DoScreenFadeOut(5000)
							SetPedToRagdoll(ped, 30000, 30000, 0, 0, 0, 0)
							Wait(20000)
							DoScreenFadeIn(5000)
						end
						TriggerServerEvent("qb-bong:server:setdata", citizenid, "amount", 0)
					end
				end
			end
		end)
	end
end)

RegisterNetEvent('qb-bong:client:high', function(citizenid, ped)
	TriggerServerEvent("qb-bong:server:setdata", citizenid, "high", 1)
	SetTimecycleModifier("spectator6")
	SetPedMotionBlur(ped, true)
	SetPedIsDrunk(ped, true)
	AnimpostfxPlay("ChopVision", 10000001, true)
	ShakeGameplayCam("DRUNK_SHAKE", 3.0)
	Wait(Config.HighTime*1000)
	SetPedIsDrunk(ped, false)		
	SetPedMotionBlur(ped, false)
	AnimpostfxStopAll()
	ShakeGameplayCam("DRUNK_SHAKE", 0.0)
	SetTimecycleModifierStrength(0.0)
	TriggerServerEvent("qb-bong:server:setdata", citizenid, "high", 0)
end)

RegisterNetEvent("qb-bong:client:effects", function(ped, coords)
	local distance = #(GetEntityCoords(PlayerPedId()) - coords)
	if distance <= 300 then
		if DoesEntityExist(NetToPed(ped)) and not IsEntityDead(NetToPed(ped)) then
			Smoke = UseParticleFxAssetNextCall("core")
			Particle = StartParticleFxLoopedOnEntityBone("exp_grd_bzgas_smoke", NetToPed(ped), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetPedBoneIndex(NetToPed(ped), 20279), Config.SmokeSize, 0.0, 0.0, 0.0)
			Wait(Config.SmokeTime*1000)
			while DoesParticleFxLoopedExist(Smoke) do
				StopParticleFxLooped(Smoke, 1)
				Wait(0)
			end
			while DoesParticleFxLoopedExist(Particle) do
				StopParticleFxLooped(Particle, 1)
				Wait(0)
			end
			while DoesParticleFxLoopedExist("exp_grd_bzgas_smoke") do
				StopParticleFxLooped("exp_grd_bzgas_smoke", 1)
				Wait(0)
			end
			while DoesParticleFxLoopedExist("core") do
				StopParticleFxLooped("core", 1)
				Wait(0)
			end
			Wait(Config.SmokeTime*1000*3)
			RemoveParticleFxFromEntity(NetToPed(ped))
		end
	end
end)
