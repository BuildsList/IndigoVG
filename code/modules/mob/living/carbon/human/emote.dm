/mob/living/carbon/human/emote(var/act,var/m_type=1,var/message = null, var/auto)
	var/param = null

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	//var/m_type = VISIBLE

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	if(src.stat == 2.0 && (act != "deathgasp"))
		return

	if(act == "oath" && src.miming)
		src.miming = 0
		for(var/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall/s in src.spell_list)
			del(s)
		message_admins("[src.name] ([src.ckey]) has broken their oath of silence. (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</a>)")
		src << "<span class = 'notice'>An unsettling feeling surrounds you...</span>"
		return

	switch(act)
		if ("airguitar")
			if (!src.restrained())
				message = "<B>[src]</B> бренчит по воздуху и дергает головой, как дика&#255; обезь&#255;на." // Translate it 2916
				m_type = VISIBLE

		if ("blink")
			message = "<B>[src]</B> моргает." // Translate it 2917
			m_type = VISIBLE

		if ("blink_r")
			message = "<B>[src]</B> быстро моргает." // Translate it 2918
			m_type = VISIBLE

		if ("bow")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> клан&#255;етс&#255; [param]." // Translate it 2919
				else
					message = "<B>[src]</B> клан&#255;етс&#255;." // Translate it 2920
			m_type = VISIBLE

		if ("custom")
			var/input = copytext(sanitize(input("Choose an emote to display.") as text|null),1,MAX_MESSAGE_LEN)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = VISIBLE
			else if (input2 == "Hearable")
				if (src.miming)
					return
				m_type = HEARABLE
			else
				alert("Невозможно использовать эту эмоцию, она должна быть видима&#255; или слышима&#255;.") // Translate it 2922
				return
			return custom_emote(m_type, message)

		if ("me")
			if(silent)
				return
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					src << "<span class = 'warning'>You cannot send IC messages (muted).</span>"
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if ("salute")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> отдает честь [param]." // Translate it 2924
				else
					message = "<B>[src]</b> салютует." // Translate it 2925
			m_type = VISIBLE

		if ("choke")
			if(miming)
				message = "<B>[src]</B> отча&#255;нно хватаетс&#255; за горло!" // Translate it 2926
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> задыхаетс&#255;!" // Translate it 2927
					m_type = HEARABLE
					message = "<B>[src]</B> издает сильный шум." // Translate it 2928
					m_type = HEARABLE

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> хлопает." // Translate it 2929
				m_type = HEARABLE
				if(miming)
					m_type = VISIBLE
		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> хлопает крыльями." // Translate it 2930
				m_type = HEARABLE
				if(miming)
					m_type = VISIBLE

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> ЗЛОБНО хлопает крыльями!" // Translate it 2931
				m_type = HEARABLE
				if(miming)
					m_type = VISIBLE

		if ("drool")
			message = "<B>[src]</B> пускает слюни." // Translate it 2932
			m_type = VISIBLE

		if ("eyebrow")
			message = "<B>[src]</B> поднимает бровь." // Translate it 2933
			m_type = VISIBLE

		if ("chuckle")
			if(miming)
				message = "<B>[src]</B> appears to chuckle."
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> хихикает." // Translate it 2935
					m_type = HEARABLE
				else
					message = "<B>[src]</B> издаёт невнятный звук."
					m_type = HEARABLE

		if ("twitch")
			message = "<B>[src]</B> &#255;ростно дергаетс&#255;." // Translate it 2937
			m_type = VISIBLE

		if ("twitch_s")
			message = "<B>[src]</B> дергаетс&#255;." // Translate it 2938
			m_type = VISIBLE

		if ("faint")
			message = "<B>[src]</B> падает в обморок." // Translate it 2939
			if(src.sleeping)
				return //Can't faint while asleep
			src.sleeping += 10 //Short-short nap
			m_type = VISIBLE

		if ("cough")
			if(miming)
				message = "<B>[src]</B> appears to cough!"
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> кашл&#255;ет!" // Translate it 2941
					m_type = HEARABLE
				else
					message = "<B>[src]</B> издает сильный шум." // Translate it 2942
					m_type = HEARABLE

		if ("frown")
			message = "<B>[src]</B> хмуритс&#255;." // Translate it 2943
			m_type = VISIBLE

		if ("nod")
			message = "<B>[src]</B> кивает." // Translate it 2944
			m_type = VISIBLE

		if ("blush")
			message = "<B>[src]</B> [src.gender==FEMALE?"покраснела":"краснеет"]." // Translate it 2945
			m_type = VISIBLE

		if ("wave")
			message = "<B>[src]</B> шатаетс&#255;." // Translate it 2946
			m_type = VISIBLE

		if ("gasp")
			if(miming)
				message = "<B>[src]</B>  по видимому, задыхаетс&#255;!" // Translate it 2947
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> задыхаетс&#255;!" // Translate it 2948
					m_type = HEARABLE
				else
					message = "<B>[src]</B> издает слабый шум." // Translate it 2949
					m_type = HEARABLE

		if ("deathgasp")
			if(M_ELVIS in mutations)
				src.emote("fart")
				message = "<B>[src]</B> has left the building..."
			if(M_HARDCORE in mutations)
				message = "<B>[src]</B> whispers with his final breath, <i>'i told u i was hardcore..'</i>"
			else
				message = "<B>[src]</B> seizes up and falls limp, \his eyes dead and lifeless..."
			m_type = VISIBLE

		if ("giggle")
			if(miming)
				message = "<B>[src]</B> тихо хихикает!" // Translate it 2951
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> хихикает." // Translate it 2952
					m_type = HEARABLE
				else
					message = "<B>[src]</B> шумит." // Translate it 2953
					m_type = HEARABLE

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> п&#255;литс&#255; на [param]." // Translate it 2954
			else
				message = "<B>[src]</B> смотрит." // Translate it 2955

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> наблюдает за [param]." // Translate it 2956
			else
				message = "<B>[src]</B> stares."

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> смотрит на [param]." // Translate it 2958
			else
				message = "<B>[src]</B> смотрит." // Translate it 2959
			m_type = VISIBLE

		if ("grin")
			message = "<B>[src]</B> скалит зубы." // Translate it 2960
			m_type = VISIBLE

		if ("cry")
			if(miming)
				message = "<B>[src]</B> плачет." // Translate it 2961
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> плачет." // Translate it 2962
					m_type = HEARABLE
				else
					message = "<B>[src]</B> насуплив брови издает слабый шум."// \He frowns. // Translate it 2963
					m_type = HEARABLE

		if ("sigh")
			if(miming)
				message = "<B>[src]</B> вздыхает." // Translate it 2964
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> охает." // Translate it 2965
					m_type = HEARABLE
				else
					message = "<B>[src]</B> издает слабый шум." // Translate it 2966
					m_type = HEARABLE

		if ("laugh")
			if(miming)
				message = "<B>[src]</B> издает смешок." // Translate it 2967
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> смеетс&#255;." // Translate it 2968
					m_type = HEARABLE
				else
					message = "<B>[src]</B> шумит." // Translate it 2969
					m_type = HEARABLE
