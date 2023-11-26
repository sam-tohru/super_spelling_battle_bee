extends Node2D
# class_name letter_piece

## Labels ##
@onready var character_label = $character_label
@onready var cost_label = $cost_label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func letter_stats_updated():
	pass


func _on_item_letter_stats_updated(item: String, cost: int):
	$character_label.text = item
	$cost_label.text = str(cost)
