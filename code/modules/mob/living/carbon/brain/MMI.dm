//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3
	origin_tech = "biotech=3"

	var/list/mommi_assembly_parts = list(
		/obj/item/weapon/cell = 1,
		/obj/item/robot_parts/l_leg = 2,
		/obj/item/robot_parts/r_leg = 2,
		/obj/item/robot_parts/r_arm = 1,
		/obj/item/robot_parts/l_arm = 1
	)

	req_access = list(access_robotics)

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.

	var/locked = 0
	var/mob/living/carbon/brain/brainmob = null//The current occupant.
	var/mob/living/silicon/robot = null//Appears unused.
	var/obj/mecha = null//This does not appear to be used outside of reference in mecha.dm.

	// Return true if handled
/obj/item/device/mmi/proc/try_handling_mommi_construction(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/weapon/screwdriver))
		for(var/t in mommi_assembly_parts)
			var/cc=contents_count(t)
			var/req=mommi_assembly_parts[t]
			if(cc<req)
				var/temppart = new t(src)
				user << "\red You're short [req-cc] [temppart]\s."
				del(temppart)
				return TRUE
		if(!istype(loc,/turf))
			user << "<span class='warning'>You can't assemble the MoMMI, \the [src] has to be standing on the ground (or a table) to be perfectly precise.</span>"
			return TRUE
		if(!brainmob)
			user << "<span class='warning'>What are you doing oh god put the brain back in.</span>"
			return TRUE
		if(!brainmob.key)
			var/ghost_can_reenter = 0
			if(brainmob.mind)
				for(var/mob/dead/observer/G in player_list)
					if(G.can_reenter_corpse && G.mind == brainmob.mind)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				user << "<span class='notice'>\The [src] indicates that their mind is completely unresponsive; there's no point.</span>"
				return TRUE
		if(brainmob.stat == DEAD)
			user << "<span class='warning'>Yeah, good idea. Give something deader than the pizza in your fridge legs.  Mom would be so proud.</span>"
			return TRUE
		if(brainmob.mind in ticker.mode.head_revolutionaries)
			user << "<span class='warning'>The [src]'s firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept the brain.</span>"
			return TRUE
		if(jobban_isbanned(brainmob, "Cyborg"))
			user << "<span class='warning'>This brain does not seem to fit.</span>"
			return TRUE
		//canmove = 0
		icon = null
		invisibility = 101
		var/mob/living/silicon/robot/mommi/M = new /mob/living/silicon/robot/mommi(get_turf(loc))
		if(!M)	return
		M.invisibility = 0
		//M.custom_name = created_name
		M.Namepick()
		M.updatename()
		brainmob.mind.transfer_to(M)

		if(M.mind && M.mind.special_role)
			M.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")

		M.job = "Cyborg"

		M.cell = locate(/obj/item/weapon/cell) in contents
		M.cell.loc = M
		src.loc = M//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
		M.mmi = src
		return TRUE
	for(var/t in mommi_assembly_parts)
		if(istype(O,t))
			var/cc=contents_count(t)
			if(cc<mommi_assembly_parts[t])
				if(!brainmob)
					user << "<span class='warning'>Why are you sticking robot legs on an empty [src], you idiot?</span>"
					return TRUE
				contents += O
				user.drop_item()
				O.loc=src
				user << "<span class='notice'>You successfully add \the [O] to the contraption,</span>"
				return TRUE
			else if(cc==mommi_assembly_parts[t])
				user << "<span class='warning'>You have enough of these.</span>"
				return TRUE
	return FALSE

