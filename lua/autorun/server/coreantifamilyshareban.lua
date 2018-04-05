//////////////////////////////////////
//	  Core-AntiFamilyShareBan    	//
//									//
//   	Created by Deis			   	//
//									//
//	  https://core-community.de/	//
//									//
//////////////////////////////////////
local APIKey = "INSERT_STEAM_API_KEY_HERE";//Get the API-KEY from Here https://steamcommunity.com/dev/apikey
local banreason = "Ban-Avoid from "

local function CheckFamilySharingBan(steamid64, ip, sv_password, cl_password, cl_name)
	http.Fetch(
	string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
		APIKey,
		steamid64
	),
	function(body)
		local body = util.JSONToTable(body)
		
		if not body or not body.response or not body.response.lender_steamid then
			error(string.format("CheckFamilySharing: Invalid Steam API response for %s | %s\n", ply:Nick(), ply:SteamID()))
		end
		local lender = body.response.lender_steamid
		if lender ~= "0" then
			local steamid = util.SteamIDFrom64( steamid64 )
			local lsteamid = util.SteamIDFrom64( lender )
			local banned = ULib.bans[ steamid ]
			local lbanned = ULib.bans[ lsteamid ]
			
			if( lbanned ~= nil ) and ( banned == nil ) then
				ULib.addBan(steamid, 0, banreason.." - "..lender, cl_name)
				print("BANNED "..steamid)
				return false, "You've been banned from this server."
			end
		end
	end,

	function(code)
		error(string.format("CheckFamilySharing: Failed API call for %s | %s (Error: %s)\n", cl_name, steamid64, code))
	end
	)
end

hook.Add("CheckPassword", "CheckFamilySharingBan", CheckFamilySharingBan)
