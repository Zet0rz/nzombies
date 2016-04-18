function GM:OnReloaded( )
	print("Reloading Data!")
	//Reload the data from the entities back into the tables
	//Door data
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() or v:IsBuyableProp() then
			local data = v.Data
			if data != nil then
				nz.nzDoors.Functions.CreateLink(v, data)
			end
		end
	end
	
	
	nz.Players.Functions.FullSync( ply )
	
end