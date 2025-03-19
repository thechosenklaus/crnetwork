-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSKINWEAPON = Tunnel.getInterface("skinweapon")
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERSKINS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.UserSkins()
    local Source = source
    local Passport = vRP.Passport(Source)
    local Identity = vRP.Identity(Passport)
    local Account = vRP.Account(Identity["License"])

    if Passport then
        local SkinsData = vRP.UserData(Passport, "Skins") or {}

        if not SkinsData then
            local Query = vRP.Query("playerdata/GetData", { Passport = Passport, Name = "Skins" })
            if Query[1] and Query[1]["Information"] then
                SkinsData = json.decode(Query[1]["Information"])
            else
                SkinsData = { List = {} }
            end
        end

        if not SkinsData["List"] then
            SkinsData["List"] = {}
        end

        return SkinsData
    end

    return {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUYSKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.BuySkin(Data)  
    local source = source
    local Passport = vRP.Passport(source)
    local Identity = vRP.Identity(Passport)
    local Account = vRP.Account(Identity["License"])

    if Passport then
        if Account["Gemstone"] >= Data["price"] then
            local SkinsData = vRP.UserData(Passport, "Skins")

            if not SkinsData then
                SkinsData = { List = {} }
            elseif not SkinsData["List"] then
                SkinsData["List"] = {}
            end

            local Price = Data["price"]

            for k,v in pairs(SkinsData["List"]) do
                if v == Data["id"] then
                    TriggerClientEvent("Notify", source, "Aviso", "Você já possui esta skin.", "vermelho", 15000, "center")        

                    return false
                end
            end

            if vRP.Request(source,"Sistema de compra de skins de armas","Você realmente deseja comprar a skin de arma <b>"..Data["name"].."</b> para a arma <b>"..Data["description"].."</b>?") then
                if vRP.PaymentGems(Passport, Price) then
                    table.insert(SkinsData["List"], Data["id"])
                    vRP.Query("playerdata/SetData",{ Passport = Passport, Name = "Skins", Information = json.encode(SkinsData) })
                    TriggerClientEvent("Notify", source, "Sucesso", "Skin adquirida com sucesso.", "verde", 5000)
                else
                    TriggerClientEvent("Notify", source, "Aviso", "Você não possui gemas o suficiente.", "vermelho", 5000) 
                end
            end
    
            return true
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLESKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.ToggleSkin(Weapon, Component)
    local Source = source
    local Passport = vRP.Passport(Source)

    if Passport then
        if Weapon then
            local SkinsData = vRP.UserData(Passport, "Skins")
    
            SkinsData[Weapon] = Component
    
            vRP.Query("playerdata/GetData",{ Passport = Passport, Name = "Skins", Information = json.encode(SkinsData) })
    
            return true
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFERSKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.TransferSkin(Target, Number, Weapon, Component)
    local source = source
    local Passport = vRP.Passport(source)
    local OtherPassport = parseInt(Target)
    local OtherSource = vRP.Source(OtherPassport)
    local Name = nil

    if Passport then
        if OtherSource and Number and Weapon and Component then
            local SkinsData = vRP.UserData(Passport, "Skins") or {}
            local TargetSkinsData = vRP.UserData(OtherPassport, "Skins") or {}

            if not TargetSkinsData["List"] then
                TargetSkinsData["List"] = {}
            end

            for k, v in pairs(vSKINWEAPON.Weapons(source)) do
                if v["weapon"] == Weapon and v["component"] == Component then
                    Name = v["name"]
                end
            end

            if vRP.Request(source,"Sistema de transferência de skins de armas","Você realmente deseja transferir a skin de arma <b>"..Name.."</b> para o jogador <b>"..vRP.FullName(OtherPassport).."</b>?") then
                for k,v in pairs(TargetSkinsData["List"]) do
                    if v == Number then
                        TriggerClientEvent("Notify", source, "Aviso", "O jogador já possui esta Skin.", "vermelho", 5000)        

                        return false
                    end
                end

                for k,v in pairs(SkinsData["List"]) do
                    if v == Number then
                        table.remove(SkinsData["List"], k)
                    end
                end

                table.insert(TargetSkinsData["List"], Number)

                vRP.Query("playerdata/SetData",{ Passport = Target, Name = "Skins", Information = json.encode(TargetSkinsData) })
                vRP.Query("playerdata/SetData",{ Passport = Passport, Name = "Skins", Information = json.encode(SkinsData) })
                TriggerClientEvent("Notify", source, "Sucesso", "Você transferiu a skin de arma <b>"..Name.."</b> para o jogador <b>"..vRP.FullName(OtherPassport).."</b>", "verde", 5000)
                TriggerClientEvent("Notify", OtherSource, "Sucesso", "Você recebeu a skin de arma <b>"..Name.."</b> do jogador <b>"..vRP.FullName(Passport).."</b>", "verde", 5000)        

                return true
            end
        elseif not OtherSource then
            TriggerClientEvent("Notify", source, "Aviso", "O jogador não existe ou ele não esta na cidade.", "vermelho", 5000)        

            return false
        end
    end
    
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVESKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.ActiveSkin(Weapon, Component)
    local source = source
    local Passport = vRP.Passport(source)
    
    if Passport then
        local SkinsData = vRP.UserData(Passport, "Skins")
        local Name = nil
        SkinsData[Weapon] = Component

        if not SkinsData then
            SkinsData = { List = {} }
        elseif not SkinsData["List"] then
            SkinsData["List"] = {}
        end

        if Users["Skins"][Passport] == nil then
            Users["Skins"][Passport] = SkinsData
        end

        Users["Skins"][Passport][Weapon] = Component

        vRP.Query("playerdata/SetData", { Passport = Passport, Name = "Skins", Information = json.encode(SkinsData) })

        for k, v in pairs(vSKINWEAPON.Weapons(source)) do
            if v["weapon"] == Weapon and v["component"] == Component then
                Name = v["name"]
            end
        end

        TriggerClientEvent("Notify", source, "Sucesso", "A skin <b>"..Name.."</b> foi ativada", "verde", 5000)

        return true
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INACTIVESKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.InactiveSkin(Weapon, Component)
    local source = source
    local Passport = vRP.Passport(source)
    if Passport then
        local SkinsData = vRP.UserData(Passport, "Skins")
        local Name = nil

        if not SkinsData then
            SkinsData = { List = {} }
        elseif not SkinsData["List"] then
            SkinsData["List"] = {}
        end

        if Users["Skins"][Passport] == nil then
            Users["Skins"][Passport] = {}
        end

        SkinsData[Weapon] = nil
        Users["Skins"][Passport][Weapon] = nil
        vRP.Query("playerdata/SetData", { Passport = Passport, Name = "Skins", Information = json.encode(SkinsData) })

        for k, v in pairs(vSKINWEAPON.Weapons(source)) do
            if v["weapon"] == Weapon and v["component"] == Component then
                Name = v["name"]
            end
        end

        TriggerClientEvent("Notify", source, "Sucesso", "A skin <b>"..Name.."</b> foi desativada", "verde", 5000)

        return true
    end
    return false
end