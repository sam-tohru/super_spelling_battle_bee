extends Area2D
class_name LetterClass

signal letter_stats_updated

@onready var click_timer = $click_timer


@onready var held = false
@onready var drag_start_pos = Vector2.ZERO

@onready var in_top_row: bool = false

## Stats ##
@onready var stats = $stats

@onready var frozen = false
@onready var frozen_rect = $frozen_rect


## Nodes ##
@onready var letter_shape = $letter_shape
@onready var letter_sprite = $letter_sprite
@onready var letter_piece_ = $letter_piece

@onready var unfocus_button = $UnfocusButton

func set_up_letter():
	pass

func focus_or_unfocus_letter(to_focus: bool = false): # default is unfocus (if send nothing)
	if to_focus: 
		letter_sprite.start_shake()
		globvars.focused_letter = self
		
		unfocus_button.disabled = false
		var tween = create_tween()
		tween.tween_property(unfocus_button, 'modulate', Color(1, 1, 1), 0.1)
	else: 
		letter_sprite.stop_shake()
		globvars.focused_letter = null
		
		unfocus_button.disabled = true
		var tween = create_tween()
		tween.tween_property(unfocus_button, 'modulate', Color.TRANSPARENT, 0.1)
		

func kill_letter():
	if globvars.focused_letter == self: focus_or_unfocus_letter(false)
	
	self.queue_free()

func freeze_or_unfreeze_letter(): ## Freezes in store & starts particles, or unfreezes if already frozen
	if !frozen: # Freezes letter
		frozen = true
		frozen_rect.start_freeze()
	else: # Unfreezes
		frozen = false
		frozen_rect.end_freeze()
	
	if held: drop_letter() # Prevents letters being stuck on held in middle of board (if drag&release to freeze)
	# Unfocus letter (idk if it should just be when freeze or both, both rn like S.A.P)
	if globvars.focused_letter == self: focus_or_unfocus_letter(false)

func _ready():
	unfocus_button.pressed.connect(focus_or_unfocus_letter.bind(false)) # Pressing unfocus_button runs unfocus function

func _physics_process(delta): # Idk if drag should be physics or just process
	if held and globvars.focused_letter == self:
		if Input.is_action_pressed("l_click"): # Dragging
			# Move (just the sprite? or both, i think just sprite, then piece has slide animation if move but idk)
			letter_sprite.global_position = get_global_mouse_position()
		elif Input.is_action_just_released("l_click"): # Just Released 
			# Stops focus shake & goes back to pos 
			drop_letter()

func _on_input_event(viewport, event, shape_idx):
	
	if Input.is_action_just_pressed("l_click"): 
		
		## Can't click/focus when in battle_phase
		if globvars.BATTLE_PHASE: return
		
		if globvars.cant_focus_new_letter: return
		
		## allows moving with clicks, will return if it can't be clicked rn
		# The newly clicked letter is what runs this, if new letter in bot, it will change focus to that (like S.A.P)
		if globvars.focused_letter != null and globvars.focused_letter != self: 
			if !globvars.globs_bot_letters.has(self): return 
		
		click_letter()
	

################################################################################
### Start Click ###
func click_letter():
	# Unfocuses current letter if exists and not self
	if globvars.focused_letter != null and globvars.focused_letter != self:
		globvars.focused_letter.focus_or_unfocus_letter(false)
	
	drag_start_pos = letter_sprite.global_position
	held = true
	focus_or_unfocus_letter(true)
	# globals.emit_signal('clicked_letter', self) # Do i need? 
	
	
	globvars.cant_focus_new_letter = true # Can't set new focus while dragging

###############################################################################
### Drop End Release ###
func drop_letter(): # Drops, but doesn't remove focus
	held = false
	globals.emit_signal('dropped_letter', self)
	
	go_back_to_start_pos()
	

func go_back_to_start_pos(): # Player didn't do anything with drag, goes back to start position
	
	var tween = create_tween()
	tween.tween_property(letter_sprite, 'global_position', drag_start_pos, 0.1)
	tween.tween_callback(globvars.change_focus_new_letter.bind(false)) # Can set new focus letter (just can't while dragging)

