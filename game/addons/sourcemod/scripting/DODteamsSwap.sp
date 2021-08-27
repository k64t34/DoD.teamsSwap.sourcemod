#define noDEBUG 1
#define PLUGIN_VERSION "1.2"
#define PLUGIN_NAME "Knife final"
#define GAME_DOD
//#define SND_GONG "ambient\\bell.wav"
#define SND_GONG "k64t\\knifefinal\\knifefinal.mp3" 
#define MSG1 "Melee"
#include "k64t"
//#include "dodhooks"

enum Slots
{
	Slot_Primary,
	Slot_Secondary,
	Slot_Melee,
	Slot_Grenade
};
// Global Var
//int g_knifeFinal=0; //0 - normal, 1- knife only
int g_iDesiredPlayerClass;
int g_hPlayerRespawn;
int g_iWeaponParent;
Handle g_hGameConfig;
char sndGong[]={SND_GONG};
public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "Kom64t",
    description = "Knife final",
    version = PLUGIN_VERSION,
    url = "https://github.com/k64t34/DoD_knifeFinal.sourcemod"
};
//***********************************************
public void OnPluginStart(){
//***********************************************
#if defined DEBUG
DebugPrint("OnPluginStart");
#endif 
LoadTranslations("knifeFinal.phrases");
RegServerCmd("knifeFinal",knifeFinal);
char buffer[MAX_FILENAME_LENGHT];
Format(buffer, MAX_FILENAME_LENGHT, /*"download\\*/"sound\\%s",SND_GONG);	
AddFileToDownloadsTable(buffer);
//PrecacheSound(sndGong,true);
//AutoExecConfig(true, "knifeFinal");

/*StartPrepSDKCall(SDKCall_Player);
PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Signature, "DODRespawn");
if ((g_hPlayerRespawn = EndPrepSDKCall()) == INVALID_HANDLE)
	{
	SetFailState("Fatal Error: Unable to find signature \"DODRespawn\"!");
	}
if ((g_iDesiredPlayerClass = FindSendPropInfo("CDODPlayer", "m_iDesiredPlayerClass")) == -1)
	{
	SetFailState("Fatal Error: Unable to find offset \"m_iDesiredPlayerClass\"!");
	}	*/
g_iWeaponParent = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");if (g_iWeaponParent == -1)SetFailState("Error - Unable to get offset for CBaseCombatWeapon::m_hOwnerEntity");
}
#if defined DEBUG
//***********************************************
public void OnMapStart(){
//***********************************************
DebugPrint("OnMapStart");
}
#endif 
public void OnMapEnd() {
	#if defined DEBUG
	DebugPrint("OnMapEnd");
	#endif 
	//g_knifeFinal=0;
	UnhookEvent("player_death",	Event_PlayerDeath, EventHookMode_Post);
	UnhookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);	
}
public  Action knifeFinal (int args){
	#if defined DEBUG
	DebugPrint("knifeFinal");
	#endif 
	LogToGame("Knife final start");
	PrecacheSound(SND_GONG,true);
	EmitSoundToAll(SND_GONG);	
	PrintHintTextToAll("%t",MSG1);
	//g_knifeFinal=1;
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
	//TODO: Убрать всё оружие с карты
	//TODO: На время победы в раунде прекратить мнговенное рождение
	//HookEvent("dod_round_win", PlayerRoundWinEvent);
	//public PlayerRoundWinEvent(Handle:event, const String:name[], bool:dontBroadcast) 
	//dod_round_active
	//Note: When the round becomes active after the "frozen" time
	RemoveAllWeapons();
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i))
		if (IsPlayerAlive(i))
		{
			int intBuff=GetClientTeam(i);
			if (intBuff==DOD_TEAM_ALLIES || intBuff==DOD_TEAM_AXIS)			
			if(IsPlayerAlive(i)) 
			RemoveWeaponFromPlayer(i);		
		}
	}		
}
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerDeath");
	#endif 
	//int client=GetClientOfUserId(event.GetInt("userid"));	
	/*if (GetEntData(client, g_iDesiredPlayerClass) != -1)
	{
		SDKCall(g_hPlayerRespawn, client);
	}*/
	//CreateTimer(0.1,Timer_PlayerSpawn,client,TIMER_FLAG_NO_MAPCHANGE);
}
public  Action Timer_PlayerSpawn(Handle timer,int client){
	#if defined DEBUG
	DebugPrint("PlayerSpawn");
	#endif 
	//Event newevent = CreateEvent("player_spawn");
    //if (newevent == null)
    //{
	//	#if defined DEBUG
	//	DebugPrint("PlayerSpawn fail");
	//	#endif 
    //    return Plugin_Stop;		
    //} 
    //newevent.SetInt("userid",GetClientUserId(client) );    
    //newevent.Fire();	
	//DispatchSpawn(client);
	return Plugin_Stop;
}
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
	#if defined DEBUG
	DebugPrint("Event_PlayerSpawn");
	#endif 	
	int client=GetClientOfUserId(event.GetInt("userid"));	
	RemoveWeaponFromPlayer(client);
}
void RemoveWeaponFromPlayer(int client){
	RemoveWeaponBySlot(client, Slot_Grenade);
	RemoveWeaponBySlot(client, Slot_Primary);
	RemoveWeaponBySlot(client, Slot_Secondary);
	RemoveWeaponBySlot(client, Slot_Melee);	
	//TODO:Switch active weapon to Melee
	//Client_SetActiveWeapon(client, GetPlayerWeaponSlot(client, 1)); 
	//https://forums.alliedmods.net/showthread.php?t=225180	
	//SDKHook_WeaponSwitch,
	int team=GetClientTeam(client);
	if (team==DOD_TEAM_ALLIES) GivePlayerItem(client, "weapon_amerknife");	
	else if (team==DOD_TEAM_AXIS) GivePlayerItem(client, "weapon_spade");	
	//Client_SetActiveWeapon(client, GetPlayerWeaponSlot(client, 1)); FROM SMLIB
	//stock Client_SetActiveWeapon(client, weapon)
	//SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", weapon);
	//ChangeEdictState(client, FindDataMapOffs(client, "m_hActiveWeapon"));
}
void RemoveWeaponBySlot(int client, Slots slot){
	int weapon = GetPlayerWeaponSlot( client, slot);	
	if (IsValidEdict(weapon))
	{		
		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");
	}
}
void RemoveAllWeapons(){
	#if defined DEBUG
	DebugPrint("RemoveAllWeapons");
	#endif
	int maxent = GetMaxEntities();
	char weapon[64];
	for (int i=MaxClients;i<maxent;i++)
		{
		if ( IsValidEdict(i) && IsValidEntity(i) && GetEntDataEnt2(i, g_iWeaponParent) == -1 )
			{
			GetEdictClassname(i, weapon, sizeof(weapon));
			if (    StrContains(weapon, "weapon_") != -1                // remove weapons
					|| StrEqual(weapon, "hostage_entity", true)         // remove hostages
					|| StrContains(weapon, "item_") != -1           )   // remove bombs
				{	
					RemoveEdict(i);
				}
		}
	}
}    
#endinput
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//weapon list
//https://github.com/zadroot/GunMenu/blob/master/configs/weapons.ini
//https://github.com/zadroot/GunMenu/blob/master/scripting/dod_gunmenu.sp




