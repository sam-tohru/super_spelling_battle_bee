extends PanelContainer

@onready var ls_label = $MarginContainer/ls_hbox/ls_label
@onready var h_separator = $MarginContainer/ls_hbox/HSeparator
@onready var save_auto = $MarginContainer/ls_hbox/save_auto
@onready var save_0 = $MarginContainer/ls_hbox/save_0
@onready var save_1 = $MarginContainer/ls_hbox/save_1
@onready var save_2 = $MarginContainer/ls_hbox/save_2
@onready var save_3 = $MarginContainer/ls_hbox/save_3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_save_menu(visibility: bool, load_or_save: String):
	
	## On or Off
	self.visible = visibility
	
	
	## Disables / Enables all buttons
	save_auto.disabled = !visibility
	save_0.disabled = !visibility
	save_1.disabled = !visibility
	save_2.disabled = !visibility
	save_3.disabled = !visibility
	
	
	## Load or Save
	ls_label.text = load_or_save
