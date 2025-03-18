-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("races", Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Payments = {}
local Cooldowns = {}
local ActiveRaces = {}
local Participants = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINISH
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Finish(Mode, Route, Points)
    local source = source
    local Passport = vRP.Passport(source)
    local Identity = vRP.Identity(Passport)
    local VehicleName = vRPC.VehicleName(source)
    if not Passport then return end

    local RaceKey = Mode .. ":" .. Route
    Points = Points and Points > 1000 and math.floor(Points / 1000) or 0

    if ActiveRaces[RaceKey] and ActiveRaces[RaceKey][Passport] then
        ActiveRaces[RaceKey][Passport] = nil
        if next(ActiveRaces[RaceKey]) == nil then
            GlobalState[RaceKey] = nil
        end
    end

    if Payments[Passport] then
        Payments[Passport] = nil

        local RouteData = Races[Mode]["Routes"][Route]
        if not RouteData then return end

        local Query = vRP.Query("races/Result", { Race = Mode, Passport = Passport })
        local Action = Query[1] and "Records" or "Insert"

        if Points > 0 then
            vRP.Query("races/"..Action, {
                Race = Mode,
                Passport = Passport,
                Name = Identity["Name"] .. " " .. Identity["Lastname"],
                Vehicle = VehicleName,
                Points = parseInt(Points)
            })
        end

        vRP.GenerateItem(Passport, 'dollar', RouteData["Payment"], true)
        exports["markers"]:Exit(source)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- START
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Start(Mode, Route)
    local source = source
    local Passport = vRP.Passport(source)
    if vRP.TakeItem(Passport,"races",1)
    if not Passport then return false end

    local RaceKey = Mode .. ":" .. Route
    Cooldowns[RaceKey] = Cooldowns[RaceKey] or {}

    if Cooldowns[RaceKey][Passport] and os.time() < Cooldowns[RaceKey][Passport] then
        local Time = Cooldowns[RaceKey][Passport] - os.time()
        return false
    end

    Cooldowns[RaceKey][Passport] = os.time() + 60
    Payments[Passport] = true
    GlobalState[RaceKey] = true
    ActiveRaces[RaceKey] = ActiveRaces[RaceKey] or {}
    ActiveRaces[RaceKey][Passport] = true

    TriggerClientEvent("races:Start", source, Mode, Route)
    local RaceData = Races[Mode]
    local RouteData = RaceData["Routes"][Route]
        return RouteData["Time"] or 60
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RANKING
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Ranking(Mode, Route)
    local Query = vRP.Query("races/Ranking", { Race = Mode })
    local Ranking = {}

    for k, v in ipairs(Query) do
        Ranking[#Ranking + 1] = {
            Name = v['Name'],
            Vehicle = v['Vehicle'],
            Time = v['Points'],
			Passport = v['Passport']
        }
    end

    return Ranking
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.GlobalState(Mode, Route)
	local source = source
	local RaceName = Mode .. ":" .. Route
    if Races[Mode] and Races[Mode]["Global"] and not GlobalState[RaceName] then
        GlobalState[RaceName] = true
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCEL
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Cancel()
    local source = source
    local Passport = vRP.Passport(source)
    if not Passport then return end

    for RaceKey, Participants in pairs(ActiveRaces) do
        if Participants[Passport] then
            Participants[Passport] = nil
            if next(Participants) == nil then
                GlobalState[RaceKey] = nil
            end
        end
    end

    Payments[Passport] = nil
    exports["markers"]:Exit(source)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect", function(Passport, source)
    Creative.Cancel(source)
end)