local COLOR_WHITE = Color(255,255,255,255)

local RadarSize = 128 * 2
local PlayerSize = 16 * 2

local BaseX = ScrW()
local BaseY = ScrH() * 0.8

local RadarMat = Material("sprites/radar_trans")
local PlayerMat = Material("sprites/player_blue_small")
local TargetMat = Material("sprites/player_red_small")
local DeadTargetMat = Material("sprites/player_red_dead")

function PRDrawRadar()

	local RadarPosX = ScreenClamp(BaseX,RadarSize,ScrW())
	local RadarPosY = ScreenClamp(BaseY,RadarSize,ScrH())

	PRDrawOverlay(RadarMat,COLOR_WHITE,RadarPosX,RadarPosY,RadarSize,0)
	
	if PRShouldHide(LocalPlayer()) then
		PRDrawOverlay(PlayerMat,COLOR_WHITE,RadarPosX,RadarPosY,PlayerSize,0)
	end
	
	local LocalXYMod = LocalPlayer():GetPos() - Vector(0,0,LocalPlayer():GetPos().z)
	local LocalZMod = LocalPlayer():GetPos() - LocalXYMod
	
	for k,v in pairs(player.GetAll()) do
		if v ~= LocalPlayer() then
		
			local EnemyXYMod = v:GetPos() - Vector(0,0,v:GetPos().z)
			local EnemyZMod = v:GetPos() - EnemyXYMod
			local DistanceMod = LocalXYMod:Distance(EnemyXYMod)
			local HeightMod = (EnemyZMod - LocalZMod).z

			if DistanceMod <= (RadarSize*4.5) + 32 then
			
				local EnemyXYMod = v:GetPos() - Vector(0,0,v:GetPos().z)
				local EnemyZMod = v:GetPos() - EnemyXYMod
				local DistanceMod = LocalXYMod:Distance(EnemyXYMod)
				local HeightMod = (EnemyZMod - LocalZMod).z
			
				if PRShouldHide(v) then
					local FinalPos, FinalAng = WorldToLocal(EnemyXYMod,v:GetAngles(),LocalXYMod,LocalPlayer():GetAngles() + Angle(0,90,0))
					FinalPos = FinalPos * 0.1
					
					local SelectedMat = TargetMat
					
					if v:Alive() == false then
						SelectedMat = DeadTargetMat
					end
					
					PRDrawOverlay(SelectedMat,COLOR_WHITE,RadarPosX - FinalPos.x,RadarPosY + FinalPos.y,math.Clamp(PlayerSize * (1 + HeightMod/500),PlayerSize / 2,PlayerSize*2),0)
				end
				
			end
		end
	end
	
end

hook.Add("HUDPaint","PR: HUDPaint",PRDrawRadar)

function PRShouldHide(ply)
	if (ply:GetVelocity():Length() > 110) or (ply:IsOnGround() == false) or (ply:Alive() == false) then
		return true
	else
		return false
	end
end

function PRDrawOverlay(material,color,x,y,size,rot)
	surface.SetMaterial(material)
	surface.SetDrawColor(color)
	surface.DrawTexturedRectRotated(x,y,size,size,rot)
end

function ScreenClamp(pos,size,screen)

	return math.Clamp(pos,0 + size/2,screen - size/2)

end

print("Updated")