extends Node2D

@onready var won = $won
@onready var won_background = $won/background_particles
@onready var firework_1 = $won/firework_1
@onready var firework_2 = $won/firework_2
@onready var firework_3 = $won/firework_3
@onready var firework_4 = $won/firework_4
@onready var won_label = $won/Label

@onready var lost = $lost
@onready var lost_background = $lost/background_particles
@onready var lost_label = $lost/Label

@onready var tie = $tie
@onready var tie_background = $tie/background_particles
@onready var tie_label = $tie/Label

@onready var fight = $fight
@onready var fight_background = $fight/background_particles
@onready var fight_label = $fight/Label


# Called when the node enters the scene tree for the first time.
func _ready():
	globals.after_battle_animations.connect(after_battle_animations)
	globals.fight_animation.connect(fight_animation)


 ## EMITS END_BATTLE_ROUND AFTER ANIMATIONS PLAY 
func after_battle_animations(player_won: String): 
	globals.emit_signal('sfx_battle_done', player_won)
	if player_won == 'won': player_won_animation()
	elif player_won == 'lost': player_lost_animation()
	else: player_tie_animation()

func player_won_animation():
	won.visible = true
	won_background.emitting = true
	var tween = create_tween()
	tween.tween_property(won_label, 'scale', Vector2(1.2, 1.2), 0.2)
	tween.tween_property(won_label, 'scale', Vector2(1.0, 1.0), 0.1)
	
	await get_tree().create_timer(0.8).timeout
	globals.emit_signal('sfx_firework')
	firework_1.emitting = true
	await get_tree().create_timer(0.8).timeout
	globals.emit_signal('sfx_firework')
	firework_2.emitting = true
	await get_tree().create_timer(0.8).timeout
	globals.emit_signal('sfx_firework')
	firework_3.emitting = true
	await get_tree().create_timer(0.8).timeout
	globals.emit_signal('sfx_firework')
	firework_4.emitting = true
	won_background.emitting = false
	await get_tree().create_timer(0.8).timeout
	var new_tween = create_tween()
	new_tween.tween_property(won_label, 'scale', Vector2(0.1, 0.1), 0.5)
	won.visible = false
	
	globals.emit_signal('end_battle_round')

func player_lost_animation():
	lost.visible = true
	lost_background.emitting = true
	var tween = create_tween()
	tween.tween_property(lost_label, 'scale', Vector2(1.2, 1.2), 0.2)
	tween.tween_property(lost_label, 'scale', Vector2(1.0, 1.0), 0.1)
	
	await get_tree().create_timer(2).timeout
	lost_background.emitting = false
	await get_tree().create_timer(1).timeout
	var new_tween = create_tween()
	new_tween.tween_property(lost_label, 'scale', Vector2(0.1, 0.1), 0.5)
	lost.visible = false
	
	globals.emit_signal('end_battle_round')

func player_tie_animation():
	tie.visible = true
	tie_background.emitting = true
	var tween = create_tween()
	tween.tween_property(tie_label, 'scale', Vector2(1.2, 1.2), 0.2)
	tween.tween_property(tie_label, 'scale', Vector2(1.0, 1.0), 0.1)
	
	await get_tree().create_timer(2).timeout
	tie_background.emitting = false
	await get_tree().create_timer(1).timeout
	var new_tween = create_tween()
	new_tween.tween_property(tie_label, 'scale', Vector2(0.1, 0.1), 0.5)
	tie.visible = false
	
	globals.emit_signal('end_battle_round')

func fight_animation():
	fight.visible = true
	fight_background.emitting = true
	var tween = create_tween()
	tween.tween_property(fight_label, 'scale', Vector2(1.2, 1.2), 0.2)
	tween.tween_property(fight_label, 'scale', Vector2(1.0, 1.0), 0.1)
	
	await get_tree().create_timer(1).timeout
	fight_background.emitting = false
	var new_tween = create_tween()
	new_tween.tween_property(fight_label, 'scale', Vector2(0.1, 0.1), 0.5)
	fight.visible = false
