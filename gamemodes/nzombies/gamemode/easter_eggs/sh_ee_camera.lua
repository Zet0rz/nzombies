
if SERVER then

	-- Scroll down to the functions you can use
	-- This here is so that the server can follow (for PVS etc)

	nzEE.Cam = nzEE.Cam or {}
	util.AddNetworkString("nzEECamera")
	
	local queue = queue or {}
	local nextqueuetime
	local curqueueinsert = 0
	
	local function NextCamQueue()
		local q = queue[1]
		if !q then
			hook.Remove("Think", "nzEECameraThink")
			return
		end
		
		nextqueuetime = RealTime() + q.time
		local time = nextqueuetime
		local camtime = q.time
		
		local startpos = q.startpos
		local endpos = q.endpos
		if startpos and endpos then
			local dir = endpos - startpos
			hook.Add("SetupPlayerVisibility", "nzEndCameraPVS", function( ply )
				local delta = math.Clamp((time-RealTime())/camtime, 0, 1)
				local pos = startpos + dir*delta
				AddOriginToPVS(pos)
				
				if time < RealTime() then
					hook.Remove("SetupPlayerVisibility", "nzEndCameraPVS")
				end
			end)
		end
		
		if q.func then q.func() end
	end
	
	local function StartCamQueue()
		PrintTable(queue)
		local start = queue[1]
		if !start then return end
		
		nextqueuetime = RealTime() + start.time
		NextCamQueue()
		
		hook.Add("Think", "nzEECameraThink", function()
			if RealTime() > nextqueuetime then
				table.remove(queue, 1)
				curqueueinsert = curqueueinsert - 1
				NextCamQueue()
			end
		end)
	end
	
	--[[ Functions in here can be queued clientside by running them along QueueView
	E.g. doing this:
		nzEE.Cam:QueueView(10)
		nzEE.Cam:Text("Hey")
		nzEE.Cam:QueueView(10)
		nzEE.Cam:Text("Hello")
	would display "Hey" for 10 seconds and then "Hello" for 10 seconds after a 10 second queue
	
	If QueueView is called with positional arguements, it will render a moving camera between these positions for this duration
	Each view is transitioned by a fade-to-black. If called without positions, just renders from eyes (can be used to queue)
	
	All other functions run along the previously called QueueView and will be drawn under the fade-to-black
	
	ply is optional and will run the cameras only on that player - Leave it empty for all players (default)
	
	]]
	
	function nzEE.Cam:QueueView(time, pos1, pos2, angle, fade, scoreboard, ply)
		net.Start("nzEECamera")
			net.WriteUInt(0, 2) -- Indicates which function is called
			net.WriteUInt(time, 8) -- Max 255 seconds (waaay too long anyway)
			if pos1 then
				net.WriteBool(true)
				net.WriteVector(pos1)
				if pos2 then
					net.WriteBool(true)
					net.WriteVector(pos2)
				else
					net.WriteBool(false)
				end
				
				if angle then
					net.WriteBool(true)
					net.WriteAngle(angle)
				else
					net.WriteBool(false)
				end
			else
				net.WriteBool(false)
			end
			
			if fade then net.WriteBool(true) else net.WriteBool(false) end
			if scoreboard then net.WriteBool(true) else net.WriteBool(false) end
			
			curqueueinsert = curqueueinsert + 1
			queue[curqueueinsert] = {time = time}
			local q = queue[curqueueinsert]
			if pos1 then
				q.startpos = pos1
				q.endpos = pos2 or pos1
			end
			
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	function nzEE.Cam:Text(msg, ply)
		if !msg then return end
		net.Start("nzEECamera")
			net.WriteUInt(1, 2) -- Text
			net.WriteString(msg)
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	function nzEE.Cam:Music(path, ply)
		if !path then return end
		net.Start("nzEECamera")
			net.WriteUInt(2, 2) -- Music
			net.WriteString(path)
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	function nzEE.Cam:Begin(ply)
		net.Start("nzEECamera")
			net.WriteUInt(3, 2) -- Start
			StartCamQueue() -- Server needs to follow to add PVS' and run functions
		return ply and net.Send(ply) or net.Broadcast()
	end
	
	-- You can use this to set a function to run with this queue
	function nzEE.Cam:Function(func)
		local q = queue[curqueueinsert]
		q.func = func
	end

end

