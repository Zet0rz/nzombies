//Chat Commands

//Setup
nz.Misc.Data.ConsoleCommands = {}

//Functions
function nz.Misc.Functions.NewConsoleCommand(text, func)
	//For Future Use
	--table.insert(nz.Misc.Data.ConsoleCommands, {text, func})
	//Console Command usage
	concommand.Add( text, func )
end

//Quick Function
NewConsoleCommand = nz.Misc.Functions.NewConsoleCommand

// Actual Commands

//Quick reload for dedicated severs
NewConsoleCommand("qr", function() 
	RunConsoleCommand("changelevel", game.GetMap())
end)

NewConsoleCommand("PrintWeps", function() 
	for k,v in pairs( weapons.GetList() ) do 
		print( v.ClassName )
	end 
end)

NewConsoleCommand("doorId", function() 
	local tr = util.TraceLine( util.GetPlayerTrace( player.GetByID(1) ) )
	if IsValid( tr.Entity ) then print( tr.Entity:doorIndex() ) end
end)

NewConsoleCommand("test1", function() 
	nz.Doors.Functions.CreateMapDoorLink( 1236, "price=500,elec=0,link=1" )
	
	timer.Simple(5, function() nz.Doors.Functions.RemoveMapDoorLink( 1236 ) end)
end)

concommand.Add("nz_forceround", function(ply, cmd, args, argStr)
	if !IsValid(ply) or ply:IsSuperAdmin() then
		local round = args[1] and tonumber(args[1]) or nil
		
		if round then
			nz.Rounds.Data.CurrentRound = round - 1
		end
		nz.Rounds.Functions.PrepareRound()
	end
end)