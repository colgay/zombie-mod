#if defined _ZOMBIE_SMA
	#endinput
#endif
#define _ZOMBIE_SMA

new bool:g_isZombie[MAX_CLIENTS+1];

OnInfectPlayer(id, attacker)
{
	Zombie@Infect(id);
}

Zombie@Precache()
{
	precache_model("models/v_knife_r.mdl");
}

Zombie@Infect(id)
{
	set_user_health(id, 1000);
	set_pev(id, pev_max_health, 1000.0);
	
	set_user_gravity(id, 0.95);
	rg_set_user_armor(id, 0, ARMOR_NONE);
	
	rg_reset_maxspeed(id);
	
	rg_set_user_model(id, "vip");
	
	rg_remove_all_items(id);
	rg_give_item(id, "weapon_knife");
}

Zombie@Disconnect(id)
{
	g_isZombie[id] = false;
}

stock infectPlayer(id, attacker=0, bool:score=ture, bool:notify=true)
{
	if (score)
	{
		if (is_user_connected(attacker))
		{
			set_user_frags(attacker, get_user_frags(attacker) + 1);
			updateScoreInfo(attacker);
			
			set_member(id, m_iDeaths, get_member(id, m_iDeaths) + 1);
			updateScoreInfo(id);
		}
	}
	
	if (notify && attacker)
	{
		SendDeathMsg(attacker, id, 0, "infection");
		SetScoreAttrib(id, 0);
	}
	
	g_isZombie[id] = true;
	
	cs_set_user_team(id, CS_TEAM_T, 0);
	
	OnInfectPlayer(id, attacker);
}