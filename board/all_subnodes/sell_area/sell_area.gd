extends Area2D

@onready var parent = get_parent() as BoardClass
@onready var acting_timer = $acting_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func sell_focused_letter(): ## Removes from top_row, give player money? need to implement money/gold
	print('selling focused letter [remember to fix top_letters click to focus not working]')
	parent.leave_animation(globvars.focused_letter)

func freeze_focused_letter(): # Frozen letters stay in shop per refresh / new rounds
	print('freezing focused letter')
	var letter_to_freeze = globvars.focused_letter as LetterClass
	
	letter_to_freeze.freeze_or_unfreeze_letter()

func _on_input_event(viewport, event, shape_idx): # Input action on area, sells(top) or freezes(bot), maybe change to button like S.A.P?
	if Input.is_action_just_released('l_click') and globvars.focused_letter != null and acting_timer.is_stopped():
		
		# Checks if focused_letter in top_letters or bot_letters (will I only be doing this on focused?)
		if parent.top_letters.has(globvars.focused_letter): sell_focused_letter()
		elif parent.bot_letters.has(globvars.focused_letter): freeze_focused_letter()
		
		acting_timer.start()
