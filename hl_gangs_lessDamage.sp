#pragma semicolon 1

#define PLUGIN_AUTHOR "walde"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <hl_gangs>
#include <autoexecconfig>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "[Gangs] Less Damage Feature", 
	author = PLUGIN_AUTHOR, 
	description = "Features for Gangs in RP", 
	version = PLUGIN_VERSION, 
	url = "https://ggc-base.de"
};

Handle g_hDistance;
float g_fDistance;
char reduceDmgName[64] = "Less Damage when Gangmembers are nearby (min 2)";

public void OnPluginStart()
{
	AutoExecConfig_SetFile("rpg_gangs_lessDamage");
	AutoExecConfig_SetCreateFile(true);
	
	g_hDistance = AutoExecConfig_CreateConVar("gangs_distance", "200.0", "Maximum distance between players to reduce damage");
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
	
	Gangs_RegisterFeature(reduceDmgName, 3, 100, 1.20, true);
	for (int i = 1; i < MAXPLAYERS; i++)
	if (isValidClient(i))
		SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnConfigsExecuted() {
	g_fDistance = GetConVarFloat(g_hDistance);
}

public void OnClientPutInServer(int client) {
	if (isValidClient(client))
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client) {
	if (isValidClient(client))
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &bweapon, float damageForce[3], const float damagePosition[3]) {
	if(!isValidClient(victim))
		return Plugin_Continue;
	if(!isValidClient(attacker))
		return Plugin_Continue;
		
	if (!Gangs_HasGang(victim))
		return Plugin_Continue;
	if (Gangs_getFeatureLevel(victim, reduceDmgName) < 1)
		return Plugin_Continue;
	
	char weaponName[64];
	GetClientWeapon(attacker, weaponName, sizeof(weaponName));
	if (StrContains(weaponName, "knife") != -1)
		return Plugin_Continue;
	
	char gangNameOfVictim[64];
	Gangs_GetGangName(victim, gangNameOfVictim, sizeof(gangNameOfVictim));
	
	float pos[3];
	GetClientAbsOrigin(victim, pos);
	
	int counter = 0;
	for (int i = 0; i < MAXPLAYERS; i++) {
		if (isValidClient(i) && IsPlayerAlive(i)) {
			float tempPos[3];
			GetClientAbsOrigin(i, tempPos);
			
			char tempGangName[64];
			Gangs_GetGangName(i, tempGangName, sizeof(tempGangName));
			if (!StrEqual(gangNameOfVictim, tempGangName, true))
				continue;
			if (GetVectorDistance(pos, tempPos, false) > g_fDistance)
				continue;
			counter++;
		}
	}
	
	if (counter >= 2) {
		PrintToChat(victim, "Damage reduced with Perk lvl %i", Gangs_getFeatureLevel(victim, reduceDmgName));
		if (Gangs_getFeatureLevel(victim, reduceDmgName) == 1) {
			damage *= 0.285;
			return Plugin_Changed;
		} else if (Gangs_getFeatureLevel(victim, reduceDmgName) == 2) {
			damage *= 0.27;
			return Plugin_Changed;
		} else if (Gangs_getFeatureLevel(victim, reduceDmgName) == 3) {
			damage *= 0.24;
			return Plugin_Changed;
		} else if (Gangs_getFeatureLevel(victim, reduceDmgName) == 4) {
			damage *= 0.22;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

stock bool isValidClient(int client) {
	return (1 <= client <= MaxClients && IsClientInGame(client));
} 