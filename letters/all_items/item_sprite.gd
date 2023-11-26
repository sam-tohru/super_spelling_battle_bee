extends Sprite2D

@onready var sprite_animation_timer = $sprite_animation_timer
@onready var shake_timer = $shake_timer
@export_range(0.1, 0.8) var shake_time: float = 0.2

@onready var letter_sprite = self
@onready var eye_sprite = $eye_sprite
@onready var max_eyes = 6
@onready var eye_wag = 0


static var item_sprites: Dictionary = {
	'apple': "res://resources/icons_items/item_apple.png",
	'bread': "res://resources/icons_items/item_bread.png",
	'shell': "res://resources/icons_items/item_shell.png",
	'lizard': "res://resources/icons_items/item_lizard.png",
	'firebomb': "res://resources/icons_items/item_explosion.png",
	'feather': "res://resources/icons_items/item_summon.png" 
}


func set_letter_sprite(item: String):
	self.texture = load(item_sprites[item])
func _on_item_letter_stats_updated(item: String, _cost): # Signal from Parent
	set_letter_sprite(item)



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


