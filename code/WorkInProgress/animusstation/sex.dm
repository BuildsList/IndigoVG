/**********************************
*******Sex code by TestUnit********
**Contains a lot ammount of !FUN!**
***********************************/

/mob/living/carbon/human/MouseDrop_T(mob/M as mob, mob/user as mob)
	//	world << "mob/m - [M] mob/user - [user], usr - [usr], src - [src]"
	if(M==src && src!=usr)		return
	if(!Adjacent(src))			return
	if(M!=usr)					return
	usr.affectedsex = src
	make_sex(machine)

/mob/proc/make_sex()
	usr.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>��������� ����� - [name]</FONT></B>
	<BR>"}
	usr << browse(dat, text("window=mob[];size=325x500", name))
	onclose(usr, "mob[name]")
	return


/mob/living/carbon/human/make_sex()
	usr.set_machine(src)
	var/dat = {"<style type="text/css">
	body{
	background-color: #c0c0c0;
	}
	A {
	text-decoration: none;
	font-size: 12pt;
	}
	A:hover {
	text-decoration: underline;
	color: red;
	}
	</style>"}
	dat += {"
	<B><FONT size=4>��������� �����</FONT></B>
	<HR>"}
	if(config.virt_allowed)
		dat += {"<font color=purple size=3>���</font><BR> \
			[in_range(usr.affectedsex,usr)? \
			"�<A href='?src=\ref[src];sex=mouthkiss'>�������</A><BR> \
			� <A href='?src=\ref[src];sex=mouthpenis'>�����</A><BR>":"������� ������"]"}
		dat += {"
		<font color=purple size=3>�����</font><BR>
		[in_range(usr.affectedsex,usr)? \
		"�<A href='?src=\ref[src];sex=chestmouth'>���</A><BR> \
		� <A href='?src=\ref[src];sex=chesthands'>����</A><BR> \
		� <A href='?src=\ref[src];sex=chestpenis'>�����</A><BR>":"������� ������"]"}
		dat += {"
		<font color=purple size=3>���</font><BR>
		[in_range(usr.affectedsex,usr)? \
		"�<A href='?src=\ref[src];sex=groinmouth'>���</A><BR> \
		� <A href='?src=\ref[src];sex=groinhands'>����</A><BR> \
		� <A href='?src=\ref[src];sex=groinpenis'>�����</A><BR>":"������� ������"]"}
		dat += {"
		<font color=purple size=3>�����</font><BR>
		[in_range(usr.affectedsex,usr)? \
		"�<A href='?src=\ref[src];sex=assmomuth'>���</A><BR> \
		� <A href='?src=\ref[src];sex=asshands'>����</A><BR> \
		� <A href='?src=\ref[src];sex=asspenis'>�����</A><BR>":"������� ������"]"}
		dat += {"
		<font color=purple size=3>������������(?)</font><BR>
		[in_range(usr.affectedsex,usr)? \
		"�<A href='?src=\ref[src];sex=assfinger'>������� �����</A><BR>":"������� ������"]
		"}
	else
		dat += {"Sorry ;C \[<font color=red>WIP</font>\]"}
	usr << browse(dat, text("window=mob[name];size=340x480"))
	onclose(usr, "mob[name]")
	return