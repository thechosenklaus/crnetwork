-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Notify")
AddEventHandler("Notify",function(Title,Message,Color,Timer,Position,Mode,Route)
	if Route and LocalPlayer["state"]["Route"] ~= Route then
		return false
	end

	Mode = Mode or Config.Mode
	Timer = Timer or Config.Timer
	Position = Position or Config.Position

	SendNUIMessage({ Action = "Notify", Payload = { Title,Message,Timer,Config.Themes[Color],Position,Mode } })
end)