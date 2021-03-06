	////////////
	//SECURITY//
	////////////
#define TOPIC_SPAM_DELAY	2		//2 ticks is about 2/10ths of a second; it was 4 ticks, but that caused too many clicks to be lost due to lag
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?
#define MIN_CLIENT_VERSION	0		//Just an ambiguously low version for now, I don't want to suddenly stop people playing.
									//I would just like the code ready should it ever need to be used.
	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client/Topic(href, href_list, hsrc)
	//var/timestart = world.timeofday
	//testing("topic call for [usr] [href]")
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	//Reduces spamming of links by dropping calls that happen during the delay period
//	if(next_allowed_topic_time > world.time)
//		return
	//next_allowed_topic_time = world.time + TOPIC_SPAM_DELAY

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		world.log << "Attempted use of scripts within a topic call, by [src]"
		message_admins("Attempted use of scripts within a topic call, by [src]")
		//del(usr)
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		cmd_admin_pm(C,null)
		return

	//Logs all hrefs
	if(config && config.log_hrefs && investigations[I_HREFS])
		var/datum/log_controller/I = investigations[I_HREFS]
		I.write("<small>[time2text(world.timeofday,"hh:mm")] [src] (usr:[usr])</small> || [hsrc ? "[hsrc] " : ""][href]<br />")

	switch(href_list["_src_"])
		if("holder")	hsrc = holder
		if("usr")		hsrc = mob
		if("prefs")		return prefs.process_link(usr,href_list)
		if("vars")		return view_var_Topic(href,href_list,hsrc)

	..()	//redirect to hsrc.Topic()
	//testing("[usr] topic call took [(world.timeofday - timestart)/10] seconds")

