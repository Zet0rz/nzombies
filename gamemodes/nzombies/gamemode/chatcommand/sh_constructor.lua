-- Chat Commands module
nzChatCommand = nzChatCommand or AddNZModule("chatcommand")

nzChatCommand.commands = nzChatCommand.commands or {}

if CLIENT then
	nzChatCommand.servercommands = nzChatCommand.servercommands or {} -- For autocomplete
end

-- Functions
--[[ 	nzChatCommand.Add
	text [string]: The text you put in chat to trigger this command
	realm [realm]: The realm this command will work in (SERVER/CLIENT)
	func [function]: The function to run when the command is issued. It runs the function with the player as the first argument, then all arguments in the chat seperated by space
	allowAll [boolean]: If set to true, will allow even non-admins to run this command
	--]]

--TODO add more descriptive table indices.
function nzChatCommand.Add(text, realm, func, allowAll, usageHelp)
	if realm or SERVER then -- Always server
		if usageHelp then
			table.insert(nzChatCommand.commands, {text, func, allowAll and true or false, usageHelp})
		else
			table.insert(nzChatCommand.commands, {text, func, allowAll and true or false})
		end
	elseif CLIENT then
		table.insert(nzChatCommand.servercommands, {text, allowAll and true or false, usageHelp})
	end
end

-- Hooks
if SERVER then
	local function commandListenerSV( ply, text, public )
		--print("Here", text, ply)
		if text[1] == "/" then
			text = string.lower(text)
			for k,v in pairs(nzChatCommand.commands) do
				if (string.sub(text, 1, string.len(v[1])) == v[1]) then
					if !v[3] and !ply:IsSuperAdmin() then
						ply:ChatPrint("NZ This command can only be used by administrators.")
						return false
					end

					local args = nzChatCommand.splitCommand(text)
					-- Check if quotionmark usage was valid
					if args then
						-- Remove first arguement (command name) and then call function with the reamianing args
						table.remove(args, 1)
						local block = v[2](ply, args) or false
						print("NZ " .. tostring(ply) .. " used command " .. v[1] .. " with arguments:\n" .. table.ToString(args))
						return block
					else
						ply:ChatPrint("NZ Invalid command usage (check for missing quotes).")
						return false
					end
				end
			end
			ply:ChatPrint("NZ No valid command exists with this name, try '/help' for a list of commands.")
		end
	end
	hook.Add("PlayerSay", "nzChatCommand", commandListenerSV)
	
	-- Receiving net messages from console command nz_chatcommand instead (in case another addon blocks the hook)
	util.AddNetworkString("nzChatCommand")
	net.Receive("nzChatCommand", function(len, ply)
		if !IsValid(ply) then return end
		local command = net.ReadString()
		print("Got command", command)
		commandListenerSV(ply, command)
	end)
end

if CLIENT then
	local function commandListenerCL( ply, text, public, dead )
		if text[1] == "/" then
			text = string.lower(text)
			for k,v in pairs(nzChatCommand.commands) do
				if (string.sub(text, 1, string.len(v[1])) == v[1]) then
					if v[3] and !ply:IsSuperAdmin() then
						return true
					end
					if ply == LocalPlayer() then
						local args = nzChatCommand.splitCommand(text)
						-- Check if quotionmark usage was valid
						if args then
							-- Remove first arguement (command name) and then call function with the reamianing args
							table.remove(args, 1)
							local block = v[2](ply, args) or false
							return block
						else
							ply:ChatPrint("NZ Invalid command usage (check for missing quotes).")
							return false
						end
					end
					return true
				end
			end
		end
	end
	hook.Add("OnPlayerChat", "nzChatCommandClient", commandListenerCL)
	
	-- Console command nz_chatcommand in case another addon blocks the hooks (works just like chat, "nz_chatcommand [chat commands]")
	local function nz_chatcommand(ply, cmd, args, argstr)
		if !argstr then return end
		argstr = string.Trim(argstr, " ") -- Trim spaces
		if string.sub(argstr, 1, 1) == "\"" and string.sub(argstr, #argstr, #argstr) == "\"" then
			argstr = string.sub(argstr, 2, #argstr-1) -- Trim quotation marks but only if they are around the WHOLE string
			-- As to avoid trimming in commmands like /revive "Some Name with Spaces"
		end
		net.Start("nzChatCommand")
			net.WriteString(argstr)
		net.SendToServer()
		commandListenerCL(LocalPlayer(), argstr)
	end
	-- Even comes with autocomplete :D
	local function nz_chatcommand_autocomplete(cmd, argstr)
		argstr = string.Trim( argstr )
		argstr = string.lower( argstr )
		
		local tbl = {}
		
		for _, cmd in pairs(nzChatCommand.servercommands) do
			local cmdText = cmd[1]
			if string.find(cmdText, argstr) then
				if cmd[2] or (!cmd[2] and LocalPlayer():IsSuperAdmin()) then
					local text = "nz_chatcommand ".. cmdText
					if !table.HasValue(tbl, text) then
						table.insert(tbl, text)
					end
				end
			end
		end
		
		for _, cmd in pairs(nzChatCommand.commands) do
			local cmdText = cmd[1]
			if string.find(cmdText, argstr) then
				if cmd[3] or (!cmd[3] and LocalPlayer():IsSuperAdmin()) then
					local text = "nz_chatcommand ".. cmdText
					if !table.HasValue(tbl, text) then
						table.insert(tbl, text)
					end
				end
			end
		end

		return tbl
	end
	concommand.Add("nz_chatcommand", nz_chatcommand, nz_chatcommand_autocomplete, "Executes a chatcommand without the use of chat, in case chatcommands don't work.")	
end

function nzChatCommand.splitCommand(command)
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	local result = {}
	for str in string.gmatch(command, "%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then
			buf = buf .. ' ' .. str
		end
		if not buf then table.insert(result, (str:gsub(spat,""):gsub(epat,""))) end
	end
	if buf then return nil end
	return result
end
