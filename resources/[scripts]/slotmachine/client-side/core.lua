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
Tunnel.bindInterface("slotmachine",Creative)
vSERVER = Tunnel.getInterface("slotmachine")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Machines = {}
local Selected = nil
local Spinning = false
local Leave = vec3(0,0,0)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPIN
-----------------------------------------------------------------------------------------------------------------------------------------
local Spin01 = nil
local Spin02 = nil
local Spin03 = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
local Buttons = {
	{ "E","Pressione para jogar" },
	{ "F","Pressione para sair" },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SLOTMACHINE:INIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("slotmachine:Init")
AddEventHandler("slotmachine:Init",function(Entity)
		Selected = nil

		for k,v in pairs(Machines) do
			local Distance = #(v["Coords"] - Entity[4])
			if Distance <= 0.25 then
				Selected = k
				break
			end
		end

		if Selected ~= nil then
			if vSERVER.Check(Selected) then
				LocalPlayer["state"]["Cancel"] = true
				LocalPlayer["state"]["Buttons"] = true

				local Ped = PlayerPedId()
				local TableHeading = GetEntityHeading(Entity[1])
				local Chairs = GetWorldPositionOfEntityBone(Entity[1],GetEntityBoneIndexByName(Entity[1],"Chair_Base_01"))

				SetEntityHeading(Ped,TableHeading)
				SetEntityCoords(Ped,Chairs["x"],Chairs["y"],Chairs["z"] + 0.65,false,false,false,false)
				vRP.playAnim(false,{ task = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" },false)

				local TableCoords = GetEntityCoords(Entity[1])
				Leave = GetOffsetFromEntityInWorldCoords(Entity[1],0.0,-1.5,0.0)
				local Offset01 = GetObjectOffsetFromCoords(TableCoords,TableHeading,-0.118,0.05,0.9)
				local Offset02 = GetObjectOffsetFromCoords(TableCoords,TableHeading,0.000,0.05,0.9)
				local Offset03 = GetObjectOffsetFromCoords(TableCoords,TableHeading,0.118,0.05,0.9)

				if LoadModel(Machines[Selected]["Prop"]) then
					Spin01 = CreateObject(Machines[Selected]["Prop"],Offset01["x"],Offset01["y"],Offset01["z"],false,false)
					Spin02 = CreateObject(Machines[Selected]["Prop"],Offset02["x"],Offset02["y"],Offset02["z"],false,false)
					Spin03 = CreateObject(Machines[Selected]["Prop"],Offset03["x"],Offset03["y"],Offset03["z"],false,false)

					SetEntityHeading(Spin01,TableHeading)
					SetEntityHeading(Spin02,TableHeading)
					SetEntityHeading(Spin03,TableHeading)

					TriggerEvent("inventory:Buttons",Buttons)

					CreateThread(function()
						while Spin01 ~= nil do
							if IsDisabledControlJustPressed(0,23) then
								if not Spinning then
									TriggerEvent("inventory:CloseButtons")
									if DoesEntityExist(Spin01) then
										DeleteEntity(Spin01)
									end

									if DoesEntityExist(Spin02) then
										DeleteEntity(Spin02)
									end

									if DoesEntityExist(Spin03) then
										DeleteEntity(Spin03)
									end


									LocalPlayer["state"]["Cancel"] = false
									LocalPlayer["state"]["Buttons"] = false
									SetEntityCoords(Ped,Leave["x"],Leave["y"],Leave["z"] + 1.0,false,false,false,false)
									vSERVER.Clean(Selected)
									vRP.Destroy()

									Spin01 = nil
									Spin02 = nil
									Spin03 = nil
									Spinning = false
									Selected = nil
								end
							end

							if IsDisabledControlJustPressed(0,38) then
								if not Spinning then
									if vSERVER.Payment(Selected) then
										Spinning = true
										vRP.playAnim(true,{"anim_casino_a@amb@casino@games@slots@female","press_spin_a"},false)
										vSERVER.StartSlots(Selected,Machines[Selected]["Value"])
									end
								end
							end

							Wait(1)
						end
					end)
				end
			else
				TriggerEvent("Notify","vermelho","Máquina ocupada.",5000)
			end
		end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MACHINESLOTS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MachineSlots(Result)
	if Spinning then
		for i = 1,300,1 do
			local rotSpin01 = GetEntityRotation(Spin01)
			local rotSpin02 = GetEntityRotation(Spin02)
			local rotSpin03 = GetEntityRotation(Spin03)

			if i < 180 then
				SetEntityRotation(Spin01,rotSpin01["x"] + math.random(40,100) / 10,rotSpin01["y"],rotSpin01["z"],1,true)
			elseif i == 180 then
				SetEntityRotation(Spin01,Result["a"] * 22.5 - 180 + 0.0,rotSpin01["y"],rotSpin01["z"],1,false)
			end

			if i < 240 then
				SetEntityRotation(Spin02,rotSpin02["x"] + math.random(40,100) / 10,rotSpin02["y"],rotSpin02["z"],1,true)
			elseif i == 240 then
				SetEntityRotation(Spin02,Result["b"] * 22.5 - 180 + 0.0,rotSpin02["y"],rotSpin02["z"],1,false)
			end

			if i < 300 then
				SetEntityRotation(Spin03,rotSpin03["x"] + math.random(40,100) / 10,rotSpin03["y"],rotSpin03["z"],1,true)
			elseif i == 300 then
				SetEntityRotation(Spin03,Result["c"] * 22.5 - 180 + 0.0,rotSpin03["y"],rotSpin03["z"],1,false)
			end

			Wait(10)
		end

		Spinning = false

		vSERVER.Winner(Selected,Result)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEMACHINES
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.UpdateMachines(Table)
	Machines = Table
end