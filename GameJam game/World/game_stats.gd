extends Node

var spawn_waves = []
var wave = 0
var enemy_number: set = set_enemy_number
var day = 1: set = set_day
var game_state = true

signal pick_up_items

func _ready():
	generate_waves()
	enemy_number = spawn_waves[0]

func set_enemy_number(value):
	enemy_number = value

func set_day(value):
	day = value

func next_wave():
	emit_signal("pick_up_items")
	wave += 1
	if wave < spawn_waves.size():
		set_enemy_number(spawn_waves[wave])
	else:
		game_state = false

func set_new_day():
	game_state = true
	day += 1
	wave = 0
	GameStats.generate_waves()

func generate_waves():
	spawn_waves.clear()
	var step = 0
	for i in range(0, day):
		spawn_waves.append(int(ceil(1 + step * day)))
		step += 0.5
	
	enemy_number = spawn_waves[0]
