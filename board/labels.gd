extends Control

@onready var parent = get_parent()

@onready var top_word_label: RichTextLabel = $top_word_label
@onready var bot_label = $bot_label


static var valid_word_string = 'Word is valid, you can battle!'
static var wrong_word_string = 'Make a real word on the top row'
static var warning_wrong_word = '[wave amp=15.0 freq=5.0 connected=1]Make a real word on the top row[/wave]'
static var warning_wrong_word_shake = '[shake rate=25.0 level=3 connected=1]Make a real word on the top row[/shake]'

@onready var running_warning: bool = false # Needs to know if the warning wrong word is on or just the normal wrong word string

# Called when the node enters the scene tree for the first time.
func _ready():
	globals.battle_button_invalid_word.connect(battle_invalid_word)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bot_label.text = str('SETTING UP: ', parent.SETTING_UP) # Sometimes board stays Setting_Up, this just shows it for debugging
	update_valid_word_label() # REMOVE THIS LATER FROM PROCESS? IDK


func update_valid_word_label():
	
	if get_parent().WORD_IS_VALID == true and top_word_label.text != valid_word_string:
		top_word_label.text = valid_word_string
	elif get_parent().WORD_IS_VALID == false and top_word_label.text != wrong_word_string:
		
		if running_warning: pass # Don't reset warning label, as it's doing text effects
		else: top_word_label.text = wrong_word_string 


func _on_board_word_is_valid_change(): # Signal from board, when word is valid change
	running_warning = false # no need for warning after a new valid is played (even if player changes they get the point maybe?)


func battle_invalid_word(): # Signal from BattleButton (warns player they need to make a real word)
	if running_warning: return # Does not run if animation already playing
	
	globals.emit_signal('sfx_invalid_word')
	running_warning = true
	top_word_label.text = warning_wrong_word_shake
	
	## Shake tween (needs to run less than the below await timers
	var shake_tween = create_tween()
	shake_tween.set_loops(12) # 12 * 0.1 = 1.2 secs
	shake_tween.tween_property(top_word_label, 'position', Vector2(top_word_label.position[0]-4, top_word_label.position[1]), 0.025)
	shake_tween.tween_property(top_word_label, 'position', Vector2(top_word_label.position[0], top_word_label.position[1]), 0.025)
	shake_tween.tween_property(top_word_label, 'position', Vector2(top_word_label.position[0]+4, top_word_label.position[1]), 0.025)
	shake_tween.tween_property(top_word_label, 'position', Vector2(top_word_label.position[0], top_word_label.position[1]), 0.025)
	
	
	## Slows down shake rate
	await get_tree().create_timer(1.0).timeout
	top_word_label.text = '[shake rate=15.0 level=3 connected=1]Make a real word on the top row[/shake]'
	await get_tree().create_timer(1.0).timeout
	running_warning = false
