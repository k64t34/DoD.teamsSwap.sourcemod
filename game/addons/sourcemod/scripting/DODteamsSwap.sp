#define DEBUG 1
#define PLUGIN_VERSION "1.0"
#define PLUGIN_NAME "DoD Teams swap"
#define GAME_DOD
#define SND_GONG "k64t\\knifefinal\\knifefinal.mp3" 
#define MSG1 "It`s time"
#include "k64t"

// Global Var
int g_1stChange=0;

ConVar Cvar_teamsSwap;
ConVar Cvar_mp_limitteams;
ConVar Cvar_dod_bonusroundtime;//Time after round win until round restarts
public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "Kom64t",
    description = "Swap teams at round end for Day of Defeat Source",
    version = PLUGIN_VERSION,
    url = "https://github.com/k64t34/DoD.teamsSwap.sourcemod"
};
//***********************************************
public void OnPluginStart(){
//***********************************************
#if defined DEBUG
DebugPrint("OnPluginStart");
RegServerCmd("teamsSwap",teamsSwap);
#endif 
LoadTranslations("DODteamsSwap.phrases");
//char buffer[MAX_FILENAME_LENGHT];
//Format(buffer, MAX_FILENAME_LENGHT, /*"download\\*/"sound\\%s",SND_GONG);	
//AddFileToDownloadsTable(buffer);
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
Cvar_teamsSwap = CreateConVar("dod_teamsSwap", "0", "Enables/Disables teams swap <0 to disable | # of rounds>");
if (Cvar_teamsSwap != null)Cvar_teamsSwap.AddChangeHook(OnCvar_dod_teamsSwap);
Cvar_mp_limitteams =	FindConVar("mp_limitteams");
Cvar_dod_bonusroundtime = FindConVar("dod_bonusroundtime");
}
public void OnPluginEnd(){
	if (Cvar_teamsSwap.IntValue!=0)
	{
		UnhookEvent("dod_round_win", Event_RoundWin, EventHookMode_Post);
		//UnhookEvent("player_team", ChangeTeam, EventHookMode_Pre);
	}
}
public void OnMapStart(){
	#if defined DEBUG
	DebugPrint("OnMapStart");
	#endif 
	g_1stChange=0;
	//int entScore = FindEntityByClassname(-1, "dod_team_scores");	
	int entScore = GetTeamEntity(DOD_TEAM_AXIS);
	PrintToServer("game_player_team entScore= %d",entScore);
	char s[128];
	GetEntPropString(entScore,Prop_Data,"m_iClassname",s,100,0);//http://world-source.ru/datamaps.txt
	PrintToServer("s= %s",s);	
	int i;
	i=GetEntProp(entScore, Prop_Data, "allies_caps", 4,0);
	PrintToServer("i= %d",i);
	/*"dod_team_scores"
	{
		"allies_caps"	"short"		// how many rounds won by Allies
		"allies_tick"	"short"		// how many tick points Allies have
		"allies_players"	"byte"	// how many players Allies have
		"axis_caps"		"short"		// .. same for Axis.
		"axis_tick"		"short"
		"axis_players"	"byte"
	}*/
}
public void OnCvar_dod_teamsSwap(ConVar convar, char[] oldValue, char[] newValue){
	if (StringToInt(oldValue)==0 && StringToInt(newValue)!=0)
	{
		HookEvent("dod_round_win", Event_RoundWin, EventHookMode_Post);
		//HookEvent("player_team", ChangeTeam, EventHookMode_Pre);		
	}
	else if (StringToInt(oldValue)!=0 && StringToInt(newValue)==0)
	{
		UnhookEvent("dod_round_win", Event_RoundWin, EventHookMode_Post);
	}
}
public void Event_RoundWin(Event event, const char[] name,  bool dontBroadcast){	
	if (Cvar_dod_bonusroundtime.IntValue==0)teamsSwap(0);
	else
	{		
		PrintToChatAll("\x01\x04Teams will be swapped in %i seconds", Cvar_dod_bonusroundtime.IntValue);
		CreateTimer(float(Cvar_dod_bonusroundtime.IntValue),Delay_teamsSwap,_,TIMER_FLAG_NO_MAPCHANGE);		
	}
}
public  Action Delay_teamsSwap (Handle timer){teamsSwap(0);return Plugin_Stop;}
public  Action teamsSwap (int args){
	#if defined DEBUG
	DebugPrint("teamsSwap");
	#endif 
	if (g_1stChange==0)
	{
		LogToGame("Teams swap start");		
		LogToGame("Reverse team start");
		g_1stChange++;
	}
	PrintToChatAll("\x01\x04Teams swap ");
	
	int old_mp_limitteams=Cvar_mp_limitteams.IntValue;
	Cvar_mp_limitteams.IntValue=20;
	int team;
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i))
		{
			team=GetClientTeam(i);
			if (team==DOD_TEAM_ALLIES)
			{
				ChangeClientTeam(i,DOD_TEAM_SPECTATOR);
				ChangeClientTeam(i,DOD_TEAM_AXIS);
				ShowVGUIPanel(i, "class_ger", INVALID_HANDLE, false);
			}
			else if (team==DOD_TEAM_AXIS)
			{
				ChangeClientTeam(i,DOD_TEAM_SPECTATOR);
				ChangeClientTeam(i,DOD_TEAM_ALLIES);		
				ShowVGUIPanel(i, "class_us", INVALID_HANDLE, false);				
			}			
		}
	}			
	Cvar_mp_limitteams.IntValue=old_mp_limitteams;
	//Swap Team Score	
	//int swTeamScore=GetTeamScore(DOD_TEAM_ALLIES);
	//SetTeamScore(DOD_TEAM_ALLIES, GetTeamScore(DOD_TEAM_AXIS));
	//SetTeamScore(DOD_TEAM_AXIS, swTeamScore);
}

#endinput
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
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