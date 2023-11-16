extends ColorRect


## main_menu buttons
@onready var resume_button = $CenterContainer/menu_splits_hbox/main_menu/MarginContainer/main_hbox/resumeButton
@onready var settings_button = $CenterContainer/menu_splits_hbox/main_menu/MarginContainer/main_hbox/settingsButton
@onready var save_button = $CenterContainer/menu_splits_hbox/main_menu/MarginContainer/main_hbox/saveButton
@onready var load_button = $CenterContainer/menu_splits_hbox/main_menu/MarginContainer/main_hbox/loadButton
@onready var quit_button = $CenterContainer/menu_splits_hbox/main_menu/MarginContainer/main_hbox/quitButton


@onready var settings = $CenterContainer/menu_splits_hbox/settings

@onready var load_save = $CenterContainer/menu_splits_hbox/load_save
@onready var ls_label = $CenterContainer/menu_splits_hbox/load_save/MarginContainer/ls_hbox/ls_label

@onready var animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	resume_button.pressed.connect(unpause) # resumes the game
	quit_button.pressed.connect(get_tree().quit) # quit the game
	
	globals.main_button_pressed.connect(pause)
	
	pause() # initially needs to pause when start game


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	# Pauses / Unpauses the game (game not set-up yet but you can imagine) 
	if event.is_action_pressed('esc') and !globvars.player_in_game_menu:
		if get_tree().paused: unpause()
		else: pause()

func unpause():
	globals.emit_signal('game_resumed')
	
	# self.visible = false # Need to make actual fade animation & disable buttons
	animation_player.play("resume")
	
	# Disables main buttons
	resume_button.disabled = true
	settings_button.disabled = true
	save_button.disabled = true
	load_button.disabled = true
	quit_button.disabled = true
	
	# Diasbles other menus
	load_save.load_save_menu(false, 'Save')
	settings.settings_menu(false)
	
	
	get_tree().paused = false

func pause():
	globals.emit_signal('game_paused')
	
	# self.visible = true # Need to make actual fade animation & disable buttons
	animation_player.play("pause")
	
	resume_button.disabled = false
	settings_button.disabled = false
	save_button.disabled = false
	load_button.disabled = false
	quit_button.disabled = false
	
	get_tree().paused = true


### Buttons that open side menus ###

func _on_settings_button_pressed():
	if settings.is_visible_in_tree(): settings.settings_menu(false)
	else: settings.settings_menu(true)

func _on_save_button_pressed():
	if load_save.is_visible_in_tree() and ls_label.text == 'Save': load_save.load_save_menu(false, 'Save')
	else: load_save.load_save_menu(true, 'Save') 

func _on_load_button_pressed():
	if load_save.is_visible_in_tree() and ls_label.text == 'Load': load_save.load_save_menu(false, 'Load')
	else: load_save.load_save_menu(true, 'Load')


