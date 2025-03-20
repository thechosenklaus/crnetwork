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
AddEventHandler("animals:Dynamic",function()
	if Hash and DoesEntityExist(Hash) then
		exports["dynamic"]:AddMenu("Domésticos","Todas as funções dos animais domésticos.","animal")
		exports["dynamic"]:AddButton("Ficar/Seguir","Colocar o animal para te ficar/seguir.","animals:Functions","Seguir","animal",false)
		exports["dynamic"]:AddButton("Guardar","Colocar o animal na casinha.","animals:Functions","Deletar","animal",false)

		local Ped = PlayerPedId()
		if IsPedInAnyVehicle(Ped) and not IsPedOnAnyBike(Ped) then
			if not IsPedInAnyVehicle(Hash) then
				exports["dynamic"]:AddButton("Colocar","Colocar o animal dentro do veículo.","animals:Functions","Colocar","animal",false)
			end

			if IsPedInAnyVehicle(Hash) then
				exports["dynamic"]:AddButton("Remover","Retirar o animal de dentro do veículo.","animals:Functions","Remover","animal",false)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMALS:DELETE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("animals:Delete")
AddEventHandler("animals:Delete",function()
	Hash = nil
	Follow = false
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
			local Network = vRPS.CreateModels(Model, Coords["x"], Coords["y"], Coords["z"], Heading, 28)
			if Network then
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
		local Vehicle = GetVehiclePedIsUsing(Ped)
		if Functions == "Seguir" then
			if not Follow then
				TaskFollowToOffsetOfEntity(Hash, Ped, 1.0, 1.0, 0.0, 5.0, -1, 2.5, 1)
				SetPedKeepTask(Hash, true)
				Follow = true
			else
				SetPedKeepTask(Hash, false)
				ClearPedTasks(Hash)
				Follow = false
			end
		elseif Functions == "Colocar" then
			TaskEnterVehicle(Hash,Vehicle,-1,0,1.0,16,0)
		elseif Functions == "Remover" then
			TaskLeaveVehicle(Hash,Vehicle,16)
			Follow = false
		elseif Functions == "Deletar" then
			TriggerServerEvent("animals:Delete")
			Follow = false
			Hash = nil
		end
	end
end)