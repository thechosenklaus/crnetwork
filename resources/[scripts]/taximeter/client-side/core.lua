-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Price = 0
local Extras = 0
local Focus = false
local Driver = false
local Starter = false
local Display = false
local ExtraPrice = 0.5
local LastCoords = vec3(0,0,0)
local PriceDecor = "_CREATIVE_TAXI_PRICE_"
local ExtraDecor = "_CREATIVE_TAXI_EXTRA_"
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTAXI
-----------------------------------------------------------------------------------------------------------------------------------------
function SetTaxi(Vehicle)
	DecorSetFloat(Vehicle,PriceDecor,tonumber(string.format("%.2f",Price)))
	DecorSetFloat(Vehicle,ExtraDecor,tonumber(string.format("%.2f",Extras)))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETTAXI
-----------------------------------------------------------------------------------------------------------------------------------------
function GetTaxi(Vehicle)
	if not DecorExistOn(Vehicle,PriceDecor) or not DecorExistOn(Vehicle,ExtraDecor) then
		return Price,Extras
	end

	return DecorGetFloat(Vehicle,PriceDecor),DecorGetFloat(Vehicle,ExtraDecor)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLETAXI
-----------------------------------------------------------------------------------------------------------------------------------------
function VehicleTaxi(Vehicle)
	for _,v in ipairs({ "taxi","taxi2" }) do
		if GetEntityArchetypeName(Vehicle) == v then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	DecorRegister(PriceDecor,1)
	DecorRegister(ExtraDecor,1)

	while true do
		local Ped = PlayerPedId()
		local Vehicle = GetVehiclePedIsIn(Ped)
		if Vehicle ~= 0 and VehicleTaxi(Vehicle) then
			local Coords = GetEntityCoords(Ped)
			local Seat = GetPedInVehicleSeat(Vehicle,-1)

			if not Display then
				Display = true
				SendNUIMessage({ type = "showUI", display = Display })
			end

			if Seat == Ped then
				if not Driver then
					Driver = true
					SendNUIMessage({ type = "updateDriver", driver = Driver })
				end

				if Starter and Coords ~= LastCoords then
					Price = Price + (GetVehicleCurrentRpm(Vehicle) / 5)
					LastCoords = Coords
					SetTaxi(Vehicle)
				end
			elseif Driver then
				Driver = false
				SendNUIMessage({ type = "updateDriver", driver = Driver })
			end

			local CurrentPrice,CurrentExtras = GetTaxi(Vehicle)
			SendNUIMessage({ type = "updateFare", fare = CurrentPrice, extras = CurrentExtras, total = CurrentPrice + CurrentExtras })
		elseif Display then
			Display = false
			SendNUIMessage({ type = "showUI", display = Display })
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXTRASADD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("extrasAdd",function()
	Extras = Extras + ExtraPrice
	UpdatePrice()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXTRASREMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("extrasRemove",function()
	if Extras >= ExtraPrice then
		Extras = Extras - ExtraPrice
		UpdatePrice()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTMETER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("startMeter",function()
	local Ped = PlayerPedId()
	local Vehicle = GetVehiclePedIsIn(Ped)

	SetTaxi(Vehicle,Price,Extras)

	LastCoords = GetEntityCoords(Ped)
	Starter = true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOPMETER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("stopMeter",function()
	local Ped = PlayerPedId()
	local Vehicle = GetVehiclePedIsIn(Ped)

	SetTaxi(Vehicle,Price,Extras)

	LastCoords = GetEntityCoords(Ped)
	Starter = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESETMETER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("resetMeter",function()
	local Ped = PlayerPedId()
	local Vehicle = GetVehiclePedIsIn(Ped)

	Price = 0
	Extras = 0
	Starter = false
	LastCoords = GetEntityCoords(Ped)

	SetTaxi(Vehicle,Price,Extras)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEPRICE
-----------------------------------------------------------------------------------------------------------------------------------------
function UpdatePrice()
	local Ped = PlayerPedId()
	local Vehicle = GetVehiclePedIsIn(Ped)

	SetTaxi(Vehicle,Price,Extras)
	SendNUIMessage({ type = "updateFare", fare = Price, extras = Extras, total = Price + Extras })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- +TAXIMETER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+Taximeter",function()
	if not Driver then
		return false
	end

	Focus = not Focus
	SetNuiFocus(Focus,Focus)
	SetNuiFocusKeepInput(Focus)

	if Focus then
		SetCursorLocation(0.85,0.85)

		CreateThread(function()
			while true do
				DisableControlAction(0,1,true)
				DisableControlAction(0,2,true)

				if not Focus then
					break
				end

				Wait(1)
			end
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEYMAPPING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("+Taximeter","Interação com o taximetro.","keyboard","F3")