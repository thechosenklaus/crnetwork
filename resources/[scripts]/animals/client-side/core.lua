-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPS = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Hash = nil
local Spawn = false
local Follow = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMALS:DYNAMIC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("animals:Dynamic")
AddEventHandler("animals:Dynamic", function()
    if Hash ~= nil then
        exports["dynamic"]:AddMenu("Domésticos", "Tudo sobre animais domésticos.", "animals")
        exports["dynamic"]:AddButton("Seguir", "Seguir o proprietário.", "animals:Functions", "follow", "animals", false)
        exports["dynamic"]:AddButton("Colocar no Veículo", "Colocar o animal no veículo.", "animals:Functions", "putvehicle", "animals", false)
        exports["dynamic"]:AddButton("Remover do Veículo", "Remover o animal no veículo.", "animals:Functions", "removevehicle", "animals", false)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMALS:SPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("animals:Spawn")
AddEventHandler("animals:Spawn", function(Model)
	if Hash == nil then
		if not Spawn then
			Spawn = true

			local Ped = PlayerPedId()
			local Heading = GetEntityHeading(Ped)
			local Coords = GetOffsetFromEntityInWorldCoords(Ped, 0.0, 1.0, 0.0)
			local Object, Network = vRPS.CreatePed(Model, Coords["x"], Coords["y"], Coords["z"], Heading, 28)
			if Object then
				local Spawn = 0

				Hash = LoadNetwork(Network)
				while not DoesEntityExist(Hash) and Spawn <= 1000 do
					Hash = LoadNetwork(Network)
					Spawn = Spawn + 1
					Wait(1)
				end

				Spawn = 0
				local PedControl = NetworkRequestControlOfEntity(Hash)
				while not PedControl and Spawn <= 1000 do
					PedControl = NetworkRequestControlOfEntity(Hash)
					Spawn = Spawn + 1
					Wait(1)
				end

				SetPedCanRagdoll(Hash, false)
				SetEntityInvincible(Hash, true)
				SetPedFleeAttributes(Hash, 0, 0)
				SetEntityAsMissionEntity(Hash, true, false)
				SetBlockingOfNonTemporaryEvents(Hash, true)
				SetPedRelationshipGroupHash(Hash, GetHashKey("k9"))
				GiveWeaponToPed(Hash, GetHashKey("WEAPON_ANIMAL"), 200, true, true)

				SetEntityAsNoLongerNeeded(Hash)

				TriggerEvent("animals:Functions", "follow")

				TriggerServerEvent("animals:Animals",Network)
			end

			Spawn = false
		end
	else
		TriggerServerEvent("animals:Delete")
		Follow = false
		Hash = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMALS:FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("animals:Functions")
AddEventHandler("animals:Functions", function(Functions)
	if Hash ~= nil then
		local Ped = PlayerPedId()
		if Functions == "follow" then
			if not Follow then
				TaskFollowToOffsetOfEntity(Hash, Ped, 1.0, 1.0, 0.0, 5.0, -1, 2.5, 1)
				SetPedKeepTask(Hash, true)
				Follow = true
			else
				SetPedKeepTask(Hash, false)
				ClearPedTasks(Hash)
				Follow = false
			end
		elseif Functions == "putvehicle" then
			if IsPedInAnyVehicle(Ped) and not IsPedOnAnyBike(Ped) then
				local Vehicle = GetVehiclePedIsUsing(Ped)
				if IsVehicleSeatFree(Vehicle, 0) then
					TaskEnterVehicle(Hash, Vehicle, -1, 0, 2.0, 16, 0)
				end
			end
		elseif Functions == "removevehicle" then
			if IsPedInAnyVehicle(Ped) and not IsPedOnAnyBike(Ped) then
				TaskLeaveVehicle(Hash, GetVehiclePedIsUsing(Ped), 256)
				TriggerEvent("animals:Functions", "follow")
			end
		elseif Functions == "destroy" then
			TriggerServerEvent("animals:Delete")
			Follow = false
			Hash = nil
		end
	end
end)