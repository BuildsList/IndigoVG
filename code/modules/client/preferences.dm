//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

var/list/preferences_datums = list()

var/global/list/special_roles = list(
	ROLE_ALIEN        = 1, //always show
	ROLE_BLOB         = 1,
	ROLE_BORER        = 1,
	ROLE_CHANGELING   = IS_MODE_COMPILED("changeling"),
	ROLE_CULTIST      = IS_MODE_COMPILED("cult"),
	ROLE_PLANT        = 1,
	"infested monkey" = IS_MODE_COMPILED("monkey"),
	ROLE_MALF         = IS_MODE_COMPILED("malfunction"),
	ROLE_NINJA        = 1,
	ROLE_OPERATIVE    = IS_MODE_COMPILED("nuclear"),
	ROLE_PAI          = 1, // -- TLE
	ROLE_POSIBRAIN    = 1,
	ROLE_REV          = IS_MODE_COMPILED("revolution"),
	ROLE_TRAITOR      = IS_MODE_COMPILED("traitor"),
	ROLE_VAMPIRE      = IS_MODE_COMPILED("vampire"),
	ROLE_VOXRAIDER    = IS_MODE_COMPILED("heist"),
	ROLE_WIZARD       = 1,
)

var/const/MAX_SAVE_SLOTS = 8

//used for alternate_option
#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2
#define POLLED_LIMIT	300

/datum/preferences
	//doohickeys for savefiles
	var/database/db = ("players2.sqlite")
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/slot = 1
	var/list/slot_names = new
	var/lastPolled = 0

	var/savefile_version = 0

	//non-preference stuff
	var/warns = 0
	var/warnbans = 0
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#b82e00"
	var/UI_style = "Midnight"
	var/toggles = TOGGLES_DEFAULT
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255
	var/special_popup = 0

	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/b_type = "A+"					//blood type (not-chooseable)
	var/underwear = 1					//underwear type
	var/backbag = 2						//backpack type
	var/h_style = "Bald"				//Hair type
	var/r_hair = 0						//Hair color
	var/g_hair = 0						//Hair color
	var/b_hair = 0						//Hair color
	var/f_style = "Shaved"				//Face hair type
	var/r_facial = 0					//Face hair color
	var/g_facial = 0					//Face hair color
	var/b_facial = 0					//Face hair color
	var/s_tone = 0						//Skin color
	var/r_eyes = 0						//Eye color
	var/g_eyes = 0						//Eye color
	var/b_eyes = 0						//Eye color
	var/species = "Human"
	var/language = "None"				//Secondary language

		//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null

		//Jobs, uses bitflags
	var/job_civilian_high = 0
	var/job_civilian_med = 0
	var/job_civilian_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engsec_high = 0
	var/job_engsec_med = 0
	var/job_engsec_low = 0

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = 0

	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = list() // skills can range from 0 to 3

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()

	var/list/player_alt_titles = new()		// the default name of a job like "Medical Doctor"

	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/disabilities = 0 // NOW A BITFIELD, SEE ABOVE

	var/nanotrasen_relation = "Neutral"

		// OOC Metadata:
	var/metadata = ""
	var/slot_name = ""

	// Whether or not to use randomized character slots
	var/randomslot = 0

	// jukebox volume
	var/volume = 100

	var/list/roles=list() // "role" => ROLEPREF_*

	var/client/client

/datum/preferences/New(client/C)
	b_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")
	client=C
	if(istype(C))
		if(!IsGuestKey(C.key))
			var/load_pref = load_preferences_sqlite(C.ckey)
			if(load_pref)
				if(load_save_sqlite(C.ckey, src, default_slot))
					return
		randomize_appearance_for()
		real_name = random_name(gender)
		save_character_sqlite(src, C.ckey, default_slot)

