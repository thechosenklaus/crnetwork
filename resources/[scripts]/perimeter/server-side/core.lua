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
Tunnel.bindInterface("perimeter",Creative)
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Perimeters = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADINITPERIMETERS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    local Consult = vRP.GetSrvData("Perimeters",true)
    for k,v in pairs(Consult) do
        Perimeters[k] = {
            Passport = v.Passport,
            Name = v.Name,
            Distance = v.Distance,
            Coords = vec3(v.Coords.x,v.Coords.y,v.Coords.z)
        }
    end

    TriggerClientEvent("perimeter:List",-1,Perimeters)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETROS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Perimeters()
    return Perimeters
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETER:NEW
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("perimeter:New")
AddEventHandler("perimeter:New",function()
    local Source = source
    local Passport = vRP.Passport(Source)
    if not Passport or not vRP.HasGroup(Passport,"Policia") then return end

    local Keyboard = vKEYBOARD.Secondary(Source,"Nome:","Distância:")
    if Keyboard then
        local Name = Keyboard[1]
        local Distance = tonumber(Keyboard[2])

        if not Name or string.len(Name) < 3 then
            TriggerClientEvent("Notify",Source,"Aviso","O nome do perímetro deve ter ao menos <b>3 caracteres</b>.",8000)
            return
        end

        if not Distance or Distance <= 0 then
            TriggerClientEvent("Notify",Source,"Aviso","A distância deve ser um valor válido.",8000)
            return
        end

        local Selected
        repeat
            Selected = GenerateString("DDLLDDLL")
        until Selected and not Perimeters[Selected]

        Perimeters[Selected] = {
            Passport = Passport,
            Name = Name,
            Distance = Distance,
            Coords = GetEntityCoords(GetPlayerPed(Source))
        }

        vRP.SetSrvData("Perimeters",Perimeters,true)

        TriggerClientEvent("perimeter:Add",-1,Selected,Perimeters[Selected])
        TriggerClientEvent("dynamic:AddButton",Source,Name,"Remover o perímetro.","perimeter:Remove",Selected,"perimeter",true)

        TriggerClientEvent("Notify",-1,"Informativo Policial","Informamos que o perímetro <b>"..Name.."</b> encontra-se fechado para circulação, pedimos a compreensão de todos e orientamos que busquem rotas alternativas, agradecemos pela colaboração.","policia",15000)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETER:REMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("perimeter:Remove")
AddEventHandler("perimeter:Remove",function(Selected)
    local Source = source
    local Passport = vRP.Passport(Source)
    if not Perimeters[Selected] or not Passport or not vRP.HasGroup(Passport,"Policia") then return end

    TriggerClientEvent("Notify",-1,"Informativo Policial","Informamos que o perímetro <b>"..Perimeters[Selected].Name.."</b> encontra-se liberado para circulação, agradecemos pela colaboração e pedimos que todos sigam as orientações de segurança.","policia",15000)

    Perimeters[Selected] = nil
    vRP.SetSrvData("Perimeters",Perimeters,true)

    TriggerClientEvent("perimeter:Remove",-1,Selected)
    TriggerClientEvent("dynamic:Close",Source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,Source)
    TriggerClientEvent("perimeter:List",Source,Perimeters)
end)