bool:IsValidClient(client)
{
	return (1 <= client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > TEAM_SPECTATOR) ? true : false;
}



//"weapon_smoke_us"  "US Smoke Grenade"
//"weapon_smoke_ger" "Stick Smoke Grenade"


// player class
//https://github.com/Bara/PlayerRespawn/blob/master/addons/sourcemod/scripting/include/dodhooks.inc


































//https://github.com/zadroot/RoundEvents_Extended/blob/master/scripting/roundevents_ex.sp
// http://www.theville.org
//
// DESCRIPTION:
// For Day of Defeat Source only
// Swaps Allies and Axis Teams at Round End

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.0.2"
#define DODTeam_Allies	2 
#define DODTeam_Axis	3

new Handle:g_Cvar_BonusRound = INVALID_HANDLE;
new Handle:g_Cvar_Swapteams = INVALID_HANDLE;

new g_teamchange;
new g_rounds;
new g_1stChange;

public Plugin:myinfo = 
{
	name = "DoDs TeamReverse",
	author = "Kom64t",
	description = "Swap teams at round end for Day of Defeat Source",
	version = PLUGIN_VERSION,
	url = "https://github.com/k64t34"
}

public OnPluginStart()
{
	CreateConVar("sm_dod_swapteams_version", PLUGIN_VERSION, "Version of sm_dod_swapteams", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_Cvar_Swapteams = CreateConVar("sm_dod_swapteams", "0", "Enables/Disables sm_dod_swapteams  <0 to disable | # of rounds>", FCVAR_PLUGIN);
	g_Cvar_BonusRound = FindConVar("dod_bonusroundtime");
	g_1stChange=0;
	
	HookEvent("dod_round_win", PlayerRoundWinEvent);
	HookEvent("player_team", ChangeTeam, EventHookMode_Pre);	
}

public OnEventShutdown()
{
	UnhookEvent("dod_round_win", PlayerRoundWinEvent);
	UnhookEvent("player_team", ChangeTeam, EventHookMode_Pre);
}

public PlayerRoundWinEvent(Handle:event, const String:name[], bool:dontBroadcast) 
{
    g_rounds+=1;
    new plugin_rounds=GetConVarInt(g_Cvar_Swapteams); 
    if(plugin_rounds != 0)
    { 
		//Added by psychocoder
        if (plugin_rounds==g_rounds) 
        { 
			if (g_1stChange==0)	
				{
				LogToGame("Reverse team start");
				g_1stChange=1;
				}
            new Float:delay = float(GetConVarInt(g_Cvar_BonusRound)); 
            PrintToChatAll("\x01\x04[SM] Teams will be swapped in %i seconds", GetConVarInt(g_Cvar_BonusRound));
            g_rounds=0; 
            if (delay > 0) 
            { 
                CreateTimer(delay, DelayedSwitch, 0, 0); 
            } 
            else 
            { 
                ChangeTeams(); 
            } 
        }
        else
        {
            PrintToChatAll("\x01\x04[SM] Teams will be swapped in %i round(s)", plugin_rounds-g_rounds);
        }
    } 
}


public Action:ChangeTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_teamchange == 1)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:DelayedSwitch(Handle:timer)
{
	ChangeTeams();
}

public Action:ChangeTeams()
{
	g_teamchange = 1;
	SetConVarInt(FindConVar("mp_limitteams"), 20);
	
	for (new client=1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && (GetClientTeam(client) == 2))
		{
			ChangeClientTeam(client, 1);
			ChangeClientTeam(client, 3);
			ShowVGUIPanel(client, "class_ger", INVALID_HANDLE, false);
		}
		else if (IsClientInGame(client) && (GetClientTeam(client) == 3))
		{
			ChangeClientTeam(client, 1);
			ChangeClientTeam(client, 2);
			ShowVGUIPanel(client, "class_us", INVALID_HANDLE, false);
		}
	}
	//Swap Team Score	
	/*int clTeam=GetTeamScore(DODTeam_Allies);
	SetTeamScore(DODTeam_Allies, GetTeamScore(DODTeam_Axis));
	SetTeamScore(DODTeam_Axis, clTeam);*/
	
	SetConVarInt(FindConVar("mp_limitteams"), 1);
	g_teamchange = 0;
			
	return Plugin_Handled;
}