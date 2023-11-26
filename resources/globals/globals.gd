extends Node

## Global Signals
# Menus
signal game_resumed
signal game_paused

## Buttons
signal main_button_pressed # On Board, to pause with main_menu

signal battle_button_invalid_word # When player tries to battle with invalid word [BattleButton -> Labels on board]
signal battle_button_pressed # Word is valid, battle stats [BattleButton -> Main]
signal end_battle_round # Ends battle phase, goes to shop_phase [board.battle -> Main]

signal re_roll_pressed # Reroll button pressed, checks if have neough gold to reroll [board.ReRollButton -> shop]
signal re_roll_shop # New Shop Letters [Board -> Main]

signal update_gold_left
signal not_enough_gold_left # Goes to GoldLeft and does little animation + sound

signal new_shop_round # When goes from battle->shop [Main -> Board.Shop & other Gold Stuff]

## Board & Letters
signal clicked_letter
signal dropped_letter

signal spawn_set_letter


## Animation Signations
signal after_battle_animations
signal fight_animation
signal hit_effect
signal explosive_sfx # From Board.Battle (death effect) -> animations

signal screen_shake

## Volume Settings 
signal volume_changed
signal music_volume_changed

## SFXs
signal sfx_firework
signal sfx_woosh
signal sfx_punch
signal sfx_grunt
signal sfx_battle_done
signal sfx_invalid_word

################################################################################

func is_real_word(top_array: Array) -> bool:
	var character_array = []
	for letter in top_array:
		if letter == null: continue
		character_array.append(letter.stats.character.to_lower())
	var word = ''.join(character_array)
	## print(word, ' | IN: ', globvars.valid_words.has(word))
	
	if globvars.valid_words.has(word): return true
	return false
