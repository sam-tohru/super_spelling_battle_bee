extends Button

@onready var board = self.owner as BoardClass

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(re_roll_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func re_roll_button_pressed(): # NEEDS TO CHECK IF HAVE MONEY LEFT TO RE_ROLL, just infinite right now for testing
	
	# Can only run in shop_phase & when not setting up
	if globvars.BATTLE_PHASE: return
	elif board.SETTING_UP: return
	
	globals.emit_signal('re_roll_pressed')