/*
		if("elaugh")
			if(miming)
				message = "<B>[src]</B> acts out a laugh."
				m_type = 1
			else if (mind.special_role)
				if(!(world.time-lastElaugh >= 600))
					usr << "<span class='warning'>You not ready to laugh again!"
				else
					message = "<B>[src]</B> laugh like a true evil! Mu-ha-ha!"
					m_type = 2
					call_sound_emote("elaugh")
					lastElaugh=world.time
			else
				if (!muzzled)
					if (!(world.time-lastElaugh >= 600))
						usr << "<span class='warning'>You not ready to laugh again!"
					else
						message = "<B>[src]</B> laughs."
						m_type = 2
						call_sound_emote("laugh")
				else
					message = "<B>[src]</B> makes a noise."
					m_type = 2
*/
		if ("mumble")
			message = "<B>[src]</B> бормочет!" // Translate it 2970
			m_type = HEARABLE
			if(miming)
				m_type = VISIBLE

		if ("grumble")
			if(miming)
				message = "<B>[src]</B> ворчит!" // Translate it 2971
				m_type = VISIBLE
			if (!muzzled)
				message = "<B>[src]</B> ворчит!" // Translate it 2971
				m_type = HEARABLE
			else
				message = "<B>[src]</B> шумит." // Translate it 2973
				m_type = HEARABLE

		if ("groan")
			if(miming)
				message = "<B>[src]</B> издает стон!" // Translate it 2974
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> cтонет!" // Translate it 2975
					m_type = HEARABLE
				else
					message = "<B>[src]</B> издает громкий шум." // Translate it 2976
					m_type = HEARABLE

		if ("moan")
			if(miming)
				message = "<B>[src]</B> стонет!" // Translate it 2977
				m_type = VISIBLE
			else
				message = "<B>[src]</B> стонет от наслаждени&#255;!" // Translate it 2978
				m_type = HEARABLE

		if ("johnny")
			var/M
			if (param)
				M = param
			if (!M)
				param = null
			else
				if(miming)
					message = "<B>[src]</B>  затягиваетс&#255; сигаретой и выдыхает дым \"[M]\" в дыму." // Translate it 2979
					m_type = VISIBLE
				else
					message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] затягиваетс&#255; сигаретой и выдувает свое им&#255;." // Translate it 2980
					m_type = HEARABLE

		if ("point")
			if (!src.restrained())
				var/atom/object_pointed = null

				if(param)
					for(var/atom/visible_object as turf | obj | mob in view())
						if(param == visible_object.name)
							object_pointed = visible_object
							break

				if(isnull(object_pointed))
					message = "<B>[src]</B> тычет пальцем." // Translate it 2981
				else
					pointed(object_pointed)

			m_type = VISIBLE

		if ("raise")
			if (!src.restrained())
				message = "<B>[src]</B> поднимает руки." // Translate it 2983
			m_type = VISIBLE

		if("shake")
			message = "<B>[src]</B> тр&#255;сет головой." // Translate it 2984
			m_type = VISIBLE

		if ("shrug")
			message = "<B>[src]</B> пожимает плечами." // Translate it 2985
			m_type = VISIBLE

		if ("signal")
			if (!src.restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1))
					if (t1 <= 5 && (!src.r_hand || !src.l_hand))
						message = "<B>[src]</B> поднимает [t1] пальцев." // Translate it 2986
					else if (t1 <= 10 && (!src.r_hand && !src.l_hand))
						message = "<B>[src]</B> поднимает [t1] пальцев." // Translate it 2987
			m_type = VISIBLE

		if ("smile")
			message = "<B>[src]</B> улыбаетс&#255;." // Translate it 2988
			m_type = VISIBLE

		if ("shiver")
			message = "<B>[src]</B> вздрагивает." // Translate it 2989
			m_type = HEARABLE
			if(miming)
				m_type = VISIBLE

		if ("pale")
			message = "<B>[src]</B> бледнеет на секунду." // Translate it 2990
			m_type = VISIBLE

		if ("tremble")
			message = "<B>[src]</B> дрожит в страхе!" // Translate it 2991
			m_type = VISIBLE

		if ("sneeze")
			if (miming)
				message = "<B>[src]</B> чихает." // Translate it 2992
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> чихает." // Translate it 2993
					m_type = HEARABLE
				else
					message = "<B>[src]</B> издает странный шум." // Translate it 2994
					m_type = HEARABLE

		if ("sniff")
			message = "<B>[src]</B> нюхает." // Translate it 2995
			m_type = HEARABLE
			if(miming)
				m_type = VISIBLE

		if ("snore")
			if (miming)
				message = "<B>[src]</B> громко сопит." // Translate it 2996
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> храпит." // Translate it 2997
					m_type = HEARABLE
				else
					message = "<B>[src]</B> шумит." // Translate it 2998
					m_type = HEARABLE

		if ("whimper")
			if (miming)
				message = "<B>[src]</B> стонет от боли." // Translate it 2999
				m_type = VISIBLE
			else
				if (!muzzled)
					message = "<B>[src]</B> хнычет." // Translate it 3000
					m_type = HEARABLE
				else
					message = "<B>[src]</B> издает слабый шум." // Translate it 3001
					m_type = HEARABLE

		if ("wink")
			message = "<B>[src]</B> подмигивает." // Translate it 3002
			m_type = VISIBLE

		if ("yawn")
			if (!muzzled)
				message = "<B>[src]</B> зевает." // Translate it 3003
				m_type = HEARABLE
				if(miming)
					m_type = VISIBLE

		if ("collapse")
			Paralyse(2)
			message = "<B>[src]</B> падает!" // Translate it 3004
			m_type = HEARABLE
			if(miming)
				m_type = VISIBLE

		if("hug")
			m_type = VISIBLE
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(2, src))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					message = "<B>[src]</B> обнимает [M]." // Translate it 3005
				else
					message = "<B>[src]</B> обнимает себ&#255;." // Translate it 3006

		if ("handshake")
			m_type = VISIBLE
			if (!src.restrained() && !src.r_hand)
				var/mob/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (M.canmove && !M.r_hand && !M.restrained())
						message = "<B>[src]</B> пожимает руку [M]." // Translate it 3007
					else
						message = "<B>[src]</B> прот&#255;гивает руку [M]." // Translate it 3008

		if("dap")
			m_type = VISIBLE
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M)
					message = "<B>[src]</B> даёт пощёчину [M]." // Translate it 3009
				else
					message = "<B>[src]</B> разочаровавшись что не может найти кому дать пощёчину даёт пощёчину себе. Позорище." // Translate it 3010

		if ("tip")
			message = "<B>[src]</B> поправл&#255;ет чёлку." // Translate it 3011
			m_type = HEARABLE
			if(miming)
				m_type = VISIBLE

		if ("scream")
			if (miming)
				message = "<B>[src]</B> acts out a scream!"
				m_type = VISIBLE
			else
				if(!stat)
					if (!muzzled)
						if (auto == 1)
							if(world.time-lastScream >= 30)//prevent scream spam with things like poly spray
