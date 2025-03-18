-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("farmer",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Poly = {}
local Blips = {}
local Display = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INPUTTARGETPOSITION
-----------------------------------------------------------------------------------------------------------------------------------------
function InputTargetPosition(Number,v)
	exports["target"]:AddBoxZone("Farmer:"..Number,v["Coords"]["xyz"],v["Width"],v["Width"],{
		name = "Farmer:"..Number,
		heading = v["Coords"]["w"] or 0.0,
		minZ = v["Coords"]["z"] - (v["Lower"] or 0.0),
		maxZ = v["Coords"]["z"] + (v["Upper"] or 0.0)
	},{
		shop = Number,
		Distance = v["Distance"] or 1.5,
		options = {
			{
				event = v["Event"],
				label = v["Label"],
				tunnel = "server"
			}
		}
	})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	for Service,_ in pairs(FastFarmer) do
		for Number,v in pairs(FastFarmer[Service]["Coords"]) do
			exports["target"]:AddCircleZone(Service..":"..Number,v,FastFarmer[Service]["Width"],{
				name = Service..":"..Number,
				heading = 0.0,
				useZ = true
			},{
				Distance = FastFarmer[Service]["Distance"],
				options = FastFarmer[Service]["Options"]
			})
		end

		if FastFarmer[Service]["PolyZone"] and not Poly[Service] then
			Poly[Service] = PolyZone:Create(FastFarmer[Service]["PolyZone"],{ name = Service })
		end
	end

	while true do
		local Ped = PlayerPedId()
		local TimerDistance = 5000
		if not IsPedInAnyVehicle(Ped) then
			local Coords = GetEntityCoords(Ped)

			for Number,v in pairs(Objects) do
				if #(Coords - v["Coords"]["xyz"]) <= (v["Show"] or 100.0) and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
					if not Display[Number] and LoadModel(v["Model"]) then
						Display[Number] = CreateObjectNoOffset(v["Model"],v["Coords"]["x"],v["Coords"]["y"],v["Coords"]["z"] - (v["Height"] or 0.0),false,false,false)

						SetEntityHeading(Display[Number],v["Coords"]["w"])
						FreezeEntityPosition(Display[Number],true)
						SetModelAsNoLongerNeeded(v["Model"])

						if v["Model"] == "prop_rub_binbag_06" then
							PlaceObjectOnGroundProperly(Display[Number])
							v["Coords"] = GetEntityCoords(Display[Number])
						end

						InputTargetPosition(Number,v)
						TimerDistance = 1000
					end
				else
					if Display[Number] then
						if DoesEntityExist(Display[Number]) then
							DeleteEntity(Display[Number])
						end

						exports["target"]:RemCircleZone("Farmer:"..Number)
						Display[Number] = nil
					end
				end

				if #Blips > 0 and v["Model"] == "prop_rub_binbag_06" and not Blips[Number] and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
					Blips[Number] = AddBlipForRadius(v["Coords"]["xyz"],5.0)
					SetBlipAlpha(Blips[Number],150)
					SetBlipColour(Blips[Number],4)
				end
			end
		end

		Wait(TimerDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FARMER:BLIPS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("farmer:Blips")
AddEventHandler("farmer:Blips",function()
	if #Blips > 0 then
		for _,v in pairs(Blips) do
			if DoesBlipExist(v) then
				RemoveBlip(v)
			end
		end

		Blips = {}

		TriggerEvent("Notify","Lixeiro","Marcações desativadas.","default",10000)
	else
		for Number,v in pairs(Objects) do
			if not Blips[Number] and v["Model"] == "prop_rub_binbag_06" and GlobalState["Work"] >= GlobalState["Farmer:"..Number] then
				Blips[Number] = AddBlipForRadius(v["Coords"]["xyz"],5.0)
				SetBlipAlpha(Blips[Number],150)
				SetBlipColour(Blips[Number],4)
			end
		end

		TriggerEvent("Notify","Lixeiro","Marcações ativadas.","default",10000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
for Number = 1,#Objects do
	AddStateBagChangeHandler("Farmer:"..Number,nil,function(Name,Key,Value)
		if Display[Number] then
			if DoesEntityExist(Display[Number]) then
				DeleteEntity(Display[Number])
			end

			exports["target"]:RemCircleZone("Farmer:"..Number)
			Display[Number] = nil
		end

		if Blips[Number] then
			if DoesBlipExist(Blips[Number]) then
				RemoveBlip(Blips[Number])
			end

			Blips[Number] = nil
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- POLYZONE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.PolyZone(Service)
	local Ped = PlayerPedId()
	local Coords = GetEntityCoords(Ped)

	return Poly[Service] and Poly[Service]:isPointInside(Coords)
end