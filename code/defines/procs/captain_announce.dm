/proc/captain_announce(var/text)
	world << "<h1 class='alert'>Priority Announcement</h1>"
	world << "<span class='alert'>[sanitize(rhtml_encode(text))]</span>"
	world << "<br>"

