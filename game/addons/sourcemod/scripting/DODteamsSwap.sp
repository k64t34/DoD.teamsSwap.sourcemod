#define noDEBUG 
#define PLUGIN_VERSION "1.5"
#define PLUGIN_NAME "DoD Teams swap"
#define GAME_DOD
#define SND_GONG "k64t\\whistle.mp3" 
//#define MSG1 "It`s time"
#define MSG_Teams_will_be_swapped "Teams will be swapped in"
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
DebugLog("OnPluginStart");
RegServerCmd("teamsSwap",teamsSwap);
#endif 
LoadTranslations("DODteamsSwap.phrases");
char buffer[MAX_FILENAME_LENGHT];
Format(buffer, MAX_FILENAME_LENGHT, /*"download\\*/"sound\\%s",SND_GONG);	
AddFileToDownloadsTable(buffer);
Cvar_teamsSwap = CreateConVar("dod_teamsSwap", "0", "Enables/Disables teams swap <0 to disable | 1 to enable>");
if (Cvar_teamsSwap != null)Cvar_teamsSwap.AddChangeHook(OnCvar_dod_teamsSwap);
Cvar_mp_limitteams =	FindConVar("mp_limitteams");
Cvar_dod_bonusroundtime = FindConVar("dod_bonusroundtime");
}
public void OnPluginEnd(){
	if (Cvar_teamsSwap.IntValue!=0)
	{
		UnhookEvent("dod_round_win", Event_RoundWin);//, EventHookMode_Post);//UnhookEvent("player_team", ChangeTeam, EventHookMode_Pre);
	}
}
public void OnMapStart(){
	#if defined DEBUG
	DebugLog("OnMapStart");
	#endif 
	g_1stChange=0;	
}
public void OnCvar_dod_teamsSwap(ConVar convar, char[] oldValue, char[] newValue){
	if (StringToInt(oldValue)==0 && StringToInt(newValue)!=0)
	{
		HookEvent("dod_round_win", Event_RoundWin, EventHookMode_Post);//HookEvent("player_team", ChangeTeam, EventHookMode_Pre);		
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
		#if defined DEBUG
		DebugLog("Event_RoundWin");
		DebugLog("%t",MSG_Teams_will_be_swapped);
		#endif 
		PrintToChatAll("\x01\x04%t %i seconds",MSG_Teams_will_be_swapped,Cvar_dod_bonusroundtime.IntValue);		
		CreateTimer(float(Cvar_dod_bonusroundtime.IntValue),Delay_teamsSwap,_,TIMER_FLAG_NO_MAPCHANGE);		
	}
}
public  Action Delay_teamsSwap (Handle timer){teamsSwap(0);return Plugin_Stop;}
public  Action teamsSwap (int args){
	#if defined DEBUG
	DebugLog("teamsSwap");
	#endif 
	if (g_1stChange==0)
	{
		LogToGame("Teams swap start");	//Need to some log parser	
		LogToGame("Reverse team start");//Need to some log parser
		g_1stChange++;
	}
	//PrintToChatAll("\x01\x04Teams swap ");
	PrecacheSound(SND_GONG,true);
	EmitSoundToAll(SND_GONG);
	
	int old_mp_limitteams=Cvar_mp_limitteams.IntValue;
	Cvar_mp_limitteams.IntValue=20;
	int team;
	//Event event = CreateEvent("player_changeclass");if (event==INVALID_HANDLE) LogError("CreateEvent(player_changeclass) INVALID_HANDLE"); 
	int class;
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientConnected(i))
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
		
		class=GetDODPlayerClass(i);//ver 1.5
		if (class!=DOD_NoClass)
			{
			Event event = CreateEvent("player_changeclass");
			if (event==INVALID_HANDLE) 
				LogError("CreateEvent(player_changeclass) return INVALID_HANDLE"); 
			else
				{		 			
				event.SetInt("userid",GetClientUserId(i));			
				event.SetInt("class", class);
				event.Fire();			
				}
			}
		}
	}			
	Cvar_mp_limitteams.IntValue=old_mp_limitteams;
	//Swap Team Score	
	int swTeamScore=GetTeamScore(DOD_TEAM_ALLIES);
	SetTeamScore(DOD_TEAM_ALLIES, GetTeamScore(DOD_TEAM_AXIS));
	SetTeamScore(DOD_TEAM_AXIS, swTeamScore);
	swTeamScore=GetTeamRoundsWon(DOD_TEAM_ALLIES);
	SetTeamRoundsWon(DOD_TEAM_ALLIES, GetTeamRoundsWon(DOD_TEAM_AXIS));
	SetTeamRoundsWon(DOD_TEAM_AXIS, swTeamScore);
	return Plugin_Continue;
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
