extends Camera2D

## Variables ##
@onready var shake_timer = $shake_timer
@onready var shake_intensity = 0 
var default_offset = offset

@export var walk_shake_intensity = 8
@export var stop_shake_intensity = 250
@export var block_shake_intensity = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	globals.screen_shake.connect(shake)


## SCREEN SHAKING ##
# When Process is running, screen will be shaking 
func _process(delta):
	var shake_vector = Vector2(randf_range(-1,1) * shake_intensity, randf_range(-1,1) * shake_intensity)
	var tween = create_tween()
	tween.tween_property(self, "offset", shake_vector, 0.1)

func shake(intensity, time=0.1):
	shake_intensity = intensity
	set_process(true) # runs _process
	shake_timer.wait_time = time
	shake_timer.start()
	

func _on_shake_timer_timeout():
	set_process(false) # stops _process
	# TWEEN TO SET BACK TO NORMAL #
	var tween = create_tween()
	tween.tween_property(self, "offset", default_offset, 0.1)

