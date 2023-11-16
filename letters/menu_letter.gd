extends Area2D

@onready var held = false
@onready var FROZEN = false
@onready var frozen_rect = $frozen_rect
@onready var frozen_particles = $frozen_rect/frozen_particles

@onready var drag_start_pos = Vector2.ZERO


## Stats ##
@onready var character: String
@onready var attack: int
@onready var health: int

## Labels ##
@onready var character_label = $character_label
@onready var attack_label = $attack_label
@onready var health_label = $health_label

@onready var focus_shake = $focus_shake

@onready var focus_tween

@onready var click_timer = $click_timer

@onready var menu_focused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_letter(9)

func kill_letter():
	self.queue_free()

func change_letter(new_letter):
	character = new_letter
	character_label.text = character
	
	var letter_int = globvars.alphabet.find(new_letter.to_upper())
	set_letter_sprite(letter_int)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if held and Input.is_action_pressed("click_left"): 
		var drag_delta = get_global_mouse_position() - drag_start_pos
		global_position = get_global_mouse_position()
		drag_start_pos = global_position

func ready_letter(reroll_penalty):
	# character = globvars.alphabet.pick_random()
	# character_label.text = character
	
	
	attack = randi_range(1, reroll_penalty)
	health = randi_range(1, reroll_penalty)
	attack_label.text = str(attack)
	health_label.text = str(health)

func freeze_letter(): # just returns now as i removed freezing
	return
	if !FROZEN:
		FROZEN = true
		frozen_rect.visible = true
		frozen_particles.emitting = true
	elif FROZEN:
		FROZEN = false
		frozen_rect.visible = false
		frozen_particles.emitting = false


func _on_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click_left") and !globvars.FOCUS_ANIMATION_PLAYING: 
		if !menu_focused: focus_menu_letter(self)
		else: unfocus_letter(self)

func change_animation(new_letter: String, reroll_num: int):
	var tween = create_tween()
	tween.tween_property(self, 'rotation_degrees', 180, 0.05)
	tween.parallel().tween_property(self, 'scale', Vector2(1.2, 1.2), 0.05)
	tween.tween_callback(change_letter.bind(new_letter))
	tween.tween_callback(ready_letter.bind(reroll_num))
	tween.tween_property(self, 'rotation_degrees', 0, 0.05)
	tween.parallel().tween_property(self, 'scale', Vector2(1, 1), 0.05)

func focus_menu_letter(letter):
	if letter == null: return
	menu_focused = true
	var tween = create_tween()
	tween.tween_property(letter, 'rotation_degrees', -5, 0.1)
	tween.parallel().tween_property(letter, 'scale', Vector2(1.3, 1.3), 0.1)
	tween.tween_property(letter, 'rotation_degrees', 0, 0.1)
	
	tween.tween_callback(letter.letter_focus_timer.bind(true))

func unfocus_letter(letter): 
	if letter == null: return
	menu_focused = false
	var tween = create_tween()
	tween.tween_callback(letter.letter_focus_timer.bind(false))
	tween.tween_property(letter, 'rotation_degrees', 5, 0.1)
	tween.parallel().tween_property(letter, 'scale', Vector2(1.0, 1.0), 0.1)
	tween.tween_property(letter, 'rotation_degrees', 0, 0.1)


func letter_focus_timer(to_go: bool):
	if to_go: 
		focus_shake.start()
		focus_tween = create_tween()
		focus_tween.tween_property(self, 'rotation_degrees', randi_range(-5,-15), 0.1)
		focus_tween.tween_property(self, 'rotation_degrees', 0, 0.1)
		focus_tween.tween_property(self, 'rotation_degrees', randi_range(-5,-15), 0.1)
		focus_tween.tween_property(self, 'rotation_degrees', 0, 0.1)
	elif !to_go: focus_shake.stop()

func _on_focus_shake_timeout():
	if focus_tween: focus_tween.kill()
	focus_tween = create_tween()
	focus_tween.tween_property(self, 'rotation_degrees', randi_range(-5,-15), 0.1)
	focus_tween.tween_property(self, 'rotation_degrees', 0, 0.1)
	focus_tween.tween_property(self, 'rotation_degrees', randi_range(5,15), 0.1)
	focus_tween.tween_property(self, 'rotation_degrees', 0, 0.1)


## Sprite & Animation Stuff ##

@onready var sprite_animation_timer = $sprite_animation_timer
@onready var letter_sprite = $letter_sprite
@onready var eye_sprite = $letter_sprite/eye_sprite
@onready var max_eyes = 6

func set_letter_sprite(letter_int: int):
	letter_sprite.frame = letter_int

func _on_sprite_animation_timer_timeout():
	eye_sprite.frame = randi_range(0, max_eyes)
