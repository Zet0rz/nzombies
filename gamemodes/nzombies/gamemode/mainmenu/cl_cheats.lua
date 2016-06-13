local CheatFrame = {}

function CheatFrame:Init()
	self:SetTitle("Cheats")
	self:MakePopup(true)
	self:SetSize( 524, 256 )
	self:SetPos( ScrW() / 2 - 256, ScrH() / 2 - 128 )
	self:SetVisible( true )

	local list = vgui.Create("NZCheatList", self)
	list:Dock(FILL)
	list:SetSize(200,200)
	list:AddCheat("Give Points", "/givepoints", "Player", "Number")
	list:AddCheat("Give Weapon", "/giveweapon", "Player", "Weapon")
	list:AddCheat("Give Perk", "/giveperk", "Player", "Perk")
	list:AddCheat("Activate electricity", "/activateelec")
	list:AddCheat("Revive", "/revive", "Player")
	list:AddCheat("Target Priority", "/targetpriority", "PlayerEntity", "Priority")
end

vgui.Register( "NZCheatFrame", CheatFrame, "DFrame")



local CheatList = {}

function CheatList:AddCheat(label, command, input1, input2, input3)
	local panel = vgui.Create("DPanel", self)
	panel.Paint = function() return end
	local cheatLabel = vgui.Create("DLabel", panel)
	cheatLabel:SetWide(128)
	cheatLabel:SetText(label)

	if input1 then

		input1 = vgui.Create("NZCheatInput" .. input1, panel)
		input1:SetPos(128,0)

		if input2 then

			input2 = vgui.Create("NZCheatInput" .. input2, panel)
			input2:SetPos(256,0)

		end

	end

	local cheatSubmit = vgui.Create("DButton", panel)
	cheatSubmit:SetSize(128, 24)
	cheatSubmit:SetPos(384,0)
	cheatSubmit:SetText("Submit")
	--[[function cheatSubmit:Think()
		if input1 and input1:GetCheatData() and input1:GetCheatData() != "" then
			if input2 and input2:GetCheatData() and input2:GetCheatData() != "" then
				cheatSubmit:SetConsoleCommand("say", command .. " " .. input1:GetCheatData() .. " " .. input2:GetCheatData())
			else
				cheatSubmit:SetConsoleCommand( "say", command .. " " .. input1:GetCheatData() )
			end
		else
			cheatSubmit:SetConsoleCommand("say", command)
		end
	end]]
	cheatSubmit.DoClick = function()
		if input1 and input1:GetCheatData() and input1:GetCheatData() != "" then
			if input2 and input2:GetCheatData() and input2:GetCheatData() != "" then
				RunConsoleCommand("say", command .. " " .. input1:GetCheatData() .. " " .. input2:GetCheatData())
			else
				RunConsoleCommand( "say", command .. " " .. input1:GetCheatData() )
			end
		else
			RunConsoleCommand("say", command)
		end
	end

	self:Add(panel)
end

function CheatList:Paint()
	return
end

vgui.Register( "NZCheatList", CheatList, "DListLayout")



local CheatInputPlayer = {}

AccessorFunc(CheatInputPlayer, "sCheatData", "CheatData", FORCE_STRING)

function CheatInputPlayer:Init()
	self:SetValue("Player")
	self:SetWide(128)
	self:SetTall(24)
	for _,ply in pairs(player.GetAll()) do
		self:AddChoice(ply:Nick())
	end
end

function CheatInputPlayer:OnSelect(index, value, data)
	self:SetCheatData(value)
end

vgui.Register("NZCheatInputPlayer", CheatInputPlayer, "DComboBox")



local CheatInputNumber = {}

AccessorFunc(CheatInputNumber, "fCheatData", "CheatData", FORCE_STRING)

function CheatInputNumber:Init()
	self:SetText("Number")
	self:SetEditable(true)
	self:SetWide(128)
	self:SetTall(24)
end

function CheatInputNumber:Think()
	self:SetCheatData(self:GetText())
end

vgui.Register("NZCheatInputNumber", CheatInputNumber, "DTextEntry")



local CheatInputText = {}

AccessorFunc(CheatInputText, "sCheatData", "CheatData", FORCE_STRING)

function CheatInputText:Init()
	self:SetText("Text")
	self:SetEditable(true)
	self:SetWide(128)
	self:SetTall(24)
end

function CheatInputText:Think()
	self:SetCheatData(self:GetText())
end

vgui.Register("NZCheatInputText", CheatInputText, "DTextEntry")



local CheatInputWeapon = {}

AccessorFunc(CheatInputWeapon, "sCheatData", "CheatData", FORCE_STRING)

function CheatInputWeapon:Init()
	self:SetValue("Weapon")
	self:SetWide(128)
	self:SetTall(24)
	for _,wep in pairs(weapons.GetList()) do
		self:AddChoice(wep.ClassName)
	end
end

function CheatInputWeapon:OnSelect(index, value, data)
	self:SetCheatData(value)
end

vgui.Register("NZCheatInputWeapon", CheatInputWeapon, "DComboBox")



local CheatInputPerk = {}

AccessorFunc(CheatInputPerk, "iCheatData", "CheatData", FORCE_STRING)

function CheatInputPerk:Init()
	self:SetValue("Perk")
	self:SetWide(128)
	self:SetTall(24)
	for id, perk in pairs(nzPerks.Data) do
		self:AddChoice(perk.name, id)
	end
end

function CheatInputPerk:OnSelect(index, value, data)
	self:SetCheatData(data)
end

vgui.Register("NZCheatInputPerk", CheatInputPerk, "DComboBox")

local CheatInputPriority = {}

AccessorFunc(CheatInputPriority, "iCheatData", "CheatData", FORCE_STRING)

function CheatInputPriority:Init()
	self:SetValue("Target")
	self:SetWide(128)
	self:SetTall(24)

	self:AddChoice("None (0)", "0")
	self:AddChoice("Player (1)", "1")
	self:AddChoice("Special (2)", "2")
	self:AddChoice("Max (3)", "3")
	self:AddChoice("Always (10)", "10")
end

function CheatInputPriority:OnSelect(index, value, data)
	self:SetCheatData(data)
end

vgui.Register("NZCheatInputPriority", CheatInputPriority, "DComboBox")


local CheatInputPlayerEntity = {}

AccessorFunc(CheatInputPlayerEntity, "sCheatData", "CheatData", FORCE_STRING)

function CheatInputPlayerEntity:Init()
	self:SetValue("Entity")
	self:SetWide(128)
	self:SetTall(24)
	for _,ply in pairs(player.GetAll()) do
		self:AddChoice(ply:Nick())
	end
	local ent = LocalPlayer():GetEyeTrace().Entity
	if IsValid(ent) then
		self:AddChoice("Entity ["..ent:EntIndex().."] ["..ent:GetClass().."]", "entity("..ent:EntIndex()..")")
	else
		self:AddChoice("Look at an entity to target that.", "")
	end
end

function CheatInputPlayerEntity:OnSelect(index, value, data)
	self:SetCheatData(data or value)
end

vgui.Register("NZCheatInputPlayerEntity", CheatInputPlayerEntity, "DComboBox")
