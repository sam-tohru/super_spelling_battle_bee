extends Node2D

@onready var hits = [$hit_1, $hit_2, $hit_3]

# Called when the node enters the scene tree for the first time.
func _ready():
	globals.hit_effect.connect(hit_effect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hit_effect():
	var to_hit = hits.pick_random()
	to_hit.emitting = true
