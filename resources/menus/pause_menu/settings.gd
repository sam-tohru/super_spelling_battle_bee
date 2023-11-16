extends PanelContainer


@onready var volume_slider = $MarginContainer/settings_hbox/volume_slider


# Called when the node enters the scene tree for the first time.
func _ready():
	volume_slider.value = globvars.volume


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func settings_menu(visibility: bool):
	
	## On or Off
	self.visible = visibility
	
	## Disables / Enables all buttons & editables
	volume_slider.editable = visibility


func _on_volume_slider_value_changed(value):
	if value == volume_slider.min_value: value = -100 # Mute on lowest
	
	globvars.volume = value
	globals.emit_signal('volume_changed')
