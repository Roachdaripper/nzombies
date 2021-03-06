AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "pap_weapon_trigger"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "WepClass")

end

function ENT:Initialize()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_OBB )
	self:SetModel("models/hunter/blocks/cube05x1x025.mdl")
	self:DrawShadow(false)

	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:Use( activator, caller )
	if activator == self.Owner then
		local class = self:GetWepClass()
		local weapon = activator:Give(class)
		if !self.RerollingAtts then -- A 2000 point reroll should not give max ammo
			nzWeps:GiveMaxAmmoWep(activator, class, true) -- We give pap ammo count
		end
		timer.Simple(0, function()
			if IsValid(weapon) and IsValid(activator) then
				if activator:HasPerk("speed") and weapon:IsFAS2() then
					weapon:ApplyNZModifier("speed")
				end
				if (activator:HasPerk("dtap") or activator:HasPerk("dtap2")) and weapon:IsFAS2()  then
					weapon:ApplyNZModifier("dtap")
				end
				weapon:ApplyNZModifier("pap")
				if IsValid(self.wep) then
					self.wep.machine:SetBeingUsed(false)
					self.wep:Remove()
				end
			end
			self:Remove()
		end)
	else
		if IsValid(self.Owner) then
			activator:PrintMessage( HUD_PRINTTALK, "This is " .. self.PapOwner:Nick() .. "'s gun. You cannot take it." )
		end
	end
end

if CLIENT then
	function ENT:Draw()
		return
	end
end
