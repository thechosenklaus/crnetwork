-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
vRPS = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("towed")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Blip = nil
local Destiny = 1
local Vehicle = nil
local Locale = false
local Service = false
local ModelSelected = ""
local TimeDistance = 999
local VehiclePlate = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVERSTART
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	for Name,v in pairs(Init) do
		exports["target"]:AddBoxZone("Towed:"..Name,v["xyz"],0.75,0.75,{
			name = "Towed:"..Name,
			heading = v["w"],
			minZ = v["z"] - 1.0,
			maxZ = v["z"] + 1.0
		},{
			shop = Name,
			Distance = 1.75,
			options = {
				{
					event = "towed:Init",
					label = "Iniciar Expediente",
					tunnel = "client"
				}
			}
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOWED:INIT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("towed:Init",function(Data)
	if DoesBlipExist(Blip) then
		RemoveBlip(Blip)
		Blip = nil
	end

	if Service then
		TriggerEvent("Notify","Central de Empregos","Você acaba finalizar sua jornada de trabalho, esperamos que você tenha aprendido bastante hoje.","default",5000)
		exports["target"]:LabelText("Towed","Iniciar Expediente")
		Service = false
		Locale = false
	else
		Locale = Data
		TriggerEvent("Notify","Central de Empregos","Você acaba de dar inicio a sua jornada de trabalho, lembrando que a sua vida não se resume só a isso.","default",5000)
		exports["target"]:LabelText("Towed","Finalizar Expediente")
		ModelSelected = Models[math.random(#Models)]
		Destiny = math.random(#Locations[Locale])
		VehiclePlate = nil
		MarkedVehicle()
		Service = true
	end

	vSERVER.Service()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOWED:INATIVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("towed:Inative")
AddEventHandler("towed:Inative",function(Plate)
	if VehiclePlate == Plate then
		ModelSelected = Models[math.random(#Models)]
		Destiny = math.random(#Locations[Locale])
		VehiclePlate = false
		TimeDistance = 999
		MarkedVehicle()
		Vehicle = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if Service then
			local Ped = PlayerPedId()
			local Coords = GetEntityCoords(Ped)

			if not Vehicle and Locale then
				TimeDistance = 1999

				if #(Coords - Locations[Locale][Destiny]["xyz"]) <= 100 then
					local Networked,Plate = vSERVER.Vehicle(ModelSelected,Locale,Destiny)
					if Networked then
						local Network = LoadNetwork(Networked)
						if Network then
							if DoesBlipExist(Blip) then
								RemoveBlip(Blip)
								Blip = nil
							end

							Vehicle = Network
							VehiclePlate = Plate

							SetVehicleEngineHealth(Vehicle,10.0)
							SetVehicleHasBeenOwnedByPlayer(Vehicle,true)
							SetVehicleNeedsToBeHotwired(Vehicle,false)
							DecorSetInt(Vehicle,"Player_Vehicle",-1)
							SetVehicleOnGroundProperly(Vehicle)
							SetVehRadioStation(Vehicle,"OFF")
							SetEntityHealth(Vehicle,10)

							SetModelAsNoLongerNeeded(ModelSelected)
						end
					end
				end
			elseif DoesEntityExist(Vehicle) and not Entity(Vehicle)["state"]["Tow"] then
				TimeDistance = 1

				local OtherCoords = GetEntityCoords(Vehicle)
				DrawMarker(22,OtherCoords["x"],OtherCoords["y"],OtherCoords["z"] + 2.5,0.0,0.0,0.0,0.0,180.0,0.0,2.5,2.5,1.5,88,101,242,175,0,0,0,1)
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKEDPASSENGER
-----------------------------------------------------------------------------------------------------------------------------------------
function MarkedVehicle()
	if DoesBlipExist(Blip) then
		RemoveBlip(Blip)
		Blip = nil
	end

	Blip = AddBlipForCoord(Locations[Locale][Destiny]["x"],Locations[Locale][Destiny]["y"],Locations[Locale][Destiny]["z"])
	SetBlipSprite(Blip,1)
	SetBlipDisplay(Blip,4)
	SetBlipAsShortRange(Blip,true)
	SetBlipColour(Blip,77)
	SetBlipScale(Blip,0.75)
	SetBlipRoute(Blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Veiculo Quebrado")
	EndTextCommandSetBlipName(Blip)
end