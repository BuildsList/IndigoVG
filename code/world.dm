/world
	mob = /mob/new_player
	turf = /turf/space
	view = "15x15"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session

#define RECOMMENDED_VERSION 501


/world/New()
	// Honk honk, fuck you science
	populate_seed_list()
	WORLD_X_OFFSET=rand(-50,50)
	WORLD_Y_OFFSET=rand(-50,50)

	// Initialize world events as early as possible.
	on_login = new ()
	on_ban   = new ()
	on_unban = new ()


	/*Runtimes, not sure if i need it still so commenting out for now
	starticon = rotate_icon('icons/obj/lightning.dmi', "lightningstart")
	midicon = rotate_icon('icons/obj/lightning.dmi', "lightning")
	endicon = rotate_icon('icons/obj/lightning.dmi', "lightningend")
	*/

	// logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")

	investigations["hrefs"] = new /datum/log_controller("hrefs", filename="data/logs/[date_string] hrefs.htm", persist=TRUE)

	diary = file("data/logs/[date_string].log")
	diaryofmeanpeople = file("data/logs/[date_string] Attack.log")
	admin_diary = file("data/logs/[date_string] admin only.log")

	var/log_start = "---------------------\n\[[time_stamp()]\]WORLD: starting up..."

	diary << log_start
	diaryofmeanpeople << log_start
	admin_diary << log_start

	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently
/*
 * IF YOU HAVE BYOND VERSION BELOW 507.1248 OR ARE ABLE TO WALK THROUGH WINDOORS/BORDER WINDOWS COMMENT OUT
 * #define BORDER_USE_TURF_EXIT
 * FOR MORE INFORMATION SEE: http://www.byond.com/forum/?post=1666940
 */
	if(byond_version < RECOMMENDED_VERSION)
		world.log << "Your server's byond version does not meet the recommended requirements for this code. Please update BYOND"
/*
#ifdef BORDER_USE_TURF_EXIT
	if(byond_version < 507)
		warning("Your server's byond version does not meet the recommended requirements for this code. Please update BYOND to atleast 507.1248 or comment BORDER_USE_TURF_EXIT in setup.dm")
#endif
*/
	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)

	load_configuration()
	load_mode()
	load_motd()
	load_admins()
	load_mods()
	LoadBansjob()
	if(config.usebwhitelist)
		load_bwhitelist()
	if(config.usewhitelist)
		load_whitelist()
	if(config.usealienwhitelist)
		load_alienwhitelist()
	jobban_loadbanfile()
	jobban_updatelegacybans()
	appearance_loadbanfile()
	LoadBans()
	SetupHooks() // /vg/

	load_library_db_to_cache()

	copy_logs() // Just copy the logs.
	if(config && config.log_runtimes)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD")]-runtime.log")
	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"
	Get_Holiday()	//~Carn, needs to be here when the station is named so :P
	src.update_status()
	makepowernets()
	//sun = new /datum/sun()
	radio_controller = new /datum/controller/radio()
	data_core = new /obj/effect/datacore()
	paiController = new /datum/paiController()
	if(!setup_database_connection())
		world.log << "Your server failed to establish a connection with the database."
	else
		world.log << "Database connection established."
		migration_controller = new
	plmaster = new /obj/effect/overlay()
	plmaster.icon = 'icons/effects/tile_effects.dmi'
	plmaster.icon_state = "plasma"
	plmaster.layer = FLY_LAYER
	plmaster.mouse_opacity = 0
	slmaster = new /obj/effect/overlay()
	slmaster.icon = 'icons/effects/tile_effects.dmi'
	slmaster.icon_state = "sleeping_agent"
	slmaster.layer = FLY_LAYER
	slmaster.mouse_opacity = 0
	src.update_status()
	sleep_offline = 1
	send2mainirc("Server starting up on [config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]")
	processScheduler = new
	master_controller = new /datum/controller/game_controller()
	spawn(1)
		processScheduler.deferSetupFor(/datum/controller/process/ticker)
		processScheduler.setup()
		master_controller.setup()
		setup_species()
	for(var/plugin_type in typesof(/plugin))
		var/plugin/P = new plugin_type()
		plugins[P.name] = P
		P.on_world_loaded()
	process_teleport_locs()				//Sets up the wizard teleport locations
	process_ghost_teleport_locs()		//Sets up ghost teleport locations.
	process_adminbus_teleport_locs()	//Sets up adminbus teleport locations.
