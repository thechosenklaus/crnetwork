-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Blip = {}
local Objects = {}
local Active = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	LoadModel(EventProp)

	if GlobalState["Christmas"] then
		Active = GlobalState["Christmas"]
		ChristmasMarkerMap()
	end

	while true do
		local TimeDistance = 5000
		if Active then
			local Ped = PlayerPedId()
			local Coords = GetEntityCoords(Ped)

			for Number,v in pairs(Components) do
				if #(Coords - v.xyz) <= 100 then
					if not GlobalState["ChristmasBlock:"..Number] and not Objects[Number] then
						Objects[Number] = CreateObjectNoOffset(EventProp,v.xyz,false,false,false)
						SetEntityLodDist(Objects[Number],0xFFFF)
						FreezeEntityPosition(Objects[Number],true)
						PlaceObjectOnGroundProperly(Objects[Number])
						SetEntityHeading(Objects[Number],v.w)

						exports["target"]:AddBoxZone("Christmas:"..Number,v.xyz,1.25,2.0,{
							name = "Christmas:"..Number,
							heading = v.w,
							minZ = v.z - 1.0,
							maxZ = v.z + 0.75
						},{
							shop = "Christmas:"..Number,
							Distance = 2.0,
							options = {
								{
									event = "chest:Open",
									label = "Abrir",
									tunnel = "client",
									service = "Custom"
								}
							}
						})
					end
				elseif Objects[Number] then
					exports["target"]:RemCircleZone("Christmas:"..Number)
					TriggerEvent("inventory:Close","Christmas:"..Number)

					if DoesEntityExist(Objects[Number]) then
						DeleteEntity(Objects[Number])
					end

					Objects[Number] = nil
				end
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
for Number in pairs(Components) do
	AddStateBagChangeHandler("ChristmasBlock:"..Number,nil,function(Name,Key,Value)
		if Value then
			if DoesBlipExist(Blip[Number]) then
				RemoveBlip(Blip[Number])
			end

			if Objects[Number] then
				exports["target"]:RemCircleZone("Christmas:"..Number)
				TriggerEvent("inventory:Close","Christmas:"..Number)

				if DoesEntityExist(Objects[Number]) then
					DeleteEntity(Objects[Number])
				end

				Objects[Number] = nil
			end
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("Christmas",nil,function(Name,Key,Value)
	Active = Value

	for _,v in pairs(Blip) do
		if DoesBlipExist(v) then
			RemoveBlip(v)
		end
	end

	if Active then
		ChristmasMarkerMap()
	end

	if CountTable(Objects) >= 1 then
		for Index,v in pairs(Objects) do
			exports["target"]:RemCircleZone("Christmas:"..Index)
			TriggerEvent("inventory:Close","Christmas:"..Index)

			if DoesEntityExist(Objects[Index]) then
				DeleteEntity(Objects[Index])
			end
		end

		Objects = {}
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHRISTMASMARKERMAP
-----------------------------------------------------------------------------------------------------------------------------------------
function ChristmasMarkerMap()
	for Index,v in pairs(Components) do
		Blip[Index] = AddBlipForCoord(v.xyz)
		SetBlipSprite(Blip[Index],478)
		SetBlipDisplay(Blip[Index],4)
		SetBlipAsShortRange(Blip[Index],true)
		SetBlipColour(Blip[Index],5)
		SetBlipScale(Blip[Index],0.6)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Presente")
		EndTextCommandSetBlipName(Blip[Index])

		Wait(10)
	end
end