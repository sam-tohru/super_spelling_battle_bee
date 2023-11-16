extends Node
class_name StatsLetter

@onready var parent = get_parent()

static var character_array = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
static var letter_stats: Dictionary = {
	'a': [1,2],
	
}

@export var character: String = 'a'
@export var attack: int = 1
@export var health: int = 1

func updated_letter(): # Letter has been updated (called after update stats)
	# emits signal from parent
	parent.emit_signal('letter_stats_updated', character, attack, health)


func set_up_letter(new_char: String, att: int, hp: int): # Sets up letter
	new_char = new_char.to_lower()
	# If not valid letter it just picks a random one
	if globvars.alphabet.has(new_char) == false: 
		printerr('uhhhh this character is not in character_array in letter.stats: ', new_char)
		new_char = character_array.pick_random()
	
	character = new_char
	attack = att
	health = hp
	
	updated_letter()


func set_up_character(): # Random letter character, just for initial spawn rn (in ready)
	## Random set_up rn, but change to a system after
	character = globvars.alphabet.pick_random()
	updated_letter()

func _ready():
	
	set_up_character()
