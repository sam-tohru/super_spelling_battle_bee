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
	var top_new_health = top_letter.stats.health - bot_letter.stats.attack
	var bot_new_health = bot_letter.stats.health - top_letter.stats.attack
	var top_pos = top_letter.global_position
	var bot_pos = bot_letter.global_position
	
	# Tween to move both together
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
	
	# Tween to move back (and death)
	if top_new_health <= 0 and bot_new_health <= 0: # Both letters dead
		parent.top_letters[top_arr_spot] = null
		parent.bot_letters[bot_arr_spot] = null
		tween.tween_callback(globals.emit_signal.bind('sfx_grunt'))
		tween.parallel().tween_callback(globals.emit_signal.bind('sfx_grunt'))
		
		tween.tween_property(top_letter.letter_sprite, 'global_position', Vector2(randi_range(-100, 100), parent.top_marker.global_position[1]), 0.1)
		tween.parallel().tween_property(bot_letter.letter_sprite, 'global_position', Vector2(randi_range(-100, 100), parent.bot_marker.global_position[1]), 0.1)
		tween.parallel().tween_property(top_letter.letter_sprite, 'rotation_degrees', 1000, 0.1)
		tween.parallel().tween_property(bot_letter.letter_sprite, 'rotation_degrees', 1000, 0.1)
		
		tween.tween_callback(top_letter.kill_letter)
		tween.tween_callback(bot_letter.kill_letter)
	elif top_new_health <= 0: # Top letter dead
		tween.tween_callback(globals.emit_signal.bind('sfx_punch'))
		tween.parallel().tween_callback(globals.emit_signal.bind('sfx_grunt'))
		
		tween.tween_callback(bot_letter.stats.set_up_letter.bind(bot_letter.stats.character, bot_letter.stats.attack, bot_new_health))
		parent.top_letters[top_arr_spot] = null
		tween.tween_property(top_letter.letter_sprite, 'global_position', Vector2(randi_range(-100, 100), parent.top_marker.global_position[1]), 0.1)
		tween.parallel().tween_property(bot_letter.letter_sprite, 'global_position', bot_pos, 0.1)
		tween.parallel().tween_property(top_letter.letter_sprite, 'rotation_degrees', 1000, 0.1)
		
		tween.tween_callback(top_letter.kill_letter)
	elif bot_new_health <= 0: # bot letter dead
		tween.tween_callback(globals.emit_signal.bind('sfx_punch'))
		tween.parallel().tween_callback(globals.emit_signal.bind('sfx_grunt'))
		
		tween.tween_callback(top_letter.stats.set_up_letter.bind(top_letter.stats.character, top_letter.stats.attack, top_new_health))
		parent.bot_letters[bot_arr_spot] = null
		tween.tween_property(bot_letter.letter_sprite, 'global_position', Vector2(randi_range(-100, 100), parent.bot_marker.global_position[1]), 0.1)
		tween.parallel().tween_property(top_letter.letter_sprite, 'global_position', top_pos, 0.1)
		tween.parallel().tween_property(bot_letter.letter_sprite, 'rotation_degrees', 1000, 0.1)
		
		tween.tween_callback(bot_letter.kill_letter)
	else: # Both letters survive
		tween.tween_callback(globals.emit_signal.bind('sfx_punch'))
		tween.parallel().tween_callback(globals.emit_signal.bind('sfx_punch'))
		
		tween.tween_callback(bot_letter.stats.set_up_letter.bind(bot_letter.stats.character, bot_letter.stats.attack, bot_new_health))
		tween.tween_callback(top_letter.stats.set_up_letter.bind(top_letter.stats.character, top_letter.stats.attack, top_new_health))
		tween.tween_property(bot_letter.letter_sprite, 'global_position', bot_pos, 0.1)
		tween.tween_property(top_letter.letter_sprite, 'global_position', top_pos, 0.1)
