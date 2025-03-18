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
Tunnel.bindInterface("spawn",Creative)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
local Licensed = {}
local Connected = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Characters()
	local Characters = {}
	local source = source
	local License = vRP.Identities(source)

	if not License then
		DropPlayer(source,"Não foi possível efetuar conexão com a "..(BaseMode == "steam" and "Steam" or "Rockstar")..".")

		return Characters
	end

	exports["vrp"]:Bucket(source,"Enter",50000 + source)

	local Consult = vRP.Query("characters/Characters",{ License = License })
	for _,v in ipairs(Consult) do
		local Passport = tonumber(v.id)

		table.insert(Characters,{
			Passport = Passport,
			Skin = v.Skin,
			Nome = v.Name.." "..v.Lastname,
			Sexo = v.Sex,
			Banco = v.Bank,
			Blood = Sanguine(v.Blood),
			Clothes = vRP.UserData(Passport,"Clothings"),
			Barber = vRP.UserData(Passport,"Barbershop"),
			Tattoos = vRP.UserData(Passport,"Tattooshop")
		})
	end

	return Characters
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.CharacterChosen(Passport)
	local source = source
	local License = vRP.Identities(source)
	if not License then
		DropPlayer(source,"Não foi possível efetuar conexão com a "..(BaseMode == "steam" and "Steam" or "Rockstar")..".")

		return false
	end

	local Consult = vRP.Query("characters/UserLicense",{ Passport = Passport, License = License })
	if Consult[1] and not Licensed[License] then
		vRP.CharacterChosen(source,Passport)
		Connected[Passport] = License
		Licensed[License] = true

		return true
	end

	DropPlayer(source,"Não foi possível efetuar conexão com a "..(BaseMode == "steam" and "Steam" or "Rockstar")..".")

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEWCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.NewCharacter(Name,Lastname,Sex)
	local source = source
	if Active[source] then
		return false
	end

	Active[source] = true

	local License = vRP.Identities(source)
	if not License then
		DropPlayer(source,"Não foi possível efetuar conexão com a "..(BaseMode == "steam" and "Steam" or "Rockstar")..".")
		Active[source] = nil

		return false
	end

	local Account = vRP.Account(License)
	if Account and Account.Characters <= vRP.Scalar("characters/Count",{ License = License }) then
		TriggerClientEvent("Notify",source,"Atenção","Limite de personagem atingido.","amarelo",5000)
		Active[source] = nil

		return false
	end

	local Sexo = (Sex == "mp_f_freemode_01") and "F" or "M"

	vRP.Query("characters/NewCharacter",{
		License = License,
		Name = FirstText(Name),
		Lastname = FirstText(Lastname),
		Sex = Sexo,
		Skin = Sex,
		Blood = math.random(4)
	})

	local Consult = vRP.Query("characters/LastCharacter",{ License = License })
	if Consult[1] then
		vRPC.DoScreenFadeOut(source)
		vRP.CharacterChosen(source,Consult[1].id,Sex)
	end

	Active[source] = nil

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	local License = Connected[Passport]
	if License then
		Connected[Passport] = nil
		Licensed[License] = nil
	end

	if Active[source] then
		Active[source] = nil
	end
end)