/datum/preferences

	proc/ShowChoices(mob/user)
		if(!user || !user.client)	return
		update_preview_icon()
		var/preview_front = fcopy_rsc(preview_icon_front)
		var/preview_side = fcopy_rsc(preview_icon_side)
		user << browse_rsc(preview_front, "previewicon.png")
		user << browse_rsc(preview_side, "previewicon2.png")
		var/dat = "<html><body><center>"

		if(!IsGuestKey(user.key))
			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:220: dat += "<center>"
			dat += {"<center>
				Slot <b>[slot_name]</b> -
				<a href=\"byond://?src=\ref[user];preference=open_load_dialog\">Load slot</a> -
				<a href=\"byond://?src=\ref[user];preference=save\">Save slot</a> -
				<a href=\"byond://?src=\ref[user];preference=reload\">Reload slot</a>
				</center>"}
			// END AUTOFIX
		else
			dat += "Please create an account to save your preferences."


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:230: dat += "</center><hr><table><tr><td width='340px' height='320px'>"
		dat += {"</center><hr><table><tr><td width='340px' height='320px'>
			<b>Name:</b> "}
		// END AUTOFIX
		if(appearance_isbanned(user))
			dat += "<b>You are banned from using custom names and appearances. You can continue to adjust your characters, but you will be randomised once you join the game.</b><br>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:234: dat += "<a href='?_src_=prefs;preference=name;task=input'><b>[real_name]</b></a><br>"
		dat += {"<a href='?_src_=prefs;preference=name;task=input'><b>[real_name]</b></a><br>
			(<a href='?_src_=prefs;preference=name;task=random'>Random Name</A>)
			(<a href='?_src_=prefs;preference=name'>Always Random Name: [be_random_name ? "Yes" : "No"]</a>)
			<br>
			<b>Gender:</b> <a href='?_src_=prefs;preference=gender'><b>[gender == MALE ? "Male" : "Female"]</b></a><br>
			<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[age]</a>
			<br>
			<b>UI Style:</b> <a href='?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>
			<b>Custom UI</b>(recommended for White UI):<br>
			-Color: <a href='?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a> <table style='display:inline;' bgcolor='[UI_style_color]'><tr><td>__</td></tr></table><br>
			-Alpha(transparency): <a href='?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>
			<b>Play admin midis:</b> <a href='?_src_=prefs;preference=hear_midis'><b>[(toggles & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>
			<b>Play lobby music:</b> <a href='?_src_=prefs;preference=lobby_music'><b>[(toggles & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>
			<b>Randomized Character Slot:</b> <a href='?_src_=prefs;preference=randomslot'><b>[randomslot ? "Yes" : "No"]</b></a><br>
			<b>Ghost ears:</b> <a href='?_src_=prefs;preference=ghost_ears'><b>[(toggles & CHAT_GHOSTEARS) ? "Nearest Creatures" : "All Speech"]</b></a><br>
			<b>Ghost sight:</b> <a href='?_src_=prefs;preference=ghost_sight'><b>[(toggles & CHAT_GHOSTSIGHT) ? "Nearest Creatures" : "All Emotes"]</b></a><br>
			<b>Ghost radio:</b> <a href='?_src_=prefs;preference=ghost_radio'><b>[(toggles & CHAT_GHOSTRADIO) ? "Nearest Speakers" : "All Chatter"]</b></a><br>
			<b>Ghost PDA:</b> <a href='?_src_=prefs;preference=ghost_pda'><b>[(toggles & CHAT_GHOSTPDA) ? "No PDA Messages" : "All PDA Messages"]</b></a><br>
			<b>Special Windows:</b><a href='?_src_=prefs;preference=special_popup'><b>[special_popup ? "Yes" : "No"]</b></a><br>"}
		// END AUTOFIX
		if(config.allow_Metadata)
			dat += "<b>OOC Notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'> Edit </a><br>"


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:252: dat += "<br><b>Occupation Choices</b><br>"
		dat += {"<br><b>Occupation Choices</b><br>
			\t<a href='?_src_=prefs;preference=job;task=menu'><b>Set Preferences</b></a><br>
			<br><table><tr><td><b>Body</b>
			(<a href='?_src_=prefs;preference=all;task=random'>&reg;</A>)
			<br>
			Species: <a href='byond://?src=\ref[user];preference=species;task=input'>[species]</a><br>
			Secondary Language:<br><a href='byond://?src=\ref[user];preference=language;task=input'>[language]</a><br>
			Blood Type: <a href='byond://?src=\ref[user];preference=b_type;task=input'>[b_type]</a><br>
			Skin Tone: <a href='?_src_=prefs;preference=s_tone;task=input'>[-s_tone + 35]/220<br></a>"}
		// END AUTOFIX
		//dat += "Skin pattern: <a href='byond://?src=\ref[user];preference=skin_style;task=input'>Adjust</a><br>"


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:264: dat += "<br><b>Handicaps</b><br>"
		dat += {"<br><b>Handicaps</b><br>
			\t<a href='byond://?src=\ref[user];task=input;preference=disabilities'><b>\[Set Disabilities\]</b></a><br>
			\tLimbs: <a href='byond://?src=\ref[user];preference=limbs;task=input'>Adjust</a><br>
			\tInternal Organs: <a href='byond://?src=\ref[user];preference=organs;task=input'>Adjust</a><br>"}
		// END AUTOFIX
		//display limbs below
		var/ind = 0
		for(var/name in organ_data)
			//world << "[ind] \ [organ_data.len]"
			var/status = organ_data[name]
			var/organ_name = null
			switch(name)
				if("l_arm")
					organ_name = "left arm"
				if("r_arm")
					organ_name = "right arm"
				if("l_leg")
					organ_name = "left leg"
				if("r_leg")
					organ_name = "right leg"
				if("l_foot")
					organ_name = "left foot"
				if("r_foot")
					organ_name = "right foot"
				if("l_hand")
					organ_name = "left hand"
				if("r_hand")
					organ_name = "right hand"
				if("heart")
					organ_name = "heart"
				if("eyes")
					organ_name = "eyes"
				if("lungs")
					organ_name = "lungs"
				if("liver")
					organ_name = "liver"
				if("kidneys")
					organ_name = "kidneys"

			if(status == "cyborg")
				++ind
				if(ind > 1)
					dat += ", "
				dat += "\tMechanical [organ_name] prothesis"
			else if(status == "amputated")
				++ind
				if(ind > 1)
					dat += ", "
				dat += "\tAmputated [organ_name]"
			else if(status == "mechanical")
				++ind
				if(ind > 1)
					dat += ", "
				dat += "\tMechanical [organ_name]"

			else if(status == "peg")
				++ind
				if(ind > 1)
					dat += ", "
				dat += "\tWooden [organ_name] prothesis"
			else if(status == "assisted")
				++ind
				if(ind > 1)
					dat += ", "
				switch(organ_name)
					if("heart")
						dat += "\tPacemaker-assisted [organ_name]"
					if("voicebox") //on adding voiceboxes for speaking skrell/similar replacements
						dat += "\tSurgically altered [organ_name]"
					if("eyes")
						dat += "\tRetinal overlayed [organ_name]"
					else
						dat += "\tMechanically assisted [organ_name]"
		if(!ind)
			dat += "\[...\]<br><br>"
		else
			dat += "<br><br>"

		if(gender == MALE)
			dat += "Underwear: <a href ='?_src_=prefs;preference=underwear;task=input'><b>[underwear_m[underwear]]</b></a><br>"
		else
			dat += "Underwear: <a href ='?_src_=prefs;preference=underwear;task=input'><b>[underwear_f[underwear]]</b></a><br>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:312: dat += "Backpack Type:<br><a href ='?_src_=prefs;preference=bag;task=input'><b>[backbaglist[backbag]]</b></a><br>"
		dat += {"Backpack Type:<br><a href ='?_src_=prefs;preference=bag;task=input'><b>[backbaglist[backbag]]</b></a><br>
			Nanotrasen Relation:<br><a href ='?_src_=prefs;preference=nt_relation;task=input'><b>[nanotrasen_relation]</b></a><br>
			</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64></td></tr></table>
			</td><td width='300px' height='300px'>"}
		// END AUTOFIX
		if(jobban_isbanned(user, "Records"))
			dat += "<b>You are banned from using character records.</b><br>"
		else
			dat += "<b><a href=\"byond://?src=\ref[user];preference=records;record=1\">Character Records</a></b><br>"


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:325: dat += "\t<a href=\"byond://?src=\ref[user];preference=skills\"><b>Set Skills</b> (<i>[GetSkillClass(used_skillpoints)][used_skillpoints > 0 ? " [used_skillpoints]" : "0"])</i></a><br>"
		dat += {"<a href='byond://?src=\ref[user];preference=flavor_text;task=input'><b>Set Flavor Text</b></a><br>"}
		// END AUTOFIX
		if(length(flavor_text) <= 40)
			if(!length(flavor_text))
				dat += "\[...\]"
			else
				dat += "[flavor_text]"
		else
			dat += "[copytext(flavor_text, 1, 37)]...<br>"


		if(!isnum(r_hair))
			WARNING("R_HAIR Expected a number")
		if(!isnum(g_hair))
			WARNING("G_HAIR Expected a number")
		if(!isnum(b_hair))
			WARNING("B_HAIR Expected a number")
		if(!isnum(r_facial))
			WARNING("R_FACIAL Expected a number")
		if(!isnum(g_facial))
			WARNING("G_FACIAL Expected a number")
		if(!isnum(b_facial))
			WARNING("B_FACIAL Expected a number")
		if(!isnum(r_eyes))
			WARNING("R_EYES Expected a number")
		if(!isnum(g_eyes))
			WARNING("G_EYES Expected a number")
		if(!isnum(b_eyes))
			WARNING("B_EYES Expected a number")
		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:335: dat += "<br>"
		dat += {"<br>
			<br><b>Hair</b><br>
			<a href='?_src_=prefs;preference=hair;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]'><table style='display:inline;' bgcolor='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]'><tr><td>__</td></tr></table></font>
			Style: <a href='?_src_=prefs;preference=h_style;task=input'>[h_style]</a><br>
			<br><b>Facial</b><br>
			<a href='?_src_=prefs;preference=facial;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]'><tr><td>__</td></tr></table></font>
			Style: <a href='?_src_=prefs;preference=f_style;task=input'>[f_style]</a><br>
			<br><b>Eyes</b><br>
			<a href='?_src_=prefs;preference=eyes;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]'><tr><td>__</td></tr></table></font>
			<br><br>"}
		// END AUTOFIX
		if(jobban_isbanned(user, "Syndicate"))
			dat += "<b>You are banned from antagonist roles.</b>"
		else
			for (var/i in special_roles)
				if(special_roles[i]) //if mode is available on the server
					if(jobban_isbanned(user, i))
						dat += "<b>Be [i]:</b> <font color=red><b> \[BANNED]</b></font><br>"
					else if(i == "pai candidate")
						if(jobban_isbanned(user, "pAI"))
							dat += "<b>Be [i]:</b> <font color=red><b> \[BANNED]</b></font><br>"
					else
						dat += "<b>Be [i]:</b> <a href='?_src_=prefs;preference=toggle_role;role_id=[i]'><b>[roles[i] & ROLEPREF_ENABLE ? "Yes" : "No"]</b></a><br>"
		dat += "</td></tr></table><hr><center>"

		if(!IsGuestKey(user.key))

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:367: dat += "<a href='?_src_=prefs;preference=load'>Undo</a> - "
			dat += {"<a href='?_src_=prefs;preference=load'>Undo</a> -
				<a href='?_src_=prefs;preference=save'>Save Setup</a> - "}
			// END AUTOFIX


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:370: dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
		dat += {"<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>
			</center></body></html>"}
		// END AUTOFIX
		var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 580, 620)
		popup.set_content(dat)
		popup.open(0)

	proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Chief Engineer", "Research Director"), widthPerColumn = 295, height = 620)
		if(!job_master)	return

		//limit - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
		//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
		//widthPerColumn - Screen's width for every column.
		//height - Screen's height.

		var/width = widthPerColumn

		var/HTML = "<center>"
		HTML += "<b>Choose occupation chances</b><br>"
		HTML += "<div align='center'>Unavailable occupations are in red.<br></div>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Close</a></center><br>" // Easier to press up here.
		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob

		for(var/datum/job/job in job_master.occupations)

			index += 1
			if((index >= limit) || (job.title in splitJobs))
				width += widthPerColumn
				if((index < limit) && (lastJob != null))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank = job.title
			lastJob = job
			if(jobban_isbanned(user, rank))
				HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[BANNED\]</b></font></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if((job_civilian_low & ASSISTANT) && (rank != "Assistant"))
				HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
				continue
			if((rank in command_positions) || (rank == "AI"))//Bold head jobs
				HTML += "<b><span class='dark'>[rank]</span></b>"
			else
				HTML += "<span class='dark'>[rank]</span>"

			HTML += "</td><td width='40%'>"

			var/prefLevelLabel = "ERROR"
			var/prefLevelColor = "pink"
			var/prefUpperLevel = -1 // level to assign on left click
			var/prefLowerLevel = -1 // level to assign on right click

			if(GetJobDepartment(job, 1) & job.flag)
				prefLevelLabel = "High"
				prefLevelColor = "slateblue"
				prefUpperLevel = 4
				prefLowerLevel = 2
			else if(GetJobDepartment(job, 2) & job.flag)
				prefLevelLabel = "Medium"
				prefLevelColor = "green"
				prefUpperLevel = 1
				prefLowerLevel = 3
			else if(GetJobDepartment(job, 3) & job.flag)
				prefLevelLabel = "Low"
				prefLevelColor = "orange"
				prefUpperLevel = 2
				prefLowerLevel = 4
			else
				prefLevelLabel = "NEVER"
				prefLevelColor = "red"
				prefUpperLevel = 3
				prefLowerLevel = 1


			HTML += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

			if(rank == "Assistant")//Assistant is special
				if(job_civilian_low & ASSISTANT)
					HTML += "<font color=green>Yes</font>"
				else
					HTML += "<font color=red>No</font>"
				HTML += "</a></td></tr>"
				continue

			HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
			HTML += "</a></td></tr>"

		for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
			HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

		HTML += "</td'></tr></table>"

		HTML += "</center></table>"

//		HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>[userandomjob ? "Get random job if preferences unavailable" : "Be an Assistant if preference unavailable"]</a></center>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>Reset</a></center>"

		user << browse(null, "window=preferences")
		//user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
		var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
		popup.set_window_options("can_close=0")
		popup.set_content(HTML)
		popup.open(0)
		return

	proc/ShowDisabilityState(mob/user,flag,label)
		if(flag==DISABILITY_FLAG_FAT && species!="Human")
			return "<li><i>[species] cannot be fat.</i></li>"
		return "<li><b>[label]:</b> <a href=\"?_src_=prefs;task=input;preference=disabilities;disability=[flag]\">[disabilities & flag ? "Yes" : "No"]</a></li>"

	proc/SetDisabilities(mob/user)
		var/HTML = "<body>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:474: HTML += "<tt><center>"
		HTML += {"<tt><center>
			<b>Choose disabilities</b><ul>"}
		// END AUTOFIX
		HTML += ShowDisabilityState(user,DISABILITY_FLAG_NEARSIGHTED,"Needs Glasses")
		HTML += ShowDisabilityState(user,DISABILITY_FLAG_FAT,        "Obese")
		HTML += ShowDisabilityState(user,DISABILITY_FLAG_EPILEPTIC,  "Seizures")
		HTML += ShowDisabilityState(user,DISABILITY_FLAG_DEAF,       "Deaf")
		/*HTML += ShowDisabilityState(user,DISABILITY_FLAG_COUGHING,   "Coughing")
		HTML += ShowDisabilityState(user,DISABILITY_FLAG_TOURETTES,   "Tourettes") Still working on it! -Angelite*/


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:481: HTML += "</ul>"
		HTML += {"</ul>
			<a href=\"?_src_=prefs;task=close;preference=disabilities\">\[Done\]</a>
			<a href=\"?_src_=prefs;task=reset;preference=disabilities\">\[Reset\]</a>
			</center></tt>"}
		// END AUTOFIX
		user << browse(null, "window=preferences")
		var/datum/browser/popup = new(user, "disabil", "<div align='center'>Character disabilities</div>", 350, 300)
		popup.set_window_options("can_close=0")
		popup.set_content(HTML)
		popup.open(0)
		return

	proc/SetRecords(mob/user)
		var/HTML = "<body>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:492: HTML += "<tt><center>"
		HTML += {"<tt><center>
			<b>Set Character Records</b><br>
			<a href=\"byond://?src=\ref[user];preference=records;task=med_record\">Medical Records</a><br>"}
		// END AUTOFIX
		if(length(med_record) <= 40)
			HTML += "[med_record]"
		else
			HTML += "[copytext(med_record, 1, 37)]..."

		HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">Employment Records</a><br>"

		if(length(gen_record) <= 40)
			HTML += "[gen_record]"
		else
			HTML += "[copytext(gen_record, 1, 37)]..."

		HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">Security Records</a><br>"

		if(length(sec_record) <= 40)
			HTML += "[sec_record]<br>"
		else
			HTML += "[copytext(sec_record, 1, 37)]...<br>"


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:516: HTML += "<br>"
		HTML += {"<br>
			<a href=\"byond://?src=\ref[user];preference=records;records=-1\">\[Done\]</a>
			</center></tt>"}
		// END AUTOFIX
		user << browse(null, "window=preferences")
		var/datum/browser/popup = new(user, "records", "<div align='center'>Character Records</div>", 350, 300)
		popup.set_window_options("can_close=0")
		popup.set_content(HTML)
		popup.open(0)
		return

	proc/GetPlayerAltTitle(datum/job/job)
		return player_alt_titles.Find(job.title) > 0 \
			? player_alt_titles[job.title] \
			: job.title

	proc/SetPlayerAltTitle(datum/job/job, new_title)
		// remove existing entry
		if(player_alt_titles.Find(job.title))
			player_alt_titles -= job.title
		// add one if it's not default
		if(job.title != new_title)
			player_alt_titles[job.title] = new_title

	proc/SetJob(mob/user, role)
		var/datum/job/job = job_master.GetJob(role)
		if(!job)
			user << browse(null, "window=mob_occupation")
			ShowChoices(user)
			return

		if(role == "Assistant")
			if(job_civilian_low & job.flag)
				job_civilian_low &= ~job.flag
			else
				job_civilian_low |= job.flag
			SetChoices(user)
			return 1

		if(GetJobDepartment(job, 1) & job.flag)
			SetJobDepartment(job, 1)
		else if(GetJobDepartment(job, 2) & job.flag)
			SetJobDepartment(job, 2)
		else if(GetJobDepartment(job, 3) & job.flag)
			SetJobDepartment(job, 3)
		else//job = Never
			SetJobDepartment(job, 4)

		SetChoices(user)
		return 1

	proc/SetJobPreferenceLevel(var/datum/job/job, var/level)
		if (!job)
			return 0

		if (level == 1) // to high
			// remove any other job(s) set to high
			job_civilian_med |= job_civilian_high
			job_engsec_med |= job_engsec_high
			job_medsci_med |= job_medsci_high
			job_civilian_high = 0
			job_engsec_high = 0
			job_medsci_high = 0

		if (job.department_flag == CIVILIAN)
			job_civilian_low &= ~job.flag
			job_civilian_med &= ~job.flag
			job_civilian_high &= ~job.flag

			switch(level)
				if (1)
					job_civilian_high |= job.flag
				if (2)
					job_civilian_med |= job.flag
				if (3)
					job_civilian_low |= job.flag

			return 1
		else if (job.department_flag == ENGSEC)
			job_engsec_low &= ~job.flag
			job_engsec_med &= ~job.flag
			job_engsec_high &= ~job.flag

			switch(level)
				if (1)
					job_engsec_high |= job.flag
				if (2)
					job_engsec_med |= job.flag
				if (3)
					job_engsec_low |= job.flag

			return 1
		else if (job.department_flag == MEDSCI)
			job_medsci_low &= ~job.flag
			job_medsci_med &= ~job.flag
			job_medsci_high &= ~job.flag

			switch(level)
				if (1)
					job_medsci_high |= job.flag
				if (2)
					job_medsci_med |= job.flag
				if (3)
					job_medsci_low |= job.flag

			return 1

		return 0


	proc/UpdateJobPreference(mob/user, role, desiredLvl)
		if(!job_master)
			return
		var/datum/job/job = job_master.GetJob(role)

		if(!job)
			user << browse(null, "window=mob_occupation")
			ShowChoices(user)
			return

		if (!isnum(desiredLvl))
			user << "\red UpdateJobPreference - desired level was not a number. Please notify coders!"
			ShowChoices(user)
			return

		if(role == "Assistant")
			if(job_civilian_low & job.flag)
				job_civilian_low &= ~job.flag
			else
				job_civilian_low |= job.flag
			SetChoices(user)
			return 1

		SetJobPreferenceLevel(job, desiredLvl)
		SetChoices(user)

		return 1

	proc/ResetJobs()
		job_civilian_high = 0
		job_civilian_med = 0
		job_civilian_low = 0

		job_medsci_high = 0
		job_medsci_med = 0
		job_medsci_low = 0

		job_engsec_high = 0
		job_engsec_med = 0
		job_engsec_low = 0


	proc/GetJobDepartment(var/datum/job/job, var/level)
		if(!job || !level)	return 0
		switch(job.department_flag)
			if(CIVILIAN)
				switch(level)
					if(1)
						return job_civilian_high
					if(2)
						return job_civilian_med
					if(3)
						return job_civilian_low
			if(MEDSCI)
				switch(level)
					if(1)
						return job_medsci_high
					if(2)
						return job_medsci_med
					if(3)
						return job_medsci_low
			if(ENGSEC)
				switch(level)
					if(1)
						return job_engsec_high
					if(2)
						return job_engsec_med
					if(3)
						return job_engsec_low
		return 0

	proc/SetJobDepartment(var/datum/job/job, var/level)
		if(!job || !level)	return 0
		switch(level)
			if(1)//Only one of these should ever be active at once so clear them all here
				job_civilian_high = 0
				job_medsci_high = 0
				job_engsec_high = 0
				return 1
			if(2)//Set current highs to med, then reset them
				job_civilian_med |= job_civilian_high
				job_medsci_med |= job_medsci_high
				job_engsec_med |= job_engsec_high
				job_civilian_high = 0
				job_medsci_high = 0
				job_engsec_high = 0

		switch(job.department_flag)
			if(CIVILIAN)
				switch(level)
					if(2)
						job_civilian_high = job.flag
						job_civilian_med &= ~job.flag
					if(3)
						job_civilian_med |= job.flag
						job_civilian_low &= ~job.flag
					else
						job_civilian_low |= job.flag
			if(MEDSCI)
				switch(level)
					if(2)
						job_medsci_high = job.flag
						job_medsci_med &= ~job.flag
					if(3)
						job_medsci_med |= job.flag
						job_medsci_low &= ~job.flag
					else
						job_medsci_low |= job.flag
			if(ENGSEC)
				switch(level)
					if(2)
						job_engsec_high = job.flag
						job_engsec_med &= ~job.flag
					if(3)
						job_engsec_med |= job.flag
						job_engsec_low &= ~job.flag
					else
						job_engsec_low |= job.flag
		return 1

	proc/SetRoles(var/mob/user, var/list/href_list)
		// We just grab the role from the POST(?) data.
		for(var/role_id in special_roles)
			if(!(role_id in href_list))
				user << "<span class='danger'>BUG: Unable to find role [role_id].</span>"
				continue
			var/oldval=text2num(roles[role_id])
			roles[role_id] = text2num(href_list[role_id])
			if(oldval!=roles[role_id])
				user << "<span class='info'>Set role [role_id] to [get_role_desire_str(user.client.prefs.roles[role_id])]!</span>"

		save_preferences_sqlite(user, user.ckey)
		save_character_sqlite(user.ckey, user, default_slot)
		return 1

	proc/ToggleRole(var/mob/user, var/list/href_list)
		var/role_id = href_list["role_id"]
		//user << "<span class='info'>Toggling role [role_id] (currently at [roles[role_id]])...</span>"
		if(!(role_id in special_roles))
			user << "<span class='danger'>BUG: Unable to find role [role_id].</span>"
			return 0

		if(roles[role_id] == null || roles[role_id] == "")
			roles[role_id] = 0
		// Always set persist.
		roles[role_id] |= ROLEPREF_PERSIST
		// Toggle role enable
		roles[role_id] ^= ROLEPREF_ENABLE
		return 1

	proc/SetRole(var/mob/user, var/list/href_list)
		var/role_id = href_list["role_id"]
		//user << "<span class='info'>Toggling role [role_id] (currently at [roles[role_id]])...</span>"
		if(!(role_id in special_roles))
			user << "<span class='danger'>BUG: Unable to find role [role_id].</span>"
			return 0

		if(roles[role_id] == null || roles[role_id] == "")
			roles[role_id] = 0

		var/question={"Would you like to be \a [role_id] this round?

No/Yes:  Only affects this round.
Never/Always: Saved for later rounds.

NOTE:  The change will take effect AFTER any current recruiting periods."}
		var/answer = alert(question,"Role Preference", "Never", "No", "Yes", "Always")
		var/newval=0
		switch(answer)
			if("Never")
				newval = ROLEPREF_NEVER
			if("No")
				newval = ROLEPREF_NO
			if("Yes")
				newval = ROLEPREF_YES
			if("Always")
				newval = ROLEPREF_ALWAYS
		roles[role_id] = (roles[role_id] & ~ROLEPREF_VALMASK) | newval // We only set the lower 2 bits, leaving polled and friends untouched.

		save_preferences_sqlite(user, user.ckey)
		save_character_sqlite(user.ckey, user, default_slot)

		return 1

	proc/process_link(mob/user, list/href_list)
		if(!user)
			return

		if(!istype(user, /mob/new_player))
			return

		if(href_list["preference"] == "job")
			switch(href_list["task"])
				if("close")
					user << browse(null, "window=mob_occupation")
					ShowChoices(user)
				if("reset")
					ResetJobs()
					SetChoices(user)
				if("random")
					if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
						alternate_option += 1
					else if(alternate_option == RETURN_TO_LOBBY)
						alternate_option = 0
					else
						return 0
					SetChoices(user)
				if("setJobLevel")
					UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
				if ("alt_title")
					var/datum/job/job = locate(href_list["job"])
					if (job)
						var/choices = list(job.title) + job.alt_titles
						var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
						if(choice)
							SetPlayerAltTitle(job, choice)
							SetChoices(user)
				if("input")
					SetJob(user, href_list["text"])
				else
					SetChoices(user)
			return 1
		else if(href_list["preference"] == "disabilities")

			switch(href_list["task"])
				if("close")
					user << browse(null, "window=disabil")
					ShowChoices(user)
				if("reset")
					disabilities=0
					SetDisabilities(user)
				if("input")
					var/dflag=text2num(href_list["disability"])
					if(dflag >= 0)
						if(!(dflag==DISABILITY_FLAG_FAT && species!="Human"))
							disabilities ^= text2num(href_list["disability"]) //MAGIC
					SetDisabilities(user)
				else
					SetDisabilities(user)
			return 1

		else if(href_list["preference"] == "records")
			if(text2num(href_list["record"]) >= 1)
				SetRecords(user)
				return
			else
				user << browse(null, "window=records")
			if(href_list["task"] == "med_record")
				var/medmsg = input(usr,"Set your medical notes here.","Medical Records",rhtml_decode(med_record)) as message

				if(medmsg != null)
					medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
					medmsg = rhtml_encode(medmsg)

					med_record = medmsg
					SetRecords(user)

			if(href_list["task"] == "sec_record")
				var/secmsg = input(usr,"Set your security notes here.","Security Records",rhtml_decode(sec_record)) as message

				if(secmsg != null)
					secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
					secmsg = rhtml_encode(secmsg)

					sec_record = secmsg
					SetRecords(user)
			if(href_list["task"] == "gen_record")
				var/genmsg = input(usr,"Set your employment notes here.","Employment Records",rhtml_decode(gen_record)) as message

				if(genmsg != null)
					genmsg = copytext(genmsg, 1, MAX_PAPER_MESSAGE_LEN)
					genmsg = rhtml_encode(genmsg)

					gen_record = genmsg
					SetRecords(user)

		else if(href_list["preference"] == "set_roles")
			return SetRoles(user,href_list)

		else if(href_list["preference"] == "toggle_role")
			ToggleRole(user,href_list)

		switch(href_list["task"])
			if("random")
				switch(href_list["preference"])
					if("name")
						real_name = random_name(gender,species)
					if("age")
						age = rand(AGE_MIN, AGE_MAX)
					if("hair")
						r_hair = rand(0,255)
						g_hair = rand(0,255)
						b_hair = rand(0,255)
					if("h_style")
						h_style = random_hair_style(gender, species)
					if("facial")
						r_facial = rand(0,255)
						g_facial = rand(0,255)
						b_facial = rand(0,255)
					if("f_style")
						f_style = random_facial_hair_style(gender, species)
					if("underwear")
						underwear = rand(1,underwear_m.len)
						ShowChoices(user)
					if("eyes")
						r_eyes = rand(0,255)
						g_eyes = rand(0,255)
						b_eyes = rand(0,255)
					if("s_tone")
						s_tone = random_skin_tone()
					if("bag")
						backbag = rand(1,4)
					/*if("skin_style")
						h_style = random_skin_style(gender)*/
					if("all")
						randomize_appearance_for()	//no params needed
			if("input")
				switch(href_list["preference"])
					if("name")
						var/new_name = reject_bad_name( input(user, "Choose your character's name:", "Character Preference")  as text|null )
						if(new_name)
							real_name = new_name
						else
							user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"

					if("age")
						var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
						if(new_age)
							age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)
					if("species")

						var/list/new_species = list("Human")
						var/prev_species = species
						var/whitelisted = 0

						if(config.usealienwhitelist) //If we're using the whitelist, make sure to check it!
							for(var/S in whitelisted_species)
								if(is_alien_whitelisted(user,S))
									new_species += S
									whitelisted = 1
							if(!whitelisted)
								alert(user, "You cannot change your species as you need to be whitelisted. If you wish to be whitelisted contact an admin in-game, on the forums, or on IRC.")
						else //Not using the whitelist? Aliens for everyone!
							new_species = whitelisted_species

						species = input("Please select a species", "Character Generation", null) in new_species

						if(prev_species != species)
							//grab one of the valid hair styles for the newly chosen species
							var/list/valid_hairstyles = list()
							for(var/hairstyle in hair_styles_list)
								var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
								if(gender == MALE && S.gender == FEMALE)
									continue
								if(gender == FEMALE && S.gender == MALE)
									continue
								if( !(species in S.species_allowed))
									continue
								valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

							if(valid_hairstyles.len)
								h_style = pick(valid_hairstyles)
							else
								//this shouldn't happen
								h_style = hair_styles_list["Bald"]

							//grab one of the valid facial hair styles for the newly chosen species
							var/list/valid_facialhairstyles = list()
							for(var/facialhairstyle in facial_hair_styles_list)
								var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
								if(gender == MALE && S.gender == FEMALE)
									continue
								if(gender == FEMALE && S.gender == MALE)
									continue
								if( !(species in S.species_allowed))
									continue

								valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

							if(valid_facialhairstyles.len)
								f_style = pick(valid_facialhairstyles)
							else
								//this shouldn't happen
								f_style = facial_hair_styles_list["Shaved"]

							//reset hair colour and skin colour
							r_hair = 0//hex2num(copytext(new_hair, 2, 4))
							g_hair = 0//hex2num(copytext(new_hair, 4, 6))
							b_hair = 0//hex2num(copytext(new_hair, 6, 8))

							s_tone = 0

					if("language")
						var/languages_available
						var/list/new_languages = list("None")

						if(config.usealienwhitelist)
							for(var/L in all_languages)
								var/datum/language/lang = all_languages[L]
								if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))))
									new_languages += lang
									languages_available = 1

							if(!(languages_available))
								alert(user, "There are not currently any available secondary languages.")
						else
							for(var/L in all_languages)
								var/datum/language/lang = all_languages[L]
								if(!(lang.flags & RESTRICTED))
									new_languages += lang.name

						language = input("Please select a secondary language", "Character Generation", null) in new_languages

					if("metadata")
						var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , metadata)  as message|null
						if(new_metadata)
							metadata = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

					if("b_type")
						var/new_b_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
						if(new_b_type)
							b_type = new_b_type

					if("hair") // H_style for everybody! TestUnit
//						if(species == "Human" || species == "Unathi")
						var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference") as color|null
						if(new_hair)
							r_hair = hex2num(copytext(new_hair, 2, 4))
							g_hair = hex2num(copytext(new_hair, 4, 6))
							b_hair = hex2num(copytext(new_hair, 6, 8))

					if("h_style")
						var/list/valid_hairstyles = list()
						for(var/hairstyle in hair_styles_list)
							var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
							if( !(species in S.species_allowed))
								continue

							valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

						var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in valid_hairstyles
						if(new_h_style)
							h_style = new_h_style

					if("facial")
						var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference") as color|null
						if(new_facial)
							r_facial = hex2num(copytext(new_facial, 2, 4))
							g_facial = hex2num(copytext(new_facial, 4, 6))
							b_facial = hex2num(copytext(new_facial, 6, 8))

					if("f_style")
						var/list/valid_facialhairstyles = list()
						for(var/facialhairstyle in facial_hair_styles_list)
							var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if( !(species in S.species_allowed))
								continue

							valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

						var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facialhairstyles
						if(new_f_style)
							f_style = new_f_style

					if("underwear")
						var/list/underwear_options
						if(gender == MALE)
							underwear_options = underwear_m
						else
							underwear_options = underwear_f

						var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
						if(new_underwear)
							underwear = underwear_options.Find(new_underwear)
						ShowChoices(user)

					if("eyes")
						var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference") as color|null
						if(new_eyes)
							r_eyes = hex2num(copytext(new_eyes, 2, 4))
							g_eyes = hex2num(copytext(new_eyes, 4, 6))
							b_eyes = hex2num(copytext(new_eyes, 6, 8))

					if("s_tone")
//						if(species != "Human")
//							return
						var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
						if(new_s_tone)
							s_tone = 35 - max(min( round(new_s_tone), 220),1)

					if("ooccolor")
						var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference") as color|null
						if(new_ooccolor)
							ooccolor = new_ooccolor

					if("bag")
						var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
						if(new_backbag)
							backbag = backbaglist.Find(new_backbag)

					if("nt_relation")
						var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
						if(new_relation)
							nanotrasen_relation = new_relation

					if("flavor_text")
						var/msg = input(usr,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",rhtml_decode(flavor_text)) as message

						if(msg != null)
							msg = copytext(msg, 1, MAX_MESSAGE_LEN)
							msg = rhtml_encode(msg)

							flavor_text = sanitize(msg)

					if("limbs")
						var/limb_name = input(user, "Which limb do you want to change?") as null|anything in list("Left Leg","Right Leg","Left Arm","Right Arm","Left Foot","Right Foot","Left Hand","Right Hand")
						if(!limb_name) return

						var/limb = null
						var/second_limb = null // if you try to change the arm, the hand should also change
						var/third_limb = null  // if you try to unchange the hand, the arm should also change
						var/valid_limb_states=list("Normal","Amputated","Prothesis")
						switch(limb_name)
							if("Left Leg")
								limb = "l_leg"
								second_limb = "l_foot"
								valid_limb_states += "Peg Leg"
							if("Right Leg")
								limb = "r_leg"
								second_limb = "r_foot"
								valid_limb_states += "Peg Leg"
							if("Left Arm")
								limb = "l_arm"
								second_limb = "l_hand"
								valid_limb_states += "Wooden Prosthesis"
							if("Right Arm")
								limb = "r_arm"
								second_limb = "r_hand"
								valid_limb_states += "Wooden Prosthesis"
							if("Left Foot")
								limb = "l_foot"
								third_limb = "l_leg"
							if("Right Foot")
								limb = "r_foot"
								third_limb = "r_leg"
							if("Left Hand")
								limb = "l_hand"
								third_limb = "l_arm"
								valid_limb_states += "Hook Prosthesis"
							if("Right Hand")
								limb = "r_hand"
								third_limb = "r_arm"
								valid_limb_states += "Hook Prosthesis"

						var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in valid_limb_states
						if(!new_state) return

						switch(new_state)
							if("Normal")
								organ_data[limb] = null
								if(third_limb)
									organ_data[third_limb] = null
							if("Amputated")
								organ_data[limb] = "amputated"
								if(second_limb)
									organ_data[second_limb] = "amputated"
							if("Prothesis")
								organ_data[limb] = "cyborg"
								if(second_limb)
									organ_data[second_limb] = "cyborg"
							if("Peg Leg","Wooden Prosthesis","Hook Prosthesis")
								organ_data[limb] = "peg"
								if(second_limb)
									if(limb == "l_arm" || limb == "r_arm")
										organ_data[second_limb] = "peg"
									else
										organ_data[second_limb] = "amputated"

					if("organs")
						var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Heart", "Eyes", "Lungs", "Liver", "Kidneys")
						if(!organ_name) return

						var/organ = null
						switch(organ_name)
							if("Heart")
								organ = "heart"
							if("Eyes")
								organ = "eyes"
							if("Lungs")
								organ = "lungs"
							if("Liver")
								organ = "liver"
							if("Kidneys")
								organ = "kidneys"

						var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal","Assisted","Mechanical")
						if(!new_state) return

						switch(new_state)
							if("Normal")
								organ_data[organ] = null
							if("Assisted")
								organ_data[organ] = "assisted"
							if("Mechanical")
								organ_data[organ] = "mechanical"

					if("skin_style")
						var/skin_style_name = input(user, "Select a new skin style") as null|anything in list("default1", "default2", "default3")
						if(!skin_style_name) return

			else
				switch(href_list["preference"])
					if("gender")
						if(gender == MALE)
							gender = FEMALE
						else
							gender = MALE

					if("hear_adminhelps")
						toggles ^= SOUND_ADMINHELP

					if("ui")
						switch(UI_style)
							if("Midnight")
								UI_style = "Orange"
							if("Orange")
								UI_style = "old"
							if("old")
								UI_style = "White"
							else
								UI_style = "Midnight"

					if("UIcolor")
						var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!") as color|null
						if(!UI_style_color_new) return
						UI_style_color = UI_style_color_new

					if("UIalpha")
						var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
						if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
						UI_style_alpha = UI_style_alpha_new

					if("name")
						be_random_name = !be_random_name

					if("special_popup")
						special_popup = !special_popup

					if("randomslot")
						randomslot = !randomslot

					if("hear_midis")
						toggles ^= SOUND_MIDI

					if("lobby_music")
						toggles ^= SOUND_LOBBY
						if(toggles & SOUND_LOBBY)
							user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
						else
							user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

					if("ghost_ears")
						toggles ^= CHAT_GHOSTEARS

					if("ghost_sight")
						toggles ^= CHAT_GHOSTSIGHT

					if("ghost_radio")
						toggles ^= CHAT_GHOSTRADIO

					if("ghost_pda")
						toggles ^= CHAT_GHOSTPDA

					if("save")
						save_preferences_sqlite(user, user.ckey)
						save_character_sqlite(user.ckey, user, default_slot)

					if("reload")
						load_preferences_sqlite(user, user.ckey)
						load_save_sqlite(user.ckey, user, default_slot)

					if("open_load_dialog")
						if(!IsGuestKey(user.key))
							open_load_dialog(user)

					if("close_load_dialog")
						close_load_dialog(user)

					if("changeslot")
						var/num = text2num(href_list["num"])
						load_save_sqlite(user.ckey, user, num)
						default_slot = num
						close_load_dialog(user)

		ShowChoices(user)
		return 1

	proc/copy_to(mob/living/carbon/human/character, safety = 0)
		if(be_random_name)
			real_name = random_name(gender,species)

		if(config.humans_need_surnames && species == "Human")
			var/firstspace = findtext(real_name, " ")
			var/name_length = length(real_name)
			if(!firstspace)	//we need a surname
				real_name += " [pick(last_names)]"
			else if(firstspace == name_length)
				real_name += "[pick(last_names)]"

		character.real_name = real_name
		character.name = character.real_name
		if(character.dna)
			character.dna.real_name = character.real_name

		character.flavor_text = flavor_text
		character.med_record = med_record
		character.sec_record = sec_record
		character.gen_record = gen_record

		character.gender = gender
		character.age = age
		character.b_type = b_type

		character.r_eyes = r_eyes
		character.g_eyes = g_eyes
		character.b_eyes = b_eyes

		character.r_hair = r_hair
		character.g_hair = g_hair
		character.b_hair = b_hair

		character.r_facial = r_facial
		character.g_facial = g_facial
		character.b_facial = b_facial

		character.s_tone = s_tone

		character.h_style = h_style
		character.f_style = f_style


		character.skills = skills

		// Destroy/cyborgize organs

		for(var/name in organ_data)
			var/datum/organ/external/O = character.organs_by_name[name]
			var/datum/organ/internal/I = character.internal_organs_by_name[name]
			var/status = organ_data[name]

			if(status == "amputated")
				O.status &= ~ORGAN_ROBOT
				O.status &= ~ORGAN_PEG
				O.amputated = 1
				O.status |= ORGAN_DESTROYED
				O.destspawn = 1
			else if(status == "cyborg")
				O.status &= ~ORGAN_PEG
				O.status |= ORGAN_ROBOT
			else if(status == "peg")
				O.status &= ~ORGAN_ROBOT
				O.status |= ORGAN_PEG
			else if(status == "assisted")
				I.mechassist()
			else if(status == "mechanical")
				I.mechanize()
			else continue

		if(disabilities & DISABILITY_FLAG_FAT && species=="Human")//character.species.flags & CAN_BE_FAT)
			character.mutations += M_FAT
			character.mutations += M_OBESITY
		if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
			character.disabilities|=NEARSIGHTED
		if(disabilities & DISABILITY_FLAG_EPILEPTIC)
			character.disabilities|=EPILEPSY
		if(disabilities & DISABILITY_FLAG_DEAF)
			character.sdisabilities|=DEAF
		/*if(disabilities & DISABILITY_FLAG_COUGHING)
			character.sdisabilities|=COUGHING
		if(disabilities & DISABILITY_FLAG_TOURETTES)
			character.sdisabilities|=TOURETTES Still working on it. - Angelite */

		if(underwear > underwear_m.len || underwear < 1)
			underwear = 0 //I'm sure this is 100% unnecessary, but I'm paranoid... sue me. //HAH NOW NO MORE MAGIC CLONING UNDIES
		character.underwear = underwear

		if(backbag > 4 || backbag < 1)
			backbag = 1 //Same as above
		character.backbag = backbag

		//Debugging report to track down a bug, which randomly assigned the plural gender to people.
		if(character.gender in list(PLURAL, NEUTER))
			if(isliving(src)) //Ghosts get neuter by default
				message_admins("[character] ([character.ckey]) has spawned with their gender as plural or neuter. Please notify coders.")
				character.gender = MALE

	proc/open_load_dialog(mob/user)

		var/database/query/q = new
		var/list/name_list[MAX_SAVE_SLOTS]

		q.Add("select real_name, player_slot from players where player_ckey=?", user.ckey)
		if(q.Execute(db))
			while(q.NextRow())
				name_list[q.GetColumn(2)] = q.GetColumn(1)
		else
			message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
			warning("Error #:[q.Error()] - [q.ErrorMsg()]")
			return 0
		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:1283: var/dat = "<body>"
		var/dat = {"<body><tt><center>"}
		// END AUTOFIX
		dat += "<b>Select a character slot to load</b><hr>"
		var/counter = 1
		while(counter <= MAX_SAVE_SLOTS)
			if(counter==default_slot)
				dat += "<a href='?_src_=prefs;preference=changeslot;num=[counter];'><b>[name_list[counter]]</b></a><br>"
			else
				if(!name_list[counter])
					dat += "<a href='?_src_=prefs;preference=changeslot;num=[counter];'>Character[counter]</a><br>"
				else
					dat += "<a href='?_src_=prefs;preference=changeslot;num=[counter];'>[name_list[counter]]</a><br>"
			counter++

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\client\preferences.dm:1228: dat += "<hr>"
		dat += {"<hr>
			<a href='byond://?src=\ref[user];preference=close_load_dialog'>Close</a><br>
			</center></tt>"}
		// END AUTOFIX
		user << browse(dat, "window=saves;size=300x390")

	proc/close_load_dialog(mob/user)
		user << browse(null, "window=saves")

	proc/configure_special_roles(var/mob/user)
		var/html={"
<form method="get">
	<input type="hidden" name="src" value="\ref[src]" />
	<input type="hidden" name="preference" value="set_roles" />
	<h1>Special Role Preferences</h1>
	<p>Please note that this also handles in-round polling for things like Raging Mages and Borers.</p>
	<fieldset>
		<legend>Legend</legend>
		<dl>
			<dt>Never:</dt>
			<dd>Always answer no to this role.</dd>
			<dt>No:</dt>
			<dd>Answer no for this round. (Default)</dd>
			<dt>Yes:</dt>
			<dd>Answer yes for this round.</dd>
			<dt>Always:</dt>
			<dd>Always answer yes to this role.</dd>
		</dl>
	</fieldset>
	<table border=\"0\">
		<thead>
			<tr>
				<th>Role</th>
				<th class="clmNever">Never</th>
				<th class="clmNo">No</th>
				<th class="clmYes">Yes</th>
				<th class="clmAlways">Always</th>
			</tr>
		</thead>
		<tbody>"}
		for(var/role_id in special_roles)
			var/desire = get_role_desire_str(roles[role_id])
			html += {"
			<tr>
				<th>[role_id]</th>
				<td class='column clmNever'><input type="radio" name="[role_id]" value="[ROLEPREF_PERSIST]" title="Never"[desire=="Never"?" checked='checked'":""]/></td>
				<td class='column clmNo'><input type="radio" name="[role_id]" value="0" title="No"[desire=="No"?" checked='checked'":""] /></td>
				<td class='column clmYes'><input type="radio" name="[role_id]" value="[ROLEPREF_ENABLE]" title="Yes"[desire=="Yes"?" checked='checked'":""] /></td>
				<td class='column clmAlways'><input type="radio" name="[role_id]" value="[ROLEPREF_ENABLE|ROLEPREF_PERSIST]" title="Always"[desire=="Always"?" checked='checked'":""] /></td>
			</tr>
			"}
		html += {"
		</tbody>
	</table>
	<input type="submit" value="Submit" />
	<input type="reset" value="Reset" />
</form>"}
		var/datum/browser/B = new /datum/browser/clean(user, "roles", "Role Selections", 300, 390)
		B.set_content(html)
		B.add_stylesheet("specialroles", 'html/browser/config_roles.css')
		B.open()

	Topic(href, href_list)
		if(!usr || !client)
			return
		if(client.mob!=usr)
			usr << "YOU AREN'T ME GO AWAY"
			return
		switch(href_list["preference"])
			if("set_roles")
				return SetRoles(usr, href_list)
			if("set_role")
				return SetRole(usr, href_list)
