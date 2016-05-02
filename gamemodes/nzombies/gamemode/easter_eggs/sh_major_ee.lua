
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

	function nzEE.Major:Win(message)
		if message then
			net.Start("nzMajorEEEndScreen")
				net.WriteString(message)
			net.Broadcast()
		end
		-- Set round state to Game Over
		nzRound:SetState( ROUND_GO )
		--Notify with chat message
		PrintMessage( HUD_PRINTTALK, "GAME OVER!" )
		PrintMessage( HUD_PRINTTALK, "Restarting in 10 seconds!" )
		timer.Simple(10, function()
			nzRound:ResetGame()
		end)

		hook.Call( "OnRoundEnd", nzRound )
	end
	
	function nzEE.Major:Reset()
		nzEE.Major.CurrentStep = 1
	end
	
	function nzEE.Major:Cleanup()
		nzEE.Major.CurrentStep = 1
		nzEE.Major.Steps = {}
	end

end

if CLIENT then

	local function ShowWinText()
		local msg = net.ReadString()
		
		local w = ScrW() / 2
		local h = ScrH() / 2
		local font = "DermaLarge"
		
		hook.Add("HUDPaint", "DrawEEEndScreen", function()
			draw.SimpleText(msg, font, w, h, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if !nzRound:InState( ROUND_GO ) then
				hook.Remove("HUDPaint", "DrawEEEndScreen")
			end
		end)
	end
	net.Receive("nzMajorEEEndScreen", ShowWinText)


end