//Main Tables
nz.Path = {}
nz.Path.Functions = {}
nz.Path.Data = {}

function nz.Path.Functions.HasValidPath(start, target)
	print("Beginning")
	local path = Path("Chase")
	path:SetMinLookAheadDistance( 300 )
	path:SetGoalTolerance( 50 )
	print(path)
	
	//Compute a path - return true if it exists
	path:Compute( start, target, function( area, fromArea, ladder, elevator, length )
		print("Computing ...")
		if ( !IsValid( fromArea ) ) then
			print("In same area")
			return true
		else
			if ( !startent.loco:IsAreaTraversable( area ) ) then
				//Our locomotor says we can't move here
				print("Not right")
				return false
			end
				
			//Prevent movement through either locked navareas or areas with closed doors
			if (nz.Nav.Data[area:GetID()]) then
				if nz.Nav.Data[area:GetID()].link then
					if !nz.Doors.Data.OpenedLinks[nz.Nav.Data[area:GetID()].link] then
						print("Behind closed door")
						return false
					end
				elseif nz.Nav.Data[area:GetID()].locked then
					print("Behind locked navmesh")
					return false
				end
			end
			//Check height change
			local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange( area )
			if ( deltaZ >= self.loco:GetStepHeight() ) then
				if ( deltaZ >= self.loco:GetMaxJumpHeight() ) then
					//Too high to reach
					print("Too high")
					return false
				end
			end
			print("Possible!")
			return true
		end
	end)

	print(path)
	return path:IsValid()
end

function nz.Path.Functions.NoValidPlayerPaths(zombie)
	
end

function nz.Path.Functions.GetNearestTeleportPoint(zombie)
	
end

function nz.Path.Functions.ChaseEnemy( start, target )

	local options = options or {}

	local path = Path( "Chase" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 50 )
	
	print(start, target)
	
	//Custom path computer, the same as default but not pathing through locked nav areas.
	path:Compute( start, target, function( area, fromArea, ladder, elevator, length )
		if ( !IsValid( fromArea ) ) then
			return 0
		else
			if ( !self.loco:IsAreaTraversable( area ) ) then
				//Our locomotor says we can't move here
				return -1
			end
				
			//Prevent movement through either locked navareas or areas with closed doors
			if (nz.Nav.Data[area:GetID()]) then
				if nz.Nav.Data[area:GetID()].link then
					if !nz.Doors.Data.OpenedLinks[nz.Nav.Data[area:GetID()].link] then
						return -1
					end
				elseif nz.Nav.Data[area:GetID()].locked then
				return -1 end
			end
			//Compute distance traveled along path so far
			local dist = 0
			if ( IsValid( ladder ) ) then
				dist = ladder:GetLength()
			elseif ( length > 0 ) then
				//Optimization to avoid recomputing length
				dist = length
			else
				dist = ( area:GetCenter() - fromArea:GetCenter() ):GetLength()
			end

			local cost = dist + fromArea:GetCostSoFar()
			//Check height change
			local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange( area )
			if ( deltaZ >= self.loco:GetStepHeight() ) then
				if ( deltaZ >= self.loco:GetMaxJumpHeight() ) then
					//Too high to reach
					return -1
				end
				//Jumping is slower than flat ground
				local jumpPenalty = 5
				cost = cost + jumpPenalty * dist
			end
			return cost
		end
	end)

	if ( !path:IsValid() ) then
		return "failed"
	end

	while ( path:IsValid() and (IsValid(self.target) or (self.HaveEnemy and self:HaveEnemy())) ) do

		//Timeout the pathing so it will rerun the entire behaviour (break barricades etc)
		if ( path:GetAge() > options.maxage ) then
			return "timeout"
		end
		path:Update( self )	-- This function moves the bot along the path

		if ( options.draw ) then path:Draw() end
		-- If we're stuck, then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end

	return "ok"

end