/obj/item/device/mmi/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(try_handling_mommi_construction(O,user))
		return
	if(istype(O,/obj/item/organ/brain) && !brainmob) //Time to stick a brain in it --NEO
		if(!O:brainmob)
			user << "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain.</span>"
			return
		for(var/mob/V in viewers(src, null))
			V.show_message(text("<span class='notice'>[user] sticks \a [O] into \the [src].</span>"))

		brainmob = O:brainmob
		O:brainmob = null
		brainmob.loc = src
		brainmob.container = src
		brainmob.stat = 0
		dead_mob_list -= brainmob//Update dem lists
		living_mob_list += brainmob

		user.drop_item()
		del(O)

		name = "Man-Machine Interface: [brainmob.real_name]"
		icon_state = "mmi_full"

		locked = 1

		feedback_inc("cyborg_mmis_filled",1)

		return

	if((istype(O,/obj/item/weapon/card/id)||istype(O,/obj/item/device/pda)) && brainmob)
		if(allowed(user))
			locked = !locked
			user << "<span class='notice'>You [locked ? "lock" : "unlock"] \the [src].</span>"
		else
			user << "<span class='warning'>Access denied.</span>"
		return
	if(brainmob)
		O.attack(brainmob, user)//Oh noooeeeee
		return
	..()

	//TODO: ORGAN REMOVAL UPDATE. Make the brain remain in the MMI so it doesn't lose organ data.
/obj/item/device/mmi/attack_self(mob/user as mob)
	if(!brainmob)
		user << "<span class='warning'>You upend \the [src], but there's nothing in it."
	else if(locked)
		user << "<span class='warning'>You upend \the [src], but the brain is clamped into place."
	else
		user << "<span class='notice'>You upend \the [src], spilling the brain onto the floor.</span>"
		var/obj/item/organ/brain/brain = new(user.loc)
		brainmob.container = null//Reset brainmob mmi var.
		brainmob.loc = brain//Throw mob into brain.
		living_mob_list -= brainmob//Get outta here
		brain.brainmob = brainmob//Set the brain to use the brainmob
		brainmob = null//Set mmi brainmob var to null

		icon_state = "mmi_empty"
		name = "Man-Machine Interface"

/obj/item/device/mmi/proc/transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	if(istype(H) && H.dna)
		brainmob.dna = H.dna.Clone()
	brainmob.container = src

	name = "Man-Machine Interface: [brainmob.real_name]"
	icon_state = "mmi_full"
	locked = 1
	return

/obj/item/device/mmi/radio_enabled
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	origin_tech = "biotech=4"

	var/obj/item/device/radio/radio = null//Let's give it a radio.

/obj/item/device/mmi/radio_enabled/New()
	..()
	radio = new(src)//Spawns a radio inside the MMI.
	radio.broadcasting = 0//So it's broadcasting from the start.

/obj/item/device/mmi/radio_enabled/verb/Toggle_Broadcasting()
	set name = "Toggle Broadcasting"
	set desc = "Toggle broadcasting channel on or off."
	set category = "MMI"
	set src = usr.loc//In user location, or in MMI in this case.
	set popup_menu = 0//Will not appear when right clicking.

	if(brainmob.stat)//Only the brainmob will trigger these so no further check is necessary.
		brainmob << "Can't do that while incapacitated or dead."

	radio.broadcasting = radio.broadcasting==1 ? 0 : 1
	brainmob << "<<span class='notice'>Radio is [radio.broadcasting==1 ? "now" : "no longer"] broadcasting.</span>"

/obj/item/device/mmi/radio_enabled/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = 0

	if(brainmob.stat)
		brainmob << "Can't do that while incapacitated or dead."

	radio.listening = radio.listening==1 ? 0 : 1
	brainmob << "<span class='notice'>Radio is [radio] receiving broadcast.</span>"

/obj/item/device/mmi/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()

/obj/item/device/mmi/proc/contents_count(var/type)
	var/c=0
	for(var/O in contents)
		if(istype(O,type))
			c++
	return c



/obj/item/device/mmi/examine(mob/user)
	user << "<span class='info'>*---------*</span>"
	..()
	if(src.brainmob)
		if(src.brainmob.stat == DEAD)
			user << "<span class='deadsay'>It appears the brain has suffered irreversible tissue degeneration</span>" //suicided
		else if(!src.brainmob.client)
			user << "<span class='notice'>It appears to be lost in its own thoughts</span>" //closed game window
		else if(!src.brainmob.key)
			user << "<span class='warning'>It seems to be in a deep dream-state</span>" //ghosted
	user << "<span class='info'>*---------*</span>"
	user << "<span class='info'>It's interface is [locked ? "locked" : "unlocked"] </span>"
