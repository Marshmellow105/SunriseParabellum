/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger"
	base_icon_state = "recharger"
	desc = "A charging dock for energy based weaponry."
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 300
	circuit = /obj/item/circuitboard/machine/recharger
	pass_flags = PASSTABLE
	var/obj/item/charging = null
	var/recharge_coeff = 1
	var/using_power = FALSE

	var/static/list/allowed_devices = typecacheof(list(
		/obj/item/gun/energy,
		/obj/item/melee/baton,
		/obj/item/ammo_box/magazine/recharge,
		/obj/item/toy/batong,
		/obj/item/modular_computer))

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating

/obj/machinery/recharger/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	if(charging)
		. += "[span_notice("\The [src] contains:")]\n"+\
		span_notice("- \A [charging].")

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += span_notice("The status display reads:")
		. += span_notice("- Recharging <b>[recharge_coeff*10]%</b> cell charge per cycle.")
		if(charging)
			var/obj/item/stock_parts/cell/C = charging.get_cell()
			if (istype(charging, /obj/item/ammo_box/magazine/recharge))
				var/obj/item/ammo_box/magazine/recharge/magazine = charging
				. += span_notice("- \The [charging]'s cell is at <b>[magazine.ammo_count() / magazine.max_ammo * 100]%</b>.")
			else if(C)
				. += span_notice("- \The [charging]'s cell is at <b>[C.percent()]%</b>.")
			else
				. += span_notice("- \The [charging] has no power cell installed.")


/obj/machinery/recharger/proc/setCharging(new_charging)
	charging = new_charging
	if (new_charging)
		START_PROCESSING(SSmachines, src)
		update_use_power(ACTIVE_POWER_USE)
		use_power = ACTIVE_POWER_USE
		using_power = TRUE
		update_appearance()
	else
		update_use_power(IDLE_POWER_USE)
		using_power = FALSE
		update_appearance()

/obj/machinery/recharger/attackby(obj/item/G, mob/user, params)
	if(G.tool_behaviour == TOOL_WRENCH)
		if(charging)
			to_chat(user, span_notice("Remove the charging item first!"))
			return
		set_anchored(!anchored)
		power_change()
		to_chat(user, span_notice("You [anchored ? "attached" : "detached"] [src]."))
		G.play_tool_sound(src)
		return

	var/allowed = is_type_in_typecache(G, allowed_devices)

	if(allowed)
		if(anchored)
			if(charging || panel_open)
				return 1

			//Checks to make sure he's not in space doing it, and that the area got proper power.
			var/area/a = get_area(src)
			if(!isarea(a) || a.power_equip == 0)
				to_chat(user, span_notice("[src] blinks red as you try to insert [G]."))
				return 1

			if (istype(G, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = G
				if(!E.can_charge)
					to_chat(user, span_notice("Your gun has no external power connector."))
					balloon_alert(user, "This gun cannot be charged.")
					return 1

			if (istype(G, /obj/item/gun/ballistic))
				var/obj/item/gun/ballistic/gun = G
				if (ispath(gun.mag_type, /obj/item/ammo_box/magazine/recharge))
					to_chat(user, span_notice("You need to charge the magazine of this gun!"))
					balloon_alert(user, "Remove the magazine first!")
					return 1

			if(!user.transferItemToLoc(G, src))
				return 1
			setCharging(G)

		else
			to_chat(user, span_notice("[src] isn't connected to anything!"))
		return 1

	if(anchored && !charging)
		if(default_deconstruction_screwdriver(user, "recharger", "recharger", G))
			update_appearance()
			return

		if(panel_open && G.tool_behaviour == TOOL_CROWBAR)
			default_deconstruction_crowbar(G)
			return

	return ..()

/obj/machinery/recharger/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	add_fingerprint(user)
	if(charging)
		charging.update_icon()
		charging.forceMove(drop_location())
		user.put_in_hands(charging)
		setCharging(null)

/obj/machinery/recharger/attack_tk(mob/user)
	if(!charging)
		return
	charging.update_icon()
	charging.forceMove(drop_location())
	setCharging(null)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/recharger/process(delta_time)
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		return PROCESS_KILL

	using_power = FALSE
	if(charging)
		var/obj/item/stock_parts/cell/C = charging.get_cell()
		if(C)
			if(C.charge < C.maxcharge)
				C.give(C.chargerate * recharge_coeff * delta_time / 2)
				use_power(125 * recharge_coeff * delta_time)
				using_power = TRUE
			update_appearance()

		if(istype(charging, /obj/item/ammo_box/magazine/recharge))
			var/obj/item/ammo_box/magazine/recharge/R = charging
			if(R.stored_ammo.len < R.max_ammo)
				R.stored_ammo += new R.ammo_type(R)
				use_power(100 * recharge_coeff * delta_time)
				using_power = TRUE
			update_appearance()
			return

	else
		return PROCESS_KILL

/obj/machinery/recharger/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_CONTENTS)
		return
	if(!(machine_stat & (NOPOWER|BROKEN)) && anchored)
		if(istype(charging,  /obj/item/gun/energy))
			var/obj/item/gun/energy/E = charging
			if(E.cell)
				E.cell.emp_act(severity)

		else if(istype(charging, /obj/item/melee/baton))
			var/obj/item/melee/baton/B = charging
			if(B.cell)
				B.cell.charge = 0



/obj/machinery/recharger/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(panel_open)
		. += mutable_appearance(icon, "[base_icon_state]-open", layer, alpha = src.alpha)
		return

	if(!charging)
		. += mutable_appearance(icon, "[base_icon_state]-empty", alpha = src.alpha)
		. += emissive_appearance(icon, "[base_icon_state]-empty", layer, alpha = src.alpha)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
		return

	if(using_power)
		. += mutable_appearance(icon, "[base_icon_state]-charging", alpha = src.alpha)
		. += emissive_appearance(icon, "[base_icon_state]-charging", layer, alpha = src.alpha)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
		return

	. += mutable_appearance(icon, "[base_icon_state]-full", alpha = src.alpha)
	. += emissive_appearance(icon, "[base_icon_state]-full", layer, alpha = src.alpha)
	ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
