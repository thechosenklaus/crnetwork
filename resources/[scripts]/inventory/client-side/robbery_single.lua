-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVERSTART
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	for Number,v in pairs(Single) do
		exports["target"]:AddBoxZone("RobberySingle:"..Number,v["Coords"]["xyz"],0.895,0.875,{
			name = "RobberySingle:"..Number,
			heading = v["Coords"]["w"],
			minZ = v["Coords"]["z"] - 0.75,
			maxZ = v["Coords"]["z"] + 0.75
		},{
			shop = Number,
			Distance = 1.25,
			options = {
				{
					event = "inventory:RobberySingle",
					tunnel = "server",
					label = "Roubar",
					service = v["Mode"]
				}
			}
		})
	end
end)