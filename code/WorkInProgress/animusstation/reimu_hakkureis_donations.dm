var/const/stuff = {"
Hats
Collectable Pete hat:/obj/item/clothing/head/collectable/petehat:150
Collectable Xeno hat:/obj/item/clothing/head/collectable/xenom:110
Collectable Top hat:/obj/item/clothing/head/collectable/tophat:120
Kitty Ears:/obj/item/clothing/head/kitty:100
Ushanka:/obj/item/clothing/head/ushanka:200

Personal Stuff
Eye patch:/obj/item/clothing/glasses/eyepatch:130
Cane:/obj/item/weapon/cane:130
Zippo:/obj/item/weapon/lighter/zippo:130
Cigarette packet:/obj/item/weapon/storage/fancy/cigarettes:20
DromedaryCo packet:/obj/item/weapon/storage/fancy/cigarettes/dromedaryco:50
Premium Havanian Cigar:/obj/item/clothing/mask/cigarette/cigar/havana:130
Beer bottle:/obj/item/weapon/reagent_containers/food/drinks/beer:80
Captain flask:/obj/item/weapon/reagent_containers/food/drinks/flask:200
Three Mile Island Ice Tea:/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/threemileisland:100

Costume sets
Plague Doctor Set:/obj/effect/landmark/costume/plaguedoctor:375

Shoes
Clown Shoes:/obj/item/clothing/shoes/clown_shoes:130
Cyborg Shoes:/obj/item/clothing/shoes/cyborg:130
Laceups Shoes:/obj/item/clothing/shoes/laceup:130
Wooden Sandals:/obj/item/clothing/shoes/sandal:80

Jumpsuits
Vice Policeman:/obj/item/clothing/under/rank/vice:180
Rainbow Suit:/obj/item/clothing/under/rainbow:130
Grim Jacket:/obj/item/clothing/under/suit_jacket:130
Black Jacket:/obj/item/clothing/under/color/blackf:130
Scratched Suit:/obj/item/clothing/under/scratch:130
Tacticool Turtleneck:/obj/item/clothing/under/syndicate/tacticool:130

Gloves
White:/obj/item/clothing/gloves/white:130
Rainbow:/obj/item/clothing/gloves/rainbow:200
Black:/obj/item/clothing/gloves/black:160

Bedsheets
Clown Bedsheet:/obj/item/weapon/bedsheet/clown:100
Mime Bedsheet:/obj/item/weapon/bedsheet/mime:100
Rainbow Bedsheet:/obj/item/weapon/bedsheet/rainbow:100
Captain Bedsheet:/obj/item/weapon/bedsheet/captain:120

Toys
Rubber Duck:/obj/item/weapon/bikehorn/rubberducky:200
Champion Belt:/obj/item/weapon/storage/belt/champion:200

Special Stuff
Santabag:/obj/item/weapon/storage/backpack/santabag:400
"}


var/list/datum/donator_prize/prizes = list()
var/list/datum/donator/donators = list()

/datum/donator
	var/ownerkey
	var/money = 0
	var/maxmoney = 0
	var/allowed_num_items = 10

	New(ckey, money)
		..()
		ownerkey = ckey
		src.money = money
		maxmoney = money
		donators[ckey] = src

	proc/show()
		var/dat = "<title>Donator panel</title>"
		dat += "You have [money] / [maxmoney]<br>"
		dat += "You can spawn [ allowed_num_items ? allowed_num_items : "no" ] more items.<br><br>"

		if (allowed_num_items)
			if (!prizes.len)
				build_prizes_list()

			var/cur_cat = "None"

			for (var/i = 1, i<=prizes.len, i++)
				var/datum/donator_prize/prize = prizes[i]
				var/cat_name = prize.category
				if (cur_cat != cat_name)
					dat += "<hr><b>[cat_name]</b><br>"
				cur_cat = cat_name
				dat += "<a href='?src=\ref[src];itemid=[i]'>[prize.item_name] : [prize.cost]</a><br>"
		usr << browse(dat, "window=donatorpanel;size=250x400")

	Topic(href, href_list)
		var/id = text2num(href_list["itemid"])
		var/datum/donator_prize/prize = prizes[id]

		var/name = prize.item_name
		var/cost = prize.cost
		var/path = prize.path_to
		var/mob/living/carbon/human/user = usr.client.mob

		var/list/slots = list (
			"backpack" = slot_in_backpack,
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store,
			"left hand" = slot_l_hand,
			"right hand" = slot_r_hand,
		)

		if(cost > money)
			usr << "\red You don't have enough funds."
			return 0

		if(!allowed_num_items)
			usr << "\red You have reached maximum amount of spawned items."
			return 0

		if(!user)
			user << "\red You must be a human to use this."
			return 0

		if(!ispath(path))
			return 0

		if(user.stat) return 0

		var/obj/spawned = new path

		var/where = user.equip_in_one_of_slots(spawned, slots, qdel_on_fail=0)

		if (!where)
			spawned.loc = user.loc
			usr << "\blue Your [name] has been spawned!"
		else
			usr << "\blue Your [name] has been spawned in your [where]!"

		money -= cost
		allowed_num_items--

		show()

/datum/donator_prize
	var/item_name = "Nothing"
	var/path_to = /datum/donator_prize
	var/cost = 0
	var/category = "Debug"

proc/load_donator(ckey)
	var/DBConnection/dbcon2 = new()
	dbcon2.Connect("dbi:mysql:forum2:[sqladdress]:[sqlport]","[sqlfdbklogin]","[sqlfdbkpass]")

	if(!dbcon2.IsConnected())
		world.log << "Failed to connect to database [dbcon2.ErrorMsg()] in load_donator([ckey])."
		diary << "Failed to connect to database in load_donator([ckey])."
		return 0

	var/DBQuery/query = dbcon2.NewQuery("SELECT round(sum) FROM Z_donators WHERE byond='[ckey]'")
	query.Execute()
	while(query.NextRow())
		var/money = round(text2num(query.item[1]))
		new /datum/donator(ckey, money)
	dbcon2.Disconnect()
	return 1

proc/build_prizes_list()
	var/list/strings = text2list ( stuff, "\n" )
	var/cur_cat = "Miscellaneous"
	for (var/string in strings)
		if (string) //It's not a delimiter between
			var/list/item_info = text2list ( string, ":" )
			if (item_info.len==3)
				var/datum/donator_prize/prize = new
				prize.item_name = item_info[1]
				prize.path_to = text2path(item_info[2])
				prize.cost = text2num(item_info[3])
				prize.category = cur_cat
				prizes += prize
			else
				cur_cat = item_info[1]


/client/verb/cmd_donator_panel()
	set name = "Donator panel"
	set category = "OOC"

	if(!ticker || ticker.current_state < 3)
		alert("Please wait until game setting up!")
		return

	if (!donators[ckey]) //It doesn't exist yet
		if (load_donator(ckey))
			var/datum/donator/D = donators[ckey]
			if(D)
				D.show()
			else
				usr << browse ("<b>You have not donated or the database is inaccessible.</b>", "window=donatorpanel")
		else
			usr << browse ("<b>You have not donated or the database is inaccessible.</b>", "window=donatorpanel")
	else
		var/datum/donator/D = donators[ckey]
		D.show()

//SPECIAL ITEMS
/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/threemileisland
	New()
		..()
		reagents.add_reagent("threemileisland", 50)
		on_reagent_change()