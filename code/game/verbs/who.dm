/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "\n<b>Current Players:</b>\n"
	var/funny_name = "Plin"

	var/list/Lines = list()

	if (holder)
		for (var/client/C in clients)
			var/entry = "\t[C.key]"

			if (C.holder && C.holder.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"

			entry += " - Playing as [C.mob.real_name]"

			switch (C.mob.stat)
				if (UNCONSCIOUS)
					entry += " - <font color='darkgray'><b>Unconscious</b></font>"

				if (DEAD)
					if (isobserver(C.mob))
						var/mob/dead/observer/O = C.mob

						if (O.started_as_observer)
							entry += " - <font color='gray'>Observing</font>"
						else
							entry += " - <font color='black'><b>DEAD</b></font>"
					else
						entry += " - <font color='black'><b>DEAD</b></font>"

			if (is_special_character(C.mob))
				entry += " - <b><font color='red'>Antagonist</font></b>"

			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry
	else
		for (var/client/C in clients)
			if (C.holder && C.holder.fakekey)
				Lines += funny_name
			else
				Lines += funny_name

	for (var/line in sortList(Lines))
		msg += "[line]\n"

	msg += "<b>Total Plin's: [length(Lines)]</b>\n"
	src << msg

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	var/aNames = ""
	var/funny_name = "Plin"
	var/funny_rank = pick("Hui", "Dick", "Cock", "Khooy", "Xyu")
//	var/mNames = ""
//	var/numAdminsOnline = 0
//	var/numModsOnline = 0

	if (holder)
		for (var/client/C in admins)
			if (R_ADMIN & C.holder.rights || (R_MOD & C.holder.rights))
				aNames += "\t[C] is a [C.holder.rank]"

				if (C.holder.fakekey)
					aNames += " <i>(as [C.holder.fakekey])</i>"

				if (isobserver(C.mob))
					aNames += " - Observing"
				else if (istype(C.mob,/mob/new_player))
					aNames += " - Lobby"
				else
					aNames += " - Playing"

				if (C.is_afk())
					aNames += " (AFK)"

				aNames += "\n"
//				numAdminsOnline++
/*			else
				mNames += "\t[C] is a [C.holder.rank]"

				if (C.holder.fakekey)
					mNames += " <i>(as [C.holder.fakekey])</i>"

				if (isobserver(C.mob))
					mNames += " - Observing"
				else if (istype(C.mob,/mob/new_player))
					mNames += " - Lobby"
				else
					mNames += " - Playing"

				if (C.is_afk())
					mNames += " (AFK)"

				mNames += "\n"
				numModsOnline++ */
	else
		for (var/client/C in admins)
			if (R_ADMIN & C.holder.rights || (R_MOD & C.holder.rights))
				if (!C.holder.fakekey)
					aNames += "\t[funny_name] is a [funny_rank]\n"
/*					numAdminsOnline++
			else
				if (!C.holder.fakekey)
					mNames += "\t[C] is a [C.holder.rank]\n"
					numModsOnline++ */

	src << "\n<b>Administators Online:</b>\n" + aNames + "\n"/*<b>Current Moderators ([numModsOnline]):</b>\n" + mNames + "\n"*/
