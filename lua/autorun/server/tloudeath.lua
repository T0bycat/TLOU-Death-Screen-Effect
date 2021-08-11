util.AddNetworkString("TLOUDEATH")

hook.Add( "PlayerDeath", "TLOUDEATH", function( victim, inflictor, attacker )
	net.Start("TLOUDEATH")
	net.Send(victim)
end )