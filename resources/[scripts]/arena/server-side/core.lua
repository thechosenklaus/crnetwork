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
Tunnel.bindInterface("arena",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
for _,v in pairs(Zones) do
	GlobalState["Arena:"..v["Route"]] = 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKENTER
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.CheckEnter(Table)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and vRP.SaveTemporary(Passport,source,Table) then
		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKEXIT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.CheckExit()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and vRP.ApplyTemporary(Passport,source) then
		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARENA:DEATH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("arena:Death")
AddEventHandler("arena:Death",function(OtherSource,Route)
	local source = source
	local Passport = vRP.Passport(source)
	local OtherPassport = vRP.Passport(OtherSource)

	if not (Passport and OtherPassport) or Passport == OtherPassport then
		return false
	end

	if not (vRP.DoesEntityExist(source) and vRP.DoesEntityExist(OtherSource)) then
		return false
	end

	vRP.Query("arena/Death",{ Passport = Passport })
	vRP.Query("arena/Killed",{ Passport = OtherPassport })

	local Identity = vRP.Identity(Passport)
	local OtherIdentity = vRP.Identity(OtherPassport)
	if not (Identity and OtherIdentity) then
		return false
	end

	for _,Sources in pairs(vRP.Players()) do
		async(function()
			if Player(Sources).state.Arena then
				TriggerClientEvent("Notify",Sources,false,string.format("%s <b>matou</b> %s",OtherIdentity.Name,Identity.Name),"verde",5000,nil,nil,Route)
			end
		end)
	end
end)