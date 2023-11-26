extends Node

@onready var parent = get_parent() as BoardClass

@onready var battle_timer = $battle_timer
@onready var read_timer = $read_timer


func end_battle_phase(): # Ends just sends signal to Main to do the stuff
	globals.emit_signal('end_battle_round')

### BATTLE PHASE ###
func battle_board():
	## Saves word to SilentWolf ##
	# globals.send_word_to_sw(top_letters)
	
	read_timer.start()
	await read_timer.timeout
	
	globals.emit_signal('fight_animation')
	battle_timer.start()
	await battle_timer.timeout
	
	
	globvars.BATTLE_PHASE = true
	var i = 0
	while globvars.BATTLE_PHASE:
		letter_battle()
		battle_timer.start()
		await battle_timer.timeout


func letter_battle():
	## Gets letters ##
	var i = 0
	var top_letter = null
	while i < globvars.MAX_LETTERS:
		top_letter = parent.top_letters[i]
		if top_letter != null: break
		i += 1
	var top_arr_spot = i
	i = 0
	var bot_letter = null
	while i < globvars.MAX_LETTERS:
		bot_letter = parent.bot_letters[i]
		if bot_letter != null: break
		i += 1
	var bot_arr_spot = i
	
	## NULL LETTERS = LOST, this will end_battle_phase & return ##
	if top_letter == null and bot_letter == null: globals.emit_signal('after_battle_animations', 'tie') ; end_battle_phase() ; return
	elif top_letter == null: globals.emit_signal('after_battle_animations', 'lost') ; end_battle_phase() ; return
	elif bot_letter == null: globals.emit_signal('after_battle_animations', 'won') ; end_battle_phase() ; return
	
	## DETERMINE WINNER & DO ANIMATION ##
	var top_new_health = get_new_health(top_letter, bot_letter)
	var bot_new_health = get_new_health(bot_letter, top_letter)
	var top_pos = top_letter.global_position
	var bot_pos = bot_letter.global_position
	
	# Tween to move both together (for fight)
	var tween = create_tween()
	tween.tween_property(top_letter.letter_sprite, 'rotation_degrees', randi_range(-10, -15), 0.2)
	tween.parallel().tween_property(bot_letter.letter_sprite, 'rotation_degrees', randi_range(-5, -15), 0.2)
	
	tween.tween_property(top_letter.letter_sprite, 'global_position', parent.mid_marker.global_position, 0.02)
	tween.parallel().tween_callback(globals.emit_signal.bind('sfx_woosh'))
	tween.parallel().tween_property(bot_letter.letter_sprite, 'global_position', parent.mid_marker.global_position, 0.02)
	tween.parallel().tween_callback(globals.emit_signal.bind('sfx_woosh'))
	tween.parallel().tween_property(top_letter.letter_sprite, 'rotation_degrees', 0, 0.02)
	tween.parallel().tween_property(bot_letter.letter_sprite, 'rotation_degrees', 0,0.02)
	
	tween.tween_callback(globals.emit_signal.bind('hit_effect'))
	tween.parallel().tween_callback(globals.emit_signal.bind('screen_shake', 10))
	
	# Deaths & Tweens to move back to position
	if top_new_health <= 0 and bot_new_health <= 0: # Both letters dead
		# SFX
		tween.tween_callback(globals.emit_signal.bind('sfx_grunt'))
		tween.parallel().tween_callback(globals.emit_signal.bind('sfx_grunt'))
		
		# Tween animation
		tween.tween_property(top_letter.letter_sprite, 'global_position', Vector2(randi_range(-100, 100), parent.top_marker.global_position[1]), 0.1)
		tween.parallel().tween_property(bot_letter.letter_sprite, 'global_position', Vector2(randi_range(-100, 100), parent.bot_marker.global_position[1]), 0.1)
		tween.parallel().tween_property(top_letter.letter_sprite, 'rotation_degrees', 1000, 0.1)
		tween.parallel().tween_property(bot_letter.letter_sprite, 'rotation_degrees', 1000, 0.1)
		
		# Kill letters
		tween.tween_callback(letter_death.bind(top_letter, top_pos, true))
		tween.tween_callback(letter_death.bind(bot_letter, bot_pos, false))
	elif top_new_health <= 0: # Top letter dead
		# SFX
		tween.tween_callback(globals.emit_signal.bind('sfx_punch'))
		tween.parallel().tween_callback(globals.emit_signal.bind('sfx_grunt'))
		
		# Tween animation
		tween.tween_callback(bot_letter.stats.set_up_letter.bind(bot_letter.stats.character, bot_letter.stats.attack, bot_new_health))
		tween.tween_property(top_letter.letter_sprite, 'global_position', Vector2(randi_range(-100, 100), parent.top_marker.global_position[1]), 0.1)
		tween.parallel().tween_property(bot_letter.letter_sprite, 'global_position', bot_pos, 0.1)
		tween.parallel().tween_property(top_letter.letter_sprite, 'rotation_degrees', 1000, 0.1)
		
		# Kills letter / bring back / spawns new based off death effect
		tween.tween_callback(letter_death.bind(top_letter, top_pos, true))
	elif bot_new_health <= 0: # bot letter dead
		# SFX
		tween.tween_callback(globals.emit_signal.bind('sfx_punch'))
		tween.parallel().tween_callback(globals.emit_signal.bind('sfx_grunt'))
		
		# Tween animation
		tween.tween_callback(top_letter.stats.set_up_letter.bind(top_letter.stats.character, top_letter.stats.attack, top_new_health))
		tween.tween_property(bot_letter.letter_sprite, 'global_position', Vector2(randi_range(-100, 100), parent.bot_marker.global_position[1]), 0.1)
		tween.parallel().tween_property(top_letter.letter_sprite, 'global_position', top_pos, 0.1)
		tween.parallel().tween_property(bot_letter.letter_sprite, 'rotation_degrees', 1000, 0.1)
		
		# Kills letter
		tween.tween_callback(letter_death.bind(bot_letter, bot_pos, false))
	else: # Both letters survive
		tween.tween_callback(globals.emit_signal.bind('sfx_punch'))
		tween.parallel().tween_callback(globals.emit_signal.bind('sfx_punch'))
		
		tween.tween_callback(bot_letter.stats.set_up_letter.bind(bot_letter.stats.character, bot_letter.stats.attack, bot_new_health))
		tween.tween_callback(top_letter.stats.set_up_letter.bind(top_letter.stats.character, top_letter.stats.attack, top_new_health))
		tween.tween_property(bot_letter.letter_sprite, 'global_position', bot_pos, 0.1)
		tween.tween_property(top_letter.letter_sprite, 'global_position', top_pos, 0.1)

