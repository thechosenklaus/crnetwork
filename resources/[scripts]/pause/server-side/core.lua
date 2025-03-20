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
local function CountShopping(Passport)
	local Shopping = {}
    local History = vRP.UserData(Passport, "Shopping")

	for k, v in pairs(History) do

		Shopping[#Shopping + 1] = {
			["Image"] = ItemIndex(v["Name"]),
			["Name"] = ItemName(v["Name"]),
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
-- PREMIUMDAYS
-----------------------------------------------------------------------------------------------------------------------------------------
function PremiumDays(source)
    local Passport = vRP.Passport(source)
    local Identity = vRP.Identity(Passport)
    local Account = vRP.Account(Identity["License"])
    local Level = Account["Level"]

    local PremiumDay = 0
    if Account["Premium"] and Account["Premium"] >= os.time() and Account["Level"] > 0 then
        local Time = Account["Premium"] - os.time()
        PremiumDay = math.floor(Time / 86400)
    end
    
    local Hierarchy = Account["Level"]
    local PremiumInfo = Premium[1]

    local Display = Premium[math.random(#Premium)]
    if Hierarchy > 0 then
        Display = Premium[Hierarchy]
        Hierarchy = Account["Level"]
    end

    return {
        ["Active"] = PremiumDay,
        ["Hierarchy"] = Hierarchy,
        ["Display"] = Display
    }
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
            
            return {
                ["Information"] = {
                    ["Name"] = vRP.FullName(Passport),
                    ["Sex"] = Identity["Sex"],
                    ["Blood"] = Sanguine(Identity["Blood"]),
                    ["Passport"] = Passport,
                    ["Bank"] = Identity["Bank"],
                    ["Phone"] = vRP.Phone(Passport),
                    ["Gemstone"] = vRP.UserGemstone(Identity["License"]),
                    ["Playing"] = CompleteTimers(os.time() - Identity["Login"]),
                    ["Medic"] = Days,
                },
                ["Premium"] = PremiumDays(source),
                ["Shopping"] = CountShopping(Passport),
                ["Carousel"] = CountCarousel(),
                ["Box"] = Boxes[math.random(#Boxes)],
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
function Creative.PremiumBuy(Index, SelectedOptionId)
    local source = source

    if type(SelectedOptionId) == "table" then
        SelectedOptionId = SelectedOptionId["Id"] or 1
    end

    local Passport = vRP.Passport(source)
    if Passport and Premium[Index] then
        local Item = Premium[Index]

        if vRP.PaymentGems(Passport, Item["Price"]) then
            exports["crons"]:Insert(Passport,"RemovePermission",30 * 1440,{ Permission = Item["Name"] })

            if Item["Selectables"] then
                for _, Selectable in ipairs(Item["Selectables"]) do
                    if Selectable["Id"] == SelectedOptionId then
                        for _, Option in ipairs(Selectable["Options"]) do
                            local VehicleIndex = Option["Index"]
							local RentalDays = Option["Amount"]

                            if VehicleIndex then
                                vRP.Query("vehicles/rentalVehicles", {
                                    Passport = Passport,
                                    vehicle = VehicleIndex,
                                    plate = vRP.GeneratePlate(),
                                    work = "false",
									rental = RentalDays
                                })

                                TriggerClientEvent("Notify", source, "Sucesso", "Premium alugado com sucesso", "verde", 5000)
                            end
                        end
                    end
                end
            end
        else
            TriggerClientEvent("Notify", source, "Erro", "Gems insuficientes para comprar este pacote.", "vermelho", 5000)
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
            local Shopping = vRP.UserData(Passport, "Shopping") or {}
            Shopping[#Shopping + 1] = {
                ['Passport'] = Passport,
                ['Name'] = Item,
                ['Amount'] = Amount,
                ['Price'] = parseInt(ShopItens[Item]["Price"] * ShopItens[Item]["Discount"]),
                ['Discount'] = ShopItens[Item]["Discount"],
		    }
            vRP.Query("playerdata/SetData",{ Passport = Passport, Name = "Shopping", Information = json.encode(Shopping) })
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
                Key = Item["key"],
                Name = ItemName(Item["item"]),
                Price = Item["price"],
                Amount = Item["quantity"]
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
                if tonumber(v["passport"]) == tonumber(Passport) then
                    local Item = {
                        Id = k,
                        Key = ItemIndex(v["item"]),
                        Name = ItemName(v["item"]),
                        Item = v["item"],
                        Price = v["price"],
                        Amount = v["quantity"],
                    }

                    PlayerItems[#PlayerItems + 1] = Item
                end
            end
            if #PlayerItems > 0 then
                return PlayerItems
            end
        end

        if Mode == "Create" then
            for Id, Slot in pairs(Inventory) do
                if Slot["item"] and not vRP.CheckDamaged(Slot["item"]) then
                    local Item = {
                        Id = Id,
                        Key = ItemIndex(Slot["item"]),
                        Name = ItemName(Slot["item"]),
                        Item = Slot["item"],
                        Amount = Slot["amount"],
                    }

                    Marketplace[#Marketplace + 1] = Item
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
            if tonumber(Item["passport"]) == tonumber(Passport) then
                Marketplace[#Marketplace + 1] = {
                    Id = Id,
                    Key = Item["key"],
                    Name = ItemName(Item["item"]),
                    Price = Item["price"],
                    Amount = Item["quantity"]
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
                passport = Passport,
                key = ItemIndex(Item),
                item = Item,
                price = Price,
                quantity = Amount,
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
            if tostring(Datatable[Id]["passport"]) == tostring(Passport) then
                TriggerClientEvent("pause:Notify", source, "Você não pode comprar seu próprio item.", "Verifique o item antes de comprar.")
                return false
            end
            if vRP.CheckWeight(Passport,Datatable[Id]["item"]) and not vRP.MaxItens(Passport,Datatable[Id]["item"]) then
                if vRP.PaymentFull(Passport, Datatable[Id]["price"]) then
                    vRP.GiveBank(Datatable[Id]["passport"], Datatable[Id]["price"])
                    vRP.GiveItem(Passport, Datatable[Id]["item"], Datatable[Id]["quantity"])
                    
                    TriggerClientEvent("pause:Notify", source, "Compra realizada com sucesso.", "Verifique seu Inventario", "verde")
                    
                    local seller = vRP.Source(Datatable[Id]["passport"])
                    if seller then
                        TriggerClientEvent("Notify", seller, "Sucesso", "Seu item foi vendido por $" .. Datatable[Id]["price"] .. ".", "verde", 5000)
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
            vRP.GiveItem(Passport, Datatable[Id]["item"], Datatable[Id]["quantity"])
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
        local Players = vRP.Players()

        for _, Source in pairs(Players) do
            local OtherPassport = vRP.Passport(Source)
            local Identity = vRP.Identity(Passport)
            local Playing = vRP.GetSrvData("Playing:"..Passport)

            Ranking[#Ranking + 1] = {
                Name = vRP.FullName(OtherPassport),
                Killed = Identity.Killed,
                Death = Identity.Death,
                Ratio = 0, -- Sem funcionamento pois Ratio = Razão porem retorna número
                Status = Playing.Online,
                Hours = os.time() - Identity.Login,
            }
        end

        return Ranking
    end

    return {}
end
function Creative.Daily()
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local Identity = vRP.Identity(Passport)
        return { Identity["Daily"], Identity["DailyReward"], #Daily }
    end

    return {}
end
function Creative.DailyRescue(Day)
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local Identity = vRP.Identity(Passport)
        local Reward = Identity["DailyReward"]

        if Day == Reward + 1 and os.date("%d-%m-%y") ~= Identity["Daily"] then
            for Item, Amount in pairs(Daily[Day]) do
                vRP.GenerateItem(Passport, Item, Amount, false)
                TriggerClientEvent("pause:Notify", source, "Item Recebido.", "Você recebeu <b>" .. Amount .. "x " .. ItemName(Item) .. "</b>.", "verde")
            end

            vRP.UpdateDaily(Passport, source, os.date("%d-%m-%y"))

            return Day
        else
            TriggerClientEvent("pause:Notify", source, "Atenção", "Você não pode regatar esse item pois ja resgatou um hoje.", "vermelho")
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
                vRP.RolepassPayment(Passport,ItemAmount,Mode)
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