-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("perimeter")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Blip = {}
local Notify = false
local Perimeter = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETER:DYNAMIC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("perimeter:Dynamic")
AddEventHandler("perimeter:Dynamic",function()
	exports["dynamic"]:AddMenu("Perimetros","Visualizar/Gerenciar perimetros.","perimeter")
	exports["dynamic"]:AddButton("Adicionar","Demarcar novo local no mapa.","perimeter:New","","perimeter",true)

	local Perimeters = vSERVER.Perimeters()
	for Selected,v in pairs(Perimeters) do
		exports["dynamic"]:AddButton(v.Name,"Remover local demarcado no mapa.","perimeter:Remove",Selected,"perimeter",true)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETER:REMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("perimeter:Remove")
AddEventHandler("perimeter:Remove",function(Selected)
	if Blip[Selected] then
		if DoesBlipExist(Blip[Selected]) then
			RemoveBlip(Blip[Selected])
		end

		Blip[Selected] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETER:ADD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("perimeter:Add")
AddEventHandler("perimeter:Add",function(Selected,Table)
	Perimeter[Selected] = Table

	if not Blip[Selected] then
		Blip[Selected] = AddBlipForRadius(Table.Coords,Table.Distance + 0.0)
		SetBlipAlpha(Blip[Selected],200)
		SetBlipColour(Blip[Selected],1)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETER:LIST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("perimeter:List")
AddEventHandler("perimeter:List",function(Table)
	Perimeter = Table

	for Selected,v in pairs(Perimeter) do
		local Coord = v.Coords
		Blip[Selected] = AddBlipForRadius(Coord.x,Coord.y,Coord.z,v.Distance + 0.0)
		SetBlipAlpha(Blip[Selected],200)
		SetBlipColour(Blip[Selected],1)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)
		for Selected,v in pairs(Blip) do
			if Perimeter[Selected] then
				if #(Coords - GetBlipCoords(v)) <= Perimeter[Selected].Distance and not Notify then
					Notify = Selected
					TriggerEvent("Notify","Atenção","Você entrou em uma área onde a circulação está restrita, pedimos que se dirija a um local autorizado ou siga as orientações para garantir sua segurança e a de todos, agradecemos pela compreensão.","amarelo",10000)
				elseif Notify == Selected and #(Coords - GetBlipCoords(v)) > Perimeter[Selected].Distance then
					TriggerEvent("Notify","Aviso","Você saiu de uma área onde a circulação estava restrita, agradecemos por seguir as orientações e garantir a segurança de todos, se precisar de mais informações estamos à disposição.","amarelo",10000)
					Notify = false
				end
			end
		end

		Wait(1000)
	end
end)