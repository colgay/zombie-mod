#pragma semicolon 1
#pragma ctrlchar '\'

#include <amxmodx>

#define VERSION "0.1"

#include "zombiemod/main.sma"

public plugin_init()
{
	register_plugin("Zombie Mod", VERSION, "holla");
	
	OnPluginInit();
}