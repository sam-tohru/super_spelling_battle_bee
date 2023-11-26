extends Node2D

@onready var board = $board as BoardClass
@onready var spawn_timer = $board/spawn_timer


# Called when the node enters the scene tree for the first time.
func _ready():
	globals.battle_button_pressed.connect(battle_button_pressed) ## Signal from BattleButton
	# globals.shop_round.connect(shop_round)
	globals.end_battle_round.connect(end_battle_round)
	
	globals.re_roll_shop.connect(shop_round)
	
	globals.spawn_set_letter.connect(spawn_set_letter)
	
	# globals.get_all_users()
	shop_round()
	


func battle_button_pressed(): # Signal from BattleButton, changes to battle round if only in shop_phase 
	if !board.SETTING_UP and !globvars.BATTLE_PHASE: next_round()
func end_battle_round(): ## Resets borad and new preps for new round (calls shop_round in)
	if !board.SETTING_UP and globvars.BATTLE_PHASE: next_round()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	# if Input.is_action_just_pressed("r_click") and !board.SETTING_UP: next_round()

func next_round(): # Clears board and changes round
	if !globvars.BATTLE_PHASE:
		board.save_frozen_letters()
		board.clear_bot()
		battle_round()
	else:# Go-to shop round
		board.clear_bot()
		shop_round()
		globals.emit_signal('new_shop_round')

func shop_round(): ## Need to incorperate spawning items (into last slot)
	if board.SETTING_UP: push_error('BOARD ALREADY SETTING UP, SHOP_ROUND') ; return
	board.SETTING_UP = true
	
	globvars.BATTLE_PHASE = false # Shop phase
	board.update_board()
	
	var i = 0
	for letter_slot in board.bot_letters:
		if i == 0 or i == 5: pass # Shop has less letter slots than battle (so skip slots turned off [1 & 5])
		elif i == 6: ## This will be item spawning [slot 6]
			if board.frozen_bot_letters[i] != null: spawn_item(board.frozen_bot_letters[i]) ; board.frozen_bot_letters[i] = null
			else: spawn_item()
		elif letter_slot == null: # Spawns letters into shop slots [1,2,3,4]
			
			if board.frozen_bot_letters[i] != null: # if any frozen letter, brings that in
				print('spawning frozen letter: ', board.frozen_bot_letters[i], ' in i: ', i)
				if board.frozen_bot_letters[i][0] == false: # Spawns letter (not item which would be true) this stops errors in-case item is in wrong slot
					spawn_set_letter(board.frozen_bot_letters[i][1], board.frozen_bot_letters[i][2], board.frozen_bot_letters[i][3], true)
				
				board.frozen_bot_letters[i] = null
			else: await spawn_letter()
		
		i += 1
	board.SETTING_UP = false

func spawn_item(item_name: String = ''):
	
	var load_item = load("res://letters/items.tscn")
	var item_instance = load_item.instantiate() as LetterClass
	item_instance.position = board.mark_spawn.position
	call_deferred('add_child', item_instance)
	board.place_letter_onto_board(item_instance)
	
	spawn_timer.start()
	await spawn_timer.timeout
	
	# Sets up random item here
	var rand_item_key = globvars.item_dict.keys()[randi() % globvars.item_dict.size()]
	var rand_item_data = globvars.item_dict[rand_item_key]
	
	if item_name != '': # Get's frozen / specific letter
		rand_item_key = item_name
		rand_item_data = globvars.item_dict[rand_item_key]
		item_instance.freeze_or_unfreeze_letter() # Freezes (rn this if only runs if item was frozen, so take that into account if change)
	
	item_instance.stats.set_up_item(rand_item_key, rand_item_data)

func spawn_letter(): ## Spawns letter from base stats (shop round mainly)
	# ADD NEW LETTER INSTANCE-
	var load_letter = load("res://letters/letter.tscn")
	var letter_instance = load_letter.instantiate() as LetterClass
	letter_instance.position = board.mark_spawn.position
	call_deferred('add_child', letter_instance)
	board.place_letter_onto_board(letter_instance)
	
	spawn_timer.start()
	await spawn_timer.timeout
	
	## SET STATS ## Each letter has the same random chance of appearing
	var let = globvars.alphabet.pick_random()
	var stat_arr = globvars.letter_stats[let]
	
	letter_instance.stats.set_up_letter(let, stat_arr[0], stat_arr[1])

func spawn_set_letter(let: String, att: int, hlth: int, is_frozen: bool = false, on_bot: bool = true): ## spawns & sets custom letters (battle round mainly)
	# ADD NEW LETTER INSTANCE
	var load_letter = load("res://letters/letter.tscn")
	var letter_instance = load_letter.instantiate() as LetterClass
	letter_instance.position = board.mark_spawn.position
	
	await call_deferred('add_child', letter_instance)
	
	board.place_letter_onto_board(letter_instance, on_bot)
	
	spawn_timer.start()
	await spawn_timer.timeout
	
	## SET STATS ##
	letter_instance.stats.set_up_letter(let, att, hlth)
	
	if is_frozen: letter_instance.freeze_or_unfreeze_letter()

func battle_round(): # Sets up battle round ### NEED TO RE-DO WHEN I HAVE NEW SW_DATABASE ###
	if board.SETTING_UP: push_error('BOARD ALREADY SETTING UP, SHOP_ROUND') ; return
	var full_data = null # await globals.get_random_sw_user_data()
	
	if full_data == null: error_spawn() ; return
	
	full_data = full_data.Weapons
	
	var max_letters = full_data[0].size()
	var i = 0 
	
	board.SETTING_UP = true
	while i < max_letters:
		await spawn_set_letter(full_data[0][i], full_data[1][i], full_data[2][i])
		i += 1
			
	board.SETTING_UP = false
	
	## Battle in board.battle
	board.battle.battle_board()


func error_spawn():
	printerr('ERROR SPAWNING, probs from no data from SilentWolf for battle_round but idk...')
	var max_letters = ['u', 'r', 'b', 'a', 'n']
	var i = 0 
	
	globvars.BATTLE_PHASE = true
	board.update_board()
	
	board.SETTING_UP = true
	for let in max_letters:
		var stat_arr = globvars.letter_stats[let]
		await spawn_set_letter(let, stat_arr[0], stat_arr[1])
		i += 1
			
	board.SETTING_UP = false
	
	## Battle in board.battle
	board.battle.battle_board()

