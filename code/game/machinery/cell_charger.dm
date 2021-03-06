/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 60
	power_channel = EQUIP
	var/obj/item/weapon/cell/charging = null
	var/chargelevel = -1

	machine_flags = WRENCHMOVE | FIXED2WORK

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

/obj/machinery/cell_charger/proc/updateicon()
	icon_state = "ccharger[charging ? 1 : 0]"

	if(charging && !(stat & (BROKEN|NOPOWER)) )

		var/newlevel = 	round(charging.percent() * 4.0 / 99)
		//world << "nl: [newlevel]"

		if(chargelevel != newlevel)

			overlays.len = 0
			overlays += "ccharger-o[newlevel]"

			chargelevel = newlevel
	else
		overlays.len = 0

/obj/machinery/cell_charger/examine(mob/user)
	..()
	user << "There's [charging ? "a" : "no"] cell in the charger."
	if(charging)
		user << "Current charge: [charging.charge]"

/obj/machinery/cell_charger/attackby(obj/item/weapon/W, mob/user)
	if(stat & BROKEN)
		return

	..()
	if(istype(W, /obj/item/weapon/cell) && anchored)
		if(charging)
			user << "<span class='warning'>There is already a cell in the charger.</span>"
			return
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				user << "<span class='warning'>The [name] blinks red as you try to insert the cell!</span>"
				return

			user.drop_item()
			W.loc = src
			charging = W
			user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
			chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/attack_hand(mob/user)
	if(charging)
		usr.put_in_hands(charging)
		charging.add_fingerprint(user)
		charging.updateicon()

		src.charging = null
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
		chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/wrenchAnchor(mob/user)
	if(charging)
		user << "<span class='warning'>Remove the cell first!</span>"
		return
	..()

/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	if(charging)
		charging.emp_act(severity)
	..(severity)


/obj/machinery/cell_charger/process()
	//world << "ccpt [charging] [stat]"
	if(!charging || (stat & (BROKEN|NOPOWER)) || !anchored)
		return

	use_power(200)		//this used to use CELLRATE, but CELLRATE is fucking awful. feel free to fix this properly!
	charging.give(175)	//inefficiency.

	updateicon()
