extends Node

@onready var parent = get_parent()
@export var item_name: String = 'bread'
@export var item_target_type: String = 'random'
@export var cost: int = 1

@onready var item_data: Array = []

func updated_item(): # Letter has been updated (called after update stats)
	# emits signal from parent
	parent.emit_signal('letter_stats_updated', item_name, cost)


func set_up_item(new_item: String, item_arr: Array): # Sets up letter
	# If not valid letter it just picks a random one
	if globvars.item_dict.has(new_item) == false: 
		printerr('ITEM NOT FOUND IN GLOBVARS DICT: ', new_item)
		return
	
	item_name = new_item
	
	item_target_type = item_arr[0]
	
	item_data = item_arr
	
	cost = item_arr[4]
	
	updated_item()