/client/proc/handle_spam_prevention(var/message, var/mute_type)
	if(config.automute_on && !holder && src.last_message == message)
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			src << "<span class='warning'>You have exceeded the spam filter limit for identical messages. An auto-mute was applied.</span>"
			cmd_admin_mute(src.mob, mute_type, 1)
			return 1
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			src << "<span class='warning'>You are nearing the spam filter limit for identical messages.</span>"
			return 0
	else
		last_message = message
		src.last_message_count = 0
		return 0

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		src << "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>"
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		src << "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>"
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	if(config)
		winset(src, null, "outputwindow.output.style=[config.world_style_config];")
		winset(src, null, "window1.msay_output.style=[config.world_style_config];") // it isn't possible to set two window elements in the same winset so we need to call it for each element we're assigning a stylesheet.
	else
		src << "<span class='warning'>The stylesheet wasn't properly setup call an administrator to reload the stylesheet or relog.</span>"
	TopicData = null							//Prevent calls to client.Topic from connect

	if(connection != "seeker")					//Invalid connection type.
		return null
	if(byond_version < MIN_CLIENT_VERSION)		//Out of date client.
		return null

	if(IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		del(src)
		return

	// Change the way they should download resources.
	if(config.resource_urls)
		src.preload_rsc = pick(config.resource_urls)
	else src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	src << "<span class='warning'>If the title screen is black, resources are still downloading. Please be patient until the title screen appears.</span>"

	clients += src
	directory[ckey] = src

	//Admin Authorisation
	holder = admin_datums[ckey]
	if(holder)
		admins += src
		holder.owner = src

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(!prefs)
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning

	. = ..()	//calls mob.Login()

	if(custom_event_msg && custom_event_msg != "")
		src << "<h1 class='alert'>Custom Event</h1>"
		src << "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>"
		src << "<span class='alert'>[rhtml_encode(custom_event_msg)]</span>"
		src << "<br>"

	if( (world.address == address || !address) && !host )
		host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		admin_memo_show()

	log_client_to_db()

	send_resources()

	if(prefs.lastchangelog != changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		winset(src, "rpane.changelog", "background-color=#eaeaea;font-style=bold")
		prefs.SetChangelog(ckey,changelog_hash)
		src << "<span class='info'>Changelog has changed since your last visit.</span>"

	//Set map label to correct map name
	winset(src, "rpane.map", "text=\"[map.nameLong]\"")

	// Notify scanners.
	INVOKE_EVENT(on_login,list(
		"client"=src,
		"admin"=(holder!=null)
	))

	//////////////
	//DISCONNECT//
	//////////////
/client/Del()
	if(holder)
		holder.owner = null
		admins -= src
	directory -= ckey
	clients -= src
	return ..()

/client/proc/log_client_to_db()
	if(IsGuestKey(key))
		return

	establish_db_connection()

	if(!dbcon.IsConnected())
		return

	var/sql_ckey = sanitizeSQL(ckey)
	testing("sql_ckey = [sql_ckey]")
	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()
	var/sql_id = 0
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		break

	var/sql_address = sanitizeSQL(address)

	var/DBQuery/query_ip = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE ip = '[sql_address]'")
	query_ip.Execute()
	related_accounts_ip = ""
	while(query_ip.NextRow())
		related_accounts_ip += "[query_ip.item[1]], "
		break

	var/sql_computerid = sanitizeSQL(computer_id)

	var/DBQuery/query_cid = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE computerid = '[sql_computerid]'")
	query_cid.Execute()
	related_accounts_cid = ""
	while(query_cid.NextRow())
		related_accounts_cid += "[query_cid.item[1]], "
		break

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/admin_rank = "Player"

	if(istype(holder))
		admin_rank = holder.rank

	var/sql_admin_rank = sanitizeSQL(admin_rank)

	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update = dbcon.NewQuery("UPDATE erro_player SET lastseen = Now(), ip = '[sql_address]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		query_update.Execute()
	else
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO erro_player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_address]', '[sql_computerid]', '[sql_admin_rank]')")
		query_insert.Execute()

	// logging player access
	var/server_address_port = "[world.internet_address]:[world.port]"
	var/sql_server_address_port = sanitizeSQL(server_address_port)
	var/DBQuery/query_connection_log = dbcon.NewQuery("INSERT INTO `erro_connection_log`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[sql_server_address_port]','[sql_ckey]','[sql_address]','[sql_computerid]');")

	query_connection_log.Execute()


/client/proc/GetHighJob()
	if(src.prefs.job_civilian_low & ASSISTANT)//This gives the preview icon clothes depending on which job(if any) is set to 'high'
		work_chosen = "Assistant"
	if(src.prefs.job_civilian_high)
		switch(src.prefs.job_civilian_high)
			if(HOP)
				work_chosen = "Head of Personnel"
			if(BARTENDER)
				work_chosen = "Bartender"
			if(BOTANIST)
				work_chosen = "Botanist"
			if(CHEF)
				work_chosen = "Chef"
			if(JANITOR)
				work_chosen = "Janitor"
			if(LIBRARIAN)
				work_chosen = "Librarian"
			if(QUARTERMASTER)
				work_chosen = "Quartermaster"
			if(CARGOTECH)
				work_chosen = "Cargotech"
			if(MINER)
				work_chosen = "Miner"
			if(LAWYER)
				work_chosen = "Lewyer"
			if(CHAPLAIN)
				work_chosen = "Chaplain"
			if(CLOWN)
				work_chosen = "Clown"
			if(MIME)
				work_chosen = "Mime"
	else if(src.prefs.job_medsci_high)
		switch(src.prefs.job_medsci_high)
			if(RD)
				work_chosen = "Research Director"
			if(SCIENTIST)
				work_chosen = "Scientist"
			if(CHEMIST)
				work_chosen = "Chemist"
			if(CMO)
				work_chosen = "Chief Medical Officer"
			if(DOCTOR)
				work_chosen = "Medical Doctor"
			if(PARAMEDIC)
				work_chosen = "Paramedic"
			if(GENETICIST)
				work_chosen = "Geneticist"
			if(VIROLOGIST)
				work_chosen = "Virologist"
//			if(PSYHIATRIST)
//				work_chosen = "Psyhyatrist"
			if(ROBOTICIST)
				work_chosen = "Roboticist"
	else if(src.prefs.job_engsec_high)
		switch(src.prefs.job_engsec_high)
			if(CAPTAIN)
				work_chosen = "Captain"
			if(HOS)
				work_chosen = "Head of Security"
			if(WARDEN)
				work_chosen = "Warden"
			if(DETECTIVE)
				work_chosen = "Detective"
			if(OFFICER)
				work_chosen = "Security Officer"
			if(CHIEF)
				work_chosen = "Chief Engineer"
			if(ENGINEER)
				work_chosen = "Station Engineer"
			if(MECHANIC)
				work_chosen = "Mechanic"
			if(ATMOSTECH)
				work_chosen = "Atmospheric Technician"
			if(AI)
				work_chosen = "AI"
			if(CYBORG)
				work_chosen = "Cyborg"
	else
		work_chosen = "Random"


#undef TOPIC_SPAM_DELAY
#undef UPLOAD_LIMIT
#undef MIN_CLIENT_VERSION

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration=3000)
	if(inactivity > duration)	return inactivity
	return 0

/client/verb/resend_resources()
	set name = "Resend Resources"
	set desc = "Re-send resources for NanoUI. May help those with NanoUI issues."
	set category = "Preferences"

	usr << "\blue Re-sending NanoUI resources.  This may result in lag."
	nanomanager.send_resources(src)

//send resources to the client. It's here in its own proc so we can move it around easiliy if need be
/client/proc/send_resources()
//	preload_vox() //Causes long delays with initial start window and subsequent windows when first logged in.

	spawn
		// Preload the HTML interface. This needs to be done due to BYOND bug http://www.byond.com/forum/?post=1487244 (hidden issue)
		// "browse_rsc() sometimes failed when an attempt was made to check on the status of a the file before it had finished downloading. This problem appeared only in threaded mode."
		var/datum/html_interface/hi
		for (var/type in typesof(/datum/html_interface))
			hi = new type(null)
			hi.sendResources(src)

	// Send NanoUI resources to this client
	nanomanager.send_resources(src)

	getFiles(
		'nano/images/uiBackground.png',
		'nano/mapbase1024.png',
		'nano/NTLogoRevised.fla',
		'nano/uiBackground.fla',
		'nano/images/source/icon-eye.xcf',
		'nano/images/source/NTLogoRevised.fla',
		'nano/images/source/uiBackground.fla',
		'nano/images/source/uiBackground.xcf',
		'nano/images/source/uiBackground-Syndicate.xcf',
		'nano/images/source/uiBasicBackground.xcf',
		'nano/images/source/uiIcons16Green.xcf',
		'nano/images/source/uiIcons16Red.xcf',
		'nano/images/source/uiIcons24.xcf',
		'nano/images/source/uiNoticeBackground.xcf',
		'nano/images/source/uiTitleBackground.xcf',
		'nano/images/icon-eye.xcf',
		'nano/images/uiBackground.png',
		'nano/images/uiBackground.xcf',
		'nano/images/uiBackground-Syndicate.xcf',
		'nano/images/uiBasicBackground.png',
		'nano/images/nanomapBackground.png',
		'nano/images/uiBackground-Syndicate.png',
		'nano/images/uiIcons16.png',
		'nano/images/uiIcons16Green.png',
		'nano/images/uiIcons16Red.png',
		'nano/images/uiIcons16Orange.png',
		'nano/images/uiIcons24.png',
		'nano/images/uiIcons24.xcf',
		'nano/images/uiLinkPendingIcon.gif',
		'nano/images/uiMaskBackground.png',
		'nano/images/uiNoticeBackground.jpg',
		'nano/images/uiTitleFluff.png',
		'nano/images/uiTitleFluff-Syndicate.png',
		'nano/templates/apc.tmpl',
		'nano/templates/advanced_airlock_console.tmpl',
		'nano/templates/ame.tmpl',
		'nano/templates/accounts_terminal.tmpl',
		'nano/templates/atmos_control.tmpl',
		'nano/templates/atmos_control_map_content.tmpl',
		'nano/templates/atmos_control_map_header.tmpl',
		'nano/templates/comm_console.tmpl',
		'nano/templates/door_access_console.tmpl',
		'nano/templates/layout_default.tmpl',
		'nano/templates/simple_airlock_console.tmpl',
		'nano/templates/TemplatesGuide.txt',
		'nano/templates/disease_splicer.tmpl',
		'nano/templates/dish_incubator.tmpl',
		'nano/templates/docking_airlock_console.tmpl',
		'nano/templates/engines_control.tmpl',
		'nano/templates/escape_pod_berth_console.tmpl',
		'nano/templates/escape_pod_console.tmpl',
		'nano/templates/exofab.tmpl',
		'nano/templates/air_alarm.tmpl',
		'nano/templates/rev-engine.tmpl',
		'nano/templates/podfab.tmpl',
		'nano/templates/atmos_control.tmpl',
		'nano/templates/atmos_control_map_header.tmpl',
		'nano/templates/atmos_control_map_content.tmpl',
		'nano/templates/crew_monitor.tmpl',
		'nano/templates/crew_monitor_map_content.tmpl',
		'nano/templates/crew_monitor_map_header.tmpl',
		'nano/templates/canister.tmpl',
		'nano/templates/chem_dispenser.tmpl',
		'nano/templates/crew_monitor.tmpl',
		'nano/templates/cryo.tmpl',
		'nano/templates/dna_modifier.tmpl',
		'nano/templates/geoscanner.tmpl',
		'nano/templates/identification_computer.tmpl',
		'nano/templates/pda.tmpl',
		'nano/templates/pda_terminal.tmpl',
		'nano/templates/smes.tmpl',
		'nano/templates/tanks.tmpl',
		'nano/templates/flatpacker.tmpl',
		'nano/templates/telescience_console.tmpl',
		'nano/templates/transfer_valve.tmpl',
		'nano/templates/uplink.tmpl',
		'nano/js/libraries/1-jquery.js',
		'nano/js/libraries.min.js',
		'nano/js/libraries/2-doT.js',
		'nano/js/libraries/3-jquery.timers.js',
		'nano/js/nano_template.js',
		'nano/js/nano_base_helpers.js',
		'nano/js/nano_update.js',
		'nano/js/nano_utility.js',
		'nano/js/nano_base_callbacks.js',
		'nano/js/nano_state.js',
		'nano/js/nano_state_manager.js',
		'nano/js/nano_state_default.js',
		'nano/css/layout_basic.css',
		'nano/css/nlayout_default.css',
		'nano/css/layout_default.css',
		'nano/css/icons.css',
		'nano/css/shared.css',
		'html/search.js',
		'html/panels.css',
		'icons/pda_icons/pda_atmos.png',
		'icons/pda_icons/pda_back.png',
		'icons/pda_icons/pda_bell.png',
		'icons/pda_icons/pda_blank.png',
		'icons/pda_icons/pda_boom.png',
		'icons/pda_icons/pda_bucket.png',
		'icons/pda_icons/pda_crate.png',
		'icons/pda_icons/pda_cuffs.png',
		'icons/pda_icons/pda_eject.png',
		'icons/pda_icons/pda_exit.png',
		'icons/pda_icons/pda_flashlight.png',
		'icons/pda_icons/pda_honk.png',
		'icons/pda_icons/pda_mail.png',
		'icons/pda_icons/pda_medical.png',
		'icons/pda_icons/pda_menu.png',
		'icons/pda_icons/pda_mule.png',
		'icons/pda_icons/pda_notes.png',
		'icons/pda_icons/pda_power.png',
		'icons/pda_icons/pda_rdoor.png',
		'icons/pda_icons/pda_alert.png',
		'icons/pda_icons/pda_reagent.png',
		'icons/pda_icons/pda_refresh.png',
		'icons/pda_icons/pda_scanner.png',
		'icons/pda_icons/pda_signaler.png',
		'icons/pda_icons/pda_status.png',
		'icons/pda_icons/pda_clock.png',
		'icons/pda_icons/pda_minimap_box.png',
		'icons/pda_icons/pda_minimap_bg_notfound.png',
		'icons/pda_icons/pda_minimap_deff.png',
		'icons/pda_icons/pda_minimap_taxi.png',
		'icons/pda_icons/pda_minimap_meta.png',
		'icons/pda_icons/pda_minimap_loc.gif',
		'icons/pda_icons/pda_minimap_mkr.gif',
		'icons/spideros_icons/sos_1.png',
		'icons/spideros_icons/sos_2.png',
		'icons/spideros_icons/sos_3.png',
		'icons/spideros_icons/sos_4.png',
		'icons/spideros_icons/sos_5.png',
		'icons/spideros_icons/sos_6.png',
		'icons/spideros_icons/sos_7.png',
		'icons/spideros_icons/sos_8.png',
		'icons/spideros_icons/sos_9.png',
		'icons/spideros_icons/sos_10.png',
		'icons/spideros_icons/sos_11.png',
		'icons/spideros_icons/sos_12.png',
		'icons/spideros_icons/sos_13.png',
		'icons/spideros_icons/sos_14.png',
		'icons/xenoarch_icons/chart1.jpg',
		'icons/xenoarch_icons/chart2.jpg',
		'icons/xenoarch_icons/chart3.jpg',
		'icons/xenoarch_icons/chart4.jpg'
		)


/proc/get_role_desire_str(var/rolepref)
	switch(rolepref & ROLEPREF_VALMASK)
		if(ROLEPREF_NEVER)
			return "Never"
		if(ROLEPREF_NO)
			return "No"
		if(ROLEPREF_YES)
			return "Yes"
		if(ROLEPREF_ALWAYS)
			return "Always"
	return "???"

/client/proc/desires_role(var/role_id, var/display_to_user=0)
	var/role_desired = prefs.roles[role_id]
	if(display_to_user && !(role_desired & ROLEPREF_PERSIST))
		if(!(role_desired & ROLEPREF_POLLED))
			spawn
				var/answer = alert(src,"[display_to_user]\n\nNOTE:  You will only be polled about this role once per round. To change your choice, use Preferences > Setup Special Roles.  The change will take place AFTER this recruiting period.","Role Recruitment", "Yes","No","Never")
				switch(answer)
					if("Never")
						prefs.roles[role_id] = ROLEPREF_NEVER
					if("No")
						prefs.roles[role_id] = ROLEPREF_NO
					if("Yes")
						prefs.roles[role_id] = ROLEPREF_YES
					//if("Always")
					//	prefs.roles[role_id] = ROLEPREF_ALWAYS
				//testing("Client [src] answered [answer] to [role_id] poll.")
				prefs.roles[role_id] |= ROLEPREF_POLLED
		else
			src << "<span style='recruit'>The game is currently looking for [role_id] candidates.  Your current answer is <a href='?src=\ref[prefs]&preference=set_role&role_id=[role_id]'>[get_role_desire_str(role_desired)]</a>.</span>"
	return role_desired & ROLEPREF_ENABLE