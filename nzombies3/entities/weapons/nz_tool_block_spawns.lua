SWEP.PrintName	= "Invisible Block Spawn Placer Tool"	
SWEP.Author		= "Alig96"		
SWEP.Slot		= 4	
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		if !IsValid(trace.Entity) or trace.Entity:GetClass() != "wall_block" then
			nz.Mapping.Functions.BlockSpawn(trace.HitPos,Angle(90,(trace.HitPos - self.Owner:GetPos()):Angle()[2] + 90,90), "models/hunter/plates/plate2x2.mdl", self.Owner)
		else
			local hitpos = trace.Entity:WorldToLocal(trace.HitPos)
			local bounds = trace.Entity:GetCollisionBounds()
			local ent = trace.Entity
			if math.abs(hitpos.x) > (math.abs(bounds.x) * 1/5) and math.abs(hitpos.x) < (math.abs(bounds.x) - 1) then
				if self.Owner:KeyDown(IN_SPEED) then
					ent:DecreaseXModel(self.Owner)
				else
					ent:IncreaseXModel(self.Owner)
				end
			end
			if math.abs(hitpos.y) > (math.abs(bounds.y) * 1/5) and math.abs(hitpos.y) < (math.abs(bounds.y) - 1) then
				if self.Owner:KeyDown(IN_SPEED) then
					--[[if ent.CurModelY == ent.CurModelX then
						self.Owner:ChatPrint("Y cannot go lower than X. You will need to rotate the block.")
						return
					end
					if ent.CurModelZ == 0 then
						if ent.CurModelY == 1 then
							self.Owner:ChatPrint("Y can only go lower than 1 if Z is over 0 (it must be a cube)")
							return
						end
					else
						if ent.CurModelY == 0.25 then
							self.Owner:ChatPrint("Y cannot go lower than 0.25")
							return
						end
					end]]
					--self.Owner:ChatPrint("Decreased Y!")
					ent:DecreaseYModel(self.Owner)
				else
					--[[if ent.CurModelY == 8 then
						self.Owner:ChatPrint("Y cannot go higher than 8")
						return
					end]]
					--self.Owner:ChatPrint("Increased Y!")
					ent:IncreaseYModel(self.Owner)
				end
			end
			if math.abs(hitpos.z) > (math.abs(bounds.z) * 1/5) and math.abs(hitpos.z) < (math.abs(bounds.z) - 1) then
				if self.Owner:KeyDown(IN_SPEED) then
					--[[if ent.CurModelZ == 0 then
						self.Owner:ChatPrint("Z cannot go lower than 0")
						return
					elseif ent.CurModelZ == 0.25 then
						if ent.CurModelX < 1 then
							if ent.CurModelY < 1 then
								self.Owner:ChatPrint("Decreased Z to 0, it is now a plate. X and Y snapped to 1.")
							else
								self.Owner:ChatPrint("Decreased Z to 0, it is now a plate. X snapped to 1.")
							end
						elseif ent.CurModelY < 1 then
							self.Owner:ChatPrint("Decreased Z to 0, it is now a plate. Y snapped to 1.")
						else
							self.Owner:ChatPrint("Decreased Z to 0, it is now a plate.")
						end
					end]]
					--self.Owner:ChatPrint("Decreased Z!")
					ent:DecreaseZModel(self.Owner)
				else
					--[[if ent.CurModelZ == 8 then
						self.Owner:ChatPrint("Z cannot go higher than 8")
						return
					elseif ent.CurModelZ == 0 then
						self.Owner:ChatPrint("Increased Z to 0.25. It is now a cube.")
					end]]
					--self.Owner:ChatPrint("Increased Z!")
					ent:IncreaseZModel(self.Owner)
				end
			end
			print(hitpos, bounds)
		end
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "wall_block" then
			trace.Entity:Remove()
		end
	end
end