extends Node
class_name ShopClass

@onready var parent = get_parent() as BoardClass

@export var gold_left: int = 12
@export var starting_amount: int = 12
@export var cost_of_letter: int = 2
@export var sell_amount: int = 1
@export var cost_of_reroll: int = 1

func _ready():
	gold_left = starting_amount
	globals.emit_signal('update_gold_left', gold_left)
	
	
	globals.new_shop_round.connect(new_shop_round)
	globals.re_roll_pressed.connect(re_roll_pressed)

func new_shop_round(): # Resets Gold to default vaules
	gold_left = starting_amount
	globals.emit_signal('update_gold_left', gold_left)

func re_roll_pressed():
	if gold_left - cost_of_reroll < 0: # Not enough gold left
		globals.emit_signal('not_enough_gold_left')
	else: # Enough gold, takes away & rerolls
		gold_left -= cost_of_reroll
		
		parent.re_roll_bot()
		globals.emit_signal('update_gold_left', gold_left)


func check_if_can_play(cost) -> bool:
	if gold_left - cost < 0: globals.emit_signal('not_enough_gold_left') ; return false
	else: return true
func charge_player(cost) :
	gold_left -= cost
	gold_left = clampi(gold_left, 0, starting_amount)
	globals.emit_signal('update_gold_left', gold_left)