//								message = "<B>[src]</B> screams in agony!"
//								var/list/screamSound = list('sound/misc/malescream1.ogg', 'sound/misc/malescream2.ogg', 'sound/misc/malescream3.ogg', 'sound/misc/malescream4.ogg', 'sound/misc/malescream5.ogg', 'sound/misc/wilhelm.ogg', 'sound/misc/goofy.ogg')
//								if (src.gender == FEMALE) //Females have their own screams. Trannys be damned.
//									screamSound = list('sound/misc/femalescream1.ogg', 'sound/misc/femalescream2.ogg', 'sound/misc/femalescream3.ogg', 'sound/misc/femalescream4.ogg', 'sound/misc/femalescream5.ogg')
//								var/scream = pick(screamSound)//AUUUUHHHHHHHHOOOHOOHOOHOOOOIIIIEEEEEE
//								playsound(get_turf(src), scream, 50, 0)
								call_sound_emote("scream")
								m_type = HEARABLE
								lastScream = world.time
						else
							message = "<B>[src]</B> кричит!" // Translate it 3011
							m_type = HEARABLE
					else
						message = "<B>[src]</B> издает очень громкий шум." // Translate it 3013
						m_type = HEARABLE

		// Needed for M_TOXIC_FART
		if("fart")
			if(src.op_stage.butt != 4)
				if(world.time-lastFart >= 400)
					for(var/mob/M in view(0))
						if(M != src && M.loc == src.loc)
							if(!miming)
								visible_message("<span class = 'warning'><b>[src]</b> farts in <b>[M]</b>'s face!</span>")
							else
								visible_message("<span class = 'warning'><b>[src]</b> silently farts in <b>[M]</b>'s face!</span>")
						else
							continue
					/*

					GAY BROKEN SHIT

					for(var/mob/M in view(1))
						if(M != src)
							if(!miming)
								visible_message("\red <b>[src]</b> farts in <b>[M]</b>'s face!")
							else
								visible_message("\red <b>[src]</b> silently farts in <b>[M]</b>'s face!")
						else
							continue

					GAY BROKEN SHIT

					*/

					var/list/farts = list(
						"farts",
						"passes wind",
						"toots",
						"farts [pick("lightly", "tenderly", "softly", "with care")]",
						)

					if(miming)
						farts = list("silently farts.", "acts out a fart.", "lets out a silent fart.")

					var/fart = pick(farts)

					if(!miming)
						message = "<b>[src]</b> [fart]."
						if(mind && mind.assigned_role == "Clown")
							playsound(get_turf(src), pick('sound/items/bikehorn.ogg','sound/items/AirHorn.ogg'), 50, 1)
						else
							playsound(get_turf(src), 'sound/misc/fart.ogg', 50, 1)
					else
						message = "<b>[src]</b> [fart]"
						//Mimes can't fart.
					m_type = HEARABLE
					var/turf/location = get_turf(src)
					var/aoe_range=2 // Default
					if(M_SUPER_FART in mutations)
						aoe_range+=3 //Was 5

					// If we're wearing a suit, don't blast or gas those around us.
					var/wearing_suit=0
					var/wearing_mask=0
					if(wear_suit && wear_suit.body_parts_covered & LOWER_TORSO)
						wearing_suit=1
						if (internal != null && wear_mask && (wear_mask.flags & MASKINTERNALS))
							wearing_mask=1

					// Process toxic farts first.
					if(M_TOXIC_FARTS in mutations)
						message=""
						playsound(get_turf(src), 'sound/effects/superfart.ogg', 50, 1)
						if(wearing_suit)
							if(!wearing_mask)
								src << "<span class = 'warning'>You gas yourself!</span>"
								reagents.add_reagent("space_drugs", rand(10,50))
						else
							// Was /turf/, now /mob/
							for(var/mob/M in view(location,aoe_range))
								if (M.internal != null && M.wear_mask && (M.wear_mask.flags & MASKINTERNALS))
									continue
								if(!airborne_can_reach(location,get_turf(M),aoe_range))
									continue
								// Now, we don't have this:
								//new /obj/effects/fart_cloud(T,L)
								// But:
								// <[REDACTED]> so, what it does is...imagine a 3x3 grid with the person in the center. When someone uses the emote *fart (it's not a spell style ability and has no cooldown), then anyone in the 8 tiles AROUND the person who uses it
								// <[REDACTED]> gets between 1 and 10 units of jenkem added to them...we obviously don't have Jenkem, but Space Drugs do literally the same exact thing as Jenkem
								// <[REDACTED]> the user, of course, isn't impacted because it's not an actual smoke cloud
								// So, let's give 'em space drugs.
								M.reagents.add_reagent("space_drugs",rand(1,50))
							/*
							var/datum/effect/effect/system/smoke_spread/chem/fart/S = new /datum/effect/effect/system/smoke_spread/chem/fart
							S.attach(location)
							S.set_up(src, 10, 0, location)
							spawn(0)
								S.start()
								sleep(10)
								S.start()
							*/
					if(M_SUPER_FART in mutations)
						message=""
						playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
						visible_message("<span class = 'warning'><b>[name]</b> hunches down and grits their teeth!</span>")
						if(do_after(usr,30))
							visible_message("<span class = 'warning'><b>[name]</b> unleashes a [pick("tremendous","gigantic","colossal")] fart!</span>","<span class = 'warning'>You hear a [pick("tremendous","gigantic","colossal")] fart.</span>")
							//playsound(L.loc, 'superfart.ogg', 50, 0)
							if(!wearing_suit)
								for(var/mob/living/V in view(src,aoe_range))
									shake_camera(V,10,5)
									if (V == src)
										continue
									V << "<span class = 'danger'>You're sent flying!</span>"
									V.Weaken(5) // why the hell was this set to 12 christ
									step_away(V,location,15)
									step_away(V,location,15)
									step_away(V,location,15)
						else
							usr << "<span class = 'notice'>You were interrupted and couldn't fart! Rude!</span>"
					lastFart=world.time
				else
					message = "<b>[src]</b> strains, and nothing happens."
					m_type = VISIBLE
			else
				message = "<b>[src]</b> lets out a [pick("disgusting","revolting","horrible","strangled","god awful")] noise out of \his mutilated asshole."
				m_type = HEARABLE
		if ("help")
			src << "blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough,\ncry, custom, deathgasp, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn"

		else
			src << "<span class = 'notice'>Unusable emote '[act]'. Say *help for a list.</span>"





	if (message)
		log_emote("[name]/[key] (@[x],[y],[z]): [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)


		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src.loc, null))
				O.show_message(message, m_type)

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  copytext(sanitize(input(usr, "This is [src]. \He is...", "Pose", null)  as text), 1, MAX_MESSAGE_LEN)

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text =  copytext(sanitize(input(usr, "Please enter your new flavour text.", "Flavour text", null)  as text), 1)

