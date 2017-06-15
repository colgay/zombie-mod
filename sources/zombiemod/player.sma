#if defined _PLAYER_SMA
	#endinput
#endif
#define _PLAYER_SMA

#include "zombiemod/item.sma"
#include "zombiemod/inventory.sma"

Player@Init()
{
	Item@Init();
	Inventory@Init();
}

Player@Disconnect(id)
{
	Inventory@Disconnect(id);
}