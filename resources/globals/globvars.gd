extends Node


## Global Variables
@onready var player_in_game_menu: bool = false # if player is in an in_game_menu (not the main_menu)

## Board Stuff
@onready var cant_focus_new_letter: bool = false # if like animation is playing or something, stops focus on new stuff
func change_focus_new_letter(go_to: bool):
	cant_focus_new_letter = go_to
	if !go_to: emit_signal('can_focus_letter_change')
signal can_focus_letter_change

# Reference to board top & bot letters, this should only be changed via board.update_global_letters() and nothing else
@onready var globs_top_letters: Array = [null, null, null, null, null, null, null] 
@onready var globs_bot_letters: Array = [null, null, null, null, null, null, null]

@onready var BATTLE_PHASE: bool = false  # shop phase vs battle phase

@onready var focused_letter: LetterClass = null

@onready var MAX_LETTERS = 7
@onready var first_play_shop = true

@onready var top_letter_movement: String = 'push'

## Items -> holds array [target_type, stat_or_effect, buff_amount/name_of_buff, amount_of_units_hits/other_info, cost_of_item]
static var item_dict: Dictionary = {
	'apple': ['single', 'stats', [1,1], 1, 4],
	'bread': ['random', 'stats', [0,1], 2, 4], # 2 is the amount of letters it hits, 4 after is the cost of item
	'shell': ['single', 'effect', 'shield', 1, 4],
	'lizard': ['single', 'effect', 'revive', 1, 4],
	'firebomb': ['single', 'effect', 'explosive', 1, 4],
	'feather': ['single', 'effect', 'summon', 1, 4]
}
static var item_effect_types: Dictionary = { # Stores all effects with when they should proc (for reference, e.g. 'damage' = when taken damage)
	'shield': ['damage'],
	'revive': ['death'],
	'explosive': ['death'],
	'summon': ['death']
}

## Words
static var alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
static var letter_stats: Dictionary = {
	'a': [1,2],
	'b': [2,2],
	'c': [2,2],
	'd': [3,2],
	'e': [1,2],
	'f': [3,1],
	'g': [2,4],
	'h': [3,3],
	'i': [1,2],
	'j': [5,1],
	'k': [4,2],
	'l': [2,3],
	'm': [3,3],
	'n': [2,4],
	'o': [1,2],
	'p': [3,2],
	'q': [5,2],
	'r': [3,3],
	's': [2,4],
	't': [1,5],
	'u': [2,2],
	'v': [4,1],
	'w': [4,2],
	'x': [5,1],
	'y': [4,1],
	'z': [6,1],
}
@onready var valid_words: Dictionary

## Settings 
@onready var mute_music: bool = false
@onready var mute_sfx: bool = false
@onready var volume: float = 0.0

func _ready():
	
	### LOADS WORDS INTO VALID_WORDS ###
	var words_file = FileAccess.open("res://resources/words_dictionary.json", FileAccess.READ)
	var json_object = JSON.new()
	var parse = json_object.parse(words_file.get_as_text())
	
	for word in json_object.get_data():
		# if word.length() == 3: three_letter_words.append(word) # Was old ID system idk if i'll keep
		
		if word.length() > MAX_LETTERS: continue
		else: valid_words[word] = 1
	
