/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply."
	icon_state = "gas_alt"
	flags = FPRINT  | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	w_class = 3.0
	can_flip = 1
	action_button_name = "Toggle Mask"
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	species_fit = list("Vox")
	body_parts_covered = FULL_HEAD

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out toxins but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list(melee = 0, bullet = 0, laser = 2,energy = 2, bomb = 0, bio = 75, rad = 0)
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	siemens_coefficient = 0.7
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	siemens_coefficient = 0.7
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	//desc = "A face-covering mask that can be connected to an air supply. It seems to house some odd electronics."
	var/mode = 0// 0==Scouter | 1==Night Vision | 2==Thermal | 3==Meson
	var/voice = "Unknown"
	var/vchange = 1//This didn't do anything before. It now checks if the mask has special functions/N
	origin_tech = "syndicate=4"
	action_button_name = "Toggle Mask"
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/voice/attack_self(mob/user)
	vchange = !vchange
	user << "<span class='notice'>The voice changer is now [vchange ? "on" : "off"]!</span>"

/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	vchange = 1
	siemens_coefficient = 0.2
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/clown_hat/wiz
	name = "clown wig and mask"
	desc = "Some pranksters are truly magical."
	icon_state = "wizzclown"
	item_state = "wizzclown"
	//TODO species_fit = list("Vox")

/obj/item/clothing/mask/gas/virusclown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	icon_state = "sexyclown"
	item_state = "sexyclown"
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon_state = "sexymime"
	item_state = "sexymime"
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death"
	item_state = "death"
	siemens_coefficient = 0.2
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop"
	icon_state = "death"
	species_fit = list("Vox")

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	species_fit = list("Vox")

/////////////////////////////////// PAYDAY 2 CLOAKER GASMASK /////////////////////////////////////
//////////////////////////////////        by Loly            /////////////////////////////////////

/obj/item/clothing/mask/gas/clocker
	name = "cloaker gas mask"
	desc = "A high-tier issue gas mask with integrated 'Cloak-o-nator 3000' device, plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you taze them. Do not tamper with the device."
	action_button_name = "Say something funny!"
	icon_state = "cloaker"
	can_flip = null
	origin_tech = "magnets=2"
	see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	see_in_dark = 8
	var/cooldown = 0
	var/aggressiveness = 2

/obj/item/clothing/mask/gas/clocker/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		switch(aggressiveness)
			if(1)
				user << "\blue You set the restrictor to the middle position."
				aggressiveness = 2
			if(2)
				user << "\blue You set the restrictor to the last position."
				aggressiveness = 3
			if(3)
				user << "\blue You set the restrictor to the first position."
				aggressiveness = 1
			if(4)
				user << "\red You adjust the restrictor but nothing happens, probably because its broken."
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(aggressiveness != 4)
			user << "\red You broke it!"
			aggressiveness = 4
	else
		..()

/obj/item/clothing/mask/gas/clocker/attack_self()
	catchphaze()

/obj/item/clothing/mask/gas/clocker/verb/wululu()
	set category = "Object"
	set name = "Get a noise"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	playsound(get_turf(src), 'sound/voice/paydaycloaker/wululu.ogg', 100, 1, vary = 0) // WULULULULULULULULULULULLULU
	usr.visible_message("<span class='warning'>[usr]'s [name] is going <b>MAD!</b></span>")


/obj/item/clothing/mask/gas/clocker/verb/catchphaze()
	set category = "Object"
	set name = "Say something funny!"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	var/phrase = 0	//selects which phrase to use
	var/phrase_text = null
	var/phrase_sound = null


	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		switch(aggressiveness)		// checks if the user has unlocked the restricted phrases
			if(1)
				phrase = rand(1,5)	// set the upper limit as the phrase above the first 'bad cop' phrase, the mask will only play 'nice' phrases
			if(2)
				phrase = rand(1,11)	// default setting, set upper limit to last 'bad cop' phrase. Mask will play good cop and bad cop phrases
			if(3)
				phrase = rand(1,18)	// user has unlocked all phrases, set upper limit to last phrase. The mask will play all phrases
			if(4)
				phrase = rand(12,18)	// user has broke the restrictor, it will now only play shitcurity phrases

		switch(phrase)	//sets the properties of the chosen phrase
			if(1)				// good cop
				phrase_text = "Соскучилс&#255; по мне, не так ли?"
				phrase_sound = "missedme"
			if(2)
				phrase_text = "Ты просил об этом!"
				phrase_sound = "youaskedforit"
			if(3)
				phrase_text = "Ты хотел чтобы &#255; вернулс&#255;, так &#255; вернулс&#255;!"
				phrase_sound = "youwantedmeback"
			if(4)
				phrase_text = "В следующий раз проверь углы."
				phrase_sound = "checkyourcorners"
			if(5)
				phrase_text = "Говори громче, &#255; теб&#255; не слышу!"
				phrase_sound = "speakup"
			if(6)				// bad cop
				phrase_text = "Теперь ты не такой крутой, а?"
				phrase_sound = "notsotoughnow"
			if(7)
				phrase_text = "Старайс&#255; чуточку сильнее."
				phrase_sound = "tryalittleharder"
			if(8)
				phrase_text = "Ну и кто теперь клоун?"
				phrase_sound = "whotheclownnow"
			if(9)
				phrase_text = "Хватит бить себ&#255;, хватит бить себ&#255;!"
				phrase_sound = "stophittingyourself"
			if(10)
				phrase_text = "Держу пари, ты позволил себ&#255; избить, просто чтобы послушать, что &#255; скажу!"
				phrase_sound = "getbeatup"
			if(11)
				phrase_text = "Теперь поплачьс&#255; маме, чтобы она сменила тебе подгузники!"
				phrase_sound = "cryformom"
			if(12)
				phrase_text = "Что останетс&#255;, если выбить всё дерьмо из куска дерьма?"
				phrase_sound = "beattheshit"
			if(13)
				phrase_text = "Ты носишь говно в своих трусах так гордо, словно почетный знак!"
				phrase_sound = "shitinyourpant"
			if(14)
				phrase_text = "Ты называешь это \"сопротивление аресту\"?"
				phrase_sound = "resistingarrest"
			if(15)
				phrase_text = "Лучше поздно, чем никогда!"
				phrase_sound = "betterlate"
			if(16)
				phrase_text = "Мы называем это отладкой сложности!"
				phrase_sound = "difficultytweak"
			if(17)
				phrase_text = "Я ожидал большего!"
				phrase_sound = "iexpectedbetter"
			if(18)
				phrase_text = "Я выбью из теб&#255; весь целлюлит!"
				phrase_sound = "beat"

		usr.visible_message("<b>[usr]</b> exclaims, <font color='red' size='4'><b>\"[phrase_text]\"</b></font>")
		playsound(src.loc, "sound/voice/paydaycloaker/[phrase_sound].ogg", 100, 0, 4)
		cooldown = world.time