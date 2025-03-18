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
Tunnel.bindInterface("christmas",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Cooldown = os.time()
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
GlobalState["Christmas"] = false
GlobalState["ChristmasBox"] = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTCHRISTMAS
-----------------------------------------------------------------------------------------------------------------------------------------
function StartChristmas(Passport)
  local Selected = math.random(#Components)
  for Number,v in pairs(Components) do
    GlobalState["ChristmasBox"] = GlobalState["ChristmasBox"] + 1

    local Multiplier = math.random(#Multiplier)
    vRP.MountContainer(Passport,"Christmas:"..Number,Loots,Multiplier)
  end

  TriggerClientEvent("Notify",-1,EventName,MessageStart,"amarelo",30000)
  GlobalState["Christmas"] = Selected
  Cooldown = os.time() + 3600
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
    local source = source
    local Passport = vRP.Passport(source)
    if Timers[os.date("%H:%M")] and os.time() >= Cooldown then
      StartChristmas(Passport)
    end

    Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHRISTMAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("christmas",function(source,Message)
  local Passport = vRP.Passport(source)
  if Passport and vRP.HasGroup(Passport,"Admin") then
    if not GlobalState["Christmas"] then
      StartChristmas(Passport)
    else
      GlobalState["Christmas"] = false
      GlobalState["ChristmasBox"] = 0
      TriggerClientEvent("Notify",-1,EventName,MessageFinish,"amarelo",30000)
    end
  end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("ChristmasBox",nil,function(Name,Key,Value)
	if Value <= 0 then
		GlobalState["Christmas"] = false
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BOX
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Box",function()
	if GlobalState["Christmas"] then
		GlobalState["ChristmasBox"] = GlobalState["ChristmasBox"] - 1

		if GlobalState["ChristmasBox"] <= 0 then
			GlobalState["Christmas"] = false
			GlobalState["ChristmasBox"] = 0
		end
	end
end)