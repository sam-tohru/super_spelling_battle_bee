extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	item_selected.connect(top_mode_changed)
	
	top_mode_changed(selected)

func top_mode_changed(index: int):
	if index < 0 or index > 2: index = clampi(index, 0, 2) ; printerr('TopModeOption Button Error, index greater than top_letter_movement range')
	
	# Changes globvars top_letter_movement based on index, make sure to keep above error check updated with max index
	if index == 0: globvars.top_letter_movement = 'ask'
	elif index == 1: globvars.top_letter_movement = 'push'
	elif index == 2: globvars.top_letter_movement = 'swap'

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
