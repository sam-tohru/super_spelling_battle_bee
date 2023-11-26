extends Node2D

@onready var firework_1 = $firework_1
@onready var firework_2 = $firework_2

# Called when the node enters the scene tree for the first time.
func _ready():
	globals.explosive_sfx.connect(explosive_sfx)


func explosive_sfx(is_top_row: bool):
	globals.emit_signal('sfx_firework')
	if is_top_row: firework_1.emitting = true
	else: firework_2.emitting = true
