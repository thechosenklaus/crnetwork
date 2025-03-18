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
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local activeRolepass = {}
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
-- MEDICDAYS
-----------------------------------------------------------------------------------------------------------------------------------------
function MedicDays(Medic)
    local Time = Medic

    if Time then
        local Hour = os.time()
        local Seconds = Time - Hour
        local Days = math.ceil(Seconds / 86400)

        return Days
    end

    return 0 
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREMIUMDAYS
-----------------------------------------------------------------------------------------------------------------------------------------
function PremiumDays(source)
    local Passport = vRP.Passport(source)
    local Identity = vRP.Identity(Passport)
    local Account = vRP.Account(Identity["License"])

    local PremiumDay = 0
    if Account["Premium"] and Account["Premium"] >= os.time() then
        local Time = Account["Premium"] - os.time()
        PremiumDay = math.floor(Time / 86400)
    end
    
    local Hierarchy = 1
    local PremiumInfo = Premium[1]

    local Display = Premium[math.random(#Premium)]
    if Hierarchy > 0 then
        Display = Premium[Hierarchy]
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
                local Experience = vRP.GetExperience(Passport,Index)

                table.insert(Experiences, { v, Experience })
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
                    ["Playing"] = vRP.Playing(Passport),
                    ["Medic"] = MedicDays(Identity["Medic"]),
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
            local SetPremium = Item["Hierarchy"]
            vRP.SetPremium(source, Passport, SetPremium, 30)

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

	return { Shop, Category }
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
                if Slot["item"] then
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

            table.insert(Datatable, {
                passport = Passport,
                key = ItemIndex(Item),
                item = Item,
                price = Price,
                quantity = Amount,
            })

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
-- GETROLEPASS
-----------------------------------------------------------------------------------------------------------------------------------------
function GetRolepass(Passport)
    if not activeRolepass[Passport] then
        activeRolepass[Passport] = vRP.UserData(Passport,"Rolepass")
    end

    return activeRolepass[Passport]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLEPASS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Rolepass()
    local source = source
    local Passport = vRP.Passport(source)

    if Passport then
        local RolepassData = GetRolepass(Passport)

        local Premium = {}
        for Index,Value in pairs(RoleItens["Premium"]) do
            Premium[#Premium + 1] = { ["id"] = Index, ["Name"] = ItemName(Value["Item"]), ["Index"] = Value["Item"], ["Amount"] = Value["Amount"], ["Image"] = ItemIndex(Value["Item"]), ["Description"] = ItemDescription(Value["Item"]) }
        end

        local Free = {}
        for Index,Value in pairs(RoleItens["Free"]) do
            Free[#Free + 1] = { ["id"] = Index, ["Name"] = ItemName(Value["Item"]), ["Index"] = Value["Item"], ["Amount"] = Value["Amount"], ["Image"] = ItemIndex(Value["Item"]), ["Description"] = ItemDescription(Value["Item"]) }
        end

        return {
            Active = RolepassData["RolepassBuy"],
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
    local Rolepass = GetRolepass(Passport)

    if Passport then
        if activeRolepass[Passport] == nil then
            activeRolepass[Passport] = false
        end
        
        if vRP.PaymentGems(Passport, RolepassPrice) then
            activeRolepass[Passport] = Rolepass
            Rolepass["RolepassBuy"] = true
            vRP.Query("playerdata/SetData", { Passport = Passport, Name = "Rolepass", Information = json.encode(Rolepass) })
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
        if activeRolepass[Passport] == nil then
            activeRolepass[Passport] = {}
        end

        if RoleItens[Mode] then
            if RoleItens[Mode][Number] then
                local Item = RoleItens[Mode][Number]["Item"]
                local itemAmount = RoleItens[Mode][Number]["Amount"]
                activeRolepass[Passport][Mode] = parseInt(Number)
                activeRolepass[Passport]["Points"] = not activeRolepass[Passport]["Points"] and 0 or activeRolepass[Passport]["Points"] - RolepassPoints
                vRP.Query("playerdata/SetData", { Passport = Passport, Name = "Rolepass", Information = json.encode(activeRolepass[Passport]) })

                vRP.GenerateItem(Passport, Item, itemAmount, false)
                TriggerClientEvent("pause:Notify", source, "Item Recebido.", "Você recebeu <b>" .. itemAmount .. "x " .. ItemName(Item) .. "</b>.", "verde")
                return true
            end
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDPOINTS
-----------------------------------------------------------------------------------------------------------------------------------------
function AddPoints(Passport, Amount)
    local Rolepass = GetRolepass(Passport)
    if type(Rolepass) == "table" then
        if not Rolepass["Points"] then
            Rolepass["Points"] = 0
        end

        Rolepass["Points"] = Rolepass["Points"] + math.min(Amount, (15000 - Rolepass["Points"]))
        vRP.Query("playerdata/SetData",{ Passport = Passport, Name = "Rolepass", Information = json.encode(Rolepass) })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDEXPERIENCE
-----------------------------------------------------------------------------------------------------------------------------------------
function AddExperience(Passport, Work, Number)
	if Passport and Work and Number then
		vRP.PutExperience(Passport,Work,Number)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETEXPERIENCE
-----------------------------------------------------------------------------------------------------------------------------------------
function GetExperience(Passport, Work)
	if Passport and Work then
		return vRP.GetExperience(Passport,Work) or 0
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("AddPoints", AddPoints)
exports('AddExperience', AddExperience)
exports('GetExperience', GetExperience)
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
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if activeRolepass[Passport] then
		vRP.Query("playerdata/SetData",{ Passport = Passport, Name = "Rolepass", Information = json.encode(activeRolepass[Passport]) })
	end
end)