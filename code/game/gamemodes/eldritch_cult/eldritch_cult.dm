/datum/game_mode/heretics
	name = "heresy"
	config_tag = "heresy"
	report_type = "heresy"
	role_preference = /datum/role_preference/antagonist/heretic
	antag_datum = /datum/antagonist/heretic
	false_report_weight = 5
	protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	restricted_jobs = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1

	allowed_special = list(/datum/special_role/traitor/higher_chance)

	announce_span = "danger"
	announce_text = "Heretics have been spotted on the station!\n \
	" + span_danger("Heretics") + ": Accomplish your objectives.\n \
	" + span_notice("Crew") + ": Do not let the madman succeed!"

	var/ecult_possible = 4 //hard limit on culties if scaling is turned off
	var/num_ecult = 1
	var/list/culties = list()

/datum/game_mode/heretics/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)


	var/esc = CONFIG_GET(number/ecult_scaling_coeff)
	if(esc)
		num_ecult = min(max(1, min(round(num_players() / (esc * 2)) + 2, round(num_players() / esc))),4)
	else
		num_ecult = max(1, min(num_players(), ecult_possible))

	for(var/i in 1 to num_ecult)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultie = antag_pick(antag_candidates, /datum/role_preference/antagonist/heretic)
		antag_candidates -= cultie
		cultie.special_role = ROLE_HERETIC
		cultie.restricted_roles = restricted_jobs
		culties += cultie
		GLOB.pre_setup_antags += cultie

	if(!LAZYLEN(culties))
		setup_error = "Not enough heretic candidates"
		return FALSE
	else
		return TRUE

/datum/game_mode/heretics/post_setup()
	for(var/c in culties)
		var/datum/mind/cultie = c
		log_game("[key_name(cultie)] has been selected as a heretic!")
		var/datum/antagonist/heretic/new_antag = new()
		cultie.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= cultie
	return ..()

/datum/game_mode/heretics/generate_report()
	return "Cybersun Industries has announced that they have successfully raided a high-security library. The library contained a very dangerous book that was \
	shown to posses anomalous properties. We suspect that the book has been copied over, Stay vigilant!"

/datum/game_mode/heretics/generate_credit_text()
	var/list/round_credits = list()

	round_credits += "<center><h1>The Eldrich Cult:</h1>"
	for(var/datum/mind/M in culties)
		round_credits += "<center><h2>[M.name] as a heretic</h2>"

	round_credits += ..()
	return round_credits
