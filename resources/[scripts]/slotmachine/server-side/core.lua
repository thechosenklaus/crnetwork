-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("slotmachine",Creative)
vCLIENT = Tunnel.getInterface("slotmachine")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
local Players = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- MACHINES
-----------------------------------------------------------------------------------------------------------------------------------------
local Machines = {
	["1"] = {
		["Winner"] = {},
		["Value"] = 250,
		["Using"] = false,
		["Coords"] = vec3(984.25,64.95,122.12),
		["Prop"] = "vw_prop_casino_slot_04a_reels"
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- Images
-----------------------------------------------------------------------------------------------------------------------------------------
local Images = { "2","3","6","2","4","1","6","5","2","1","3","6","7","1","4","5" }
-----------------------------------------------------------------------------------------------------------------------------------------
-- Multiplier
-----------------------------------------------------------------------------------------------------------------------------------------
local Multiplier = {
	["1"] = 2,
	["2"] = 4,
	["3"] = 6,
	["4"] = 8,
	["5"] = 10,
	["6"] = 12,
	["7"] = 14
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECK
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Check(Table)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Machines[Table] then
		if not Machines[Table]["Using"] then
			Machines[Table]["Using"] = true
			Players[Passport] = Table
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEAN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Clean(Table)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Machines[Table] then
		if Machines[Table]["Using"] then
			Machines[Table]["Winner"] = {}
			Machines[Table]["Using"] = false
		end

		if Players[Passport] then
			Players[Passport] = nil
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if Players[Passport] then
		local Table = Players[Passport]
		if Machines[Table] then
			if Machines[Table]["Using"] then
				Machines[Table]["Winner"] = {}
				Machines[Table]["Using"] = false
			end
		end

		Players[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Payment(Table)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Machines[Table] then
		if vRP.PaymentBank(Passport,Machines[Table]["Value"]) then
			return true
		else
			TriggerClientEvent("Notify",source,"vermelho","<b>Dólares</b> insuficientes.",5000)
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTSLOTS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.StartSlots(Table)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Machines[Table] then
		local Result = {
			["a"] = math.random(16),
			["b"] = math.random(16),
			["c"] = math.random(16)
		}

		Machines[Table]["Winner"] = Result
		vCLIENT.MachineSlots(source,Result)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WINNER
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Winner(Table,Result)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and Machines[Table] then
		Active[Passport] = true

		if Machines[Table]["Winner"] then
			if Machines[Table]["Winner"]["a"] == Result["a"] and Machines[Table]["Winner"]["b"] == Result["b"] and Machines[Table]["Winner"]["c"] == Result["c"] then
				local Total = 0
				local Spin01 = Images[Result["a"]]
				local Spin02 = Images[Result["b"]]
				local Spin03 = Images[Result["c"]]

				if Spin01 == Spin02 and Spin01 == Spin03 then
					if Multiplier[Spin01] then
						Total = Machines[Table]["Value"] * Multiplier[Spin01]
					end
				elseif Spin01 == Spin02 or Spin02 == Spin03 or Spin01 == Spin03 then
					Total = Machines[Table]["Value"] * 2
				end

				if Total > 0 then
					vRP.GiveBank(Passport,Total)
				end
			end

			Machines[Table]["Winner"] = {}
		end

		Active[Passport] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	vCLIENT.UpdateMachines(source,Machines)
end)