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
Tunnel.bindInterface("garages",Creative)
vCLIENT = Tunnel.getInterface("garages")
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local Spawn = {}
local Active = {}
local Signal = {}
local Changed = {}
local Searched = {}
local Respawns = {}
local Propertys = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTITYREMOVED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("entityRemoved",function(Network)
	if DoesEntityExist(Network) and not IsPedAPlayer(Network) and GetEntityType(Network) == 2 then
		local Plate = GetVehicleNumberPlateText(Network)
		if Spawn[Plate] then
			local Coords = GetEntityCoords(Network)
			local Healths = GetEntityHealth(Network)
			local Heading = GetEntityHeading(Network)
			local Body = GetVehicleBodyHealth(Network)
			local Engine = GetVehicleEngineHealth(Network)

			local Windows = {}
			for Number = 0,5 do
				Windows[Number] = IsVehicleWindowIntact(Network,Number)
			end

			Respawns[Plate] = vec4(Coords["x"],Coords["y"],Coords["z"],Heading)
			TriggerClientEvent("garages:Respawn",-1,"Add",Plate,Respawns[Plate])
			vRP.Query("vehicles/updateVehiclesRespawns",{ Passport = Spawn[Plate][1], Vehicle = Spawn[Plate][2], Nitro = Entity(Network)["state"]["Nitro"] or 0, Engine = parseInt(Engine), Body = parseInt(Body), Health = parseInt(Healths), Fuel = Entity(Network)["state"]["Fuel"] or 0, Windows = json.encode(Windows) })
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVERVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.ServerVehicle(Model,Coords,Plate,Nitrox,Doors,Body,Fuel,Seatbelt,Drift)
	local Vehicle = CreateVehicle(Model,Coords,true,true)

	while not DoesEntityExist(Vehicle) do
		Wait(1)
	end

	if DoesEntityExist(Vehicle) then
		if not Plate then
			Plate = vRP.GeneratePlate()
		end

		SetVehicleBodyHealth(Vehicle,Body + 0.0)
		SetVehicleNumberPlateText(Vehicle,Plate)
		SetEntityIgnoreRequestControlFilter(Vehicle,true)

		if Doors then
			local Doors = json.decode(Doors)
			if Doors ~= nil then
				for Number,Status in pairs(Doors) do
					if Status then
						SetVehicleDoorBroken(Vehicle,parseInt(Number),true)
					end
				end
			end
		end

		Entity(Vehicle)["state"]:set("Fuel",Fuel or 100,true)
		Entity(Vehicle)["state"]:set("Nitro",Nitrox or 0,true)
		Entity(Vehicle)["state"]:set("Drift",Drift or false,true)
		Entity(Vehicle)["state"]:set("Seatbelt",Seatbelt or false,true)

		return true,NetworkGetNetworkIdFromEntity(Vehicle),Vehicle,Plate
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:RESPAWNS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Respawns")
AddEventHandler("garages:Respawns",function(Plate)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Respawns[Plate] and Spawn[Plate] and Spawn[Plate][1] == Passport then
		local Vehicle = vRP.SelectVehicle(Spawn[Plate][1],Spawn[Plate][2])
		if Vehicle then
			local Mods = vRP.GetSrvData("LsCustoms:"..Spawn[Plate][1]..":"..Spawn[Plate][2])
			local Exist,Network,Vehicles = Creative.ServerVehicle(Spawn[Plate][2],Respawns[Plate],Plate,Vehicle["Nitro"],Vehicle["Doors"],Vehicle["Body"],Vehicle["Fuel"],Vehicle["Seatbelt"],Vehicle["Drift"])
			if Exist then
				local Players = vRPC.Players(source)
				for _,Sources in pairs(Players) do
					async(function()
						vCLIENT.CreateVehicle(Sources,Spawn[Plate][2],Network,Vehicle["Engine"],Vehicle["Health"],Mods,Vehicle["Windows"],Vehicle["Tyres"])
					end)
				end

				Entity(Vehicles)["state"]:set("Lockpick",Spawn[Plate][1],true)
				Spawn[Plate] = { Spawn[Plate][1],Spawn[Plate][2],Vehicles }
				TaskWarpPedIntoVehicle(GetPlayerPed(source),Vehicles,-1)
				TriggerClientEvent("garages:Respawn",-1,"Remove",Plate)
				Respawns[Plate] = nil
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:CHANGEPLATE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("garages:ChangePlate",function(Plate,NewPlate)
	Changed[NewPlate] = Plate
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SIGNALREMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("SignalRemove",function(Plate)
	if not Signal[Plate] then
		Signal[Plate] = true
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Vehicles(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Garages[Number] then
		local Vehicle = {}
		local Selected = Garages[Number]["Name"]
		if Garages[Number]["Permission"] and not vRP.HasService(Passport,Garages[Number]["Permission"]) then
			return false
		end

		if Works[Selected] then
			for _,v in pairs(Works[Selected]) do
				if VehicleExist(v) then
					local Consult = vRP.SelectVehicle(Passport,v)
					if Consult then
						local Tax = false
						local Rental = false

						if Consult["Tax"] > os.time() then
							Tax = CompleteTimers(Consult["Tax"] - os.time())
						end

						if Consult["Rental"] ~= 0 then
							if Consult["Rental"] > os.time() then
								Rental = CompleteTimers(Consult["Rental"] - os.time())
							else
								Rental = "Vencido"
							end
						end

						Vehicle[#Vehicle + 1] = {
							["Model"] = v,
							["Name"] = VehicleName(v),
							["Tax"] = VehiclePrice(v) * PercentageTaxs,
							["Mode"] = VehicleMode(v),
							["Weight"] = Consult["Weight"],
							["Engine"] = Consult["Engine"] / 10,
							["Body"] = Consult["Body"] / 10,
							["Fuel"] = Consult["Fuel"],
							["TaxTime"] = Tax,
							["RentalTime"] = Rental
						}
					else
						Vehicle[#Vehicle + 1] = {
							["Model"] = v,
							["Name"] = VehicleName(v),
							["Tax"] = VehiclePrice(v) * PercentageTaxs,
							["Mode"] = VehicleMode(v),
							["Weight"] = VehicleWeight(v),
							["Engine"] = 100,
							["Body"] = 100,
							["Fuel"] = 100,
							["TaxTime"] = "30 Dias e 29 Horas",
							["RentalTime"] = false
						}
					end
				end
			end
		else
			if string.sub(Number,1,9) == "Propertys" then
				local Consult = vRP.Query("propertys/Exist",{ Name = Number })
				if Consult[1] and (vRP.InventoryFull(Passport,"propertys-"..Consult[1]["Serial"]) or Consult[1]["Passport"] == Passport) then
					if os.time() > Consult[1]["Tax"] then
						return false
					end
				else
					return false
				end
			end

			local Consult = vRP.Query("vehicles/UserVehicles",{ Passport = Passport })
			for _,v in pairs(Consult) do
				if VehicleExist(v["Vehicle"]) and not v["Work"] then
					local Tax = false
					local Rental = false

					if v["Tax"] > os.time() then
						Tax = CompleteTimers(v["Tax"] - os.time())
					end

					if v["Rental"] > os.time() then
						Rental = CompleteTimers(v["Rental"] - os.time())
					end

					if v["Rental"] ~= 0 then
						if v["Rental"] > os.time() then
							Rental = CompleteTimers(v["Rental"] - os.time())
						else
							Rental = "Vencido"
						end
					end

					Vehicle[#Vehicle + 1] = {
						["Model"] = v["Vehicle"],
						["Name"] = VehicleName(v["Vehicle"]),
						["Tax"] = VehiclePrice(v["Vehicle"]) * PercentageTaxs,
						["Mode"] = VehicleMode(v["Vehicle"]),
						["Weight"] = v["Weight"],
						["Engine"] = v["Engine"] / 10,
						["Body"] = v["Body"] / 10,
						["Fuel"] = v["Fuel"],
						["TaxTime"] = Tax,
						["RentalTime"] = Rental
					}
				end
			end
		end

		return Vehicle
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:SELL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Sell")
AddEventHandler("garages:Sell",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		local Mode = VehicleMode(Name)
		if Mode ~= "Work" and Mode ~= "Rental" and VehicleClass(Name) ~= "Exclusivos" then
			Active[Passport] = true
			TriggerClientEvent("garages:Close",source)

			local Price = VehiclePrice(Name) * PercetageSelling
			if vRP.Request(source,"Garagem","Vender o veículo <b>"..VehicleName(Name).."</b> por <b>$"..Dotted(Price).."</b>?") then
				local Consult = vRP.SelectVehicle(Passport,Name)
				if Consult and not Consult["Block"] then
					vRP.GiveBank(Passport,Price)
					vRP.RemSrvData("LsCustoms:"..Passport..":"..Name)
					vRP.RemSrvData("Trunkchest:"..Passport..":"..Name)
					vRP.Query("vehicles/removeVehicles",{ Passport = Passport, Vehicle = Name })
				end
			end

			Active[Passport] = nil
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:TRANSFER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Transfer")
AddEventHandler("garages:Transfer",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Consult = vRP.SelectVehicle(Passport,Name)
		if Consult and not Consult["Block"] then
			TriggerClientEvent("garages:Close",source)

			local Keyboard = vKEYBOARD.Primary(source,"Passaporte")
			if Keyboard then
				local OtherPassport = parseInt(Keyboard[1])
				if vRP.Request(source,"Garagem","Transferir o veículo <b>"..VehicleName(Name).."</b> para <b>"..vRP.FullName(OtherPassport).."</b>?") then
					if vRP.SelectVehicle(OtherPassport,Name) then
						TriggerClientEvent("Notify",source,"Atenção","<b>"..vRP.FullName(OtherPassport).."</b> já possui este modelo de veículo.","amarelo",5000)
					else
						vRP.Query("vehicles/moveVehicles",{ Passport = Passport, OtherPassport = OtherPassport, Vehicle = Name })

						local Datatable = vRP.GetSrvData("LsCustoms:"..Passport..":"..Name,true)
						vRP.SetSrvData("LsCustoms:"..OtherPassport..":"..Name,Datatable,true)
						vRP.RemSrvData("LsCustoms:"..Passport..":"..Name)

						local Datatable = vRP.GetSrvData("Trunkchest:"..Passport..":"..Name,true)
						vRP.SetSrvData("Trunkchest:"..OtherPassport..":"..Name,Datatable,true)
						vRP.RemSrvData("Trunkchest:"..Passport..":"..Name)

						TriggerClientEvent("Notify",source,"Sucesso","Transferência concluída.","verde",5000)
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:TAX
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Tax")
AddEventHandler("garages:Tax",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Vehicle = vRP.SelectVehicle(Passport,Name)
		if Vehicle and Vehicle["Tax"] <= os.time() then
			TriggerClientEvent("garages:Close",source)

			local Price = VehiclePrice(Name) * PercentageTaxs
			if vRP.Request(source,"Garagem","Pagar a <b>Taxa</b> do veículo <b>"..VehicleName(Name).."</b> por <b>$"..Dotted(Price).."</b>?") then
				if vRP.PaymentFull(Passport,Price) then
					vRP.Query("vehicles/updateVehiclesTax",{ Passport = Passport, Vehicle = Name })
					TriggerClientEvent("Notify",source,"Sucesso","Pagamento concluído.","verde",5000)
				else
					TriggerClientEvent("Notify",source,"Aviso","Dinheiro insuficiente.","amarelo",5000)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:SPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Spawn")
AddEventHandler("garages:Spawn",function(Name,Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] and VehicleExist(Name) then
		Active[Passport] = true

		local Coin = "Diamantes"
		local Price = VehiclePrice(Name)
		local Gemstone = VehicleGemstone(Name)
		local Vehicle = vRP.SelectVehicle(Passport,Name)
		if not Vehicle then
			if Gemstone > 0 then
				TriggerClientEvent("garages:Close",source)

				if vRP.Request(source,"Garagem","Pagar o aluguel do veículo <b>"..VehicleName(Name).."</b> por <b>"..Gemstone.."</b> "..Coin.."?") then
					if vRP.PaymentGems(Passport,Gemstone) then
						vRP.Query("vehicles/rentalVehicles",{ Passport = Passport, Vehicle = Name, Plate = vRP.GeneratePlate(), Days = 30, Weight = VehicleWeight(Name), Work = 1 })
						TriggerClientEvent("Notify",source,"Sucesso","Aluguel do veículo <b>"..VehicleName(Name).."</b> concluído.","verde",5000)
						Vehicle = vRP.SelectVehicle(Passport,Name)
					else
						TriggerClientEvent("Notify",source,"Aviso",Coin.." insuficiente.","amarelo",5000)
						Active[Passport] = nil

						return false
					end
				else
					Active[Passport] = nil

					return false
				end
			else
				if Price > 0 then
					TriggerClientEvent("garages:Close",source)

					if vRP.Request(source,"Garagem","Comprar o veículo <b>"..VehicleName(Name).."</b> por <b>"..Currency..Dotted(Price).."</b>?") then
						if vRP.PaymentFull(Passport,Price) then
							vRP.Query("vehicles/addVehicles",{ Passport = Passport, Vehicle = Name, Plate = vRP.GeneratePlate(), Weight = VehicleWeight(Name), Work = 1 })
							exports["bank"]:AddTaxs(Passport,source,"Concessionária",Price,"Compra do veículo "..VehicleName(Name)..".")
							Vehicle = vRP.SelectVehicle(Passport,Name)
						else
							TriggerClientEvent("Notify",source,"Aviso","Dinheiro insuficiente.","amarelo",5000)
						end
					else
						Active[Passport] = nil

						return false
					end
				else
					vRP.Query("vehicles/addVehicles",{ Passport = Passport, Vehicle = Name, Plate = vRP.GeneratePlate(), Weight = VehicleWeight(Name), Work = 1 })
					Vehicle = vRP.SelectVehicle(Passport,Name)
				end
			end
		end

		if Vehicle then
			local Save = Vehicle["Save"]
			if Number ~= Save then
				if Garages[Save] and Garages[Number] and Garages[Number]["Save"] then
					TriggerClientEvent("Notify",source,"Aviso","O veículo não se encontra neste local, mas não se preoculpe, o mesmo está marcado em seu mapa durante os próximos 30 segundos.","amarelo",5000)
					TriggerClientEvent("garages:Close",source)
					vCLIENT.SearchBlip(source,Save)

					if vRP.Request(source,"Garagem","Resgatar o veículo tem o custo de <b>"..Currency..Dotted(Price * PercentageRescue).."</b>, deseja prosseguir com o resgate do mesmo para essa garagem?") then
						if vRP.PaymentFull(Passport,Price * PercentageRescue) then
							vRP.Query("vehicles/UpdateSave",{ Passport = Passport, Vehicle = Name, Save = Number })
							TriggerClientEvent("Notify",source,"Sucesso","Resgate concluído.","verde",5000)
						else
							TriggerClientEvent("Notify",source,"Aviso","Dinheiro insuficiente.","amarelo",5000)
							Active[Passport] = nil

							return false
						end
					else
						Active[Passport] = nil

						return false
					end
				else
					vRP.Query("vehicles/UpdateSave",{ Passport = Passport, Vehicle = Name, Save = Number })
				end
			end

			if Vehicle["Arrest"] then
				TriggerClientEvent("garages:Close",source)

				if vRP.Request(source,"Garagem","Liberar o veículo tem o custo de <b>$"..Currency..Dotted(Price * PercentageArrest).."</b>, deseja prosseguir com a liberação do mesmo?") then
					if vRP.PaymentFull(Passport,Price * PercentageArrest) then
						vRP.Query("vehicles/PaymentArrest",{ Passport = Passport, Vehicle = Name })
						TriggerClientEvent("Notify",source,"Sucesso","Veículo liberado.","policia",5000)
						exports["bank"]:AddTaxs(Passport,source,"Garagem",Price * PercentageImpost,"Liberação do veículo.")
					else
						TriggerClientEvent("Notify",source,"Aviso","Dinheiro insuficiente.","amarelo",5000)
						Active[Passport] = nil

						return false
					end
				else
					Active[Passport] = nil

					return false
				end
			end

			local Plate = Vehicle["Plate"]
			if Spawn[Plate] then
				if not Signal[Plate] then
					if not Searched[Passport] then
						Searched[Passport] = os.time()
					end

					if os.time() >= parseInt(Searched[Passport]) then
						Searched[Passport] = os.time() + 60

						if not Respawns[Plate] then
							if DoesEntityExist(Spawn[Plate][3]) and not IsPedAPlayer(Spawn[Plate][3]) and GetEntityType(Spawn[Plate][3]) == 2 then
								vCLIENT.SearchBlip(source,GetEntityCoords(Spawn[Plate][3]))
								TriggerClientEvent("Notify",source,"Atenção","Rastreador do veículo foi ativado por <b>30</b> segundos, lembrando que se o mesmo estiver em movimento a localização pode ser imprecisa.","policia",10000)
							else
								if Spawn[Plate] then
									Spawn[Plate] = nil
								end

								TriggerClientEvent("Notify",source,"Sucesso","A seguradora efetuou o resgate do seu veículo e o mesmo já se encontra disponível para retirada.","policia",5000)
							end
						else
							vCLIENT.SearchBlip(source,Respawns[Plate]["xyz"])
							TriggerClientEvent("Notify",source,"Atenção","Rastreador do veículo foi ativado por <b>30</b> segundos, lembrando que se o mesmo estiver em movimento a localização pode ser imprecisa.","policia",10000)
						end
					else
						TriggerClientEvent("Notify",source,"Aviso","Rastreador só pode ser ativado a cada <b>60</b> segundos.","policia",5000)
					end
				else
					TriggerClientEvent("Notify",source,"Aviso","Rastreador está desativado.","policia",5000)
				end
			else
				if Gemstone > 0 and Vehicle["Rental"] ~= 0 and Vehicle["Rental"] <= os.time() then
					TriggerClientEvent("garages:Close",source)

					if VehicleClass(Name) == "Exclusivos" then
						Coin = "Platina"
					end

					if vRP.Request(source,"Garagem","Pagar o aluguel do veículo <b>"..VehicleName(Name).."</b> por <b>"..Dotted(Gemstone).." "..Coin.."</b>?") then
						if (Coin == "Diamantes" and vRP.PaymentGems(Passport,Gemstone)) or (Coin == "Platina" and vRP.TakeItem(Passport,"platinum",Gemstone)) then
							vRP.Query("vehicles/rentalVehiclesUpdate",{ Passport = Passport, Vehicle = Name, Days = 30 })
							TriggerClientEvent("Notify",source,"Sucesso","Aluguel do veículo <b>"..VehicleName(Name).."</b> atualizado.","verde",5000)
						else
							TriggerClientEvent("Notify",source,"Aviso",Coin.." insuficiente.","amarelo",5000)
							Active[Passport] = nil

							return false
						end
					else
						Active[Passport] = nil

						return false
					end
				end

				if Vehicle["Tax"] <= os.time() then
					TriggerClientEvent("garages:Close",source)

					if vRP.Request(source,"Garagem","Pagar a <b>Taxa</b> do veículo <b>"..VehicleName(Name).."</b> por <b>$"..Dotted(Price * PercentageTaxs).."</b>?") then
						if vRP.PaymentFull(Passport,Price * PercentageTaxs) then
							vRP.Query("vehicles/updateVehiclesTax",{ Passport = Passport, Vehicle = Name })
							TriggerClientEvent("Notify",source,"Sucesso","Pagamento concluído.","verde",5000)
						else
							TriggerClientEvent("Notify",source,"Aviso","Dinheiro insuficiente.","amarelo",5000)
							Active[Passport] = nil

							return false
						end
					else
						Active[Passport] = nil

						return false
					end
				end

				local Coords = vCLIENT.SpawnPosition(source,Number)
				if Coords then
					local Mods = vRP.GetSrvData("LsCustoms:"..Passport..":"..Name)
					local Exist,Network,Vehicles = Creative.ServerVehicle(Name,Coords,Plate,Vehicle["Nitro"],Vehicle["Doors"],Vehicle["Body"],Vehicle["Fuel"],Vehicle["Seatbelt"],Vehicle["Drift"])

					if Exist then
						local Players = vRPC.Players(source)
						for _,Sources in pairs(Players) do
							async(function()
								vCLIENT.CreateVehicle(Sources,Name,Network,Vehicle["Engine"],Vehicle["Health"],Mods,Vehicle["Windows"],Vehicle["Tyres"])
							end)
						end

						Entity(Vehicles)["state"]:set("Lockpick",Passport,true)

						Spawn[Plate] = { Passport,Name,Vehicles }
					end
				end
			end
		end

		Active[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("car",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,CarPermission) and Message[1] then
		local Name = Message[1]
		local Ped = GetPlayerPed(source)
		local Coords = GetEntityCoords(Ped)
		local Heading = GetEntityHeading(Ped)
		local Plate = "VEH"..(10000 + Passport)
		local Exist,Network,Vehicle = Creative.ServerVehicle(Name,vec4(Coords["x"],Coords["y"],Coords["z"],Heading),Plate,2000,nil,1000,50,true)

		if Exist then
			local Players = vRPC.Players(source)
			for _,Sources in pairs(Players) do
				async(function()
					vCLIENT.CreateVehicle(Sources,Name,Network,1000,1000,nil,false,false,false)
				end)
			end

			Entity(Vehicle)["state"]:set("Lockpick",Passport,true)
			Spawn[Plate] = { Passport,Name,Vehicle }
			TaskWarpPedIntoVehicle(Ped,Vehicle,-1)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DV
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("dv",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,DvPermission) then
		TriggerClientEvent("garages:Delete",source)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:KEY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Key")
AddEventHandler("garages:Key",function(Entitys)
	local source = source
	local Plate = Entitys[1]
	local Passport = vRP.Passport(source)
	if Passport then
		local Networked = NetworkGetEntityFromNetworkId(Entitys[4])
		if DoesEntityExist(Networked) and Entity(Networked)["state"]["Lockpick"] and Entity(Networked)["state"]["Lockpick"] == Passport then
			vRP.GiveItem(Passport,"vehiclekey-"..os.time().."-"..Plate,1,true)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:LOCK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Lock")
AddEventHandler("garages:Lock",function(Network)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Networked = NetworkGetEntityFromNetworkId(Network)
		if DoesEntityExist(Networked) and Entity(Networked)["state"]["Lockpick"] and Entity(Networked)["state"]["Lockpick"] == Passport then
			TriggerEvent("garages:LockVehicle",source,Network)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:LOCKVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("garages:LockVehicle",function(source,Network)
	local Networked = NetworkGetEntityFromNetworkId(Network)
	if DoesEntityExist(Networked) then
		local Doors = GetVehicleDoorLockStatus(Networked)

		if parseInt(Doors) <= 1 then
			TriggerClientEvent("Notify",source,"Aviso","Veículo trancado.","default",5000)
			TriggerClientEvent("sounds:Private",source,"locked",0.5)
			SetVehicleDoorsLocked(Networked,2)
		else
			TriggerClientEvent("Notify",source,"Aviso","Veículo destrancado.","default",5000)
			TriggerClientEvent("sounds:Private",source,"unlocked",0.5)
			SetVehicleDoorsLocked(Networked,1)
		end

		if not vRP.InsideVehicle(source) then
			vRPC.playAnim(source,true,{"anim@mp_player_intmenu@key_fob@","fob_click_fp"},false)
			Wait(350)
			vRPC.stopAnim(source)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Delete(Network,Doors,Tyres,Plate,Save)
	if Spawn[Plate] then
		local Networked = NetworkGetEntityFromNetworkId(Network)
		if DoesEntityExist(Networked) and not IsPedAPlayer(Networked) and GetEntityType(Networked) == 2 and GetVehicleNumberPlateText(Networked) == Plate then
			local Name = Spawn[Plate][2]
			local Passport = Spawn[Plate][1]
			if vRP.SelectVehicle(Passport,Name) then
				local Health = GetEntityHealth(Networked)
				local Body = GetVehicleBodyHealth(Networked)
				local Engine = GetVehicleEngineHealth(Networked)

				local Windows = {}
				for Number = 0,5 do
					Windows[Number] = IsVehicleWindowIntact(Networked,Number)
				end

				if VehicleMode(Name) ~= "Work" and Save and Garages[Save] and Garages[Save]["Name"] == "Garage" then
					vRP.Query("vehicles/updateVehiclesSave",{ Passport = Passport, Vehicle = Name, Nitro = Entity(Networked)["state"]["Nitro"] or 0, Engine = parseInt(Engine), Body = parseInt(Body), Health = parseInt(Health), Fuel = Entity(Networked)["state"]["Fuel"] or 0, Doors = json.encode(Doors), Windows = json.encode(Windows), Tyres = json.encode(Tyres), Save = Save })
				else
					vRP.Query("vehicles/updateVehicles",{ Passport = Passport, Vehicle = Name, Nitro = Entity(Networked)["state"]["Nitro"] or 0, Engine = parseInt(Engine), Body = parseInt(Body), Health = parseInt(Health), Fuel = Entity(Networked)["state"]["Fuel"] or 0, Doors = json.encode(Doors), Windows = json.encode(Windows), Tyres = json.encode(Tyres) })
				end
			end
		end
	end

	TriggerEvent("garages:Delete",Network,Plate)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:DELETED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Deleted")
AddEventHandler("garages:Deleted",function(Network,Plate)
	Creative.Delete(Network,{},{},Plate)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:DELETE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Delete")
AddEventHandler("garages:Delete",function(Network,Plate)
	if Network and Plate then
		if Signal[Plate] then
			Signal[Plate] = nil
		end

		if Changed[Plate] then
			local Backup = Changed[Plate]
			if Spawn[Backup] then
				Spawn[Backup] = nil
			end

			Changed[Plate] = nil
		end

		if Spawn[Plate] then
			Spawn[Plate] = nil
		end

		local Networked = NetworkGetEntityFromNetworkId(Network)
		if DoesEntityExist(Networked) and not IsPedAPlayer(Networked) and GetEntityType(Networked) == 2 and GetVehicleNumberPlateText(Networked) == Plate then
			DeleteEntity(Networked)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:PROPERTYS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Propertys")
AddEventHandler("garages:Propertys",function(Name)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		local Consult = vRP.Query("propertys/Exist",{ Name = Name })
		if Consult[1] and Consult[1]["Passport"] == Passport then
			Active[Passport] = true
			TriggerClientEvent("dynamic:Close",source)
			TriggerClientEvent("Notify",source,"Aviso","Selecione o local da garagem.","amarelo",5000)

			local Hash = "prop_offroad_tyres02"
			local Application,Coords = vRPC.ObjectControlling(source,Hash)
			if Application then
				if #(vec3(Coords[1],Coords[2],Coords[3]) - exports["propertys"]:Coords(Name)) <= 25 then
					TriggerClientEvent("Notify",source,"Aviso","Selecione o local do veículo.","amarelo",5000)

					local Open = Coords
					local Hash = "sultanrs"
					local Application,Coords = vRPC.ObjectControlling(source,Hash)
					if Application then
						if #(vec3(Coords[1],Coords[2],Coords[3]) - exports["propertys"]:Coords(Name)) <= 25 then
							local New = {
								["1"] = { Open[1],Open[2],Open[3] + 1 },
								["2"] = { Coords[1],Coords[2],Coords[3] + 1,Coords[4] }
							}

							Garages[Name] = { ["Name"] = "Garage", ["Save"] = true }

							Propertys[Name] = {
								["x"] = New["1"][1],
								["y"] = New["1"][2],
								["z"] = New["1"][3],
								["1"] = New["2"]
							}

							vRP.Query("propertys/Garage",{ Name = Name, Garage = json.encode(New) })
							TriggerClientEvent("garages:Propertys",-1,Propertys)
						else
							TriggerClientEvent("Notify",source,"Error","A garagem precisa ser próximo da entrada.","vermelho",5000)
						end
					end
				else
					TriggerClientEvent("Notify",source,"Error","A garagem precisa ser próximo da entrada.","vermelho",5000)
				end
			end

			Active[Passport] = nil
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVERSTART
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local Consult = vRP.Query("propertys/Garages")
	for _,v in pairs(Consult) do
		local Name = v["Name"]
		if not Propertys[Name] and v["Garage"] then
			local Table = json.decode(v["Garage"])
			Garages[Name] = { ["Name"] = "Garage", ["Save"] = true }

			Propertys[Name] = {
				["x"] = Table["1"][1],
				["y"] = Table["1"][2],
				["z"] = Table["1"][3],
				["1"] = Table["2"]
			}
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SIGNAL
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Signal",function(Plate)
	return Signal[Plate]
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	TriggerClientEvent("garages:Propertys",source,Propertys,Respawns)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	if Active[Passport] then
		Active[Passport] = nil
	end
end)