extends Button

# @onready var board = self.owner as BoardClass ## Board scene (top of the scene)

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(battle_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func battle_button_pressed():
	
	var board = self.owner as BoardClass
	
	if board == null: printerr('Error in BattleButton, owner is not type BoardClass (or is just null), it should be the board') ; return
	# if self.owner is BoardClass == false: printerr('Error in BattleButton, owner is not type BoardClass, it should be the board') ; return
	
	# Checks if word is valid on board or not, and does what it should
	if board.WORD_IS_VALID: globals.emit_signal('battle_button_pressed') ## Word is valid, starts battle round
	else: globals.emit_signal('battle_button_invalid_word') ## Word not valid, indicate to player they need to make a real word