if CLIENT then

	local queue = queue or {}
	local nextqueuetime
	local curqueueinsert = 0
	
	local function FadeCam()
		print("Fading")
		local fade = 0
		local fadeup = true
		hook.Add("HUDPaint", "nzEECameraFade", function()
			fade = fadeup and fade + 255*RealFrameTime() or fade - 255*RealFrameTime()
			if fade > 300 then fadeup = false end
			surface.SetDrawColor(0,0,0,fade)
			surface.DrawRect(0,0,ScrW(),ScrH())
			if fade <= 0 and !fadeup then
				hook.Remove("HUDPaint", "nzEECameraFade")
			end
		end)
	end
	
	local function NextCamQueue()
		local q = queue[1]
		if !q then
			hook.Remove("Think", "nzEECameraThink")
			return
		end
		
		nextqueuetime = RealTime() + q.time
		local time = nextqueuetime
		local camtime = q.time
		
		local startpos = q.startpos
		local endpos = q.endpos
		if startpos and endpos then
			local dir = endpos - startpos
			local ang = q.ang or dir:Angle()
			hook.Add("CalcView", "nzEECamera", function(ply, origin, angles, fov, znear, zfar)
				if time < RealTime() then
					hook.Remove("CalcView", "nzEECamera")
				end
				
				local delta = math.Clamp((time-RealTime())/camtime, 0, 1)
				local pos = endpos - dir*delta
				
				return {origin = pos, angles = ang, drawviewer = true}
			end)
			hook.Add("CalcViewModelView", "nzEECamera", function(wep, vm, oldpos, oldang, pos, ang)
				if time < RealTime() then
					hook.Remove("CalcViewModelView", "nzEECamera")
				end
				
				return oldpos - ang:Forward()*50, ang
			end)
		end
		
		if q.fade then
			local fadestart = nextqueuetime - 1
			hook.Add("Think", "nzEECamera", function()
				if fadestart < RealTime() then
					FadeCam()
					hook.Remove("Think", "nzEECamera")
				end
			end)
		end
		
		local text = q.text
		if text then
			local w = ScrW() / 2
			local h = ScrH() / 2
			local font = "DermaLarge"
			
			hook.Add("HUDPaint", "nzEECamera", function()
				draw.SimpleText(text, font, w, h, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				if time < RealTime() then
					hook.Remove("HUDPaint", "nzEECamera")
				end
			end)
		end
		
		local music = q.music
		if music then
			surface.PlaySound(music)
		end
	end
	
	local function StartCamQueue()
		PrintTable(queue)
		local start = queue[1]
		if !start then return end
		
		nextqueuetime = RealTime() + start.time
		NextCamQueue()
		
		hook.Add("Think", "nzEECameraThink", function()
			if RealTime() > nextqueuetime then
				table.remove(queue, 1)
				curqueueinsert = curqueueinsert - 1
				NextCamQueue()
			end
		end)
	end
	
	local queuefunctions = {
		[0] = function() -- QueueView
			local time = net.ReadUInt(8)
			
			curqueueinsert = curqueueinsert + 1
			queue[curqueueinsert] = {time = time}
			local q = queue[curqueueinsert]
			
			if net.ReadBool() then
				local pos1 = net.ReadVector()
				local pos2 = nil
				
				if net.ReadBool() then
					pos2 = net.ReadVector()
				end
				pos2 = pos2 or pos1
				
				if net.ReadBool() then
					ang = net.ReadAngle()
				else
					ang = (pos2 - pos1):Angle()
				end				
				
				q.startpos = pos1
				q.endpos = pos2
				q.ang = ang
			end
			
			if net.ReadBool() then q.fade = true end
			if net.ReadBool() then q.scoreboard = true end
		end,
		[1] = function() -- Text
			local msg = net.ReadString()
			
			local q = queue[curqueueinsert]
			q.text = msg
		end,
		[2] = function() -- Music
			local path = net.ReadString()
			
			local q = queue[curqueueinsert]
			q.music = path
		end,
		[3] = function() -- Start queue
			StartCamQueue()
		end
	}
	
	local function ReceiveQueuedCam()
		local func = net.ReadUInt(2)
		queuefunctions[func]()
	end
	net.Receive("nzEECamera", ReceiveQueuedCam)
	
	local function ShowWinScreen()
		local easteregg = net.ReadBool()
		local win = net.ReadBool()
		local msg = net.ReadString()
		local camtime = net.ReadFloat()
		local time = CurTime() + camtime
		local endcam = net.ReadBool()
		
		local startpos, endpos
		if endcam then
			startpos = net.ReadVector()
			endpos = net.ReadVector()
		end
		
		local w = ScrW() / 2
		local h = ScrH() / 2
		local font = "DermaLarge"
		
		if endcam and startpos and endpos and time then
			local dir = endpos - startpos
			local ang = dir:Angle()
			hook.Add("CalcView", "nzCalcEndCameraView", function(ply, origin, angles, fov, znear, zfar)
				if time < CurTime() then
					hook.Remove("CalcView", "nzCalcEndCameraView")
				end
				
				local delta = math.Clamp((time-CurTime())/camtime, 0, 1)
				local pos = endpos - dir*delta
				
				return {origin = pos, angles = ang, drawviewer = true}
			end)
			hook.Add("CalcViewModelView", "nzCalcEndCameraView", function(wep, vm, oldpos, oldang, pos, ang)
				if time < CurTime() then
					hook.Remove("CalcViewModelView", "nzCalcEndCameraView")
				end
				
				return oldpos - ang:Forward()*50, ang
			end)
		end
		
		hook.Add("HUDPaint", "nzDrawEEEndScreen", function()
			draw.SimpleText(msg, font, w, h, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if time < CurTime() then
				hook.Remove("HUDPaint", "nzDrawEEEndScreen")
			end
		end)
		
		if easteregg then
			if win then
				surface.PlaySound(GetGlobalString("winmusic", "nz/easteregg/motd_standard.wav"))
			else
				surface.PlaySound(GetGlobalString("losemusic", "nz/round/game_over_4.mp3"))
			end
		end
	end
	net.Receive("nzMajorEEEndScreen", ShowWinScreen)


end