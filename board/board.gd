extends Node2D
class_name BoardClass

signal setting_up_done
signal word_is_valid_change

@onready var sprites_board = $sprites_board

@onready var top = $top
@onready var bot = $bot
@onready var battle = $battle
@onready var shop = $shop

@onready var mark_spawn = $bot/mark_spawn
@onready var mark_leave = $bot/mark_leave
@onready var mid_marker = $mid_marker
@onready var top_marker = $mid_marker/top_marker
@onready var bot_marker = $mid_marker/bot_marker

@onready var bot_markers = [$bot/mark_0, $bot/mark_1, $bot/mark_2, $bot/mark_3, $bot/mark_4, $bot/mark_5, $bot/mark_6]
@onready var bot_letters = [null, null, null, null, null, null, null]
@onready var frozen_bot_letters = [null, null, null, null, null, null, null] # For when saving frozen letters for next shop_phase

@onready var top_markers = [$top/mark_0, $top/mark_1, $top/mark_2, $top/mark_3, $top/mark_4, $top/mark_5, $top/mark_6]
@onready var top_letters = [null, null, null, null, null, null, null]
@onready var WORD_IS_VALID: bool = false

@onready var SETTING_UP:bool = false

@onready var battle_timer = $Timers/battle_timer

func change_setting_up(go_to: bool):
	SETTING_UP = go_to
	if !go_to: emit_signal('setting_up_done')

func change_word_is_valid(go_to: bool):
	WORD_IS_VALID = go_to
	emit_signal('word_is_valid_change')

# Called when the node enters the scene tree for the first time.
func _ready():
	top.area_click_released.connect(area_click_released)
	bot.area_click_released.connect(area_click_released)

func area_click_released(what_row: String, what_slot: int):
	return

func update_board(): # When chaning from Battle_phase to Shop_phase
	# Shop phase has less slots at bot
	if globvars.BATTLE_PHASE: 
		bot_markers[0].visible = true
		bot_markers[5].visible = true
	else: # Shop 
		bot_markers[0].visible = false
		bot_markers[5].visible = false

func update_global_letters(): # there's a globvars bot_letters & top_letters that are updated to match board here (globvars is just reference for letters to use to check)
	if globvars.globs_bot_letters != bot_letters: globvars.globs_bot_letters = bot_letters
	if globvars.globs_top_letters != top_letters: globvars.globs_top_letters = top_letters

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_global_letters()

func place_letter_onto_board(letter): ## Places letter onto bot only
	var marker_int = get_free_spot('bot')
	if marker_int == -1: push_error('GET_FREE_SPOT IS FULL IN PLANCE_LETTER_ONTO_BOARD'); return
	
	bot_letters[marker_int] = letter
	place_animation(letter, marker_int)

# Moves to empty slot 
func move_letter_into_empty_slot(letter_to_place: LetterClass, what_slot: int, from_where: String = 'none', to_top: bool = true):
	var row_letters = top_letters
	if !to_top: row_letters = bot_letters
	
	what_slot = clampi(what_slot, 0, 6) # Prevents array out of bounds errors, just clamps 6 is max in array 0->6
	
	if row_letters[what_slot] != null: # Error Can't place into full slot, returns false
		printerr('BOARD MOVE_LETTER_INTO_EMPTY_SLOT ERROR, SLOT NOT EMPTY')
		return false
	
	
	# Removes from old (sets to null) if no from_where given, it's a new letter and doesn't need remove
	if from_where == 'bot': 
		var old_slot = bot_letters.find(letter_to_place)
		bot_letters[old_slot] = null
	elif from_where == 'top':
		var old_slot = top_letters.find(letter_to_place)
		top_letters[old_slot] = null
	
	# Add letter to new slot
	row_letters[what_slot] = letter_to_place
	
	## Change positions & reset drag somehow?
	place_animation(letter_to_place, what_slot, false)

## Get's free spot on bot or top (where)
func get_free_spot(where:String) -> int:
	var marker_int = 0
	var what_array = bot_letters
	var what_markers = bot_markers
	if where == 'top': what_array = top_letters ; what_markers = top_markers
	
	for letter_slot in what_array:
		if letter_slot == null and what_markers[marker_int].visible: 
			return marker_int
		marker_int += 1
	
	return -1

func clear_bot() -> bool: # clears all in bot
	if SETTING_UP: push_error('BOARD ALREADY SETTING UP, SHOP_ROUND') ; return false
	if globvars.focused_letter != null: 
		globvars.focused_letter.focus_or_unfocus_letter(false)
		globvars.cant_focus_new_letter = false
	
	SETTING_UP = true
	var i = 0
	for letter in bot_letters:
		if letter != null:
			bot_letters[i] = null
			leave_animation(letter)
		i += 1
	SETTING_UP = false
	return true

func re_roll_bot(): # Re_rolls bot row (needs to keep frozen so different from above clear_bot)
	if SETTING_UP: push_error('BOARD ALREADY SETTING UP, SHOP_ROUND')
	SETTING_UP = true
	var i = 0
	for letter in bot_letters: # loops through bot_letters removing those not-frozen
		if letter != null:
			if letter.frozen == false: # removes non-frozen letters
				bot_letters[i] = null
				leave_animation(letter)
		i += 1
	SETTING_UP = false
	
	globals.emit_signal('re_roll_shop') # Goes to Main
	
	return

func save_frozen_letters(): ## Saves frozen letters into seperate array, to spawn back next shop_phase (saves: [is_item, char, att, hlth]
	var i = 0
	for letter in bot_letters:
		if letter == null: pass # Skips empty slots
		
		elif letter.frozen == true: 
			if letter.is_item == false: 
				frozen_bot_letters[i] = [letter.is_item, letter.stats.character, letter.stats.attack, letter.stats.health]
		
		i += 1

####################################################################################################
### ANIMATIONS ###
func place_animation(letter: LetterClass, into_pos: int, is_bot: bool = true): # for general placing on bot only (round start/change shop)
	if letter == null: return
	var row_markers = bot_markers
	if !is_bot: row_markers = top_markers
	change_setting_up(true)
	var tween = create_tween()
	tween.tween_property(letter, 'global_position', row_markers[into_pos].global_position, 0.2)
	tween.parallel().tween_callback(globals.emit_signal.bind('sfx_woosh'))
	tween.tween_interval(0.1)
	tween.tween_callback(change_setting_up.bind(false))

func leave_animation(letter): ## KILLS LETTERS
	if letter == null: return
	
	remove_letter_from_arrays(letter)
	
	var tween = create_tween()
	tween.tween_property(letter, 'position', mark_leave.position, 0.2)
	tween.parallel().tween_callback(globals.emit_signal.bind('sfx_woosh'))
	tween.tween_callback(letter.kill_letter)

func remove_letter_from_arrays(what_letter: LetterClass): ## Removes frop top or bot depending on which has the letter, if none (already removed) does nothing
	
	if top_letters.has(what_letter): 
		var spot = top_letters.find(what_letter)
		top_letters[spot] = null
	elif bot_letters.has(what_letter): 
		var spot = bot_letters.find(what_letter)
		bot_letters[spot] = null

####################################################################################################

