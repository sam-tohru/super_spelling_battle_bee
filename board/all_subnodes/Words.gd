extends Node

@onready var parent = get_parent()



func _process(delta):
	check_if_top_is_valid()

func check_if_top_is_valid():
	if get_parent().WORD_IS_VALID: # Word is valid, checks if no longer is valid
		if !globals.is_real_word(get_parent().top_letters): get_parent().change_word_is_valid(false)
	else: # Word not valid, checks if new is valid
		if globals.is_real_word(get_parent().top_letters): get_parent().change_word_is_valid(true)
