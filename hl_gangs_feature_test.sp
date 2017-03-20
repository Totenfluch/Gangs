#pragma semicolon 1

#define PLUGIN_AUTHOR "Totenfluch"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <hl_gangs>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Test feature for HL Gangs", 
	author = PLUGIN_AUTHOR, 
	description = "Test lalilu", 
	version = PLUGIN_VERSION, 
	url = "http://ggc-base.de"
};

public void OnPluginStart() {  }

public void OnMapStart() {
	Gangs_RegisterFeature("Test Feature", 10, 2000, 1.25, false);
}
