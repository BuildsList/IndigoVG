
/obj/item/weapon/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher0"
	item_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 10
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 10.0
	m_amt = 90 // TODO: Check against autolathe.
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	attack_verb = list("slammed", "whacked", "bashed", "thunked", "battered", "bludgeoned", "thrashed")
	var/max_water = 50
	var/last_use = 1.0
	var/safety = 1
	var/sprite_name = "fire_extinguisher"

/obj/item/weapon/extinguisher/New()
	. = ..()
	create_reagents(max_water)
	reagents.add_reagent("water", max_water)

/obj/item/weapon/extinguisher/mini
	name = "fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	flags = FPRINT
	throwforce = 2
	w_class = 2.0
	force = 3.0
	m_amt = 0
	max_water = 30
	sprite_name = "miniFE"

/obj/item/weapon/extinguisher/foam
	name = "foam fire extinguisher"
	desc = "A modern foam fire supression system."
	icon_state = "foam_extinguisher0"
	item_state = "foam_extinguisher"
	sprite_name = "foam_extinguisher"

/obj/item/weapon/extinguisher/examine(mob/user)
	..()
	if(!is_open_container())
		user << "It contains:"
		if(reagents && reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				user << "<span class='info'>[R.volume] units of [R.name]</span>"
		else
			user << "<span class='info'>Nothing</span>"
	for(var/thing in src)
		user << "<span class='warning'>\A [thing] is jammed into the nozzle!</span>"

/obj/item/weapon/extinguisher/attack_self(mob/user as mob)
	safety = !safety
	src.icon_state = "[sprite_name][!safety]"
	src.desc = "The safety is [safety ? "on" : "off"]."
	user << "The safety is [safety ? "on" : "off"]."
	return

/obj/item/weapon/extinguisher/attackby(obj/item/W, mob/user)
	if(user.stat || user.restrained() || user.lying)	return
	if (istype(W, /obj/item/weapon/wrench))
		if(!is_open_container())
			user.visible_message("[user] begins to unwrench the fill cap on \the [src].","<span class='notice'>You begin to unwrench the fill cap on \the [src].</span>")
			if(do_after(user, 25))
				user.visible_message("[user] removes the fill cap on \the [src].","<span class='notice'>You remove the fill cap on \the [src].</span>")
				playsound(get_turf(src),'sound/items/Ratchet.ogg', 100, 1)
				flags |= OPENCONTAINER
		else
			user.visible_message("[user] begins to seal the fill cap on \the [src].","<span class='notice'>You begin to seal the fill cap on \the [src].</span>")
			if(do_after(user, 25))
				user.visible_message("[user] fastens the fill cap on \the [src].","<span class='notice'>You fasten the fill cap on \the [src].</span>")
				playsound(get_turf(src),'sound/items/Ratchet.ogg', 100, 1)
				flags &= ~OPENCONTAINER
		return

	if (istype(W, /obj/item) && !is_open_container())
		if(W.w_class>1)
			user << "\The [W] won't fit into the nozzle!"
			return
		if(locate(/obj) in src)
			user << "There's already something crammed into the nozzle."
			return
		if(isrobot(user) && !isMoMMI(user)) // MoMMI's can but borgs can't
			user << "You're a robot. No."
			return
		user.drop_item()
		W.loc=src
		user << "You cram \the [W] into the nozzle of \the [src]."
		message_admins("[user]/[user.ckey] has crammed \a [W] into a [src].")

/obj/item/weapon/extinguisher/afterattack(atom/target, mob/user , flag)
	user.delayNextAttack(5)
	if(get_dist(src,target) <= 1)
		if((istype(target, /obj/structure/reagent_dispensers)))
			var/obj/o = target
			var/list/badshit=list()
			for(var/bad_reagent in src.reagents_to_log)
				if(o.reagents.has_reagent(bad_reagent))
					badshit += reagents_to_log[bad_reagent]
			if(badshit.len)
				var/hl="<span class='danger'>([english_list(badshit)])"
				// message_admins("[user.name] ([user.ckey]) filled \a [src] with [o.reagents.get_reagent_ids()] [hl]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
				log_game("[user.name] ([user.ckey]) filled \a [src] with [o.reagents.get_reagent_ids()] [hl]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			o.reagents.trans_to(src, 50)
			user << "<span class='notice'>\The [src] is now refilled</span>"
			playsound(get_turf(src), 'sound/effects/refill.ogg', 50, 1, -6)
			return

		if(is_open_container() && reagents.total_volume)
			user << "<span class='notice'>You empty \the [src] onto [target].</span>"
			if(reagents.has_reagent("fuel"))
				message_admins("[user.name] ([user.ckey]) poured Welder Fuel onto [target]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
				log_game("[user.name] ([user.ckey]) poured Welder Fuel onto [target]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			src.reagents.reaction(target, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return
	if (!safety && !is_open_container())
		if (src.reagents.total_volume < 1)
			usr << "<span class='warning'>\The [src] is empty.</span>"
			return

		if (world.time < src.last_use + 20)
			return

		var/list/badshit=list()
		for(var/bad_reagent in src.reagents_to_log)
			if(reagents.has_reagent(bad_reagent))
				badshit += reagents_to_log[bad_reagent]
		if(badshit.len)
			var/hl="<span class='danger'>([english_list(badshit)])</span>"
			message_admins("[user.name] ([user.ckey]) used \a [src] filled with [reagents.get_reagent_ids(1)] [hl]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			log_game("[user.name] ([user.ckey]) used \a [src] filled with [reagents.get_reagent_ids(1)] [hl]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		src.last_use = world.time

		playsound(get_turf(src), 'sound/effects/extinguish.ogg', 75, 1, -3)

		var/direction = get_dir(src,target)

		if(usr.buckled && isobj(usr.buckled) && !usr.buckled.anchored )
			spawn(0)
				var/obj/B = usr.buckled
				var/movementdirection = turn(direction,180)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(usr,movementdirection), movementdirection)

		if(locate(/obj) in src)
			for(var/obj/thing in src)
				thing.loc = get_turf(src)
				thing.throw_at(target,10,rand(45,50))
				user.visible_message(
					"<span class='danger'>[user] fires [src] and launches [thing] at [target]!</span>",
					"<span class='danger'>You fire [src] and launch [thing] at [target]!</span>")
				break

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		for(var/a=0, a<5, a++)
			spawn(0)
				var/obj/effect/effect/water/W = new /obj/effect/effect/water( get_turf(src) )
				var/turf/my_target = pick(the_targets)
				var/datum/reagents/R = new/datum/reagents(5)
				if(!W) return
				W.reagents = R
				R.my_atom = W
				if(!W || !src) return
				src.reagents.trans_to(W,1)
				for(var/b=0, b<5, b++)
					step_towards(W,my_target)
					if(!W || !W.reagents) return
					W.reagents.reaction(get_turf(W), TOUCH)
					for(var/atom/atm in get_turf(W))
						if(!W) return
						W.reagents.reaction(atm, TOUCH)                      // Touch, since we sprayed it.
						if(W.reagents.has_reagent("water"))
							if(isliving(atm)) // For extinguishing mobs on fire
								var/mob/living/M = atm                           // Why isn't this handled by the reagent? - N3X
								M.ExtinguishMob()
							if(atm.on_fire) // For extinguishing objects on fire
								atm.extinguish()
							if(atm.molten) // Molten shit.
								atm.molten=0
								atm.solidify()
					if(W.loc == my_target) break
					sleep(2)

		if((istype(usr.loc, /turf/space)) || (usr.lastarea && usr.lastarea.has_gravity == 0))
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)
	else
		return ..()
	return




/obj/item/weapon/extinguisher/foam/afterattack(atom/target, mob/user , flag)
	if(get_dist(src,target) <= 1)
		if((istype(target, /obj/structure/reagent_dispensers/watertank)))
			var/obj/o = target
			o.reagents.trans_to(src, 50)
			user << "<span class='notice'>\The [src] is now refilled</span>"
			playsound(get_turf(src), 'sound/effects/refill.ogg', 50, 1, -6)
			return

	if (!safety && !is_open_container())
		if (src.reagents.total_volume < 1)
			usr << "<span class='warning'>\The [src] is empty."
			return

		if (world.time < src.last_use + 20)
			return

		src.last_use = world.time

		playsound(get_turf(src), 'sound/effects/extinguish.ogg', 75, 1, -3)

		var/direction = get_dir(src,target)

		if(usr.buckled && isobj(usr.buckled) && !usr.buckled.anchored )
			spawn(0)
				var/obj/B = usr.buckled
				var/movementdirection = turn(direction,180)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(1)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(2)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(usr,movementdirection), movementdirection)
				sleep(3)
				B.Move(get_step(usr,movementdirection), movementdirection)

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		for(var/a=0, a<5, a++)
			spawn(0)
				var/datum/reagents/R = new/datum/reagents(5)
				R.my_atom = src
				reagents.trans_to_holder(R,1)
				var/obj/effect/effect/foam/fire/W = new /obj/effect/effect/foam/fire( get_turf(src) , R)
				var/turf/my_target = pick(the_targets)
				if(!W || !src) return
				for(var/b=0, b<5, b++)
					var/turf/oldturf = get_turf(W)
					step_towards(W,my_target)
					if(!W || !W.reagents) return
					W.reagents.reaction(get_turf(W), TOUCH)
					for(var/atom/atm in get_turf(W))
						if(!W) return
						W.reagents.reaction(atm, TOUCH)                      // Touch, since we sprayed it.
						if(W.reagents.has_reagent("water"))
							if(isliving(atm)) // For extinguishing mobs on fire
								var/mob/living/M = atm                           // Why isn't this handled by the reagent? - N3X
								M.ExtinguishMob()
							if(atm.on_fire) // For extinguishing objects on fire
								atm.extinguish()
							if(atm.molten) // Molten shit.
								atm.molten=0
								atm.solidify()

					var/obj/effect/effect/foam/fire/F = locate() in oldturf
					if(!istype(F) && oldturf != get_turf(src))
						F = new /obj/effect/effect/foam/fire( get_turf(oldturf) , W.reagents)
					if(W.loc == my_target) break
					sleep(2)

		if((istype(usr.loc, /turf/space)) || (usr.lastarea && usr.lastarea.has_gravity == 0))
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)
	else
		return ..()
	return
