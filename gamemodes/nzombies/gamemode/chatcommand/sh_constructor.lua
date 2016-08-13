-- Chat Commands module
chatcommand = {}

chatcommand.commands = {}

-- Functions
--[[ 	chatcommand.Add
	text [string]: The text you put in chat to trigger this command
	func [function]: The function to run when the command is issued. It runs the function with the player as the first argument, then all arguments in the chat seperated by space
	allowAll [boolean]: If set to true, will allow even non-admins to run this command
	--]]

--TODO add more descriptive table indices.
function chatcommand.Add(text, func, allowAll, usageHelp)
	if usageHelp then
		table.insert(chatcommand.commands, {text, func, allowAll and true or false, usageHelp})
	else
		table.insert(chatcommand.commands, {text, func, allowAll and true or false})
	end
end

-- Hooks
if SERVER then
	local function commandListenerSV( ply, text, public )
		if text[1] == "/" then
			text = string.lower(text)
			for k,v in pairs(chatcommand.commands) do
				if (string.sub(text, 1, string.len(v[1])) == v[1]) then
					if !v[3] and !ply:IsSuperAdmin() then
						ply:ChatPrint("NZ This command can only be used by administrators.")
						return false
					end

					local args = chatcommand.splitCommand(text)
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
end

if CLIENT then
	local function commandListenerCL( ply, text, public, dead )
		if text[1] == "/" then
			text = string.lower(text)
			for k,v in pairs(chatcommand.commands) do
				if (string.sub(text, 1, string.len(v[1])) == v[1]) then
					if v[3] and !ply:IsSuperAdmin() then
						return true
					end
					if ply == LocalPlayer() then
						local args = chatcommand.splitCommand(text)
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
end

function chatcommand.splitCommand(command)
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
