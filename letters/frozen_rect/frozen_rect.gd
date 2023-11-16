extends ColorRect

@onready var parent = get_parent()
@onready var frozen_rect = self
@onready var frozen_particles = $frozen_particles

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_freeze():
	frozen_rect.visible = true

func end_freeze():
	frozen_rect.visible = false
