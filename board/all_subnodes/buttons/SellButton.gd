extends Button

@onready var board = self.owner as BoardClass
@onready var acting_timer = $acting_timer

@onready var mouse_on_button: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(sell_button_pressed)
	
	# For when dragging to freeze/sell letters, needs to check if mouse is over button (gui_input dont work when holding letter)
	mouse_entered.connect(func(): mouse_on_button=true)
	mouse_exited.connect(func(): mouse_on_button=false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if globvars.focused_letter != null:
		if board.top_letters.has(globvars.focused_letter): self.text = 'Sell'
		elif board.bot_letters.has(globvars.focused_letter): self.text = 'Freeze'

func sell_focused_letter(): ## Removes from top_row, give player money? need to implement money/gold
	board.leave_animation(globvars.focused_letter)

func freeze_focused_letter(): # Frozen letters stay in shop per refresh / new rounds
	var letter_to_freeze = globvars.focused_letter as LetterClass
	
	letter_to_freeze.freeze_or_unfreeze_letter()


func checks_and_sells_or_freezes(): # Just an if-statement that either sells or freezes focused_letter
	if globvars.focused_letter == null: return
	
	# Checks if focused_letter in top_letters or bot_letters (will I only be doing this on focused?)
	if board.top_letters.has(globvars.focused_letter): sell_focused_letter()
	elif board.bot_letters.has(globvars.focused_letter): freeze_focused_letter()


func sell_button_pressed(): # for when the player presses button
	if acting_timer.is_stopped():
		checks_and_sells_or_freezes()
		acting_timer.start()

func _input(event): # For when player drags & releases over button
	if event.is_action_released('l_click') and mouse_on_button and acting_timer.is_stopped():
		checks_and_sells_or_freezes()
		acting_timer.start()
