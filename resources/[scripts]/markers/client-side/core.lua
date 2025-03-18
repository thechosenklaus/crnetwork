-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("markers")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Markers = {}
local Players = {}
local Pause = false
local Active = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- INFORMATION
-----------------------------------------------------------------------------------------------------------------------------------------
local Information = {
	LSPD = {
		["Chefe"] = 3,
		["Capitão"] = 18,
		["Tenente"] = 6,
		["Sargento"] = 32,
		["Oficial"] = 42,
		["Cadete"] = 53
	},
	BCSO = {
		["Chefe"] = 3,
		["Capitão"] = 18,
		["Tenente"] = 6,
		["Sargento"] = 32,
		["Oficial"] = 42,
		["Cadete"] = 53
	},
	BCPR = {
		["Chefe"] = 3,
		["Capitão"] = 18,
		["Tenente"] = 6,
		["Sargento"] = 32,
		["Oficial"] = 42,
		["Cadete"] = 53
	},
	Paramedico = {
		["Chefe"] = 1,
		["Médico"] = 6,
		["Enfermeiro"] = 59,
		["Residente"] = 76
	},
	Corredor = {
		["Corredor"] = 8
	},
	Traficante = {
		["Traficante"] = 5
	},
	Boosting = {
		["Boosting"] = 47
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADMARKERS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	for Index,_ in pairs(Information) do
		AddStateBagChangeHandler(Index,("player:%s"):format(LocalPlayer["state"]["Source"]),function(Name,Key,Value)
			Active = Key

			if not Value then
				Active = false
				CleanMarkers()
			end
		end)
	end

	while true do
		local TimeDistance = 999
		if LocalPlayer["state"]["Active"] and Active and Information[Active] then
			if IsPauseMenuActive() then
				if not Pause then
					CleanMarkers()
					Pause = true
				end

				local Users = vSERVER.Users()
				for Index,v in pairs(Users) do
					if Information[v.Permission] and Information[v.Permission][v.Level] and ((LocalPlayer["state"]["Paramedico"] and v.Permission == "Paramedico") or (CheckPolice() and v.Permission ~= "Paramedico")) then
						if Markers[Index] then
							async(function()
								MoveBlipSmooth(Markers[Index],v.Coords)
							end)
						else
							Markers[Index] = AddBlipForCoord(v.Coords)
							SetBlipSprite(Markers[Index],1)
							SetBlipDisplay(Markers[Index],4)
							SetBlipAsShortRange(Markers[Index],false)
							SetBlipColour(Markers[Index],Information[v.Permission][v.Level])
							SetBlipScale(Markers[Index],0.7)
							BeginTextCommandSetBlipName("STRING")
							AddTextComponentString("! "..v.Permission.." : "..v.Level)
							EndTextCommandSetBlipName(Markers[Index])
						end
					end
				end
			else
				if Pause then
					CleanMarkers()
					Pause = false
				end

				local Ped = PlayerPedId()
				if IsPedInAnyVehicle(Ped) then
					TimeDistance = 100

					local List = GetPlayers()
					for Index,v in pairs(Players) do
						if List[Index] then
							if not Markers[Index] and Information[v.Permission] and Information[v.Permission][v.Level] and ((LocalPlayer["state"]["Paramedico"] and v.Permission == "Paramedico") or (CheckPolice() and v.Permission ~= "Paramedico")) then
								local Source = GetPlayerFromServerId(Index)
								local Ped = GetPlayerPed(Source)

								Markers[Index] = AddBlipForEntity(Ped)
								SetBlipSprite(Markers[Index],1)
								SetBlipDisplay(Markers[Index],4)
								SetBlipAsShortRange(Markers[Index],false)
								SetBlipColour(Markers[Index],Information[v.Permission][v.Level])
								SetBlipScale(Markers[Index],0.7)
								BeginTextCommandSetBlipName("STRING")
								AddTextComponentString("! "..v.Permission.." : "..v.Level)
								EndTextCommandSetBlipName(Markers[Index])
							end
						else
							if Markers[Index] then
								if DoesBlipExist(Markers[Index]) then
									RemoveBlip(Markers[Index])
								end

								Markers[Index] = nil
							end
						end
					end
				end
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
function GetPlayers()
	local Selected = {}
	local GamePool = GetGamePool("CPed")

	for _,Entity in ipairs(GamePool) do
		if IsPedAPlayer(Entity) then
			local Index = NetworkGetPlayerIndexFromPed(Entity)
			if Index and NetworkIsPlayerConnected(Index) then
				Selected[GetPlayerServerId(Index)] = Entity
			end
		end
	end

	return Selected
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEANMARKERS
-----------------------------------------------------------------------------------------------------------------------------------------
function CleanMarkers()
	for _,v in pairs(Markers) do
		if DoesBlipExist(v) then
			RemoveBlip(v)
		end
	end

	Markers = {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOVEBLIPSMOOTH
-----------------------------------------------------------------------------------------------------------------------------------------
function MoveBlipSmooth(Blip,Coords)
	if not DoesBlipExist(Blip) then
		return false
	end

	local Timer = 0.0
	local Init = GetBlipCoords(Blip)
	local LastUpdate = GetGameTimer()

	while Timer < 1.0 do
		local CurrentTime = GetGameTimer()
		if CurrentTime - LastUpdate > 10 then
			LastUpdate = CurrentTime
			Timer = Timer + 0.01

			SetBlipCoords(Blip,Init + (Coords - Init) * Timer)
		end

		Wait(1)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKERS:ADD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("markers:Add")
AddEventHandler("markers:Add",function(Source,Table)
	Players[Source] = Table
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKERS:FULL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("markers:Full")
AddEventHandler("markers:Full",function(Table)
	Players = Table
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKERS:REMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("markers:Remove")
AddEventHandler("markers:Remove",function(Source)
	if Players[Source] then
		if Markers[Source] then
			if DoesBlipExist(Markers[Source]) then
				RemoveBlip(Markers[Source])
			end

			Markers[Source] = nil
		end

		Players[Source] = nil
	end
end)