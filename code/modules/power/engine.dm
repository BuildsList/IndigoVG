/turf/simulated/floor/engine/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/engine/attack_hand(var/mob/user as mob)
	user.Move_Pulled(src)
	return

/turf/simulated/floor/engine/ex_act(severity)
	switch(severity)
		if(1.0)
			ChangeTurf(/turf/space)
			return
		if(2.0)
			if (prob(50))
				ChangeTurf(/turf/space)
				return
		else
	return

/turf/simulated/floor/engine/blob_act()
	if (prob(25))
		ChangeTurf(/turf/space)
		del(src)
		return
	return