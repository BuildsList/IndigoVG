/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"

	if(say_disabled)
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return
	usr.say(message)

/mob/verb/whisper(message as text)
	set name = "Whisper"
	set category = "IC"
	return
/*
/mob/proc/whisper(var/message, var/unheard=" whispers something", var/heard="whispers,", var/apply_filters=1, var/allow_lastwords=1)
	return
*/

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(ishuman(src) || isrobot(src))
		usr.emote("me",usr.emote_type,message)
	else
		usr.emote(message)

/mob/proc/say_dead(var/message)
	var/name = src.real_name
	var/alt_name = ""

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "<span class='danger'>Speech is currently admin-disabled.</span>"
		return

	if(client && !(client.prefs.toggles & CHAT_DEAD))
		usr << "<span class='danger'>You have deadchat muted.</span>"
		return

	if(mind && mind.name)
		name = "[mind.name]"
	else
		name = real_name
	if(name != real_name)
		alt_name = " (died as [real_name])"

	message = src.say_quote(message)
	//var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[message]</span></span>"
	var/rendered2 = null//edited
	for(var/mob/M in player_list)
		rendered2 = "<span class='game deadsay'><a href='byond://?src=\ref[M];follow2=\ref[M];follow=\ref[src]'>(Follow)</a><span class='prefix'> DEAD:</span> <span class='name'>[name]</span>[alt_name] <span class='message'>[message]</span></span>"//edited
		if(istype(M, /mob/new_player))
			continue
		if(M.client && M.client.holder && M.client.holder.rights & R_ADMIN && (M.client.prefs.toggles & CHAT_DEAD)) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			M << rendered2	//Admins can hear deadchat, if they choose to, no matter if they're blind/deaf or not.
		else if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_DEAD))
			//M.show_message(rendered2, 2) //Takes into account blindness and such.
			M << rendered2
	return

/mob/proc/emote(var/act, var/type, var/message, var/auto)
	if(act == "me")
		return custom_emote(type, message)


/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)

/mob/proc/lingcheck()
	return 0

/mob/proc/construct_chat_check(var/setting)
	return 0
