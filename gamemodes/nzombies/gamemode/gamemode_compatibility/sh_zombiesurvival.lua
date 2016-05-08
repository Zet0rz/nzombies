function AccessorFuncDT(tab, membername, type, id)
	local emeta = FindMetaTable("Entity")
	local setter = emeta["SetDT"..type]
	local getter = emeta["GetDT"..type]

	tab["Set"..membername] = function(me, val)
		setter(me, id, val)
	end

	tab["Get"..membername] = function(me)
		return getter(me, id)
	end
end

if SERVER then

	util.AddNetworkString("zs_worldhint")
	util.AddNetworkString("zs_centernotify")

	local function WorldHint(hint, pos, ent, lifetime, filter)
		net.Start("zs_worldhint")
			net.WriteString(hint)
			net.WriteVector(pos or ent and ent:IsValid() and ent:GetPos() or vector_origin)
			net.WriteEntity(ent or NULL)
			net.WriteFloat(lifetime or 8)
		if filter then
			net.Send(filter)
		else
			net.Broadcast()
		end
	end
	
	function nz_zsCenterNotifyAll(...)
		local args = {...}
		local msg = ""
		for k,v in pairs(args) do
			local vtype = type(v)
			if vtype == "Player" then
				msg = msg .. v:Nick() .. " "
			elseif vtype == "Entity" then
				msg = msg .. "[".. IsValid(v) and v:GetClass() or "?" .."] "
			elseif vtype == "table" then
				-- nothing
			else
				msg = msg .. tostring(v) .. " "
			end
		end
		net.Start("zs_centernotify")
			net.WriteString(msg)
		net.Broadcast()
	end
	
	function nz_zsCenterNotifyPlayer(ply, ...)
		local args = {...}
		local msg = ""
		for k,v in pairs(args) do
			local vtype = type(v)
			if vtype == "Player" then
				msg = msg .. v:Nick() .. " "
			elseif vtype == "Entity" then
				msg = msg .. "[".. IsValid(v) and v:GetClass() or "?" .."] "
			elseif vtype == "table" then
				-- nothing
			else
				msg = msg .. tostring(v) .. " "
			end
		end
		net.Start("zs_centernotify")
			net.WriteString(msg)
		net.Send(ply)
	end
	
	local meta = FindMetaTable("Entity")
	if meta then
		function meta:AddOnOutput(key, value)
			self[key] = self[key] or {}
			local tab = string.Explode(",", value)
			table.insert(self[key], {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
		end
		
		function meta:FireOutput(outpt, activator, caller, args)
			local intab = self[outpt]
			if intab then
				for key, tab in pairs(intab) do
					for __, subent in pairs(self:FindByNameHammer(tab.entityname, activator, caller)) do
						local delay = tonumber(tab.delay)
						if delay == nil or delay <= 0 then
							subent:Input(tab.input, activator, caller, tab.args)
						else
							local inp = tab.input
							local args = tab.args
							timer.Simple(delay, function() if subent:IsValid() then subent:Input(inp, activator, caller, args) end end)
						end
					end
				end
			end
		end
		
		function meta:FindByNameHammer(name, activator, caller)
			if name == "!self" then return {self} end
			if name == "!activator" then return {activator} end
			if name == "!caller" then return {caller} end
			return ents.FindByName(name)
		end
	end
	
else
	local Hints = {}

	local function DrawPointWorldHints()
		for _, ent in pairs(ents.FindByClass("point_worldhint")) do ent:DrawHint() end
	end

	local function WorldHint(hint, pos, ent, lifetime)
		lifetime = lifetime or 8

		if ent and ent:IsValid() then
			if pos then
				pos = ent:WorldToLocal(pos)
			else
				pos = ent:OBBCenter()
			end
		end

		local hint = {Hint = hint, Pos = pos, Entity = ent, StartTime = CurTime(), EndTime = CurTime() + lifetime}
		table.insert(Hints, hint)

		return hint
	end

	net.Receive("zs_worldhint", function(length)
		WorldHint(net.ReadString(), net.ReadVector(), net.ReadEntity(), net.ReadFloat())
	end)

	local matRing = Material("effects/select_ring")
	local colFG = Color(220, 220, 220, 255)
	function DrawWorldHint(hint, pos, delta, scale)
		local eyepos = EyePos()

		delta = delta or 1

		colFG.a = math.min(220, delta * 220)

		local ang = (eyepos - pos):Angle()
		ang:RotateAroundAxis(ang:Right(), 270)
		ang:RotateAroundAxis(ang:Up(), 90)

		cam.IgnoreZ(true)
		cam.Start3D2D(pos, ang, (scale or 1) * math.max(250, eyepos:Distance(pos)) * delta * 0.0005)

		draw.SimpleText("!", "DermaLarge", 0, 0, colFG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(hint, "DermaLarge", 0, 64, colFG, TEXT_ALIGN_CENTER)

		surface.SetMaterial(matRing)
		for i=1, 4 do
			colFG.a = colFG.a * (1 / i)
			surface.SetDrawColor(colFG)
			local pulse = math.max(0.25, math.abs(math.sin(RealTime() * 6))) * 30 * i
			surface.DrawTexturedRectRotated(0, 0, 128 + pulse, 128 + pulse, 0)
		end

		cam.End3D2D()
		cam.IgnoreZ(false)
	end
	local DrawWorldHint = DrawWorldHint

	local function DrawWorldHints()
		if #Hints > 0 then
			local curtime = CurTime()

			local done = true

			for _, hint in pairs(Hints) do
				local ent = hint.Entity
				if curtime < hint.EndTime and not (ent and not ent:IsValid()) then
					done = false

					DrawWorldHint(hint.Hint, ent and ent:LocalToWorld(hint.Pos) or hint.Pos, math.Clamp(hint.EndTime - curtime, 0, 1))
				end
			end

			if done then
				Hints = {}
			end
		end
	end
	
	hook.Add("PostDrawTranslucentRenderables", "nzDrawZSWorldHints", function()
		DrawPointWorldHints()
		DrawWorldHints()
	end)
	
	net.Receive("zs_centernotify", function(length)
		-- We use the same HUD as the revive notifications
		Revive:CustomNotify(net.ReadString(), 10)
	end)
end