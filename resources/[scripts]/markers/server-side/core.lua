-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("markers",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Timers = {}
local Players = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Users()
    local Markers = {}

    for Source,v in pairs(Players) do
        local playerTimer = Timers[v.Passport]
        if playerTimer and not playerTimer.Stop and os.time() >= playerTimer.Timer then
            exports["markers"]:Exit(Source,v.Passport)
        else
            local Ped = GetPlayerPed(Source)
            if DoesEntityExist(Ped) then
                Markers[Source] = {
                    Coords = GetEntityCoords(Ped),
                    Permission = v.Permission,
                    Level = v.Level
                }
            end
        end
    end

    return Markers
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTER
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Enter",function(source,Permission,Level,Passport,Timed)
	if not Players[source] then
		Players[source] = {
			Passport = Passport,
			Permission = Permission,
			Level = vRP.NameHierarchy(Permission,Level)
		}

		if Timed then
			Timers[Passport] = {
				Permission = Permission,
				Timer = os.time() + Timed,
				Level = Level or 1,
				Stop = false
			}
		end

		local Service = vRP.NumPermission("Policia")
		for _,Sources in pairs(Service) do
			TriggerClientEvent("markers:Add",Sources,source,Players[source])
		end

		TriggerClientEvent("markers:Full",source,Players)
	else
		local timerData = Timers[Passport]
		if Timed and timerData then
			local currentTime = os.time()
			if currentTime > timerData.Timer then
				timerData.Timer = currentTime + Timed
			else
				timerData.Timer = timerData.Timer + Timed
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXIT
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Exit",function(source,Passport)
	if Players[source] then
		Players[source] = nil

		local Service = vRP.NumPermission("Policia")
		for _,Sources in pairs(Service) do
			TriggerClientEvent("markers:Remove",Sources,source)
		end
	end

	local timerData = Timers[Passport]
	if timerData then
		local currentTime = os.time()
		if timerData.Timer > currentTime then
			timerData.Stop = true
			timerData.Timer = timerData.Timer - currentTime
		else
			Timers[Passport] = nil
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	exports["markers"]:Exit(source,Passport)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	local timerData = Timers[Passport]
	if timerData then
		exports["markers"]:Enter(source,timerData["Permission"],timerData["Level"],Passport,timerData["Timer"])
	end
end)