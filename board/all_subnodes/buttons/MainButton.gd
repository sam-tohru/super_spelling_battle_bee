extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(main_button_pressed)

func main_button_pressed():
	if !globvars.player_in_game_menu: globals.emit_signal('main_button_pressed')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

