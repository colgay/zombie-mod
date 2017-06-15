#if defined _MAIN_SMA
	#endinput
#endif
#define _MAIN_SMA

#include "zombiemod/globals.sma"
#include "zombiemod/player.sma"
#include "zombiemod/stocks.sma"

OnPluginInit()
{
	g_maxClients = get_maxplayers();
	
	Player@Init();
}

public client_disconnected(id)
{
	Player@Disconnect(id);
}