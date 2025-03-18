-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADLOCATION
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	for Number,v in pairs(Eletronic) do
		exports["target"]:AddBoxZone("Eletronic:"..Number,v["Coords"]["xyz"],0.6,0.55,{
			name = "Eletronic:"..Number,
			heading = v["Coords"]["w"],
			minZ = v["Coords"]["z"] - 1.0,
			maxZ = v["Coords"]["z"] + 0.5
		},{
			shop = Number,
			Distance = 1.25,
			options = {
				{
					event = "inventory:RobberySingle",
					tunnel = "server",
					label = "Roubar",
					service = "Eletronic"
				}
			}
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:EXPLOSION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Explosion")
AddEventHandler("inventory:Explosion",function(Coords)
	AddExplosion(Coords["x"],Coords["y"],Coords["z"],2,1.0,true,false,true)
end)