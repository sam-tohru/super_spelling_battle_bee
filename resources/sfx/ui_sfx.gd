extends Node

@onready var error = $error

@onready var wrong_word = $wrong_word
@onready var wrong_word2 = $wrong_word2
@onready var wrong_word3 = $wrong_word3


func _ready():
	globals.not_enough_gold_left.connect(sfx_no_gold)
	
	globals.sfx_invalid_word.connect(sfx_invalid_word)

func sfx_no_gold():
	if globvars.mute_sfx: return
	
	error.set_volume_db(globvars.volume)
	error.play()

func sfx_invalid_word():
	if globvars.mute_sfx: return
	
	## Picks one to play (out of the 3, the 3rd being super rare and a bit long but funny, so i kept in lol)
	var randi = randi_range(1, 100)
	var sfx_to_play = wrong_word
	if randi == 100: sfx_to_play = wrong_word3
	elif randi > 60: sfx_to_play = wrong_word2
	
	sfx_to_play.set_volume_db(globvars.volume)
	sfx_to_play.play()
