extends Node2D
class_name letter_piece

## Labels ##
@onready var character_label = $character_label
@onready var attack_label = $attack_label
@onready var health_label = $health_label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func letter_stats_updated():
	pass


func _on_letter_letter_stats_updated(character: String, attack: int, health: int):
	
	$character_label.text = character.capitalize()
	$attack_label.text = str(attack)
	$health_label.text = str(health)
