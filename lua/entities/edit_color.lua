
AddCSLuaFile()
DEFINE_BASECLASS( "base_edit" )

ENT.Spawnable			= true
ENT.AdminOnly			= true

ENT.PrintName			= "Color Correction Editor"
ENT.Category			= "Editors"

function ENT:Initialize()

	BaseClass.Initialize( self )

	--self:SetMaterial( Material("gmod/demo.png",  "noclamp smooth") )
	
	-- There can only be one!
	if IsValid(ents.FindByClass("edit_color")[1]) and ents.FindByClass("edit_color")[1] != self then ents.FindByClass("edit_color")[1]:Remove() end

	if ( CLIENT ) then
		hook.Add( "RenderScreenspaceEffects", self, self.DrawColorCorretion )
	end
	
end

function ENT:SetupDataTables()

	self:NetworkVar( "Float",	0, "AddRed", { KeyName = "addred", Edit = { type = "Float", min = -1, max = 1, order = 1 } }  );
	self:NetworkVar( "Float",	1, "AddGreen", { KeyName = "addgreen", Edit = { type = "Float", min = -1, max = 1, order = 2 } }  );
	self:NetworkVar( "Float",	2, "AddBlue", { KeyName = "addblue", Edit = { type = "Float", min = -1, max = 1, order = 3 } }  );
	
	self:NetworkVar( "Float",	3, "Brightness", { KeyName = "brightness", Edit = { type = "Float", min = -2, max = 2, order = 4 } }  );
	self:NetworkVar( "Float",	4, "Contrast", { KeyName = "contrast", Edit = { type = "Float", min = 0, max = 2, order = 5 } }  );
	self:NetworkVar( "Float",	5, "Colour", { KeyName = "colour", Edit = { type = "Float", min = -10, max = 10, order = 6 } }  );
	
	self:NetworkVar( "Float",	6, "MulRed", { KeyName = "mulred", Edit = { type = "Float", min = -1, max = 1, order = 7 } }  );
	self:NetworkVar( "Float",	7, "MulGreen", { KeyName = "mulgreen", Edit = { type = "Float", min = -1, max = 1, order = 8 } }  );
	self:NetworkVar( "Float",	8, "MulBlue", { KeyName = "mulblue", Edit = { type = "Float", min = -1, max = 1, order = 9 } }  );

	--
	-- TODO: Should skybox fog be edited seperately?
	--

	if ( SERVER ) then

		-- defaults
		self:SetAddRed( 0.0 )
		self:SetAddGreen( 0.0 )
		self:SetAddBlue( 0.05 )
		
		self:SetBrightness( 0 )
		self:SetContrast( 1.2 )
		self:SetColour( 2 )
		
		self:SetMulRed( 0 )
		self:SetMulGreen( 0 )
		self:SetMulBlue( 0.02 )

	end

end

function ENT:DrawColorCorretion()
	local tbl = {
		[ "$pp_colour_addr" ] = self:GetAddRed(),
		[ "$pp_colour_addg" ] = self:GetAddGreen(),
		[ "$pp_colour_addb" ] = self:GetAddGreen(),
		[ "$pp_colour_brightness" ] = self:GetBrightness(),
		[ "$pp_colour_contrast" ] = self:GetContrast(),
		[ "$pp_colour_colour" ] = self:GetColour(),
		[ "$pp_colour_mulr" ] = self:GetMulRed(),
		[ "$pp_colour_mulg" ] = self:GetMulGreen(),
		[ "$pp_colour_mulb" ] = self:GetMulBlue()
	}
	
	DrawColorModify(tbl)
end

--
-- This edits something global - so always network - even when not in PVS
--
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
