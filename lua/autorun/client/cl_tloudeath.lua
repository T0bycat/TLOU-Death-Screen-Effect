local tloudeathblackout = CreateClientConVar("tloudeath_blackouttime", 0.9, true, false, "How much time before the screen blacks out after dying", 0, 100)
local tloudeathsound = CreateClientConVar("tloudeath_deathsound", 1, true, false, "Play the death sound?", 0, 1)
local tloudeathpp = CreateClientConVar("tloudeath_postprocess", 1, true, false, "Enable post processing effects?", 0, 1)
local tloudeathdsp = CreateClientConVar("tloudeath_dsp", 1, true, false, "Enable sound DSP on blackout?", 0, 1)
local tloudeathsoundalt = CreateClientConVar("tloudeath_altsound", 0, true, false, "Enable the Alternate death sound? (Credit to u/GateCages)", 0, 1)

hook.Add( "HUDShouldDraw", "RemoveThatShit", function( name ) 
    if ( name == "CHudDamageIndicator" ) then 
       return false 
    end
end )

hook.Add("PlayerDeathSound", "RemoveFlatlineSound", function()
return true
end)

local function IsOnGround()
		local grtr = util.TraceLine( {
		start = LocalPlayer():EyePos(),
		endpos = LocalPlayer():EyePos() - Vector(0,0,50),
		filter = ply,
	} )
	return grtr.Hit
end 

net.Receive("TLOUDEATH", function()
	local ply = LocalPlayer()
	local randrot = math.Rand(-10,10)
	local lastposfallback = ply:GetPos()
	ply:SetDSP(16)
	
	local tr = util.TraceLine( {
		start = LocalPlayer():EyePos(),
		endpos = LocalPlayer():EyePos() + Vector(math.Rand(-200, 200), math.Rand(-200, 200), math.Rand(0, 20)),
		filter = ply,
	} )
	
	if not IsOnGround() then
	tr = util.TraceLine( {
		start = LocalPlayer():EyePos(),
		endpos = LocalPlayer():EyePos() + Vector(math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(-600, -300)),
		filter = ply,
	} )
	end
	
	local campos = tr.HitPos + Vector(0,0,50)
	
	hook.Add( "CalcView", "TLOUDEATH_CAM", function()
		local ragdoll
		local Ang
		
		if IsValid(ply:GetRagdollEntity()) then
			ragdoll = ply:GetRagdollEntity()
			Ang = ragdoll:GetPos() - campos
			lastposfallback = ragdoll:GetPos()
			else
			ragdoll = ply
			Ang = lastposfallback - campos
		end
		
		local view = {}
		view.origin = campos
		view.angles = Ang:Angle() + Angle(0,0,randrot)
		view.fov = 75 - math.Clamp(campos:DistToSqr(ragdoll:GetPos()) * 0.001, 0, 30)
		view.drawviewer = true
		
		return view
	end)

	if tloudeathpp:GetBool() then
		hook.Add("RenderScreenspaceEffects", "TLOUDEATH_PP", function()
		DrawMotionBlur(0.25, 0.75, 0 )
		end )
	end

	timer.Create("TLOUDEATH_BLACKOUTTIMER", tloudeathblackout:GetFloat(), 1, function()
		ply:ScreenFade(SCREENFADE.STAYOUT, Color( 0, 0, 0, 255 ), 0, 0)
		if tloudeathdsp:GetBool() then
			ply:SetDSP(16)
		end
		hook.Remove("CalcView", "TLOUDEATH_CAM")
		hook.Remove("RenderScreenspaceEffects", "TLOUDEATH_PP")
	end)
	
	if tloudeathsound:GetBool() then
		sound.PlayFile( "sound/tloudeath/tloudeath.wav", "", function( station, errCode, errStr )
		end )
	end

	if tloudeathsoundalt:GetBool() then
		sound.PlayFile( "sound/tloudeath/tloudeathalt.wav", "", function( station, errCode, errStr )
		end )
	end
	
end)

gameevent.Listen( "player_spawn" )
hook.Add( "player_spawn", "tloudeath_respawn", function( data ) 
	hook.Remove("CalcView", "TLOUDEATH_CAM")
	hook.Remove("RenderScreenspaceEffects", "TLOUDEATH_PP")
	timer.Stop("TLOUDEATH_BLACKOUTTIMER")
end )