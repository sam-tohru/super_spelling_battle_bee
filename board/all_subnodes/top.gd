extends Node2D

signal area_click_released
@onready var parent = get_parent() as BoardClass
@onready var max_letters = 6 # for parent.top_letters[6]

@onready var acting_timer = $acting_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func check_if_left_or_right(what_slot: int) -> bool:
	## True = Right, False = Left
	
	var focused_slot = parent.top_letters.find(globvars.focused_letter)
	
	if focused_slot == -1: return true ## No Focused Slot found, still pushes right
	
	if focused_slot > what_slot: # Focused is more right than what_slot (would be going left)
		
		# Checks if slot next to what_slot is empty (as can push with 1 maybe)
		if parent.top_letters[what_slot+1] == null: return true # Going right
		
		return false ## Going left
	
	return true ## Going Right
	
## Top letters Movement ##
func push_letters_right(what_slot: int) -> bool: # pushes all from slot to the right from slot (to make slot null, to move focus_letter)
	# return false
	var free_slot = parent.top_letters.find(null, what_slot) # Finds emtpy slot from what_slot
	
	if free_slot == -1: return false # No free slot, return false
	
	for i in range(free_slot, what_slot, -1):
		if i - 1 == -1: return false # Stops array[-1] errors
		# if parent.top_letters[i] == globvars.focused_letter: continue
		
		parent.place_animation(parent.top_letters[i-1], i, false)
		parent.top_letters[i] = parent.top_letters[i - 1]
		parent.top_letters[i - 1] = null
		# await parent.setting_up_done
	
	# Push Successful moves focused letter
	print('pushing right')
	return true

func push_letters_left(what_slot: int) -> bool:
	# return false
	var free_slot = parent.top_letters.find(null) # Finds emtpy slot
	
	
	if free_slot == -1: return false # No free slot, return false
	elif free_slot > what_slot: return false # can't push right (this is left)
	
	for i in range(free_slot, what_slot):
		# if i - 1 == -1: return false # Stops array[-1] errors
		# if parent.top_letters[i] == globvars.focused_letter: continue
		
		# Left 
		parent.place_animation(parent.top_letters[i+1], i, false)
		parent.top_letters[i] = parent.top_letters[i + 1]
		parent.top_letters[i + 1] = null
		
	
	# Push Successful moves focused letter
	
	return true

func swap_letters(what_slot: int): # Swaps if can't push right (or maybe prompt) only top-top swap
	
	if parent.top_letters[what_slot] == null: # Empty slot just move to
		parent.move_letter_into_empty_slot(globvars.focused_letter, what_slot, 'top')
		return
	elif parent.top_letters[what_slot] == globvars.focused_letter: return # Same as focused do nothing
	print('swapping')
	# Sets focused letter slot in top_letters to null & moves letter in what_slot to
	var old_slot = parent.top_letters.find(globvars.focused_letter)
	var old_letter = parent.top_letters[old_slot]
	parent.top_letters[old_slot] = null
	
	parent.move_letter_into_empty_slot(parent.top_letters[what_slot], old_slot, 'top')
	# await parent.setting_up_done # Maybe wait maybe don't idk
	parent.move_letter_into_empty_slot(old_letter, what_slot, 'none') # none as it'll remove above move if not
####################################################################################################

func move_to_top(what_slot: int): # bot -> top, Checks and Moves
	
	if globvars.focused_letter.frozen: globvars.focused_letter.freeze_or_unfreeze_letter() # Unfreezes letter if moving to top
	
	if parent.top_letters[what_slot] == null: # Move From Bot -> Top (empty slot)
		# Moves to empty slot
		parent.move_letter_into_empty_slot(globvars.focused_letter, what_slot, 'bot', true)
		return true 
	else: ## Letter in slot, -> Tries to push right, then left (bot->top, no swap, if full give prompt) ##
		if push_letters_right(what_slot) == true: 
			parent.move_letter_into_empty_slot(globvars.focused_letter, what_slot, 'bot', true)
			return true
		elif push_letters_left(what_slot) == true:
			parent.move_letter_into_empty_slot(globvars.focused_letter, what_slot, 'bot', true)
			return true
		else: 
			printerr('NEED SOME SORT OF INDICATOR THAT PLAYER CANT PLACE, THIS SHOULD ONLY BE WHEN TOP IS FULL, CANT SWAP BOT->TOP')
	
	return false
	

func top_to_top(what_slot: int) -> bool: # Re-arranging letters in top-row, or upgrading using letters on top-row
	if parent.top_letters[what_slot] == globvars.focused_letter: return false # Same letter
	
	elif parent.top_letters[what_slot] == null: ## Empty Slot, Just Move ##
		# Moves to empty slot
		parent.move_letter_into_empty_slot(globvars.focused_letter, what_slot, 'top', true)
		return true 
	
	else: ## Letter in slot, -> either swaps or pushes based on setting ##
		
		if globvars.top_letter_movement == 'ask': printerr('ERROR IN TOP, ASK letter movement not setup yet, need to return true or false') # Make prompt & wait, or react with signal
		elif globvars.top_letter_movement == 'swap': swap_letters(what_slot) ; return true
		elif globvars.top_letter_movement == 'push': # Pushes left or right, just swaps if can't
			if check_if_left_or_right(what_slot): # Pushes letters right
				if push_letters_right(what_slot) == true: parent.move_letter_into_empty_slot(globvars.focused_letter, what_slot, 'top', true) ; return true
				else: swap_letters(what_slot) ; return true
			else: # Pushes left
				if push_letters_left(what_slot) == true: parent.move_letter_into_empty_slot(globvars.focused_letter, what_slot, 'top', true) ; return true
				else: swap_letters(what_slot) ; return true # Left => Swap for top->top
	
	# Every path should return true if moved, this means it didn't move and returns false
	return false

