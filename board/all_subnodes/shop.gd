extends Node

@onready var parent = get_parent() as BoardClass

@export var gold_left: int = 12
@export var starting_amount: int = 12
@export var cost_of_letter: int = 2
@export var sell_amount: int = 1
@export var cost_of_reroll: int = 1

func _ready():
	gold_left = starting_amount
	globals.emit_signal('update_gold_left', gold_left)
	
	globals.re_roll_pressed.connect(re_roll_pressed)


func re_roll_pressed():
	if gold_left - cost_of_reroll < 0: # Not enough gold left
		globals.emit_signal('not_enough_gold_left')
	else: # Enough gold, takes away & rerolls
		gold_left -= cost_of_reroll
		
		parent.re_roll_bot()
		globals.emit_signal('update_gold_left', gold_left)
