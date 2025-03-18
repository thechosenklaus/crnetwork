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
Tunnel.bindInterface("lscustoms",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Networked = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Permission(Index)
	local source = source
	local Passport = vRP.Passport(source)

	return Passport and Locations[Index] and (not Locations[Index]["Permission"] or (Locations[Index]["Permission"] and vRP.HasService(Passport,Locations[Index]["Permission"]))) and true or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Save(Model,Plate,Initial)
	local Return = false
	local source = source
	local Passport = vRP.Passport(source)
	local Price = Calculate(Initial,Model)
	if Passport and (Price <= 0 or vRP.PaymentFull(Passport,Price,true)) then
		local OtherPassport = vRP.PassportPlate(Plate)
		if OtherPassport then
			local Consult = vRP.GetSrvData("LsCustoms:"..OtherPassport..":"..Model,true)
			for Index,v in pairs(Initial) do
				if Index == "VehicleExtras" then
					for Type,Results in pairs(Initial[Index]) do
						if Results["Installed"] ~= Results["Selected"] then
							if not Consult[Index] then
								Consult[Index] = {}
							end

							Consult[Index][Type] = Results["Selected"]
						end
					end
				elseif Index == "Respray" then
					Consult[Index] = {
						["PrimaryColour"] = {
							["Type"] = Initial[Index]["PrimaryColour"]["Selected"]["Type"],
							["Color"] = Initial[Index]["PrimaryColour"]["Selected"]["Color"]
						},
						["SecondaryColour"] = {
							["Type"] = Initial[Index]["SecondaryColour"]["Selected"]["Type"],
							["Color"] = Initial[Index]["SecondaryColour"]["Selected"]["Color"]
						},
						["PearlescentColour"] = Initial[Index]["PearlescentColour"]["Selected"],
						["WheelColour"] = Initial[Index]["WheelColour"]["Selected"],
						["DashboardColour"] = Initial[Index]["DashboardColour"]["Selected"],
						["InteriorColour"] = Initial[Index]["InteriorColour"]["Selected"]
					}
				elseif Index == "Wheels" then
					for Type,Results in pairs(Initial[Index]) do
						if Results["Installed"] ~= Results["Selected"] then
							if Consult[Index] then
								if Type == "TyreSmoke" then
									Consult[Index]["TyreSmoke"] = Initial[Index]["TyreSmoke"]["Selected"]
								elseif Type == "CustomTyres" then
									Consult[Index]["CustomTyres"] = Initial[Index]["CustomTyres"]["Selected"]
								else
									Consult[Index]["Category"] = Type
									Consult[Index]["Value"] = Results["Selected"]
								end
							else
								if Type == "TyreSmoke" then
									Consult[Index] = {
										["TyreSmoke"] = Initial[Index]["TyreSmoke"]["Selected"]
									}
								elseif Type == "CustomTyres" then
									Consult[Index] = {
										["CustomTyres"] = Initial[Index]["CustomTyres"]["Selected"]
									}
								else
									Consult[Index] = {
										["Category"] = Type,
										["Value"] = Results["Selected"]
									}
								end
							end
						end
					end
				elseif v["Installed"] ~= v["Selected"] then
					Consult[Index] = v["Selected"]
				end
			end

			vRP.SetSrvData("LsCustoms:"..OtherPassport..":"..Model,Consult,true)
		end

		Return = true
	end

	return Return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LSCUSTOMS:NETWORK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("lscustoms:Network")
AddEventHandler("lscustoms:Network",function(Network,Plate)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if not Network then
			if Networked[Passport] then
				Networked[Passport] = nil
			end
		else
			Networked[Passport] = { Network,Plate }
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	if Networked[Passport] then
		SetTimeout(2500,function()
			TriggerEvent("garages:Deleted",Networked[Passport][1],Networked[Passport][2])
			Networked[Passport] = nil
		end)
	end
end)