func what_to_do_top(what_slot: int):
	if !parent.SETTING_UP:
		if globvars.cant_focus_new_letter: await globvars.can_focus_letter_change
		
		var moved = false
		
		if globvars.focused_letter.is_in_group('item'): moved = play_item(what_slot)
		elif parent.top_letters.has(globvars.focused_letter): moved = top_to_top(what_slot)
		elif parent.bot_letters.has(globvars.focused_letter): moved = move_to_top(what_slot)
		
		## Removes focus from letter, if it has been moved
		
		if globvars.focused_letter != null and moved:
			globvars.focused_letter.focus_or_unfocus_letter(false)
		
		# Board.SETTING_UP needs to be switched from the signal below (it's just animation playing bool, so change with that)
		emit_signal('area_click_released', 'top', what_slot) 

####################################################################################################
### Items play ###
func play_item(what_slot):
	var succesful_play = false # What it returns, if succesfull removes item
	var item_name = globvars.focused_letter.stats.item_name
	var item_target_type = globvars.focused_letter.stats.item_target_type
	var item_data = globvars.focused_letter.stats.item_data
	
	if item_data.is_empty():
		printerr('Play_item in top error, item data is empty')
		return false
	elif parent.shop.check_if_can_play(globvars.focused_letter.stats.cost) == false: return false
	
	
	if item_target_type == 'single': succesful_play = play_single_target_item(what_slot, item_name, item_data)
	elif item_target_type == 'random': succesful_play = play_random_target_item(item_name, item_data)
	
	if !succesful_play: printerr('item failed to play at last step') ; return succesful_play
	
	parent.shop.charge_player(globvars.focused_letter.stats.cost)
	
	return succesful_play

func play_single_target_item(what_slot: int, item_name: String, item_data: Array): 
	# Won't play if slot is empty
	if parent.top_letters[what_slot] == null: return false
	
	
	if item_data[1] == 'stats': # Buff stats of letter with item_data[2]
		parent.top_letters[what_slot].stats.upgrade_stats(item_data[2])
		parent.leave_animation(globvars.focused_letter)
	elif item_data[1] == 'effect':
		parent.top_letters[what_slot].stats.add_effect(item_data[2])
		parent.leave_animation(globvars.focused_letter)
	
	return true

func play_random_target_item(item_name: String, item_data: Array):
	if item_data[1] != 'stats': printerr('in board.top -> NEED TO SETUP EFFECTS FOR RANDOM UNITS (idk if i will add this ngl, but just-in-case)') ; return false
	# Below assumes we only buff stats (as above ^^ blocks it)
	
	var amount_to_target = item_data[3] # Amount of units it targets
	
	# Checks if there is even that amount of letters in top_row
	var letters_in_top = []
	for letter in parent.top_letters:
		if letter != null: letters_in_top.append(letter)
	if letters_in_top.size() == 0: return false # No letters in top, just doesn't play
	elif letters_in_top.size() < amount_to_target: amount_to_target = letters_in_top.size() # if less than target_amount, sets target_amount to that
	
	# Randomly picks letters to upgrade
	while amount_to_target > 0:
		if letters_in_top.is_empty(): break # Stops loop if array is empty
		
		var letter_to_buff = letters_in_top.pick_random()
		letters_in_top.erase(letter_to_buff) # Removes from array, as can't buff things more than once
		letter_to_buff.stats.upgrade_stats(item_data[2]) # Buffs letter with item_data[2]
		amount_to_target -= 1
	
	# All successful -> removes item also
	parent.leave_animation(globvars.focused_letter)
	return true

####################################################################################################
### Signals Area ###
func _on_top_area_0_input_event(viewport, event, shape_idx):
	
	if Input.is_action_just_released('l_click') and globvars.focused_letter != null and acting_timer.is_stopped():
		what_to_do_top(0)
		acting_timer.start()


func _on_top_area_1_input_event(viewport, event, shape_idx):
	if Input.is_action_just_released('l_click') and globvars.focused_letter != null and acting_timer.is_stopped():
		what_to_do_top(1)
		acting_timer.start()


func _on_top_area_2_input_event(viewport, event, shape_idx):
	if Input.is_action_just_released('l_click') and globvars.focused_letter != null and acting_timer.is_stopped():
		what_to_do_top(2)
		acting_timer.start()


func _on_top_area_3_input_event(viewport, event, shape_idx):
	if Input.is_action_just_released('l_click') and globvars.focused_letter != null and acting_timer.is_stopped():
		what_to_do_top(3)
		acting_timer.start()


func _on_top_area_4_input_event(viewport, event, shape_idx):
	if Input.is_action_just_released('l_click') and globvars.focused_letter != null and acting_timer.is_stopped():
		what_to_do_top(4)
		acting_timer.start()


func _on_top_area_5_input_event(viewport, event, shape_idx):
	if Input.is_action_just_released('l_click') and globvars.focused_letter != null and acting_timer.is_stopped():
		what_to_do_top(5)
		acting_timer.start()


func _on_top_area_6_input_event(viewport, event, shape_idx):
	if Input.is_action_just_released('l_click') and globvars.focused_letter != null and acting_timer.is_stopped():
		what_to_do_top(6)
		acting_timer.start()
