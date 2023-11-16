extends Sprite2D

@onready var sprite_animation_timer = $sprite_animation_timer
@onready var shake_timer = $shake_timer
@export_range(0.1, 0.8) var shake_time: float = 0.2

@onready var letter_sprite = self
@onready var eye_sprite = $eye_sprite
@onready var max_eyes = 6
@onready var eye_wag = 0

static var letter_to_sprite: Dictionary = {
	'a': 0,
	'b': 1,
	'c': 2,
	'd': 3,
	'e': 4,
	'f': 5,
	'g': 6,
	'h': 7,
	'i': 8,
	'j': 9,
	'k': 10,
	'l': 11,
	'm': 12,
	'n': 13,
	'o': 14,
	'p': 15,
	'q': 16,
	'r': 17,
	's': 18,
	't': 19,
	'u': 20,
	'v': 21,
	'w': 22,
	'x': 23,
	'y': 24,
	'z': 25,
}

func set_letter_sprite(letter: String):
	if !letter_to_sprite.has(letter): printerr('SET_LETTER_SPRITE LETTER NOT IN DICTIONARY: ', letter) ; return
	
	var letter_int = letter_to_sprite[letter]
	self.set_frame(letter_int)
func _on_letter_letter_stats_updated(letter: String, _attack, _health): # Signal from Parent
	set_letter_sprite(letter)



func _on_sprite_animation_timer_timeout():
	if get_parent().held: 
		if sprite_animation_timer.wait_time != 0.01: sprite_animation_timer.set_wait_time(0.05)
	
		var eye_wag_arr = [5, 6, 4, 6]
		eye_wag += 1
		if eye_wag >= 4: eye_wag = 0
	
		# eye_sprite.frame = eye_wag_arr[eye_wag]
		eye_sprite.frame = randi_range(0, max_eyes) 
	else: 
		eye_sprite.frame = randi_range(0, max_eyes) 
		if sprite_animation_timer.wait_time != 0.6: sprite_animation_timer.set_wait_time(0.6)
	
#	eye_sprite.frame = randi_range(0, max_eyes) 
#	if sprite_animation_timer.wait_time != 0.6: sprite_animation_timer.wait_time == 0.6

func shake_tween():
	var tween = create_tween()
	tween.tween_property(self, 'rotation_degrees', randf_range(3,6),shake_time/4)
	tween.tween_property(self, 'rotation_degrees', 0, shake_time/4)
	tween.tween_property(self, 'rotation_degrees', randf_range(-3,-6), shake_time/4)
	tween.tween_property(self, 'rotation_degrees', 0, shake_time/4)

func start_shake():
	shake_timer.start()
	shake_tween()
func stop_shake():
	shake_timer.stop()

func _on_shake_timer_timeout(): 
	# Keeps shaking until globvars.focused_letter not parent, might change to just stop_shake? idk
	if globvars.focused_letter == get_parent(): 
		shake_tween()
		shake_timer.start()



