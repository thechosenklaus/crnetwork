-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Init = {}
local Sprays = {}
local Objects = {}
local Switch = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPRAYEXIST
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.SprayExist(Distance)
	local Ped = PlayerPedId()
	local Coords = GetEntityCoords(Ped)

	for _,Spray in pairs(Sprays) do
		if #(Coords - GetBlipCoords(Spray["Blip"])) <= (Distance or 250) then
			return Spray["Permission"]
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OBJECTS:TABLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("objects:Table")
AddEventHandler("objects:Table",function(Table)
	Objects = Table

	local Colors = {
		LootMedics = 76,
		LootWeapons = 52,
		LootSupplies = 56,
		LootLegendary = 81
	}

	for Number,v in pairs(Objects) do
		if v["Mode"] then
			if Colors[v["Mode"]] then
				local Blip = AddBlipForRadius(v["Coords"][1],v["Coords"][2],v["Coords"][3],25.0)
				SetBlipAlpha(Blip,200)
				SetBlipColour(Blip,Colors[v["Mode"]])
			elseif v["Mode"] == "Sprays" then
				if not Sprays[Number] then
					Sprays[Number] = {}
				end

				Sprays[Number]["Blip"] = AddBlipForRadius(v["Coords"][1],v["Coords"][2],v["Coords"][3],250.0)
				SetBlipColour(Sprays[Number]["Blip"],v["Color"])
				Sprays[Number]["Permission"] = v["Permission"]
				SetBlipAlpha(Sprays[Number]["Blip"],150)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OBJECTS:ADICIONAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("objects:Adicionar")
AddEventHandler("objects:Adicionar",function(Number,Table)
	if not Table then return end

	Objects[Number] = Table

	if Table["Mode"] and Table["Mode"] == "Sprays" then
		if not Sprays[Number] then
			Sprays[Number] = {}
		end

		local Blip = AddBlipForRadius(Table["Coords"][1],Table["Coords"][2],Table["Coords"][3],250.0)
		SetBlipColour(Blip,Table["Color"])
		SetBlipAlpha(Blip,150)

		Sprays[Number]["Blip"] = Blip
		Sprays[Number]["Permission"] = Table["Permission"]
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OBJECTS:REMOVER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("objects:Remover")
AddEventHandler("objects:Remover",function(Number)
	if Init[Number] then
		if DoesEntityExist(Init[Number]) then
			DeleteEntity(Init[Number])
		end

		if Objects[Number] and Objects[Number]["Mode"] then
			exports["target"]:RemCircleZone("Objects:"..Number)
		end

		Init[Number] = nil
	end

	if Objects[Number] and Objects[Number]["Active"] == "Spikes" then
		TriggerEvent("spikes:Remover",Number)
	end

	if Sprays[Number] then
		local Blip = Sprays[Number]
		if DoesBlipExist(Blip["Blip"]) then
			RemoveBlip(Blip["Blip"])
		end

		Sprays[Number] = nil
	end

	if Objects[Number] then
		Objects[Number] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDTARGETZONE
-----------------------------------------------------------------------------------------------------------------------------------------
function AddTargetZone(Number,Coords,Mode,Weight,options,size,isBox)
	local zoneParams = {
		name = "Objects:"..Number,
		heading = Coords[4] or 0.0
	}

	if isBox then
		zoneParams.minZ = Coords[3]
		zoneParams.maxZ = Coords[3] + (size.maxZ or 1.5)
		exports["target"]:AddBoxZone("Objects:"..Number,vec3(Coords[1],Coords[2],Coords[3] + Weight),size.width,size.height,zoneParams,options)
	else
		zoneParams.useZ = true
		exports["target"]:AddCircleZone("Objects:"..Number,vec3(Coords[1],Coords[2],Coords[3] + Weight),size.radius,zoneParams,options)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TARGETLABEL
-----------------------------------------------------------------------------------------------------------------------------------------
function TargetLabel(Number,Coords,Mode,Weight,Item)
	local modes = {
		Store = {
			isBox = false,
			size = { radius = 0.75 },
			options = {
				shop = Number,
				Distance = 1.5,
				options = {
					{ event = "inventory:StoreObjects", label = "Guardar", tunnel = "server" }
				}
			}
		},
		Destroy = {
			isBox = false,
			size = { radius = 0.75 },
			options = {
				shop = Number,
				Distance = 1.5,
				options = {
					{ event = "inventory:StoreObjects", label = "Destruir", tunnel = "server" }
				}
			}
		},
		Craftings = {
			isBox = false,
			size = { radius = 0.25 },
			options = {
				shop = Number,
				Distance = 1.5,
				options = {
					{ event = "crafting:Open", label = "Abrir", tunnel = "products", service = Item and SplitOne(Item) or "" },
					{ event = "inventory:StoreObjects", label = "Guardar", tunnel = "server" }
				}
			}
		},
		Shops = {
			isBox = false,
			size = { radius = 0.45 },
			options = {
				shop = Number,
				Distance = 1.5,
				options = {
					{ event = "shops:Open", label = "Abrir", tunnel = "products", service = Item and SplitOne(Item) or "" },
					{ event = "inventory:StoreObjects", label = "Guardar", tunnel = "server" }
				}
			}
		},
		Chests = {
			isBox = true,
			size = { width = 1.4, height = 1.7, maxZ = 1.5 },
			options = {
				shop = Number,
				Distance = 1.75,
				options = {
					{ event = "chest:Item", label = "Abrir", tunnel = "products", service = Item and SplitOne(Item) or "" },
					{ event = "inventory:StoreObjects", label = "Guardar", tunnel = "server" }
				}
			}
		},
		Sprays = {
			isBox = false,
			size = { radius = 1.0 },
			options = {
				shop = Number,
				Distance = 2.5,
				options = {
					{ event = "inventory:StoreObjects", label = "Violar", tunnel = "server" }
				}
			}
		},
		Recycle = {
			isBox = true,
			size = { width = 1.5, height = 3.75, maxZ = 2.0 },
			options = {
				shop = Number,
				Distance = 2.25,
				options = {
					{ event = "chest:Recycle", label = "Abrir", tunnel = "client" }
				}
			}
		},
		LootLegendary = {
			isBox = true,
			size = { width = 1.15, height = 2.15, maxZ = 0.8 },
			options = {
				shop = Number,
				Distance = 2.0,
				options = {
					{ event = "inventory:Loot", label = "Abrir", tunnel = "server", service = Mode }
				}
			}
		},
		LootSupplies = {
			isBox = true,
			size = { width = 0.5, height = 1.0, maxZ = 0.55 },
			options = {
				shop = Number,
				Distance = 1.5,
				options = {
					{ event = "inventory:Loot", label = "Abrir", tunnel = "server", service = Mode }
				}
			}
		},
		LootWeapons = {
			isBox = true,
			size = { width = 0.9, height = 1.5, maxZ = 0.65 },
			options = {
				shop = Number,
				Distance = 1.5,
				options = {
					{ event = "inventory:Loot", label = "Abrir", tunnel = "server", service = Mode }
				}
			}
		},
		LootMedics = {
			isBox = true,
			size = { width = 0.75, height = 1.0, maxZ = 0.55 },
			options = {
				shop = Number,
				Distance = 1.5,
				options = {
					{ event = "inventory:Loot", label = "Abrir", tunnel = "server", service = Mode }
				}
			}
		},
		LootCode = {
			isBox = true,
			size = { width = 1.0, height = 1.0, maxZ = 1.75 },
			options = {
				shop = Number,
				Distance = 1.5,
				options = {
					{ event = "inventory:Loot", label = "Abrir", tunnel = "server", service = Mode }
				}
			}
		}
	}

	if modes[Mode] then
		AddTargetZone(Number,Coords,Mode,Weight,modes[Mode].options,modes[Mode].size,modes[Mode].isBox)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEANDMANAGEOBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
function CreateAndManageObject(Number,v,Coords)
	local OtherCoords = vec3(v["Coords"][1],v["Coords"][2],v["Coords"][3])

	if #(Coords - OtherCoords) <= (v["Distance"] or 100) then
		if not Init[Number] and LoadModel(v["Object"]) then
			Init[Number] = CreateObjectNoOffset(v["Object"],OtherCoords.x,OtherCoords.y,OtherCoords.z,false,false,false)
			SetEntityHeading(Init[Number],v["Coords"][4])
			FreezeEntityPosition(Init[Number],true)
			SetModelAsNoLongerNeeded(v["Object"])

			if v["Mode"] then
				TargetLabel(Number,v["Coords"],v["Mode"],v["Weight"] or 0.0,v["Item"])
			end

			if not v["Ground"] then
				PlaceObjectOnGroundProperly(Init[Number])
			end

			if v["Active"] == "Spikes" then
				local Max = GetOffsetFromEntityInWorldCoords(Init[Number],0.0,1.84,0.1)
				local Min = GetOffsetFromEntityInWorldCoords(Init[Number],0.0,-1.84,-0.1)
				TriggerEvent("spikes:Adicionar",Number,v["Coords"],Min,Max)
			end
		end
	elseif Init[Number] then
		DestroyObject(Number,v)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)

		for Number,v in pairs(Objects) do
			if not v["Bucket"] or v["Bucket"] == LocalPlayer["state"]["Route"] then
				CreateAndManageObject(Number,v,Coords)
			elseif Init[Number] then
				DestroyObject(Number,v)
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYOBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
function DestroyObject(Number,v)
	if Init[Number] then
		if v["Mode"] then
			exports["target"]:RemCircleZone("Objects:"..Number)
		end

		if DoesEntityExist(Init[Number]) then
			DeleteEntity(Init[Number])
		end

		if v["Active"] and v["Active"] == "Spikes" then
			TriggerEvent("spikes:Remover",Number)
		end

		Init[Number] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OBJECTCONTROLLING
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.ObjectControlling(Model,Rotate,Align)
	local Switch = false
	local Aplication = false
	local OtherCoords = false

	if LoadModel(Model) then
		local Progress = true
		local Ped = PlayerPedId()
		local Heading = GetEntityHeading(Ped)
		local Coords = GetOffsetFromEntityInWorldCoords(Ped,0.0,Align or 1.0,0.0)
		local NextObject = CreateObjectNoOffset(Model,Coords.x,Coords.y,Coords.z,false,false,false)

		SetEntityAlpha(NextObject,175,false)
		PlaceObjectOnGroundProperly(NextObject)
		SetEntityCollision(NextObject,false,false)
		SetEntityHeading(NextObject,Heading + (Rotate or 0.0))

		local defaultButtons = {
			{ "F","Cancelar" },
			{ "H","Posicionar" },
			{ "Q","Rotacionar Esquerda" },
			{ "E","Rotacionar Direita" },
			{ "Z","Trocar Modo" }
		}

		local extendedButtons = {
			{ "F","Cancelar" },
			{ "H","Posicionar" },
			{ "Q","Rotacionar Esquerda" },
			{ "E","Rotacionar Direita" },
			{ "-","Descer" },
			{ "+","Subir" },
			{ "↑","Movimentar para Frente" },
			{ "←","Movimentar para Esquerda" },
			{ "↓","Movimentar para Baixo" },
			{ "→","Movimentar para Direita" },
			{ "Z","Trocar Modo" }
		}

		TriggerEvent("inventory:Buttons",defaultButtons)

		while Progress do
			local controlPressed = GetMovementControls(NextObject)
			if controlPressed then
				MoveObject(NextObject,controlPressed)
			end

			RotateObject(NextObject)
			DrawGraphOutline(NextObject)

			if not Switch then
				local Cam = GetGameplayCamCoord()
				local Handle = StartExpensiveSynchronousShapeTestLosProbe(Cam,GetCoordsFromCam(10.0,Cam),-1,Ped,4)
				local _,_,Coords = GetShapeTestResult(Handle)
				SetEntityCoords(NextObject,Coords.x,Coords.y,Coords.z,false,false,false,false)
			end

			if IsControlJustPressed(0,48) then
				Switch = not Switch
				TriggerEvent("inventory:Buttons",Switch and extendedButtons or defaultButtons)
			elseif IsControlJustPressed(1,74) then
				TriggerEvent("inventory:CloseButtons")
				Aplication = true
				Progress = false
				Switch = false
			elseif IsControlJustPressed(0,49) then
				TriggerEvent("inventory:CloseButtons")
				Aplication = false
				Progress = false
				Switch = false
			end

			Wait(1)
		end

		if DoesEntityExist(NextObject) then
			local oCoords = GetEntityCoords(NextObject)
			local oHeading = GetEntityHeading(NextObject)
			OtherCoords = { Optimize(oCoords.x),Optimize(oCoords.y),Optimize(oCoords.z),Optimize(oHeading) }

			DeleteEntity(NextObject)
		end
	end

	if not OtherCoords or (OtherCoords and OtherCoords[1] == 0.0 and OtherCoords[2] == 0.0) then
		Aplication = false
	end

	return Aplication,OtherCoords
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETMOVEMENTCONTROLS
-----------------------------------------------------------------------------------------------------------------------------------------
function GetMovementControls(NextObject)
	local controls = false

	if IsDisabledControlPressed(1,314) then
		controls = {}
		controls.zMoveUp = true
	elseif IsDisabledControlPressed(1,315) then
		controls = {}
		controls.zMoveDown = true
	end

	if IsDisabledControlPressed(1,172) then
		controls = {}
		controls.xMoveRight = true
	elseif IsDisabledControlPressed(1,173) then
		controls = {}
		controls.xMoveLeft = true
	end

	if IsDisabledControlPressed(1,174) then
		controls = {}
		controls.yMoveBackward = true
	elseif IsDisabledControlPressed(1,175) then
		controls = {}
		controls.yMoveForward = true
	end

	return controls
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOVEOBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
function MoveObject(NextObject,controls)
	local Coords = GetEntityCoords(NextObject)

	if controls.zMoveUp then
		Coords = GetOffsetFromEntityInWorldCoords(NextObject,0.0,0.0,0.005)
		SetEntityCoordsNoOffset(NextObject,Coords.x,Coords.y,Coords.z,false,false,false)
	elseif controls.zMoveDown then
		Coords = GetOffsetFromEntityInWorldCoords(NextObject,0.0,0.0,-0.005)
		SetEntityCoordsNoOffset(NextObject,Coords.x,Coords.y,Coords.z,false,false,false)
	end

	if controls.xMoveRight then
		Coords = GetOffsetFromEntityInWorldCoords(NextObject,0.0,0.005,0.0)
		SetEntityCoordsNoOffset(NextObject,Coords.x,Coords.y,Coords.z,false,false,false)
	elseif controls.xMoveLeft then
		Coords = GetOffsetFromEntityInWorldCoords(NextObject,0.0,-0.005,0.0)
		SetEntityCoordsNoOffset(NextObject,Coords.x,Coords.y,Coords.z,false,false,false)
	end

	if controls.yMoveBackward then
		Coords = GetOffsetFromEntityInWorldCoords(NextObject,-0.005,0.0,0.0)
		SetEntityCoordsNoOffset(NextObject,Coords.x,Coords.y,Coords.z,false,false,false)
	elseif controls.yMoveForward then
		Coords = GetOffsetFromEntityInWorldCoords(NextObject,0.005,0.0,0.0)
		SetEntityCoordsNoOffset(NextObject,Coords.x,Coords.y,Coords.z,false,false,false)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTATEOBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
function RotateObject(NextObject)
	if IsControlPressed(0,38) then
		SetEntityHeading(NextObject,GetEntityHeading(NextObject) + 0.25)
	elseif IsControlPressed(0,52) then
		SetEntityHeading(NextObject,GetEntityHeading(NextObject) - 0.25)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAWGRAPHOUTLINE
-----------------------------------------------------------------------------------------------------------------------------------------
function DrawGraphOutline(Object)
	local Coords = GetEntityCoords(Object)

	local offsetX = GetOffsetFromEntityInWorldCoords(Object,2.0,0.0,0.0)
	local offsetY = GetOffsetFromEntityInWorldCoords(Object,0.0,2.0,0.0)
	local offsetZ = GetOffsetFromEntityInWorldCoords(Object,0.0,0.0,2.0)

	local x1,x2 = Coords.x - offsetX.x,Coords.x + offsetX.x
	local y1,y2 = Coords.y - offsetY.y,Coords.y + offsetY.y
	local z1,z2 = Coords.z - offsetZ.z,Coords.z + offsetZ.z

	DrawLine(x1,Coords.y,Coords.z,x2,Coords.y,Coords.z,255,0,0,255)
	DrawLine(Coords.x,y1,Coords.z,Coords.x,y2,Coords.z,0,0,255,255)
	DrawLine(Coords.x,Coords.y,z1,Coords.x,Coords.y,z2,0,255,0,255)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETCOORDSFROMCAM
-----------------------------------------------------------------------------------------------------------------------------------------
function GetCoordsFromCam(Distance,Coords)
    local Rotation = GetGameplayCamRot()
    local pitch = math.rad(Rotation.x)
    local yaw = math.rad(Rotation.y)
    local roll = math.rad(Rotation.z)

    local direction = vec3(
        -math.sin(roll) * math.abs(math.cos(pitch)),
        math.cos(roll) * math.abs(math.cos(pitch)),
        math.sin(pitch)
    )

    return vec3(
        Coords.x + direction.x * Distance,
        Coords.y + direction.y * Distance,
        Coords.z + direction.z * Distance
    )
end