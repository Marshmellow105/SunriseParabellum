/obj/item/firing_pin
	name = "electronic firing pin"
	desc = "A small authentication device, to be inserted into a firearm receiver to allow operation. NT safety regulations require all new designs to incorporate one."
	icon = 'icons/obj/device.dmi'
	icon_state = "firing_pin"
	item_state = "pen"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("pokes")
	attack_verb_simple = list("poke")
	var/fail_message = span_warning("INVALID USER.")
	var/selfdestruct = 0 // Explode when user check is failed.
	var/force_replace = 0 // Can forcefully replace other pins.
	var/pin_removeable = 0 // Can be replaced by any pin.
	var/obj/item/gun/gun

/obj/item/firing_pin/New(newloc)
	..()
	if(istype(newloc, /obj/item/gun))
		gun = newloc

/obj/item/firing_pin/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		if(istype(target, /obj/item/gun))
			var/obj/item/gun/G = target
			if(G.no_pin_required)
				return
			if(G.pin && (force_replace || G.pin.pin_removeable))
				G.pin.forceMove(get_turf(G))
				G.pin.gun_remove(user)
				to_chat(user, span_notice("You remove [G]'s old pin."))

			if(!G.pin)
				if(!user.temporarilyRemoveItemFromInventory(src))
					return
				gun_insert(user, G)
				to_chat(user, span_notice("You insert [src] into [G]."))
			else
				to_chat(user, span_notice("This firearm already has a firing pin installed."))

/obj/item/firing_pin/on_emag(mob/user)
	..()
	to_chat(user, span_notice("You override the authentication mechanism."))

/obj/item/firing_pin/proc/gun_insert(mob/living/user, obj/item/gun/G)
	gun = G
	forceMove(gun)
	gun.pin = src
	return

/obj/item/firing_pin/proc/gun_remove(mob/living/user)
	gun.pin = null
	gun = null
	return

/obj/item/firing_pin/proc/pin_auth(mob/living/user)
	return TRUE

/obj/item/firing_pin/proc/auth_fail(mob/living/user)
	if(user)
		user.show_message(fail_message, MSG_VISUAL)
	if(selfdestruct)
		if(user)
			user.show_message("[span_danger("SELF-DESTRUCTING...")]<br>", MSG_VISUAL)
			to_chat(user, span_userdanger("[gun] explodes!"))
		explosion(get_turf(gun), -1, 0, 2, 3)
		if(gun)
			qdel(gun)



/obj/item/firing_pin/magic
	name = "magic crystal shard"
	desc = "A small enchanted shard which allows magical weapons to fire."


// Test pin, works only near firing range.
/obj/item/firing_pin/test_range
	name = "test-range firing pin"
	desc = "This safety firing pin allows weapons to be fired within proximity to a firing range."
	fail_message = span_warning("TEST RANGE CHECK FAILED.")
	pin_removeable = TRUE

/obj/item/firing_pin/test_range/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if(locate(/obj/machinery/magnetic_controller) in range(3, user))
		return TRUE
	return FALSE


// Implant pin, checks for implant
/obj/item/firing_pin/implant
	name = "implant-keyed firing pin"
	desc = "This is a security firing pin which only authorizes users who are implanted with a certain device."
	fail_message = span_warning("IMPLANT CHECK FAILED.")
	var/obj/item/implant/req_implant = null

/obj/item/firing_pin/implant/pin_auth(mob/living/user)
	if(user)
		for(var/obj/item/implant/I in user.implants)
			if(req_implant && I.type == req_implant)
				return TRUE
	return FALSE

/obj/item/firing_pin/implant/mindshield
	name = "mindshield firing pin"
	desc = "This Security firing pin authorizes the weapon for only mindshield-implanted users."
	icon_state = "firing_pin_loyalty"
	req_implant = /obj/item/implant/mindshield

/obj/item/firing_pin/implant/pindicate
	name = "syndicate firing pin"
	icon_state = "firing_pin_pindi"
	req_implant = /obj/item/implant/weapons_auth



// Honk pin, clown's joke item.
// Can replace other pins. Replace a pin in cap's laser for extra fun!
/obj/item/firing_pin/clown
	name = "hilarious firing pin"
	desc = "Advanced clowntech that can convert any firearm into a far more useful object."
	color = "#FFFF00"
	fail_message = span_warning("HONK!")
	force_replace = TRUE