#######################################################################
### Effects & Calculate Damage & Final Death Stuff###
## Gets new_health & checks if any effects apply on hit or on damage ##
func get_new_health(letter_taking_damage: LetterClass, hitting_letter: LetterClass) -> int:
	## Should I check effects on damage or on hits first?? probs need to think on this
	
	# Checks if letter_taking_damage has any effects on 'damage'
	if letter_taking_damage.stats.effect_from_item != '':
		var damage_effect = letter_taking_damage.stats.effect_from_item
		if globvars.item_effect_types[damage_effect][0] == 'damage': # Only effects on damage taken
			match damage_effect:
				'shield': # Removes shield & takes no damage (just returns old health)
					letter_taking_damage.stats.remove_effect()
					return letter_taking_damage.stats.health
	
	# Checks if hitting_letter has any effects on 'hit'
	if hitting_letter.stats.effect_from_item != '':
		var damage_effect = hitting_letter.stats.effect_from_item
		if globvars.item_effect_types[damage_effect][0] == 'hit': # Only effects on damage taken
			print('set_up hit effects here, letter that hit: ', hitting_letter.stats.character)
	
	# This is the original & default battle (NEED to make a letter.stats.hit(attack_damage) function)
	var new_health = letter_taking_damage.stats.hit_letter(hitting_letter.stats.attack)
	
	return new_health

## Used in letter_death func below
func check_death_effects(dead_letter: LetterClass) -> String:
	if dead_letter.stats.effect_from_item != '':
		var death_effect = dead_letter.stats.effect_from_item
		if globvars.item_effect_types[death_effect][0] == 'death': # Only effects on death
			dead_letter.stats.remove_effect()
			return death_effect # Letter needs to come back'
	
	return 'not_relevant'

## Final letter death (checks if any death effects that need to spawn stuff or something)
func letter_death(letter: LetterClass, orig_pos: Vector2, is_top_row: bool):
	if !is_instance_valid(letter): return # If letter has already been removed, this stops crash
	
	var death_effect = check_death_effects(letter)
	
	var tween = create_tween()
	# Kills letter / bring back / spawns new based off death effect
	match death_effect:
		'explosive':
			globals.emit_signal('explosive_sfx', is_top_row)
			
			# Targets letters in enemy array (opposite of dead_letters array)
			var row_to_damage = parent.bot_letters
			if !is_top_row: row_to_damage = parent.top_letters
			
			for letters in row_to_damage: # Damages all letters hit by explosion (1 damage), checks if valid fist 
				if is_instance_valid(letters): letters.stats.aoe_damage_letter(1)
			
			# Still dies afterwards
			parent.remove_letter_from_arrays(letter) # Removes from board letter array (top or bot)
			tween.tween_callback(letter.kill_letter) # Kills letter
		'revive': # Brings back dead letter with 1 hp
			tween.tween_callback(letter.stats.set_up_letter.bind(letter.stats.character, letter.stats.attack, 1))
			tween.parallel().tween_property(letter.letter_sprite, 'global_position', orig_pos, 0.1)
			tween.parallel().tween_property(letter.letter_sprite, 'rotation_degrees', 0, 0.1)
		'summon': # Summons a [1,1] '?'
			# Kills orig letter
			parent.remove_letter_from_arrays(letter) # Removes from board letter array (top or bot)
			tween.tween_callback(letter.kill_letter) # Kills letter
			
			# Summons a '?' letter in same place
			tween.tween_callback(globals.emit_signal.bind('spawn_set_letter', '?', 1, 1, false, false))
			
		_: # Default, just kills letter
			parent.remove_letter_from_arrays(letter) # Removes from board letter array (top or bot)
			tween.tween_callback(letter.kill_letter) # Kills letter

## Used when letters are killed outside of normal battle (i.e. explosion or cleave damage)
func check_if_letters_died():
	pass
