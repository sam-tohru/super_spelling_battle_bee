extends PanelContainer

@onready var gold_left_label = $CenterContainer/HBoxContainer/GoldLeftLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	globals.update_gold_left.connect(update_gold_left)
	globals.not_enough_gold_left.connect(not_enough_gold_left)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_gold_left(new_value: int):
	gold_left_label.text = str(new_value)

func not_enough_gold_left(): # Not enough gold, does little animation to indicate to player (and play sound)
	
	var tween = create_tween()
	tween.set_loops(2)
	tween.tween_property(gold_left_label, 'rotation_degrees', -64, 0.1)
	tween.parallel().tween_property(self, 'scale', Vector2(1.2,1.2), 0.1)
	
	tween.tween_property(gold_left_label, 'rotation_degrees', 0, 0.1)
	tween.parallel().tween_property(self, 'scale', Vector2(1.0,1.0), 0.1)
	
	tween.tween_property(gold_left_label, 'rotation_degrees', 64, 0.1)
	tween.parallel().tween_property(self, 'scale', Vector2(1.2,1.2), 0.1)
	
	tween.tween_property(gold_left_label, 'rotation_degrees', 0, 0.1)
	tween.parallel().tween_property(self, 'scale', Vector2(1.0,1.0), 0.1)