/mob/living/carbon/human/proc/call_sound_emote(var/E)
	switch(E)
		if("scream")
			if (src.gender == "male")
				playsound(src.loc, pick('sound/emotions/male/Screams_Male_1.ogg', 'sound/emotions/male/Screams_Male_2.ogg', 'sound/emotions/male/Screams_Male_3.ogg', 'sound/misc/malescream1.ogg', 'sound/misc/malescream2.ogg', 'sound/misc/malescream3.ogg', 'sound/misc/malescream4.ogg', 'sound/misc/malescream5.ogg', 'sound/misc/wilhelm.ogg', 'sound/misc/goofy.ogg'), 100, 1)
			else
				playsound(src.loc, pick('sound/emotions/female/Screams_Woman_1.ogg', 'sound/emotions/female/Screams_Woman_2.ogg', 'sound/emotions/female/Screams_Woman_3.ogg', 'sound/misc/femalescream1.ogg', 'sound/misc/femalescream2.ogg', 'sound/misc/femalescream3.ogg', 'sound/misc/femalescream4.ogg', 'sound/misc/femalescream5.ogg'), 100, 1)

		if("laugh")
			if (src.gender == "male")
				playsound(src.loc, pick('sound/emotions/male/male_laugh_1.ogg', 'sound/emotions/male/male_laugh_2.ogg', 'sound/emotions/male/male_laugh_3.ogg'), 100, 1)
			else
				playsound(src.loc, pick('sound/emotions/female/female_laugh_1.ogg', 'sound/emotions/female/female_laugh_2.ogg'), 100, 1)
/*
		if("fart")
			playsound(playsound(src.loc, 'fart.ogg', 65, 1))

		if("elaugh")
			playsound(src.loc, 'sound/voice/elaugh.ogg', 100, 1)

		if("z_roar")
			playsound(src.loc, 'sound/voice/z_roar.ogg', 100, 1)

		if("z_shout")
			playsound(src.loc, 'sound/voice/z_shout.ogg', 100, 1)

		if("z_mutter")
			playsound(src.loc, 'sound/voice/z_mutter.ogg', 100, 1)
*/