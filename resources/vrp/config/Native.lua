-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADMODEL
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadModel(Hash)
	if type(Hash) == "string" then
		Hash = GetHashKey(Hash)
	end

	if not IsModelInCdimage(Hash) or not IsModelValid(Hash) then
		return false
	end

	RequestModel(Hash)
	local Looping = GetGameTimer()
	while not HasModelLoaded(Hash) do
		Wait(100)

		if GetGameTimer() - Looping > 1000 then
			return false
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADANIM
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadAnim(Dict)
	if HasAnimDictLoaded(Dict) then
		return true
	end

	RequestAnimDict(Dict)
	local Looping = GetGameTimer()
	while not HasAnimDictLoaded(Dict) do
		Wait(100)

		if GetGameTimer() - Looping > 1000 then
			return false
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADTEXTURE
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadTexture(Library)
	if HasStreamedTextureDictLoaded(Library) then
		return true
	end

	local Looping = GetGameTimer()
	RequestStreamedTextureDict(Library,false)
	while not HasStreamedTextureDictLoaded(Library) do
		Wait(100)

		if GetGameTimer() - Looping > 1000 then
			return false
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADMOVEMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadMovement(Library)
	if HasAnimSetLoaded(Library) then
		return true
	end

	RequestAnimSet(Library)
	local Looping = GetGameTimer()
	while not HasAnimSetLoaded(Library) do
		Wait(100)

		if GetGameTimer() - Looping > 1000 then
			return false
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADPTFXASSET
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadPtfxAsset(Library)
	if HasNamedPtfxAssetLoaded(Library) then
		return true
	end

	RequestNamedPtfxAsset(Library)
	local Looping = GetGameTimer()
	while not HasNamedPtfxAssetLoaded(Library) do
		Wait(100)

		if GetGameTimer() - Looping > 1000 then
			return false
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADNETWORK
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadNetwork(Network)
	local Primary = GetGameTimer()
	while not NetworkDoesNetworkIdExist(Network) do
		Wait(100)

		if GetGameTimer() - Primary > 1000 then
			return false
		end
	end

	local Object = NetToEnt(Network)
	if not DoesEntityExist(Object) then
		return false
	end

	local Secondary = GetGameTimer()
	NetworkRequestControlOfEntity(Object)
	while not NetworkHasControlOfEntity(Object) do
		Wait(100)

		if GetGameTimer() - Secondary > 1000 then
			return false
		end
	end

	local Tertiary = GetGameTimer()
	SetEntityAsMissionEntity(Object,true,true)
	while not IsEntityAMissionEntity(Object) do
		Wait(100)

		if GetGameTimer() - Tertiary > 1000 then
			return false
		end
	end

	return Object,ObjToNet(Object)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKPOLICE
-----------------------------------------------------------------------------------------------------------------------------------------
function CheckPolice()
	return LocalPlayer["state"]["LSPD"] or LocalPlayer["state"]["BCSO"] or LocalPlayer["state"]["BCPR"]
end