#include <amxmodx>
#include <amxmisc>

#define PLUGIN_VERSION "2.0"

new g_iSayText
new g_szPage[256]
new const g_szPrefix[] = "!n[!gGametracker!n]"

public plugin_init()
{
	register_plugin("Gametracker: Player Page", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXGametracker", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	
	register_clcmd("say /gt", "CmdOpenGametracker")
	register_clcmd("say_team /gt", "CmdOpenGametracker")
	register_clcmd("say /gtlink", "CmdShowLink")
	register_clcmd("say_team /gtlink", "CmdShowLink")
	register_concmd("amx_gametracker", "CmdPlayerGametracker", ADMIN_ALL, "<nick|#userid> <link/open> -- Get player's Gametracker page")
	
	new szIP[22]
	get_user_ip(0, szIP, charsmax(szIP))
	formatex(g_szPage, charsmax(g_szPage), "http://www.gametracker.com/player/<name>/%s/", szIP)
	g_iSayText = get_user_msgid("SayText")
}

public CmdOpenGametracker(id)
{
	show_gametracker_motd(id, id)
	return PLUGIN_HANDLED
}

public CmdShowLink(id)
{
	new szPage[256]
	get_gametracker_link(id, szPage, charsmax(szPage))
	ColorChat(id, "!nYour !tGametracker page !nis: !g%s", szPage)
	return PLUGIN_HANDLED
}

public CmdPlayerGametracker(id, iLevel, iCid)
{
	if(!cmd_access(id, iLevel, iCid, 3))
		return PLUGIN_HANDLED
	
	new szArg[32]
	read_argv(1, szArg, charsmax(szArg))
	
	new iPlayer = cmd_target(id, szArg, 0)
	
	if(!iPlayer)
		return PLUGIN_HANDLED
		
	new szName[32], szType[5]
	get_user_name(iPlayer, szName, charsmax(szName))
	read_argv(2, szType, charsmax(szType))
	
	switch(szType[0])
	{
		case 'L', 'l':
		{
			new szPage[256]
			get_gametracker_link(iPlayer, szPage, charsmax(szPage))
			client_print(id, print_console, "%s's Gametracker page is: %s", szName, szPage)
		}
		case 'O', 'o': show_gametracker_motd(id, iPlayer)
		default: client_print(id, print_console, "* Unknown type ^"%s^". Please use one of the following: link/open", szType)
	}
	
	return PLUGIN_HANDLED
}
	
show_gametracker_motd(id, iPlayer)
{
	new szPage[256], szHeader[64], szName[32]
	get_gametracker_link(iPlayer, szPage, charsmax(szPage))
	get_user_name(iPlayer, szName, charsmax(szName))
	formatex(szHeader, charsmax(szHeader), "[GT] %s", szName)
	show_motd(id, szPage, szHeader)
}

get_gametracker_link(id, szPage[256], iLen)
{
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	copy(szPage, iLen, g_szPage)
	replace(szPage, iLen, "<name>", szName)
}

ColorChat(const id, const szInput[], any:...)
{
	new iPlayers[32], iCount = 1
	static szMessage[191]
	vformat(szMessage, charsmax(szMessage), szInput, 3)
	format(szMessage[0], charsmax(szMessage), "%s %s", g_szPrefix, szMessage)
	
	replace_all(szMessage, charsmax(szMessage), "!g", "^4")
	replace_all(szMessage, charsmax(szMessage), "!n", "^1")
	replace_all(szMessage, charsmax(szMessage), "!t", "^3")
	
	if(id)
		iPlayers[0] = id
	else
		get_players(iPlayers, iCount, "ch")
	
	for(new i; i < iCount; i++)
	{
		if(is_user_connected(iPlayers[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_iSayText, _, iPlayers[i])
			write_byte(iPlayers[i])
			write_string(szMessage)
			message_end()
		}
	}
}