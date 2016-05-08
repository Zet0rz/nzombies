
if SERVER then

	nzEE.Major.Steps = nzEE.Major.Steps or {}
	nzEE.Major.CurrentStep = nzEE.Major.CurrentStep or 1

	function nzEE.Major:AddStep(func, step)
		if step and tonumber(step) then
			nzEE.Major.Steps[step] = func
		else
			table.insert(nzEE.Major.Steps, func)
		end
	end

	function nzEE.Major:SetCurrentStep(step)
		nzEE.Major.CurrentStep = step
	end

	function nzEE.Major:CompleteStep(step, ...)
		if nzEE.Major.CurrentStep == step then
			if nzEE.Major.Steps[step] then
				print("Completed step "..step)
				local args = {...}
				nzEE.Major.Steps[step](args) -- Varargs passable if you call Complete Step with more stuff
			end
			nzEE.Major.CurrentStep = nzEE.Major.CurrentStep + 1
		end
	end
	
	util.AddNetworkString("nzMajorEEEndScreen")
	
	function nzEE.Major:Reset()
		nzEE.Major.CurrentStep = 1
	end
	
	function nzEE.Major:Cleanup()
		nzEE.Major.CurrentStep = 1
		nzEE.Major.Steps = {}
	end

end

if CLIENT then

	local function ShowWinScreen()
		local win = net.ReadBool()
		local msg = net.ReadString()
		
		local w = ScrW() / 2
		local h = ScrH() / 2
		local font = "DermaLarge"
		
		local time = CurTime()
		local override = GetGlobalVector("endcamerapos", 1)
		if type(override) ~= "number" then
			local endposition = override
			
			hook.Add("CalcView", "nzCalcEndCameraView", function(ply, origin, angles, fov, znear, zfar)
				if !nzRound:InState( ROUND_GO ) then
					hook.Remove("CalcView", "nzCalcEndCameraView")
				end
				
				local delta = math.Clamp((CurTime() - time) * 2, 0, 1)
	 
				local start = endposition * delta + origin * (1 - delta)
				local tr = util.TraceHull({start = start, endpos = start + delta * 64 * Angle(0, CurTime() * 30, 0):Forward(), mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2), filter = player.GetAll(), mask = MASK_SOLID})
				return {origin = tr.HitPos + tr.HitNormal, angles = (start - tr.HitPos):Angle()}
			end)
		end
		
		hook.Add("HUDPaint", "nzDrawEEEndScreen", function()
			draw.SimpleText(msg, font, w, h, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if !nzRound:InState( ROUND_GO ) then
				hook.Remove("HUDPaint", "nzDrawEEEndScreen")
			end
		end)
		
		if win then
			surface.PlaySound(GetGlobalString("winmusic", "nz/easteregg/motd_standard.wav"), 21)
		else
			surface.PlaySound(GetGlobalString("losemusic", "nz/round/game_over_4.mp3"), 21)
		end
	end
	net.Receive("nzMajorEEEndScreen", ShowWinScreen)


end