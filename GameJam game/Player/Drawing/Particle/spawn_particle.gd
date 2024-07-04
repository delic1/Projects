extends Node2D

var mouse_left_down: bool = false
var last_spawn_position : Vector2 = Vector2(-100, -100)
@export var distance_to_spawn : float = 10.0

const draw_particle = preload("res://Player/Drawing/Particle/particle.tscn")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	if mouse_left_down && last_spawn_position.distance_to(mouse_position) > distance_to_spawn:
		spawnParticle(mouse_position)

func spawnParticle(mouse_position):
	var drawParticle = draw_particle.instantiate()
	get_parent().add_child(drawParticle)
	drawParticle.global_position = mouse_position
	
	last_spawn_position = mouse_position
