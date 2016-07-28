
-- A copy paste of the sandbox one, but only for models

local HasCreated = HasCreated or false

local function GetAllFiles( tab, folder, extension, path )

	local files, folders = file.Find( folder .. "/*", path )

	for k, v in pairs( files ) do

		if ( v:EndsWith( extension ) ) then
			table.insert( tab, (folder .. v):lower() )
		end

	end

	for k, v in pairs( folders ) do
		timer.Simple( k * 0.1, function()
			GetAllFiles( tab, folder .. v .. "/", extension, path )
		end )
	end

	if ( folder == "models/" ) then
		hook.Run( "SearchUpdate" )
	end

end


local model_list = nil
--
-- Model Search
--
if !HasCreated then
	search.AddProvider( function( str )

		str = str:PatternSafe()

		if ( model_list == nil ) then

			model_list = {}
			GetAllFiles( model_list, "models/", ".mdl", "GAME" )
			timer.Simple( 1, function() hook.Run( "SearchUpdate" ) end )

		end

		local list = {}

		for k, v in pairs( model_list ) do

			if ( v:find( str ) ) then

				if ( IsUselessModel( v ) ) then continue end
				
				table.insert( list, v )

			end

			if ( #list >= 128 ) then break end

		end

		return list

	end )
end