/obj/item/firing_pin/clown/pin_auth(mob/living/user)
	playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
	return FALSE

// Ultra-honk pin, clown's deadly joke item.
// A gun with ultra-honk pin is useful for clown and useless for everyone else.
/obj/item/firing_pin/clown/ultra/pin_auth(mob/living/user)
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
	if(user && (!(HAS_TRAIT(user, TRAIT_CLUMSY)) && !(user.mind && user.mind.assigned_role == JOB_NAME_CLOWN)))
		return FALSE
	return TRUE

/obj/item/firing_pin/clown/ultra/gun_insert(mob/living/user, obj/item/gun/G)
	..()
	G.clumsy_check = FALSE

/obj/item/firing_pin/clown/ultra/gun_remove(mob/living/user)
	gun.clumsy_check = initial(gun.clumsy_check)
	..()

// Now two times deadlier!
/obj/item/firing_pin/clown/ultra/selfdestruct
	desc = "Advanced clowntech that can convert any firearm into a far more useful object. It has a small nitrobananium charge on it."
	selfdestruct = TRUE


// DNA-keyed pin.
// When you want to keep your toys for yourself.
/obj/item/firing_pin/dna
	name = "DNA-keyed firing pin"
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link."
	icon_state = "firing_pin_dna"
	fail_message = span_warning("DNA CHECK FAILED.")
	var/unique_enzymes = null

/obj/item/firing_pin/dna/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag && iscarbon(target))
		var/mob/living/carbon/M = target
		if(M.dna && M.dna.unique_enzymes)
			unique_enzymes = M.dna.unique_enzymes
			to_chat(user, span_notice("DNA-LOCK SET."))

/obj/item/firing_pin/dna/pin_auth(mob/living/carbon/user)
	if(user && user.dna && user.dna.unique_enzymes)
		if(user.dna.unique_enzymes == unique_enzymes)
			return TRUE
	return FALSE

/obj/item/firing_pin/dna/auth_fail(mob/living/carbon/user)
	if(!unique_enzymes)
		if(user?.dna?.unique_enzymes)
			unique_enzymes = user.dna.unique_enzymes
			to_chat(user, span_notice("DNA-LOCK SET."))
	else
		..()

/obj/item/firing_pin/dna/dredd
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link. It has a small explosive charge on it."
	selfdestruct = TRUE

// Paywall pin, brought to you by ARMA 3 DLC.
// Checks if the user has a valid bank account on an ID and if so attempts to extract a one-time payment to authorize use of the gun. Otherwise fails to shoot.
/obj/item/firing_pin/paywall
	name = "paywall firing pin"
	desc = "A firing pin with a built-in configurable paywall."
	color = "#FFD700"
	fail_message = ""
	var/list/gun_owners = list() //list of people who've accepted the license prompt. If this is the multi-payment pin, then this means they accepted the waiver that each shot will cost them money
	var/payment_amount //how much gets paid out to license yourself to the gun
	var/obj/item/card/id/pin_owner
	var/multi_payment = FALSE //if true, user has to pay everytime they fire the gun
	var/owned = FALSE
	var/active_prompt = FALSE //purchase prompt to prevent spamming it

/obj/item/firing_pin/paywall/attack_self(mob/user)
	multi_payment = !multi_payment
	to_chat(user, span_notice("You set the pin to [( multi_payment ) ? "process payment for every shot" : "one-time license payment"]."))

/obj/item/firing_pin/paywall/examine(mob/user)
	. = ..()
	if(pin_owner)
		. += span_notice("This firing pin is currently authorized to pay into the account of [pin_owner.registered_name].")

/obj/item/firing_pin/paywall/gun_insert(mob/living/user, obj/item/gun/G)
	if(!pin_owner)
		to_chat(user, span_warning("ERROR: Please swipe valid identification card before installing firing pin!"))
		return
	gun = G
	forceMove(gun)
	gun.pin = src
	if(multi_payment)
		gun.desc += span_notice(" This [gun.name] has a per-shot cost of [payment_amount] credit[( payment_amount > 1 ) ? "s" : ""].")
		return
	gun.desc += span_notice(" This [gun.name] has a license permit cost of [payment_amount] credit[( payment_amount > 1 ) ? "s" : ""].")
	return


