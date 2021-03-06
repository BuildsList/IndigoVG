/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to
	var/drying = 0 // tracking if something is currently drying
/turf/simulated/New()
	..()
	if(istype(loc, /area/chapel))
		holy = 1
	levelupdate()

/turf/simulated/proc/AddTracks(var/typepath,var/bloodDNA,var/comingdir,var/goingdir,var/bloodcolor="#A10808")
	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = new typepath(src)
	tracks.AddTracks(bloodDNA,comingdir,goingdir,bloodcolor)

/turf/simulated/Entered(atom/A, atom/OL)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		usr << "<span class='warning'>Movement is admin-disabled.</span>" //This is to identify lag problems
		return

	if (istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.lying)	return
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M

			if(istype(H.shoes, /obj/item/clothing/shoes/))
				var/steppath
				if(istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
					steppath = "clownstep"
				else
					if(istype(H.loc, /turf/simulated/floor/carpet))
						steppath = "step_carpet"
					else if(istype(H.loc, /turf/simulated/floor/beach/sand))
						steppath = "step_sand"
					else if(istype(H.loc, /turf/simulated/floor/wood))
						steppath = "step_wood"
					else if(istype(H.loc, /turf/simulated/floor/engine))
						steppath = "step_metall"
					else if(istype(H.loc, /turf/simulated/floor/vault))
						steppath = "step_panel"
					else if(istype(H.loc, /turf/simulated/floor/grass))
						steppath = "step_grass"
		/*			else if(istype(H.loc, /turf/simulated/floor/music))
						if(O.footstep >= 2)
							steppath = "din_don_step"
							flick("light_on-b", src)
							O.footstep = 0
						else
							steppath = "din_don_step"
							flick("light_on-r", src)
							O.footstep ++
						return*/
					else if(istype(H.loc, /turf/simulated/floor))
						steppath = "step_concrete"
					else if(istype(H.loc, /turf/simulated))
						steppath = "step_rubber"
				if(M.m_intent == "run")
					playsound(src, steppath, pick(60,20,0,0), 1)
				else
					playsound(src, steppath, pick(5,10,0,0), 1)


			// Tracking blood
			var/list/bloodDNA = null
			var/bloodcolor=""
			if(H.shoes)
				var/obj/item/clothing/shoes/S = H.shoes
				if(S.track_blood && S.blood_DNA)
					bloodDNA = S.blood_DNA
					bloodcolor=S.blood_color
					S.track_blood--
			else
				if(H.track_blood && H.feet_blood_DNA)
					bloodDNA = H.feet_blood_DNA
					bloodcolor=H.feet_blood_color
					H.track_blood--

			if (bloodDNA)
				if(istype(M,/mob/living/carbon/human/vox))
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/vox,bloodDNA,H.dir,0,bloodcolor) // Coming
				else
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,H.dir,0,bloodcolor) // Coming
				var/turf/simulated/from = get_step(H,reverse_direction(H.dir))
				if(istype(from) && from)
					if(istype(M,/mob/living/carbon/human/vox))
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/vox,bloodDNA,0,H.dir,bloodcolor) // Going
					else
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,0,H.dir,bloodcolor) // Going

			bloodDNA = null

			// Floorlength braids?  Enjoy your tripping.
			if((H.h_style && !(H.head && (H.head.flags & BLOCKHEADHAIR))))
				var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
				if(hair_style && (hair_style.flags & HAIRSTYLE_CANTRIP))
					if(H.m_intent == "run" && prob(5))
						H.stop_pulling()
						step(H, H.dir)
						H << "<span class='notice'>You tripped over your hair!</span>"
						playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
						H.Stun(4)
						H.Weaken(5)

		switch (src.wet)
			if(1)
				if(istype(M, /mob/living/carbon/human)) // Added check since monkeys don't have shoes
					if ((M.m_intent == "run") && !(istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP))
						M.stop_pulling()
						step(M, M.dir)
						M << "<span class='notice'>You slipped on the wet floor!</span>"
						playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(5)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return
				else if(!istype(M, /mob/living/carbon/slime))
					if (M.m_intent == "run")
						M.stop_pulling()
						step(M, M.dir)
						M << "<span class='notice'>You slipped on the wet floor!</span>"
						playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(5)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return

			if(2) //lube		//can cause infinite loops - needs work
				if(!istype(M, /mob/living/carbon/slime))
					M.stop_pulling()
					step(M, M.dir)
					spawn(1) step(M, M.dir)
					spawn(2) step(M, M.dir)
					spawn(3) step(M, M.dir)
					spawn(4) step(M, M.dir)
					M.take_organ_damage(2) // Was 5 -- TLE
					M << "<span class='notice'>You slipped on the floor!</span>"
					playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
					M.Weaken(10)
			if(3) // Ice
				if(istype(M, /mob/living/carbon/human)) // Added check since monkeys don't have shoes
					if ((M.m_intent == "run") && !(istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP) && prob(30))
						M.stop_pulling()
						step(M, M.dir)
						M << "<span class='notice'>You slipped on the icy floor!</span>"
						playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(4)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return
				else if(!istype(M, /mob/living/carbon/slime))
					if (M.m_intent == "run" && prob(30))
						M.stop_pulling()
						step(M, M.dir)
						M << "<span class='notice'>You slipped on the icy floor!</span>"
						playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(4)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return

	..()

//returns 1 if made bloody, returns 0 otherwise
/turf/simulated/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0

	for(var/obj/effect/decal/cleanable/blood/B in contents)
		if(!B.blood_DNA[M.dna.unique_enzymes])
			B.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
			B.virus2 = virus_copylist(M.virus2)
		return 1 //we bloodied the floor

	blood_splatter(src,M,1)
	return 1 //we bloodied the floor


// Only adds blood on the floor -- Skie
/turf/simulated/proc/add_blood_floor(mob/living/carbon/M as mob)
	if(istype(M, /mob/living/carbon/monkey))
		blood_splatter(src,M,1)
	else if( istype(M, /mob/living/carbon/alien ))
		var/obj/effect/decal/cleanable/blood/xeno/this = new /obj/effect/decal/cleanable/blood/xeno(src)
		this.blood_DNA["UNKNOWN BLOOD"] = "X*"
	else if( istype(M, /mob/living/silicon/robot ))
		new /obj/effect/decal/cleanable/blood/oil(src)
