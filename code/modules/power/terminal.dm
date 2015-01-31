// the underfloor wiring terminal for the APC
// autogenerated when an APC is placed
// all conduit connects go to this object instead of the APC
// using this solves the problem of having the APC in a wall yet also inside an area

/obj/machinery/power/terminal
	name = "terminal"
	icon_state = "term"
	desc = "It's an underfloor wiring terminal for power equipment."
	level = 1
	layer = TURF_LAYER
	var/obj/machinery/power/master
	anchored = 1
	layer = 2.6 // a bit above wires


/obj/machinery/power/terminal/New()
	..()
	var/turf/T = src.loc
	if(level==1) hide(T.intact)
	return


/obj/machinery/power/terminal/hide(var/i)
	if(i)
		invisibility = 101
		icon_state = "term-f"
	else
		invisibility = 0
		icon_state = "term"

/obj/machinery/power/terminal/Destroy()
	if (master)
		master:terminal = null
		master = null

	..()
