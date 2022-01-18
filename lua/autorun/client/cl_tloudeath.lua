local tloudeathblackout = CreateClientConVar("tloudeath_blackouttime", 0.9, true, false, "How much time before the screen blacks out after dying", 0, 100)
local tloudeathsound = CreateClientConVar("tloudeath_deathsound", "", true, false, "What sound to play on death")
local tloudeathpp = CreateClientConVar("tloudeath_postprocess", 1, true, false, "Enable post processing effects?", 0, 1)
local tloudeathdsp = CreateClientConVar("tloudeath_dsp", 1, true, false, "Enable sound DSP on blackout?", 0, 1)
local gmlogo = Material("tloudeath/tloudeathlogo.png", "smooth")
surface.CreateFont( "TLOUDEATH_HINTFONT", {
	font = "DermaLarge",
	extended = false,
	size = ScrW() * 0.03,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

hook.Add( "OnScreenSizeChanged", "TLOUDEATH_RESCHANGETEXTFIX", function( oldWidth, oldHeight ) -- Recreate the font if the resolution changes so it's scaled properly.
	surface.CreateFont( "TLOUDEATH_HINTFONT", {
	font = "DermaLarge",
	extended = false,
	size = ScrW() * 0.03,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
	} )

end )

hook.Add( "HUDShouldDraw", "RemoveThatShit", function( name ) 
    if ( name == "CHudDamageIndicator" ) then 
       return false 
    end
end )

hook.Add("PlayerDeathSound", "RemoveFlatlineSound", function() -- This doesn't seem to work everytime?
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

-- CREATING HINTS 101
--[[
Make sure your hints are short enough to fit on the screen and have a little bit of space (for aesthetics). 70 characters is around the maximum you should aim for.
There is a commented out line in the hook below the hinttable in the death hook that prints the attacker and inflictor. Uncomment it by removing the -- if you're making new hints to get the inflictors easily.
For NPCs, the attacker is usually the same as the inflictor, excluding edge cases like the Zombine's grenade, or the Antlion Worker's spit (which returns nil).
For players, the inflictor should be their weapon, e.g. "weapon_smg1" will be returned if a player killed you with an smg.
The hint used is determined by the inflictor, so use that when adding non-generic hints.
Place generic hints below. A generic hint is displayed when the inflictor doesn't exist in the non-generic hinttable.
--]]
local hinttablegeneric = {
	
	"Don't die.",
	'"Son, always remember - Dying is gay."',
	"Dying is not encouraged by the healthy lifestyle.",
	"Sometimes, I dream about cheese.",
	"Just get good.",
	"You're dead now. Simple as.",
	
}
-- Place non-generic hints below. Can be a string, a table of strings, or a function which returns a string.
local hinttable = {
	
	["npc_zombie"] = 	{
						"Zombies are slow. Use that to your advantage to outmaneuver them.",
						"Luring zombies out in the open can help you deal with them more easily.",
						"Aim for the head.",
						"Sawblades are your friends."

						},
	["npc_fastzombie_torso"] = "Fast zombie torsos attack extremely fast, keep your distance.",
	["npc_fastzombie"] = 	{
							"Fast zombies will always lunge at you when they reach a certain range.",
							"Fast zombies frenzy in place after their close range slash attack."
							},
	["npc_grenade_frag"] = 	{
							"You have 2.5 seconds to run or hide after a grenade is thrown.",
							"Hiding behind a solid wall will negate all explosion damage.",
							"Grenades can be thrown back at their throwers for a instant explosive kill."
							},
	["npc_headcrab"] = 		{
							"One whack of a crowbar can instantly kill a headcrab.",
							"A headcrab is no match for a cinderblock.",
							},
	["player"] = function(dat) 
		if dat.entindex_attacker == LocalPlayer():EntIndex() then
			local suicidehints = {
				"Did you kill yourself?",
				"Bind "..input.LookupBinding("kill", true).." to kill, huh? Not what I'd have picked.",
				"Contact your local killbind prevention hotline. We're here to help.",
				LocalPlayer():Nick().." took the easy way out."
			}
			return suicidehints[math.random(#suicidehints)]
		else
			return hinttablegeneric[math.random(#hinttablegeneric)]
		end
	end,
	
	["npc_antlionguard"] = 	{
							"Try to bait the Antlion Guard into charging into a wall.",
							"Antlion Guards are not affected by bugbait.",
							"An Antlion Guard can easily outrun you in open areas."
							},
	["npc_sniper"] = 	{
						"Combine Snipers can only be killed with explosives.",
						"Snipers will lead their shots. Change directions at the last second.",
						"You have little time to find cover once a Sniper spots you."
						},
	["hunter_flechette"] = "Flechettes explode a few seconds after sticking. Don't stick around.",
	["npc_hunter"] = 	{
						"Hunters can be stunned by baiting them to charge into a wall.",
						"Hunters are more likely to charge if they miss their flechette burst."
						},
	["npc_rollermine"] = 	{
							"Rollermines can be killed by explosives or water.",
							"Rollermines can stick to your car. Get them off with your Gravity Gun."
							},
	["npc_helicopter"] = 	{
							"The helicopter only shoots in bursts, telegraphed by an audible windup.",
							"Use the helicopter burst's downtime to run or to hit it with explosives."
							},
	["npc_strider"] = 	{
						"Striders will miss the first few shots of their burst.",
						"If you hear the Strider's cannon winding up, run.",
						"Striders can be killed with explosives or AR2 balls."
						},
	["npc_metropolice"] = "You failed to pick up the can."
}

gameevent.Listen( "entity_killed" )
hook.Add("entity_killed", "tloudeath_death", function(data)
	if data.entindex_killed == LocalPlayer():EntIndex() then
	local ply = LocalPlayer()
	-- Uncomment to print attacker and inflictor class to console when killed.
	--print(Entity(data.entindex_attacker), Entity(data.entindex_inflictor):GetClass())
	local selectedhint
					
	if !IsValid(Entity(data.entindex_inflictor)) or not hinttable[Entity(data.entindex_inflictor):GetClass()] then
		selectedhint = hinttablegeneric[math.random(#hinttablegeneric)]
	else
		local hintsforent = hinttable[Entity(data.entindex_inflictor):GetClass()]
		if type(hintsforent) == "string" then
			selectedhint = hintsforent
		elseif type(hintsforent) == "table" then
			selectedhint = hintsforent[math.random(#hintsforent)]
		elseif type(hintsforent) == "function" then
			selectedhint = hintsforent(data)
		end
	end
			
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
		local scrw, scrh, start = ScrW(), ScrH(), SysTime()
		local alphalerp
		
		hook.Add("HUDPaint", "TLOUDEATH_HINTS", function()
			alphalerp = Lerp( math.Clamp(SysTime() - start, 0, 1), 0, 255 )
			draw.SimpleText(selectedhint, "TLOUDEATH_HINTFONT", scrw * 0.16, scrh * 0.8, Color(255,255,255, alphalerp ))
			surface.SetMaterial(gmlogo)
			surface.SetDrawColor(Color(255,255,255, alphalerp ))
			surface.DrawTexturedRect(scrw * 0.12, scrh * 0.8, scrw * 0.03, scrw * 0.03)
		end)
	end)
	
	if tloudeathsound:GetString() == "" or not tloudeathsound:GetString() then
		sound.PlayFile( "sound/tloudeath/tloudeath.wav", "", function( station, errCode, errStr )
		end )
	else
		sound.PlayFile( "sound/"..tloudeathsound:GetString(), "", function( station, errCode, errStr )
		end )
	end
	end
end)

gameevent.Listen( "player_spawn" )
hook.Add( "player_spawn", "tloudeath_respawn", function( data ) 
	hook.Remove("CalcView", "TLOUDEATH_CAM")
	hook.Remove("RenderScreenspaceEffects", "TLOUDEATH_PP")
	hook.Remove("HUDPaint", "TLOUDEATH_HINTS")
	timer.Stop("TLOUDEATH_BLACKOUTTIMER")
end )