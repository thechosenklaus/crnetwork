-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
tvRP = {}
Proxy.addInterface("vRP",tvRP)
Tunnel.bindInterface("vRP",tvRP)
vRPS = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local BlipAdmin = false
local Information = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Theme",function(Data,Callback)
	Callback(Theme)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESTPEDS
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.ClosestPeds(Radius)
	local Selected = {}
	local Ped = PlayerPedId()
	local Coords = GetEntityCoords(Ped)
	local GamePool = GetGamePool("CPed")
	local Radius = (Radius or 2.0) + 0.0001

	for _,Entitys in pairs(GamePool) do
		local Index = NetworkGetPlayerIndexFromPed(Entitys)
		if IsPedAPlayer(Entitys) and Index and Ped ~= Entitys and NetworkIsPlayerConnected(Index) and #(Coords - GetEntityCoords(Entitys)) <= Radius then
			Selected[#Selected + 1] = GetPlayerServerId(Index)
		end
	end

	return Selected
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESTPED
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.ClosestPed(Radius)
	local Selected = false
	local Ped = PlayerPedId()
	local Coords = GetEntityCoords(Ped)
	local GamePool = GetGamePool("CPed")
	local Radius = (Radius or 2.0) + 0.0001

	for _,Entitys in pairs(GamePool) do
		local Index = NetworkGetPlayerIndexFromPed(Entitys)
		if IsPedAPlayer(Entitys) and Index and Ped ~= Entitys and NetworkIsPlayerConnected(Index) then
			local OtherCoords = GetEntityCoords(Entitys)
			local OtherDistance = #(Coords - OtherCoords)
			if OtherDistance <= Radius then
				Selected = GetPlayerServerId(Index)
				Radius = OtherDistance
			end
		end
	end

	return Selected
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
function GetPlayers()
	local Voip = {}
	local Selected = {}
	local GamePool = GetGamePool("CPed")

	for _,Entitys in pairs(GamePool) do
		local Index = NetworkGetPlayerIndexFromPed(Entitys)

		if Index and IsPedAPlayer(Entitys) and NetworkIsPlayerConnected(Index) then
			Selected[Entitys] = GetPlayerServerId(Index)
			Voip[Entitys] = Index
		end
	end

	return Selected,Voip
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.Players()
	return GetPlayers()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLIPADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.BlipAdmin()
	BlipAdmin = not BlipAdmin
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYSOUND
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.PlaySound(Dict,Name)
	PlaySoundFrontend(-1,Dict,Name,false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSPORTENALBLE
-----------------------------------------------------------------------------------------------------------------------------------------
function PassportEnable()
	if not Information and not IsPauseMenuActive() then
		Information = true

		while Information do
			local Ped = PlayerPedId()
			local Players = GetPlayers()
			local Coords = GetEntityCoords(Ped)

			for Entitys,v in pairs(Players) do
				local OtherCoords = GetEntityCoords(Entitys)
				local Passport = Player(v)["state"]["Passport"]

				if Ped ~= Entitys and Passport and HasEntityClearLosToEntity(Ped,Entitys,17) and #(Coords - OtherCoords) <= 10.0 then
					DrawText3D(OtherCoords,"~w~[ "..Passport.." ]",1.375)
				end
			end

			Wait(0)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSPORTDISABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function PassportDisable()
	Information = false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REGISTERCOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+Information",PassportEnable)
RegisterCommand("-Information",PassportDisable)
RegisterKeyMapping("+Information","Visualizar passaporte.","keyboard","F7")
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local YTD = CreateRuntimeTxd("Textures")

	for _,Name in pairs(TexturePack) do
		local PNG = LoadResourceFile("vrp","config/textures/"..Name..".png")
		local DICT = "data:image/png;base64,"..Base64(PNG)
		local TEXTURE = CreateRuntimeTexture(YTD,Name,512,512)

		SetRuntimeTextureImage(TEXTURE,DICT)
	end

	while true do
		local TimeDistance = 999
		if LocalPlayer["state"]["Active"] then
			local Ped = PlayerPedId()
			local Players,Voip = GetPlayers()
			local Coords = GetEntityCoords(Ped)

			for Entitys,v in pairs(Players) do
				local PlayerState = Player(v)["state"]
				local Passport = PlayerState["Passport"]
				local OtherCoords = GetEntityCoords(Entitys)
				local Title = PlayerState["Title"]

				if Ped ~= Entitys and Title and HasEntityClearLosToEntity(Ped,Entitys,17) and #(Coords - OtherCoords) <= 10.0 then
					TimeDistance = 0

					DrawText3D(OtherCoords,"~w~[ "..Title.." ]",1.250)
				end

				if BlipAdmin and Ped ~= Entitys and Passport then
					TimeDistance = 0

					local Armour = GetPedArmour(Entitys)
					local Health = GetEntityHealth(Entitys) - 100
					local Talking = MumbleIsPlayerTalking(Voip[Entitys])

					DrawText3D(OtherCoords,"~w~[ "..(Talking and "~q~" or "")..(PlayerState["Name"] or "Carregando").."~w~ ] [ ~y~"..Passport.."~w~ ] [ ~g~"..(Health <= 0 and "Morto" or Health).."~w~ ] [ ~b~"..Armour.."~w~ ]",1.125)
				end
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAWTEXT3D
-----------------------------------------------------------------------------------------------------------------------------------------
function DrawText3D(Coords,Text,Height,Background)
	local onScreen,x,y = World3dToScreen2d(Coords["x"],Coords["y"],Coords["z"] + Height)

	if onScreen then
		SetTextFont(4)
		SetTextDropShadow()
		SetTextCentre(true)
		SetTextProportional(1)
		SetTextScale(0.35,0.35)
		SetTextColour(255,255,255,200)

		SetTextEntry("STRING")
		AddTextComponentString(Text)
		EndTextCommandDisplayText(x,y)

		if Background then
			local Length = string.len(Text)
			local Width = (Length / 160) * 0.0
			DrawRect(x,y + 0.0125,Width,0.03,15,15,15,175)
		end
	end
end