-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("pause", Creative)
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- BATTLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("battle", function(source)
    local Passport = vRP.Passport(source)
    if Passport and vRP.HasGroup(Passport, "Admin") then
        local Keyboard = vKEYBOARD.Secondary(source, "Passaporte", "Quantidade XP")
        if Keyboard then
            local targetPassport = Keyboard[1]
            local amount = tonumber(Keyboard[2])
            if targetPassport and amount then
                vRP.RolepassPoints(targetPassport, amount, true)
                TriggerClientEvent("Notify", source, "Sucesso", "XP atualizado.", "verde", 5000)
                exports["discord"]:Embed("XP Setado", "**[ADMIN]:** " .. Passport .. "\n**[PASSAPORTE]:** " .. targetPassport .. "\n**[XP]:** " .. amount .. "\n**[DATA & HORA]:** " .. os.date("%d/%m/%Y") .. " às " .. os.date("%H:%M"))
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COUNTSHOPPING
-----------------------------------------------------------------------------------------------------------------------------------------
local function CountShopping()
	local Shopping = {}
    local History = vRP.GetSrvData("Shopping")

	for k, v in pairs(History) do
        local Identity = vRP.Identity(v["Passport"])
		Shopping[#Shopping + 1] = {
			["Image"] = ItemIndex(v["Name"]),
			["Name"] = Identity["Name"],
			["Index"] = ItemIndex(v["Name"]),
			["Amount"] = v["Amount"],
			["Price"] = v["Price"],
			["Discount"] = v["Discount"],
            ["Category"] = v["Category"]
		}
	end

	return Shopping
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COUNTCAROUSEL
-----------------------------------------------------------------------------------------------------------------------------------------
local function CountCarousel()
	local Carousel = {}
	local Counter = 0

	for k, v in pairs(ShopItens) do
		if (#Carousel + 1) > 3 then break end

		if v["Discount"] < 1 then
			Carousel[#Carousel + 1] = {
				["id"] = Counter,
				["Index"] = k,
				["Image"] = ItemIndex(k),
				["Name"] = ItemName(k),
				["Amount"] = 1,
				["Price"] = v["Price"],
				["Discount"] = v["Discount"]
			}
			Counter = Counter + 1
		end
	end
	return Carousel
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HOME
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Home()
	local source = source
	local Passport = vRP.Passport(source)

	if Passport then
	    local Identity = vRP.Identity(Passport)

		if Identity then
            local Experiences = {}
            
            for Index, v in pairs(Works) do
                local Experience = vRP.GetExperience(Passport, Index)
                table.insert(Experiences, { v, Experience })
            end

            local Medic = Identity["Medic"]
            local Days = 0

            if Medic then
                local Hour = os.time()
                local Seconds = Medic - Hour
                Days = (Seconds > 0) and math.ceil(Seconds / 86400) or 0
            end

            repeat
                Box1 = math.random(#Boxes)
                Box2 = math.random(#Boxes)
            until Box1 and Box2 and Box1 ~= Box2 and not Boxes[Selected]
            
            return {
                ["Information"] = {
                    ["Name"] = vRP.FullName(Passport),
                    ["Sex"] = Identity["Sex"],
                    ["Blood"] = Sanguine(Identity["Blood"]),
                    ["Passport"] = Passport,
                    ["Bank"] = Identity["Bank"],
                    ["Phone"] = vRP.Phone(Passport),
                    ["Gemstone"] = vRP.UserGemstone(Identity["License"]),
                    ["Playing"] = CompleteTimers(os.time() - Identity["Created"]),
                    ["Medic"] = Days,
                },
                ["Shopping"] = CountShopping(),
                ["Carousel"] = CountCarousel(),
                ["Boxes"] = { Boxes[Box1], Boxes[Box2] },
                ["Levels"] = TableLevel(),
                ["Experience"] = Experiences,
            }
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Premium()
    local source = source
    local Passport = vRP.Passport(source)
    if Passport then
        return Premium
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREMIUMBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.PremiumBuy(Index, Select)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local Item = Premium[Index]
        if Item then
            local Price = Item.Price
            if vRP.PaymentGems(Passport,Price) then
                exports["crons"]:Insert(Passport,"RemovePermission",Item.Duration * 1440,{ Permission = Item.Permission })
                vRP.SetPermission(Passport,Item.Permission)
                TriggerClientEvent("Notify",source,"Sucesso","Premium comprado com sucesso.","verde",5000)

                if Item.Selectables then
                    for Number, v in ipairs(Item.Selectables) do
                        local Option = v.Options[Select[Number]]
                        if Option then
                            vRP.Query("vehicles/rentalVehicles", {
                                Passport = Passport,
                                Vehicle = Option.Index,
                                Plate = vRP.GeneratePlate(),
                                Weight = VehicleWeight(Option.Index),
                                Work = 0,
                                Rental = Option.Duration
                            })
                        end
                    end
                end
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DIAMONDSLIST
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.StoreList()
	local Shop = {}
    local Category = {}

	for k, v in pairs(ShopItens) do
		Shop[#Shop + 1] = {
			["Index"] = k,
			["Description"] = ItemDescription(k),
			["Image"] = ItemIndex(k),
			["Name"] = ItemName(k),
			["Price"] = v["Price"],
			["Discount"] = v["Discount"],
            ["Category"] = v["Category"]
		}

        table.insert(Category, v["Category"])
	end

	return Shop,Category
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DIAMONDSBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.StoreBuy(Item, Amount)
	if ShopItens[Item] then
		local source = source
		local Passport = vRP.Passport(source)
		local Price = ShopItens[Item]["Price"] * ((100 - ShopItens[Item]["Discount"]) / 100)

		if vRP.PaymentGems(Passport, Amount * Price) then
            local Shopping = vRP.GetSrvData("Shopping") or {}
            Shopping[#Shopping + 1] = {
                ['Passport'] = Passport,
                ['Name'] = Item,
                ['Amount'] = Amount,
                ['Price'] = parseInt(ShopItens[Item]["Price"] * ShopItens[Item]["Discount"]),
                ['Discount'] = ShopItens[Item]["Discount"],
		    }
            vRP.SetSrvData("Shopping", Shopping, true)
            TriggerClientEvent("pause:Notify", source, "Sucesso", "Compra concluida.", "verde")
			vRP.GenerateItem(Passport, Item, Amount)
		end

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENBOX
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.OpenBox(Data)
    local Source = source
    local Passport = vRP.Passport(Source)
    if not Passport then return false end

    local BoxData
    for _, Box in pairs(Boxes) do
        if Box["Id"] == Data then
            BoxData = Box
            break
        end
    end

    if not BoxData then return false end

    local Price = parseInt(BoxData["Price"] * BoxData["Discount"])
    if not vRP.PaymentGems(Passport, Price) then
        TriggerClientEvent("pause:Notify", Source, "Gemas insuficientes", "Você não possui gemas suficientes", "vermelho")
        return false
    end

    local TotalChance = 0
    for _, Reward in pairs(BoxData["Rewards"]) do
        local AdjustedChance = Reward["Chance"]

        if Reward["Amount"] >= 2000 then
            AdjustedChance = math.floor(Reward["Chance"] * 0.1)
        elseif Reward["Amount"] >= 1500 then
            AdjustedChance = math.floor(Reward["Chance"] * 0.2)
        elseif Reward["Amount"] >= 1250 then
            AdjustedChance = math.floor(Reward["Chance"] * 0.3)
        elseif Reward["Amount"] >= 1000 then
            AdjustedChance = math.floor(Reward["Chance"] * 0.5)
        end

        TotalChance = TotalChance + AdjustedChance
        Reward["AdjustedChance"] = AdjustedChance
    end

    local Random = math.random(TotalChance)
    local CurrentChance = 0

    for _, Reward in pairs(BoxData["Rewards"]) do
        CurrentChance = CurrentChance + Reward["AdjustedChance"]
        if Random <= CurrentChance then
            vRP.GenerateItem(Passport, Reward["Item"], Reward["Amount"], false)
            Citizen.SetTimeout(6000, function()
                TriggerClientEvent("pause:Notify", Source, "Sucesso", "Você recebeu " .. Reward["Amount"] .. "x " .. Reward["Name"], "verde")
            end)
            return Reward["Id"]
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Marketplace()
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local List = {}
        local Datatable = vRP.GetSrvData("Marketplace")

        for Id, Item in pairs(Datatable) do
            List[#List + 1] = {
                Id = Id,
                Key = Item["Key"],
                Name = ItemName(Item["Item"]),
                Price = Item["Price"],
                Amount = Item["Quantity"]
            }
        end

        return List
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACEINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MarketplaceInventory(Mode)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local Marketplace = {}
        local Inventory = vRP.Inventory(Passport)

        if Mode == "Announce" then
            local Datatable = vRP.GetSrvData("Marketplace")
            local PlayerItems = {}
            for k, v in ipairs(Datatable) do
                if tonumber(v["Passport"]) == tonumber(Passport) then
                    PlayerItems[#PlayerItems + 1] = {
                        Id = k,
                        Key = ItemIndex(v["Item"]),
                        Name = ItemName(v["Item"]),
                        Item = v["Item"],
                        Price = v["Price"],
                        Amount = v["Quantity"],
                    }
                end
            end
            if #PlayerItems > 0 then
                return PlayerItems
            end
        end

        if Mode == "Create" then
            for Id, Slot in pairs(Inventory) do
                if Slot["item"] and not vRP.CheckDamaged(Slot["item"]) and not BlockMarket(Slot["item"]) then
                    Marketplace[#Marketplace + 1] = {
                        Id = Id,
                        Key = ItemIndex(Slot["item"]),
                        Name = ItemName(Slot["item"]),
                        Item = Slot["item"],
                        Amount = Slot["amount"],
                    }
                end
            end
        end

        return Marketplace
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACELIST
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MarketplaceList(Mode)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local Marketplace = {}
        local Datatable = vRP.GetSrvData("Marketplace")

        for Id, Item in ipairs(Datatable) do
            if tonumber(Item["Passport"]) == tonumber(Passport) then
                Marketplace[#Marketplace + 1] = {
                    Id = Id,
                    Key = Item["Key"],
                    Name = ItemName(Item["Item"]),
                    Price = Item["Price"],
                    Amount = Item["Quantity"]
                }
            end
        end

        if #Marketplace > 0 then
            return Marketplace
        else
            return false
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACEANNOUNCE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MarketplaceAnnounce(Data)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        if vRP.TakeItem(Passport, Data["Item"], Data["Amount"]) then
            local Datatable = vRP.GetSrvData("Marketplace")

            local Item = Data["Item"]
            local Price = Data["Price"]
            local Amount = Data["Amount"]

            Datatable[#Datatable + 1] = {
                Passport = Passport,
                Key = ItemIndex(Item),
                Item = Item,
                Price = Price,
                Quantity = Amount,
            }

            vRP.SetSrvData("Marketplace", Datatable, true)

            TriggerClientEvent("pause:Notify", source, "Item anunciado com sucesso.")
            return true
        else
            TriggerClientEvent("pause:Notify", source, "Você não tem esse item em quantidade suficiente.", "Verifique o inventario")
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACEBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MarketplaceBuy(Id)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local Datatable = vRP.GetSrvData("Marketplace")

        if Datatable[Id] then
            if tostring(Datatable[Id]["Passport"]) == tostring(Passport) then
                TriggerClientEvent("pause:Notify", source, "Você não pode comprar seu próprio item.", "Verifique o item antes de comprar.")
                return false
            end
            if vRP.CheckWeight(Passport,Datatable[Id]["Item"]) and not vRP.MaxItens(Passport,Datatable[Id]["Item"]) then
                if vRP.PaymentFull(Passport, Datatable[Id]["Price"]) then
                    vRP.GiveBank(Datatable[Id]["Passport"], Datatable[Id]["Price"])
                    vRP.GiveItem(Passport, Datatable[Id]["Price"], Datatable[Id]["Quantity"])
                    
                    TriggerClientEvent("pause:Notify", source, "Compra realizada com sucesso.", "Verifique seu Inventario", "verde")
                    
                    local seller = vRP.Source(Datatable[Id]["Passport"])
                    if seller then
                        TriggerClientEvent("Notify", seller, "Sucesso", "Seu item foi vendido por $" .. Datatable[Id]["Price"] .. ".", "verde", 5000)
                    end

                    Datatable[Id] = nil
                    vRP.SetSrvData("Marketplace", Datatable, true)

                    return true
                else
                    TriggerClientEvent("pause:Notify", source, "Dinheiro insuficiente.", "Verifique seu banco ou inventario.")
                    return false
                end
            else
                TriggerClientEvent("pause:Notify", source, "Espaço insuficiente.", "Verifique seu espaço no inventario.")
                return false
            end
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARKETPLACECANCEL
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.MarketplaceCancel(Id)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local Datatable = vRP.GetSrvData("Marketplace")

        if Datatable[Id] then
            vRP.GiveItem(Passport, Datatable[Id]["Item"], Datatable[Id]["Quantity"])
            Datatable[Id] = nil

            TriggerClientEvent("pause:Notify", source, "Item cancelado com sucesso.", "Verifique o seu Inventorio.")

            vRP.SetSrvData("Marketplace", Datatable, true)
            return true
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RANKING
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Ranking(Column, Direction)
    local source = source
    local Passport = vRP.Passport(source)
    
    if Passport then
        local Ranking = {}
        local Consult = vRP.Query("accounts/All",{})

        for k,v in pairs(Consult) do
            local Characters = vRP.Query("characters/Characters",{ License = v.License })

            for k,v in pairs(Characters) do
                local Identity = vRP.Identity(v.id)

                local Killed = Identity.Killed or 0
                local Death = Identity.Death or 0
                local Ratio = 0
                if Death > 0 then
                    Ratio = Killed / Death
                elseif Killed > 0 then
                    Ratio = Killed
                end

                Ranking[#Ranking + 1] = {
                    Name = vRP.FullName(v.id),
                    Killed = Killed,
                    Death = Death,
                    Ratio = Ratio,
                    Status = vRP.Source(v.id),
                    Hours = os.time() - Identity.Created,
                }
            end
        end

        return Ranking
    end

    return {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DAILY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Daily()
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local Identity = vRP.Identity(Passport)
        return { Identity["Daily"], Identity["DailyReward"] - 1, #Daily }
    end

    return {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DAILYRESCUE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.DailyRescue(Day)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local Identity = vRP.Identity(Passport)
        local Reward = Identity["DailyReward"]

        if Day == Reward and Identity["Daily"] ~= os.date("%d-%m-%y") then
            for Item, Amount in pairs(Daily[Day]) do
                vRP.GenerateItem(Passport, Item, Amount, false)
                TriggerClientEvent("pause:Notify", source, "Item Recebido.", "Você recebeu <b>" .. Amount .. "x " .. ItemName(Item) .. "</b>.", "verde")
            end

            vRP.UpdateDaily(Passport, source, os.date("%d-%m-%y"))

            return Day
        else
            TriggerClientEvent("pause:Notify", source, "Atenção", "Você não pode regatar a <b>Recompensa Diária</b> mais de uma vez no mesmo dia, espere até amanhã!", "vermelho")
        end
    end

    return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CODE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Code(Code)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local ValidCodes = {
            ["GOLD"] = "GOLD",
            ["SILVER"] = "SILVER",
            ["BRONZE"] = "BRONZE",
        }

        if ValidCodes[string.upper(Code)] then
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Rolepass()
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local RolepassData = vRP.Rolepass(Passport)

        local Premium = {}
        for Index,Value in pairs(RoleItens["Premium"]) do
            Premium[#Premium + 1] = { ["id"] = Index, ["Name"] = ItemName(Value["Item"]), ["Index"] = Value["Item"], ["Amount"] = Value["Amount"], ["Image"] = ItemIndex(Value["Item"]), ["Description"] = ItemDescription(Value["Item"]) }
        end

        local Free = {}
        for Index,Value in pairs(RoleItens["Free"]) do
            Free[#Free + 1] = { ["id"] = Index, ["Name"] = ItemName(Value["Item"]), ["Index"] = Value["Item"], ["Amount"] = Value["Amount"], ["Image"] = ItemIndex(Value["Item"]), ["Description"] = ItemDescription(Value["Item"]) }
        end

        return {
            Active = RolepassData["Active"],
            CurrentFree = parseInt(RolepassData["Free"]),
            CurrentPremium = parseInt(RolepassData["Premium"]),
            Finish = Rolepass - os.time(),
            Free = Free,
            Necessary = RolepassPoints,
            Points = parseInt(RolepassData["Points"]),
            Premium = Premium,
            Price = RolepassPrice
        }
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASSBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.RolepassBuy()
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then   
        if vRP.PaymentGems(Passport, RolepassPrice) then
            vRP.RolepassBuy(Passport)
            TriggerClientEvent("pause:Notify", source, "Compra concluída.", "Verifique o Passe de Batalha.", "verde")
            return true
        else
            TriggerClientEvent("pause:Notify", source, "Gemas insuficientes.", "Verifique suas Gemas.", "vermelho")
            return false
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASSRESCUE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.RolepassRescue(Mode, Number)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then  
        if RoleItens[Mode] then
            if RoleItens[Mode][Number] then
                local Item = RoleItens[Mode][Number]["Item"]
                local ItemAmount = RoleItens[Mode][Number]["Amount"]
                vRP.RolepassPayment(Passport,RolepassPoints,Mode)
                vRP.GenerateItem(Passport, Item, ItemAmount, false)
                TriggerClientEvent("pause:Notify", source, "Item Recebido.", "Você recebeu <b>" .. ItemAmount .. "x " .. ItemName(Item) .. "</b>.", "verde")
                return true
            end
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Disconnect()
	local source = source
	local Passport = vRP.Passport(source)
    
	if Passport then
		vRP.Kick(source, "Volte mais tarde!")
	end
end