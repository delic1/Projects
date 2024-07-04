extends Node2D

@onready var timer = $Timer

func _on_button_pressed():
	GameStats.set_new_day()
	
	get_tree().change_scene_to_file("res://World/world.tscn")
	timer.start(0.5)

func _on_timer_timeout():
	get_node("/root/World")._ready()
