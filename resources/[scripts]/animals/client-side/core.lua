-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
vRPS = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Animal = nil
local Follow = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMALS:DYNAMIC
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("animals:Dynamic",function()
	if Animal and DoesEntityExist(Animal) then
		exports["dynamic"]:AddMenu("Domésticos","Todas as funções dos animais domésticos.","animal")
		exports["dynamic"]:AddButton("Ficar/Seguir","Colocar o animal para te ficar/seguir.","animals:Functions","Seguir","animal",false)
		exports["dynamic"]:AddButton("Guardar","Colocar o animal na casinha.","animals:Functions","Deletar","animal",false)

		local Ped = PlayerPedId()
		if IsPedInAnyVehicle(Ped) and not IsPedOnAnyBike(Ped) then
			if not IsPedInAnyVehicle(Animal) then
				exports["dynamic"]:AddButton("Colocar","Colocar o animal dentro do veículo.","animals:Functions","Colocar","animal",false)
			end

			if IsPedInAnyVehicle(Animal) then
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
	Animal = nil
	Follow = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMALS:SPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("animals:Spawn")
AddEventHandler("animals:Spawn",function(Model)
	if Animal and DoesEntityExist(Animal) then return end

	local Timeout = 5000
	local Ped = PlayerPedId()
	local StartTime = GetGameTimer()
	local Coords = GetOffsetFromEntityInWorldCoords(Ped,0.0,1.0,0.0)

	local Network = vRPS.CreateModels(Model,Coords.x,Coords.y,Coords.z,5)
	if not Network then return end

	Animal,AnimalNet = LoadNetwork(Network)
	while not DoesEntityExist(Animal) do
		if GetGameTimer() - StartTime > Timeout then
			return
		end

		Wait(100)
	end

	ClearPedTasks(Animal)
	SetPedKeepTask(Animal,true)
	SetPedCanRagdoll(Animal,false)
	SetEntityInvincible(Animal,true)
	SetPedFleeAttributes(Animal,0,0)
	SetEntityAsMissionEntity(Animal,true,false)
	SetBlockingOfNonTemporaryEvents(Animal,true)
	SetPedRelationshipGroupHash(Animal,GetHashKey("k9"))
	TaskFollowToOffsetOfEntity(Animal,Ped,0.5,0.0,0.0,5.0,-1,0.0,1)
	GiveWeaponToPed(Animal,GetHashKey("WEAPON_ANIMAL"),200,true,true)

	TriggerServerEvent("animals:Register",AnimalNet)
	TriggerEvent("dynamic:Close")

	SetEntityAsNoLongerNeeded(Animal)
	SetModelAsNoLongerNeeded(Animal)

	Follow = true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMALS:FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("animals:Functions",function(Mode)
	if not Animal or not DoesEntityExist(Animal) then return end

	local Ped = PlayerPedId()
	local Vehicle = GetVehiclePedIsUsing(Ped)

	if Mode == "Seguir" then
		ClearPedTasks(Animal)

		if Follow then
			SetPedKeepTask(Animal,false)
		else
			SetPedKeepTask(Animal,true)
			TaskFollowToOffsetOfEntity(Animal,Ped,0.5,0.0,0.0,5.0,-1,0.0,1)
		end

		Follow = not Follow
	elseif Mode == "Colocar" and Vehicle and IsVehicleSeatFree(Vehicle,0) then
		TaskEnterVehicle(Animal,Vehicle,-1,0,1.0,16,0)
	elseif Mode == "Remover" and Vehicle then
		TaskLeaveVehicle(Animal,Vehicle,16)
		Follow = false
	elseif Mode == "Deletar" then
		TriggerServerEvent("animals:Cleaner")
		TriggerEvent("dynamic:Close")
		Follow = false
		Animal = nil
	end
end)