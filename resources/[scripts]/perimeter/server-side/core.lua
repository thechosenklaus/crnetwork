-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
local Creative = {}
Tunnel.bindInterface("perimeter", Creative)
local vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Perimeters = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETERS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Perimeters()
    return Perimeters
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETER:NEW
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("perimeter:New")
AddEventHandler("perimeter:New", function()
    local source = source
    local Passport = vRP.Passport(source)
    if Passport and vRP.HasGroup(Passport, "Policia") then
        TriggerClientEvent("dynamic:Close", source)

        local Keyboard = vKEYBOARD.Secondary(source, "Nome", "Distancia")

        if not Keyboard or not Keyboard[1] or not Keyboard[2] then
            return
        end

        local Title = Keyboard[1]
        local Distance = parseInt(Keyboard[2])

        if Title == "" then
            TriggerClientEvent("Notify",source,"Erro","Título inválido.", "vermelho",5000)
            return
        end

        if Distance < 5 then
            TriggerClientEvent("Notify",source,"Erro","O perímetro deve ter mais de 5m.", "vermelho",5000)
            return
        end

        local Ped = GetPlayerPed(source)
        local Coords = GetEntityCoords(Ped)        
        table.insert(Perimeters, { Name = Title, Coords = Coords, Distance = Distance })
        local Index = #Perimeters

        TriggerClientEvent("perimeter:Add", -1, Index, Perimeters[Index])
        TriggerClientEvent("Notify",-1,"Informativo Policial","Informamos que o perímetro <b>" .. Title .. "</b> encontra-se fechado para circulação, pedimos a compreensão de todos e orientamos que busquem rotas alternativas, agradecemos pela colaboração.","policia",5000)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERIMETER:REMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("perimeter:Remove")
AddEventHandler("perimeter:Remove", function(Index)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport and vRP.HasGroup(Passport, "Policia") then
        if Perimeters[Index] then
            local Title = Perimeters[Index].Name
            TriggerClientEvent("dynamic:Close", source)
            table.remove(Perimeters, Index)
            TriggerClientEvent("perimeter:Remove", -1, Index)
            TriggerClientEvent("Notify",-1,"Informativo Policial","Informamos que o perímetro <b>" .. Title .. "</b> encontra-se liberado para circulação, agradecemos pela colaboração e pedimos que todos sigam as orientações de segurança.","policia",5000)
        else
            TriggerClientEvent("Notify", source, "Erro","Perímetro não encontrado.","vermelho",5000)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect", function(Passport, Source)
    SetTimeout(2000, function()
        TriggerClientEvent("perimeter:List", Source, Perimeters)
    end)
end)