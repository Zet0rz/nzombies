AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "player_handler"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Weapons			= {}

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "StartWep" )
	self:NetworkVar( "Int", 0, "StartPoints" )
	self:NetworkVar( "Int", 1, "NumWeps" )
	self:NetworkVar( "String", 1, "EEURL" )
	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Initialize()

	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor(Color(0, 255, 255, 255)) 
	self:DrawShadow( false )
	
end

function ENT:SetData(points, weapon, numweps, eeurl)

	local topreload = false

	if not points then points = 500 end
	if not weapon then weapon = "fas2_m1919" end
	if not numweps then numweps = 2 end
	if not eeurl then eeurl = "" end
	
	if eeurl != self:GetEEURL() then topreload = true end

	self:SetStartPoints(points)
	self:SetStartWep(weapon)
	self:SetNumWeps(numweps)
	self:SetEEURL(eeurl)
	
	if topreload then hook.Call("nz.EE.EasterEggPreload") end

end

if SERVER then 
	util.AddNetworkString("EasterEggSong")
	util.AddNetworkString("EasterEggSongPreload")
	util.AddNetworkString("EasterEggSongStop")

	hook.Add("nz.EE.EasterEgg", "PlayEESong", function()
		net.Start("EasterEggSong")
		net.Broadcast()
	end)
	hook.Add("nz.EE.EasterEggPreload", "PreloadEESong", function()
		net.Start("EasterEggSongPreload")
		net.Broadcast()
	end)
	hook.Add("nz.EE.EasterEggStop", "StopEESong", function()
		net.Start("EasterEggSongStop")
		net.Broadcast()
	end)
	hook.Add("PlayerInitialSpawn", "PreloadEESongSpawn", function(ply)
		net.Start("EasterEggSongPreload")
		net.Send(ply)
	end)
end

if CLIENT then

	EEAudioChannel = nil

	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
	net.Receive("EasterEggSong", function()
		local ent = ents.FindByClass("player_handler")[1]
		if !IsValid(ent) then return end
		ent:PlaySong()
	end)
	
	net.Receive("EasterEggSongPreload", function()
		timer.Simple(1, function()
			local ent = ents.FindByClass("player_handler")[1]
			if !IsValid(ent) then return end
			ent:ParseSong(false)
		end)
	end)
	
	net.Receive("EasterEggSongStop", function()
		local ent = ents.FindByClass("player_handler")[1]
		if !IsValid(ent) then return end
		ent:StopSong()
	end)
	
	function ENT:ParseSong(play)
		local url = string.lower(self:GetEEURL())
		if url == nil or url == "" then return end
		local strstart, strend = string.find( url, "youtube.com/watch" )
		
		if strstart then
			url = string.sub(url, strend + 4)
		else
			local strstart2, strend2 = string.find(url, "youtu.be/")
			if strstart2 then
				url = string.sub(url, strend2 + 1)
			else
				print( "This is not a valid URL! It needs to be a youtube.com/watch?v=ID or youtu.be/ID" )
				return
			end
		end
		http.Fetch( "http://www.youtubeinmp3.com/fetch/?format=JSON&video=http://youtube.com/watch?v="..url,
		function( body, len, headers, code )
			if body == "$$$ERROR$$$" then
				Error( "Failed to fetch song from YouTube!" )
				return
			end

			local tbl = util.JSONToTable(body)
			print("Preloading Easter Egg song ...")
			if !tbl then print("Error loading video URL! Try a different URL format (youtu.be or youtube.com/watch) or a different video.") return end
			if tbl.error then print("Error: "..tbl.error) return end
			PrintTable(tbl)
			if play then self:PlaySong(tbl.link) return end
			self:PreloadSong(tbl.link)
		end, 
		function( error )
			Error( "Failed to fetch song! Error: " .. error )
		end )
	end
	
	function ENT:PlaySong(url)
		//We have a preloaded channel
		if EEAudioChannel then
			EEAudioChannel:Play()
		//We need to instantly play the given link
		elseif url then
			print("Playing!")
			sound.PlayURL( url, "", function(channel) EEAudioChannel = channel end)
		//No link and no preload, parse the link and loopback to above
		else
			self:ParseSong(true)
		end
	end
	
	function ENT:StopSong()
		if EEAudioChannel then
			EEAudioChannel:Stop()
		end
	end
	
	function ENT:PreloadSong(song)
		sound.PlayURL( song, "noplay noblock", function(channel) EEAudioChannel = channel end)
	end
end
