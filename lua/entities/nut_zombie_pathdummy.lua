AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.PrintName = "Zombie Pathfinding Dummy"
ENT.Category = "Dissolution"
ENT.Author = "Chessnut"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()
	self:SetNoDraw(true)
end

function ENT:TestPath(target)
	//Compute a path - return true if it exists
	self.target = target
	return self.validpath
end

function ENT:RunBehaviour()
	while (true) do
		if self.target then
			--print("Beginning")
			self.path = Path("Chase")
			self.path:SetMinLookAheadDistance( 300 )
			self.path:SetGoalTolerance( 50 )
			--print(self.path)
			self.path:Compute( self, self.target, function( area, fromArea, ladder, elevator, length )
				print("Computing ...")
				if ( !IsValid( fromArea ) ) then
					print("In same area")
					self.validpath = true
					return 0
				else
					if ( !startent.loco:IsAreaTraversable( area ) ) then
						//Our locomotor says we can't move here
						print("Not right")
						self.validpath = false
						return -1
					end
						
					//Prevent movement through either locked navareas or areas with closed doors
					if (nz.Nav.Data[area:GetID()]) then
						if nz.Nav.Data[area:GetID()].link then
							if !nz.Doors.Data.OpenedLinks[nz.Nav.Data[area:GetID()].link] then
								print("Behind closed door")
								self.validpath = false
								return -1
							end
						elseif nz.Nav.Data[area:GetID()].locked then
							print("Behind locked navmesh")
							self.validpath = false
							return -1
						end
					end
					//Check height change
					local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange( area )
					if ( deltaZ >= self.loco:GetStepHeight() ) then
						if ( deltaZ >= self.loco:GetMaxJumpHeight() ) then
							//Too high to reach
							print("Too high")
							self.validpath = false
							return -1
						end
					end
					print("Possible!")
					self.validpath = true
					return 0
				end
			end)
		end
		coroutine.yield()
	end
end