//	SortAreas()							//Build the list of all existing areas and sort it alphabetically
	spawn(3000)		//so we aren't adding to the round-start lag
		if(config.ToRban)
			ToRban_autoupdate()
		/*if(config.kick_inactive)
			KickInactiveClients()*/
#undef RECOMMENDED_VERSION
	return ..()
//world/Topic(href, href_list[])
//		world << "Received a Topic() call!"
//		world << "[href]"
//		for(var/a in href_list)
//			world << "[a]"
//		if(href_list["hello"])
//			world << "Hello world!"
//			return "Hello world!"
//		world << "End of Topic() call."
//		..()

/world/Topic(T, addr, master, key)
	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

	else if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		var/n = 0
		var/admins = 0

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admins++
			s["player[n]"] = C.key
			n++
		s["players"] = n

//		if(revdata)	s["revision"] = revdata.revision
		s["admins"] = admins

		return list2params(s)


/world/Reboot(reason)
	if(config.map_voting)
		//testing("we have done a map vote")
		if(fexists(vote.chosen_map))
			//testing("[vote.chosen_map] exists")
			var/start = 1
			var/pos = findtext(vote.chosen_map, "/", start)
			var/lastpos = pos
			//testing("First slash [lastpos]")
			while(pos > 0)
				lastpos = pos
				pos = findtext(vote.chosen_map, "/", start)
				start = pos + 1
				//testing("Next slash [pos]")
			var/filename = copytext(vote.chosen_map, lastpos + 1, 0)
			//testing("Found [filename]")

			if(!fcopy(vote.chosen_map, filename))
				//testing("Fcopy failed, deleting and copying")
				fdel(filename)
				fcopy(vote.chosen_map, filename)
			sleep(60)

	processScheduler.stop()

	spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg','sound/misc/slugmissioncomplete.ogg')) // random end sounds!! - LastyBatsy

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")
		else
			C << link("byond://[world.address]:[world.port]")

	..()


#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	spawn(-1)
		//set background = 1
		while(1)
			sleep(INACTIVITY_KICK)
			for(var/client/C in clients)
				if(C.is_afk(INACTIVITY_KICK))
					if(!istype(C.mob, /mob/dead))
						log_access("AFK: [key_name(C)]")
						C << "<span class='warning'>You have been inactive for more than 10 minutes and have been disconnected.</span>"
						del(C)
//#undef INACTIVITY_KICK


/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			diary << "Saved mode is '[master_mode]'"

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")

/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn

/world/proc/load_mods()
	if(config.admin_legacy_system)
		var/text = file2text("config/moderators.txt")
		if (!text)
			diary << "Failed to load config/mods.txt\n"
		else
			var/list/lines = text2list(text, "\n")
			for(var/line in lines)
				if (!line)
					continue

				if (copytext(line, 1, 2) == ";")
					continue
				var/rights = admin_ranks["Moderator"]
				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins("Moderator", rights, ckey)
				D.associate(directory[ckey])
/world/proc/update_status()
	var/s = ""
	if (config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "
	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\world.dm:235: s += "<b>[station_name()]</b>";
	s += {"<b>[station_name()]</b>"
		(
		<a href=\"http://\">" //Change this to wherever you want the hub to link to
		Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version
		</a>
		)"}
	// END AUTOFIX
	var/list/features = list()

	if(ticker)
		if(master_mode)
			features += master_mode
	else
		features += "<b>STARTING</b>"

	if (!enter_allowed)
		features += "closed"

	features += abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

	if (config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"

	/*
	is there a reason for this? the byond site shows 'hosted by X' when there is a proper host already.
	if (host)
		features += "hosted by <b>[host]</b>"
	*/

	if (!host && config && config.hostedby)
		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [list2text(features, ", ")]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0

proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		world.log << "Database Error: [dbcon.ErrorMsg()]"
		failed_db_connections++		//If it failed, increase the failed connections counter.

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	var/DBQuery/q
	if(dbcon)
		q = dbcon.NewQuery("show global variables like 'wait_timeout'")
		q.Execute()
	if(q.ErrorMsg())
		dbcon.Disconnect()
	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF