/obj/machinery/computer/aifixer
	name = "AI System Integrity Restorer"
	icon = 'computer.dmi'
	icon_state = "ai-fixer"
	req_access = list(access_captain, access_robotics, access_heads)
	var/mob/living/silicon/ai/occupant = null
	var/active = 0

/obj/machinery/computer/aifixer/New()
	src.overlays += image('computer.dmi', "ai-fixer-empty")


/obj/machinery/computer/aifixer/attackby(I as obj, user as mob)
/*
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/robotics/M = new /obj/item/weapon/circuitboard/robotics( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/robotics/M = new /obj/item/weapon/circuitboard/robotics( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
*/
	if(istype(I, /obj/item/device/aicard))
		if(stat & (NOPOWER|BROKEN))
			user << "This terminal isn't functioning right now, get it working!"
			return
		var/obj/item/device/aicard/C = I
		if(contents.len == 0)
			if (C.contents.len == 0)
				user << "No AI to copy over!"//Well duh
			else for(var/mob/living/silicon/ai/A in C)
				A << "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here."
				user << "<b>Transfer succesful</b>: [A.name] ([rand(1000,9999)].exe) installed and executed succesfully. Local copy has been removed."
				C.icon_state = "aicard"
				C.name = "inteliCard"
				C.overlays = null
				A.loc = src
				occupant = A
				A.control_disabled = 1
				if (A.stat == 2)
					overlays += image('computer.dmi', "ai-fixer-404")
				else
					overlays += image('computer.dmi', "ai-fixer-full")
				overlays -= image('computer.dmi', "ai-fixer-empty")


		else
			if(C.contents.len == 0 && src.occupant && !src.active)
				C.name = "inteliCard - [occupant.name]"
				overlays += image('computer.dmi', "ai-fixer-empty")
				if (src.occupant.stat == 2)
					C.icon_state = "aicard-404"
					src.overlays -= image('computer.dmi', "ai-fixer-404")
				else
					C.icon_state = "aicard-full"
					src.overlays -= image('computer.dmi', "ai-fixer-full")
				occupant << "You have been downloaded to a mobile storage device. Still no remote access."
				user << "<b>Transfer succeeded</b>: [occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
				occupant.loc = C
				occupant = null
			else if (C.contents.len)
				user << "There's already an AI in the reconstructer!"
			else if (active)
				user << "Can't remove an AI during reconstruction!"
			else if (!occupant)
				user << "No AI to remove!"

	//src.attack_hand(user)
	return

/obj/machinery/computer/aifixer/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/aifixer/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/aifixer/attack_hand(var/mob/user as mob)
	if(..())
		return

	if(ishuman(user))//Checks to see if they are ninja
		if(istype(user:gloves, /obj/item/clothing/gloves/space_ninja)&&user:gloves:candrain&&!user:gloves:draining)
			if(user:wear_suit:control)
				attackby(user:wear_suit:aicard,user)
			else
				user << "\red <b>ERROR</b>: \black Remote access channel disabled."
			return

	user.machine = src
	var/dat = "<h3>AI System Integrity Restorer</h3><br><br>"

	if (src.occupant)
		var/laws
		dat += "Stored AI: [src.occupant.name]<br>System integrity: [(src.occupant.health+100)/2]%<br>"

		if (src.occupant.laws_object.zeroth)
			laws += "0: [src.occupant.laws_object.zeroth]<BR>"

		var/number = 1
		for (var/index = 1, index <= src.occupant.laws_object.inherent.len, index++)
			var/law = src.occupant.laws_object.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		for (var/index = 1, index <= src.occupant.laws_object.supplied.len, index++)
			var/law = src.occupant.laws_object.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		dat += "Laws:<br>[laws]<br>"

		if (src.occupant.stat == 2)
			dat += "<b>AI nonfunctional</b>"
		else
			dat += "<b>AI functional</b>"
		if (!src.active)
			dat += {"<br><br><A href='byond://?src=\ref[src];fix=1'>Begin Reconstruction</A>"}
		else
			dat += "<br><br>Reconstruction in process, please wait.<br>"
	dat += {" <A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/aifixer/process()
	if(stat & (NOPOWER|BROKEN))
		return


	src.updateDialog()
	return

/obj/machinery/computer/aifixer/Topic(href, href_list)
	if(..())
		return
	if (href_list["fix"])
		src.active = 1
		src.overlays += image('computer.dmi', "ai-fixer-on")
		while (src.occupant.health < 100)
			src.occupant.oxyloss = max (src.occupant.oxyloss-1, 0)
			src.occupant.fireloss = max (src.occupant.fireloss-1, 0)
			src.occupant.toxloss = max (src.occupant.toxloss-1, 0)
			src.occupant.bruteloss = max (src.occupant.bruteloss-1, 0)
			src.occupant.updatehealth()
			if (src.occupant.health >= 0 && src.occupant.stat == 2)
				src.occupant.stat = 0
				src.overlays -= image('computer.dmi', "ai-fixer-404")
				src.overlays += image('computer.dmi', "ai-fixer-full")
			src.updateUsrDialog()
			sleep(10)
		src.active = 0
		src.overlays -= image('computer.dmi', "ai-fixer-on")


		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


