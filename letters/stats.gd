extends Node
class_name StatsLetter

@onready var parent = get_parent()

static var character_array = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

@export var character: String = 'a'
@export var attack: int = 1
@export var health: int = 1

@export var effect_from_item: String = '' # Any effects will be stored here

func updated_letter(): # Letter has been updated (called after update stats)
	# emits signal from parent
	parent.emit_signal('letter_stats_updated', character, attack, health)


func set_up_letter(new_char: String, att: int, hp: int): # Sets up letter
	new_char = new_char.to_lower()
	# If not valid letter it just picks a random one
	if new_char == '?': pass # '?' is only from item_effect now (idk if will add to alphabet but if do remove is
	elif globvars.alphabet.has(new_char) == false: 
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

func hit_letter(damage: int) -> int:
	var new_health = health - damage
	
	return new_health

# AoE damage currently doesn't kill letters (sets to a minimum or 1hp, this stops frustration from insta-killing letters, but might change)
func aoe_damage_letter(damage: int): 
	
	# AoE can doesn't kill, goes to minimum of 1
	var new_health = health - damage
	if new_health <= 0: new_health = 1
	
	var rand_dir = [-1,1].pick_random() * 12 # This just gets -12 or 12 for random rotation
	
	var tween = create_tween()
	tween.tween_property(parent, 'rotation_degrees', rand_dir, 0.05)
	tween.tween_callback(set_up_letter.bind(character, attack, new_health))
	tween.parallel().tween_property(parent, 'rotation_degrees', 0, 0.05)

#####################################################
## Upgrades form items ##
func upgrade_stats(data: Array): # add stat to stats [attack, health]
	attack += data[0]
	health += data[1]
	updated_letter()
	updrage_tween()

func updrage_tween():
	var tween = create_tween()
	tween.tween_property(parent, 'rotation_degrees', randi_range(14,18), 0.05)
	tween.tween_property(parent, 'rotation_degrees', 0, 0.05)
	tween.tween_property(parent, 'rotation_degrees', randi_range(-14,-18), 0.05)
	tween.tween_property(parent, 'rotation_degrees', 0, 0.05)

func add_effect(effect_type: String):
	effect_from_item = effect_type
	updrage_tween()
	parent.modulate = Color(0, 1, 0) # REMOVE LATER, JUST FOR VISUAL RIGHT NOW
func remove_effect():
	effect_from_item = ''
	parent.modulate = Color(1, 1, 1) # REMOVE LATER, JUST FOR VISUAL RIGHT NOW
