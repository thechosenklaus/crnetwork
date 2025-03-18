-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Notify")
AddEventHandler("Notify",function(Title,Message,Css,Timer,Route)
	if Route and LocalPlayer["state"]["Route"] ~= Route then
		return false
	end

	SendNUIMessage({ name = "Notify", payload = { Css,Message,Title,Timer } })
end)