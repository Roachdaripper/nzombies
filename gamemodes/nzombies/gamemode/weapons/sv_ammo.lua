-- Functions
function nzWeps:CalculateMaxAmmo(class, pap)
	local wep = weapons.Get(class)
	local clip = wep.Primary.ClipSize
	
	if pap then
		clip = math.Round((clip *1.5)/5)* 5
		return clip * 10 <= 500 and clip * 10 or clip * math.ceil(500/clip) -- Cap the ammo to stop at the clip that passes 500 max
	else
		return clip * 10 <= 300 and clip * 10 or clip * math.ceil(300/clip) -- 300 max for non-pap weapons
	end
end

function nzWeps:GiveMaxAmmoWep(ply, class, papoverwrite)

	for k,v in pairs(ply:GetWeapons()) do
		-- If the weapon entity exist, just give ammo on that
		if v:GetClass() == class then v:GiveMaxAmmo() return end
	end
	
	-- Else we'll have to refer to the old system (for now, this should never happen)
	local wep = weapons.Get(class)
	if !wep then return end
	
	-- Weapons can have their own Max Ammo functions that are run instead
	if wep.NZMaxAmmo then wep:NZMaxAmmo() return end
	
	if !wep.Primary then return end
	
	local ammo_type = wep.Primary.Ammo
	local max_ammo = nzWeps:CalculateMaxAmmo(class, (IsValid(ply:GetWeapon(class)) and ply:GetWeapon(class).pap) or papoverwrite)

	local curr_ammo = ply:GetAmmoCount( ammo_type )
	local give_ammo = max_ammo - curr_ammo
	
	--print(give_ammo)

	-- Just for display, since we're setting their ammo anyway
	ply:GiveAmmo(give_ammo, ammo_type)
	ply:SetAmmo(max_ammo, ammo_type)
	
end

function nzWeps:GiveMaxAmmo(ply)
	for k,v in pairs(ply:GetWeapons()) do
		if !v:IsSpecial() then
			v:GiveMaxAmmo()
		else
			if nzSpecialWeapons.Weapons[v:GetClass()].maxammo then
				nzSpecialWeapons.Weapons[v:GetClass()].maxammo(ply, v)
			end
		end
	end
end

local meta = FindMetaTable("Weapon")

function meta:CalculateMaxAmmo()
	if !self.Primary then return 0 end
	local clip = self.Primary and self.Primary.ClipSize_Orig or self.Primary.ClipSize or nil
	if !clip then return 0 end
	-- When calculated directly on a weapon entity, its clipsize will already have changed from PaP
	if self.pap then
		return clip * 10 <= 500 and clip * 10 or clip * math.ceil(500/clip) -- Cap the ammo to stop at the clip that passes 500 max
	else
		return clip * 10 <= 300 and clip * 10 or clip * math.ceil(300/clip) -- 300 max for non-pap weapons
	end
end

function meta:GiveMaxAmmo()

	if self.NZMaxAmmo then self:NZMaxAmmo() return end

	local ply = self.Owner
	if !IsValid(ply) then return end
	
	local ammo_type = self:GetPrimaryAmmoType() or self.Primary.Ammo
	local max_ammo = self:CalculateMaxAmmo()

	local curr_ammo = ply:GetAmmoCount( ammo_type )
	local give_ammo = max_ammo - curr_ammo

	-- Just for display, since we're setting their ammo anyway
	ply:GiveAmmo(give_ammo, ammo_type)
	ply:SetAmmo(max_ammo, ammo_type)
	
end