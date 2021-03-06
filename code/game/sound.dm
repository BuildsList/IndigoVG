var/list/shatter_sound = list('sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg')
var/list/explosion_sound = list('sound/effects/Explosion1.ogg','sound/effects/Explosion2.ogg','sound/effects/Explosion3.ogg','sound/effects/Explosion4.ogg','sound/effects/Explosion5.ogg','sound/effects/Explosion6.ogg')
var/list/spark_sound = list('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
var/list/rustle_sound = list('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
var/list/punch_sound = list('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
var/list/clown_sound = list('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
var/list/swing_hit_sound = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
var/list/hiss_sound = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
var/list/page_sound = list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
var/list/mechstep_sound = list('sound/mecha/mechstep1.ogg', 'sound/mecha/mechstep2.ogg')
var/list/gib_sound = list('sound/effects/gib1.ogg', 'sound/effects/gib2.ogg', 'sound/effects/gib3.ogg')
var/list/mommicomment_sound = list('sound/voice/mommi_comment1.ogg', 'sound/voice/mommi_comment2.ogg', 'sound/voice/mommi_comment3.ogg', 'sound/voice/mommi_comment5.ogg', 'sound/voice/mommi_comment6.ogg', 'sound/voice/mommi_comment7.ogg', 'sound/voice/mommi_comment8.ogg')
//var/list/gun_sound = list('sound/weapons/Gunshot.ogg', 'sound/weapons/Gunshot2.ogg','sound/weapons/Gunshot3.ogg','sound/weapons/Gunshot4.ogg')
var/list/clownstep = list('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
var/list/swing_hit = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
var/list/hiss = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
var/list/pageturn = list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
var/list/step_concrete = list('sound/effects/footsteps/concrete_step1.ogg', 'sound/effects/footsteps/concrete_step2.ogg', 'sound/effects/footsteps/concrete_step3.ogg', 'sound/effects/footsteps/concrete_step4.ogg')
var/list/step_wood = list('sound/effects/footsteps/wood_step2.ogg', 'sound/effects/footsteps/wood_step3.ogg')
var/list/step_metall = list('sound/effects/footsteps/metalgrate_step1.ogg', 'sound/effects/footsteps/metalgrate_step2.ogg', 'sound/effects/footsteps/metalgrate_step3.ogg', 'sound/effects/footsteps/metalsolid_step1.ogg', 'sound/effects/footsteps/metalsolid_step2.ogg', 'sound/effects/footsteps/metalsolid_step3.ogg')
var/list/step_panel = list('sound/effects/footsteps/panel_step1.ogg', 'sound/effects/footsteps/panel_step2.ogg', 'sound/effects/footsteps/panel_step3.ogg')
var/list/step_sand = list('sound/effects/footsteps/sand_step1.ogg', 'sound/effects/footsteps/sand_step2.ogg', 'sound/effects/footsteps/sand_step3.ogg')
var/list/step_carpet = list('sound/effects/footsteps/carpet_step1.ogg', 'sound/effects/footsteps/carpet_step2.ogg', 'sound/effects/footsteps/carpet_step3.ogg', 'sound/effects/footsteps/carpet_step4.ogg')
var/list/step_grass = list('sound/effects/footsteps/earth_step1.ogg', 'sound/effects/footsteps/earth_step2.ogg', 'sound/effects/footsteps/earth_step3.ogg')
var/list/step_rubber = list('sound/effects/footsteps/rubber_step1.ogg', 'sound/effects/footsteps/rubber_step2.ogg', 'sound/effects/footsteps/rubber_step3.ogg', 'sound/effects/footsteps/rubber_step4.ogg')
var/list/step_dindon = list('sound/effects/footsteps/1.ogg', 'sound/effects/footsteps/2.ogg', 'sound/effects/footsteps/3.ogg', 'sound/effects/footsteps/4.ogg', 'sound/effects/footsteps/5.ogg', 'sound/effects/footsteps/6.ogg', 'sound/effects/footsteps/7.ogg', 'sound/effects/footsteps/8.ogg', 'sound/effects/footsteps/9.ogg', 'sound/effects/footsteps/10.ogg', 'sound/effects/footsteps/11.ogg', 'sound/effects/footsteps/12.ogg', 'sound/effects/footsteps/13.ogg', 'sound/effects/footsteps/14.ogg','sound/effects/footsteps/15.ogg','sound/effects/footsteps/16.ogg','sound/effects/footsteps/17.ogg','sound/effects/footsteps/18.ogg','sound/effects/footsteps/19.ogg','sound/effects/footsteps/20.ogg','sound/effects/footsteps/21.ogg','sound/effects/footsteps/22.ogg')


//gas_modified controls if a sound is affected by how much gas there is in the atmosphere of the source
//space sounds have no gas modification, for example. Though >space sounds
/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num, falloff, var/gas_modified = 1)

	soundin = get_sfx(soundin) // same sound for everyone

	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return

	var/frequency = get_rand_frequency() // Same frequency for everybody
	var/turf/turf_source = get_turf(source)


/* What's going on in this block?
	If the proc isn't set to not be modified by air, the following steps occur:
	- The atmospheric pressure of the turf where the sound is played is determined
	- A calculation is made as to the fraction of one atmosphere that the pressure is at, in tenths e.g. 0.1, 0.3, 0.7, never exceeding 1
	- If the proc has extrarange, the fraction of this extrarange that applies is equal to that of the pressure of the tile
	- If the proc has NO extrarange, the fraction of the 7 range is used, so a sound only trasmits to those in the screen at regular pressure
	- This means that at low or 0 pressure, sound doesn't trasmit from the tile at all! How cool is that?
*/
	if(!extrarange)
		extrarange = 0
	if(!vol) //don't do that
		return

	if(gas_modified && turf_source && !turf_source.c_airblock(turf_source)) //if the sound is modified by air, and we are on an airflowing tile
		var/atmosphere = 0
		var/datum/gas_mixture/current_air = turf_source.return_air()
		if(current_air)
			atmosphere = current_air.return_pressure()
		else
			atmosphere = 0 //no air

		//message_admins("We're starting off with [atmosphere], [extrarange], and [vol]")
		var/atmos_modifier = round(atmosphere/ONE_ATMOSPHERE, 0.1)
		var/total_range = world.view + extrarange //this must be positive.
		total_range = min ( round( (total_range) * sqrt(atmos_modifier), 1 ), (total_range * 2)  ) //upper range of twice the original range. Range technically falls off with the root of pressure (see Newtonian sound)
		extrarange = total_range - world.view
		vol = min( round( (vol) * atmos_modifier, 1 ), vol * 2) //upper range of twice the volume. Trust me, otherwise you get 10000 volume in a plasmafire
		//message_admins("We've adjusted the sound of [source] at [turf_source.loc] to have a range of [7 + extrarange] and a volume of [vol]")

 	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue
		if(get_dist(M, turf_source) <= world.view + extrarange)
			var/turf/T = get_turf(M)
			if(T && T.z == turf_source.z)
				M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, gas_modified)

var/const/FALLOFF_SOUNDS = 1
var/const/SURROUND_CAP = 7

#define MIN_SOUND_PRESSURE	2 //2 kPa of pressure required to at least hear sound
/mob/proc/playsound_local(var/turf/turf_source, soundin, vol as num, vary, frequency, falloff, gas_modified)
	if(!src.client || ear_deaf > 0)
		return

	if(gas_modified)
		var/turf/current_turf = get_turf(src)
		if(!current_turf)
			return

		var/datum/gas_mixture/environment = current_turf.return_air()
		var/atmosphere = 0
		if(environment)
			atmosphere = environment.return_pressure()

		/// Local sound modifications ///
		if(atmosphere < MIN_SOUND_PRESSURE) //no sound reception in space, boyos
			vol = 0
		else
			vol = min( vol * atmosphere / ONE_ATMOSPHERE, vol) //sound can't be amplified from low to high pressure, but can be reduced
		/// end ///

	soundin = get_sfx(soundin)

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)
		var/dx = turf_source.x - T.x // Hearing from the right/left

		S.x = round(max(-SURROUND_CAP, min(SURROUND_CAP, dx)), 1)

		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = round(max(-SURROUND_CAP, min(SURROUND_CAP, dz)), 1)

		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	src << S

/client/proc/playtitlemusic()
	if(!ticker || !ticker.login_music)	return
	if(prefs.toggles & SOUND_LOBBY)
		src << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("shatter") soundin = pick(shatter_sound)
			if ("explosion") soundin = pick(explosion_sound)
			if ("sparks") soundin = pick(spark_sound)
			if ("rustle") soundin = pick(rustle_sound)
			if ("punch") soundin = pick(punch_sound)
			if ("clownstep") soundin = pick(clown_sound)
			if ("swing_hit") soundin = pick(swing_hit_sound)
			if ("hiss") soundin = pick(hiss_sound)
			if ("pageturn") soundin = pick(page_sound)
			if ("mechstep") soundin = pick(mechstep_sound)
			if ("gib") soundin = pick(gib_sound)
			if ("mommicomment") soundin = pick(mommicomment_sound)
			//if ("gunshot") soundin = pick(gun_sound)
			if ("step_concrete") soundin = pick(step_concrete)
			if ("step_wood") soundin = pick(step_wood)
			if ("step_metall") soundin = pick(step_metall)
			if ("step_panel") soundin = pick(step_panel)
			if ("step_sand") soundin = pick(step_sand)
			if ("step_carpet") soundin = pick(step_carpet)
			if ("step_grass") soundin = pick(step_grass)
			if ("step_rubber") soundin = pick(step_rubber)
			if ("step_dindon") soundin = pick(step_dindon)

	return soundin