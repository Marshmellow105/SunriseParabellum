/datum/looping_sound/showering
	start_sound = 'sound/machines/shower/shower_start.ogg'
	start_length = 2
	mid_sounds = list('sound/machines/shower/shower_mid1.ogg'=1,'sound/machines/shower/shower_mid2.ogg'=1,'sound/machines/shower/shower_mid3.ogg'=1)
	mid_length = 10
	end_sound = 'sound/machines/shower/shower_end.ogg'
	volume = 20

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/supermatter
	mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)
	mid_length = 60
	volume = 40
	extra_range = 10
	falloff_exponent = 10
	falloff_distance = 5
	vary = TRUE

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/generator
	start_sound = 'sound/machines/generator/generator_start.ogg'
	start_length = 4
	mid_sounds = list('sound/machines/generator/generator_mid1.ogg'=1, 'sound/machines/generator/generator_mid2.ogg'=1, 'sound/machines/generator/generator_mid3.ogg'=1)
	mid_length = 4
	end_sound = 'sound/machines/generator/generator_end.ogg'
	volume = 40

/datum/looping_sound/oven
	start_sound = 'sound/machines/oven/oven_loop_start.ogg' //my immersions
	start_length = 12
	mid_sounds = list('sound/machines/oven/oven_loop_mid.ogg' = 1)
	mid_length = 13
	end_sound = 'sound/machines/oven/oven_loop_end.ogg'
	volume = 100
	falloff_exponent = 4

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/looping_sound/deep_fryer
	start_sound = 'sound/machines/fryer/deep_fryer_immerse.ogg' //my immersions
	start_length = 10
	mid_sounds = list('sound/machines/fryer/deep_fryer_1.ogg' = 1, 'sound/machines/fryer/deep_fryer_2.ogg' = 1)
	mid_length = 2
	end_sound = 'sound/machines/fryer/deep_fryer_emerge.ogg'
	volume = 15

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/grill
	mid_sounds = list('sound/machines/grill/grillsizzle.ogg' = 1)
	mid_length = 18
	volume = 50

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/deep_fryer
	mid_length = 2
	mid_sounds = list('sound/machines/fryer/deep_fryer_1.ogg' = 1, 'sound/machines/fryer/deep_fryer_2.ogg' = 1)
	volume = 30

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/microwave
	start_sound = 'sound/machines/microwave/microwave-start.ogg'
	start_length = 10
	mid_sounds = list('sound/machines/microwave/microwave-mid1.ogg'=10, 'sound/machines/microwave/microwave-mid2.ogg'=1)
	mid_length = 10
	end_sound = 'sound/machines/microwave/microwave-end.ogg'
	volume = 90

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/washing_machine
	start_sound = 'sound/machines/washingmachine/washingmachinestart.ogg'
	start_length = 40
	mid_sounds = list('sound/machines/washingmachine/washingmid1.ogg'=1,
					'sound/machines/washingmachine/washingmid2.ogg'=1,
					'sound/machines/washingmachine/washingmid3.ogg'=1,
					'sound/machines/washingmachine/washingmid4.ogg'=1,
					'sound/machines/washingmachine/washingmid5.ogg'=1,
					'sound/machines/washingmachine/washingmid6.ogg'=1,
					'sound/machines/washingmachine/washingmid7.ogg'=1,
					'sound/machines/washingmachine/washingmid8.ogg'=1,)
	mid_length = 10
	end_sound = 'sound/machines/washingmachine/washingmachineend.ogg'
	falloff_exponent = 5
	falloff_distance = 3
	volume = 150

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/rbmk
	mid_sounds = list('sound/effects/rbmk/alarm.ogg' = 1)
	volume = 100
	extra_range = 10
	mid_length = 58
	ignore_walls = TRUE

/datum/looping_sound/rbmk_ambience
	mid_sounds = list('sound/effects/rbmk/ambience.ogg' = 1)
	mid_length = 19
	volume = 20
	extra_range = 10
	falloff_exponent = 10
	falloff_distance = 5
	vary = FALSE

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/firealarm
	mid_sounds = list('sound/machines/FireAlarm1.ogg' = 1,'sound/machines/FireAlarm2.ogg' = 1,'sound/machines/FireAlarm3.ogg' = 1,'sound/machines/FireAlarm4.ogg' = 1)
	mid_length = 2.4 SECONDS
	volume = 40