/obj/item/firing_pin/paywall/gun_remove(mob/living/user)
	gun.desc = initial(desc)
	..()

/obj/item/firing_pin/paywall/attackby(obj/item/M, mob/user, params)
	if(istype(M, /obj/item/card/id))
		var/obj/item/card/id/id = M
		if(!id.registered_account)
			to_chat(user, span_warning("ERROR: Identification card lacks registered bank account!"))
			return
		if(id != pin_owner && owned)
			to_chat(user, span_warning("ERROR: This firing pin has already been authorized!"))
			return
		if(id == pin_owner)
			to_chat(user, span_notice("You unlink the card from the firing pin."))
			gun_owners -= user
			pin_owner = null
			owned = FALSE
			return
		var/transaction_amount = input(user, "Insert valid deposit amount for gun purchase", "Money Deposit") as null|num
		if(transaction_amount < 1)
			to_chat(user, span_warning("ERROR: Invalid amount designated."))
			return
		if(!transaction_amount)
			return
		pin_owner = id
		owned = TRUE
		payment_amount = transaction_amount
		gun_owners += user
		to_chat(user, span_notice("You link the card to the firing pin."))

/obj/item/firing_pin/paywall/pin_auth(mob/living/user)
	if(!istype(user))//nice try commie
		return FALSE
	if(ishuman(user))
		var/datum/bank_account/credit_card_details
		var/mob/living/carbon/human/H = user
		if(H.get_bank_account())
			credit_card_details = H.get_bank_account()
		if(H in gun_owners)
			if(multi_payment && credit_card_details)
				if(credit_card_details.adjust_money(-payment_amount))
					pin_owner.registered_account.adjust_money(payment_amount)
					return TRUE
				to_chat(user, span_warning("ERROR: User balance insufficent for successful transaction!"))
				return FALSE
			return TRUE
		if(credit_card_details && !active_prompt)
			var/license_request = alert(usr, "Do you wish to pay [payment_amount] credit[( payment_amount > 1 ) ? "s" : ""] for [( multi_payment ) ? "each shot of [gun.name]" : "usage license of [gun.name]"]?", "Weapon Purchase", "Yes", "No")
			active_prompt = TRUE
			if(!user.canUseTopic(src, BE_CLOSE))
				active_prompt = FALSE
				return FALSE
			switch(license_request)
				if("Yes")
					if(credit_card_details.adjust_money(-payment_amount))
						pin_owner.registered_account.adjust_money(payment_amount)
						gun_owners += H
						to_chat(user, span_notice("Gun license purchased, have a secure day!"))
						active_prompt = FALSE
						return FALSE //we return false here so you don't click initially to fire, get the prompt, accept the prompt, and THEN the gun
					to_chat(user, span_warning("ERROR: User balance insufficent for successful transaction!"))
					return FALSE
				if("No")
					to_chat(user, span_warning("ERROR: User has declined to purchase gun license!"))
					return FALSE
		to_chat(user, span_warning("ERROR: User has no valid bank account to substract neccesary funds from!"))
		return FALSE


// Laser tag pins
/obj/item/firing_pin/tag
	name = "laser tag firing pin"
	desc = "A recreational firing pin, used in laser tag units to ensure users have their vests on."
	fail_message = span_warning("SUIT CHECK FAILED.")
	var/obj/item/clothing/suit/suit_requirement = null
	var/tagcolor = ""

/obj/item/firing_pin/tag/pin_auth(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		if(istype(M.wear_suit, suit_requirement))
			return TRUE
	to_chat(user, span_warning("You need to be wearing [tagcolor] laser tag armor!"))
	return FALSE

/obj/item/firing_pin/tag/red
	name = "red laser tag firing pin"
	icon_state = "firing_pin_red"
	suit_requirement = /obj/item/clothing/suit/redtag
	tagcolor = "red"

/obj/item/firing_pin/tag/blue
	name = "blue laser tag firing pin"
	icon_state = "firing_pin_blue"
	suit_requirement = /obj/item/clothing/suit/bluetag
	tagcolor = "blue"

/obj/item/firing_pin/Destroy()
	if(gun)
		gun.pin = null
	return ..()
