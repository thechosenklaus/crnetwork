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
Tunnel.bindInterface("moneywash",Creative)
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local MoneyWash = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADINITMACHINES
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    local Consult = vRP.GetSrvData("MoneyWash",true)
    for k,v in pairs(Consult) do
        MoneyWash[k] = {
          Route = v.Route,
          Coords = v.Coords,
          Hash = v.Hash,
          Item = v.Item,
          Money = v.Money,
          Washed = v.Washed,
          Timer = v.Timer,
        }
    end

    TriggerClientEvent("moneywash:Table", -1, MoneyWash)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WASH
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Wash",function(Passport, Full, Hash, Coords, Bucket, Timer, Value)
  repeat
    Selected = GenerateString("DDLLDDLL")
  until Selected and not MoneyWash[Selected]
  MoneyWash[Selected] = {
    Route = Bucket,
    Coords = Coords,
    Hash = Hash,
    Item = Full,
    Money = 0,
    Washed = 0,
    Timer = 0,
  }
  vRP.SetSrvData("MoneyWash",MoneyWash,true)
  TriggerClientEvent("moneywash:New", -1, Selected, MoneyWash[Selected])
  TriggerClientEvent("Notify",vRP.Source(Passport),"Sucesso","Você posicionou a máquina de lavagem de dinheiro.","verde",5000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:STOREOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:StoreObjects")
AddEventHandler("moneywash:StoreObjects",function(Selected)
  local source = source
  local Passport = vRP.Passport(source)
  if not MoneyWash[Selected] or not Passport then return end
  vRP.GenerateItem(Passport,MoneyWash[Selected]["Item"],1,true)
  MoneyWash[Selected] = nil
  vRP.SetSrvData("MoneyWash",MoneyWash,true)
  TriggerClientEvent("moneywash:Remove",-1,Selected)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:ADD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:Add")
AddEventHandler("moneywash:Add",function(Selected)
    local Source = source
    local Passport = vRP.Passport(Source)
    if not MoneyWash[Selected] or not Passport then return end

    local Keyboard = vKEYBOARD.Primary(Source,"Quatidade:")
    if Keyboard then
        local Quantity = Keyboard[1]

        if vRP.TakeItem(Passport,"wetdollar",Quantity,true) then
          MoneyWash[Selected]["Money"] += Quantity

          vRP.SetSrvData("MoneyWash",MoneyWash,true)

          TriggerClientEvent("dynamic:Close",Source)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:MONEY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:Money")
AddEventHandler("moneywash:Money",function(Selected)
    local Source = source
    local Passport = vRP.Passport(Source)
    if not MoneyWash[Selected] or not Passport then return end

    local Keyboard = vKEYBOARD.Primary(Source,"Quatidade:")
    if Keyboard then
        local Quantity = tonumber(Keyboard[1])

        if MoneyWash[Selected]["Money"] >= Quantity then
          MoneyWash[Selected]["Money"] -= Quantity

          vRP.SetSrvData("MoneyWash",MoneyWash,true)
          vRP.GenerateItem(Passport,"wetdollar",Quantity,true)

          TriggerClientEvent("dynamic:Close",Source)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:WASHED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:Washed")
AddEventHandler("moneywash:Washed",function(Selected)
    local Source = source
    local Passport = vRP.Passport(Source)
    if not MoneyWash[Selected] or not Passport then return end

    local Keyboard = vKEYBOARD.Primary(Source,"Quatidade:")
    if Keyboard then
        local Quantity = tonumber(Keyboard[1])

        if MoneyWash[Selected]["Washed"] >= Quantity then
          MoneyWash[Selected]["Washed"] -= Quantity

          vRP.SetSrvData("MoneyWash",MoneyWash,true)
          vRP.GenerateItem(Passport,"dollar",Quantity,true)

          TriggerClientEvent("dynamic:Close",Source)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:BATTERY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:Battery")
AddEventHandler("moneywash:Battery",function(Selected)
    local Source = source
    local Passport = vRP.Passport(Source)
    if not MoneyWash[Selected] or not Passport then return end

    if vRP.TakeItem(Passport, "washbattery", 1, true) then
      MoneyWash[Selected]["Timer"] = os.time() + 86400

      vRP.SetSrvData("MoneyWash",MoneyWash,true)

      TriggerClientEvent("dynamic:Close",Source)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INFORMATION
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Information(Selected)
  local source = source
  local Passport = vRP.Passport(source)
  if not MoneyWash[Selected] or not Passport then return end
  return MoneyWash[Selected]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OSTIME
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.OsTime()
  return os.time()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect", function(Passport, Source)
  TriggerClientEvent("moneywash:Table", Source, MoneyWash)
end)