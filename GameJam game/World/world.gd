extends Node2D

var Pirate = preload("res://Enemy/Custom/pirate.tscn")
var Animal = preload("res://Enemy/Custom/animal.tscn")
var Caveman = preload("res://Enemy/Custom/caveman.tscn")

@onready var timerWaves = $TimerWaves
@onready var timerSpawns = $TimerSpawns

var rng = RandomNumberGenerator.new()
var sp = 0
var subWaveSize:int = 5
var subWaves = 0
var lastSubWave = 0

func _process(delta):
	if GameStats.game_state == false:
		get_tree().change_scene_to_file("res://World/night.tscn")
	if GameStats.enemy_number <= 0 && timerWaves.time_left <= 0:
		GameStats.next_wave()
		timerWaves.start(0.5)

func _ready():
	start_timerBWaves()

func start_timerBWaves():
	timerWaves.start(0.1)

func spawn_enemy(sp):
	var enemy
	var spawning_position = Vector2.ZERO
	
	#(0 - 536, 0) || (1610, 427 - 709) pirate/caveman
	#(0, 50 - 425) || (160 - 644, 850) pirate
	#(1076 - 1610, 0) || (1610, 0 - 423) animal/caveman
	
	match sp:
		0:
			if randi() % 2 == 0:
				enemy = Pirate.instantiate()
			else:
				enemy = Caveman.instantiate()
			
			if randi() % 2 == 0:
				spawning_position = Vector2(rng.randi_range(0, 536), 0)
			else: 
				spawning_position = Vector2(1610, rng.randi_range(427, 709))
		1:
			enemy = Pirate.instantiate()
			
			if randi() % 2 == 0:
				spawning_position = Vector2(rng.randi_range(160, 644), 850)
			else: 
				spawning_position = Vector2(0, rng.randi_range(50, 425))
		2:
			if randi() % 2 == 0:
				enemy = Animal.instantiate()
			else:
				enemy = Caveman.instantiate()
			
			if randi() % 2 == 0:
				spawning_position = Vector2(rng.randi_range(1076, 1610), 0)
			else: 
				spawning_position = Vector2(1610, rng.randi_range(0, 423))
	
	var main = get_tree().current_scene
	main.add_child(enemy)
	enemy.global_position = spawning_position

func spawn_wave(amount_to_spawn):
	for i in range(0 , amount_to_spawn):
		spawn_enemy(sp)
		sp += 1
		if sp >= 3:
			sp = 0

func _on_timer_waves_timeout():
	subWaves = GameStats.enemy_number / subWaveSize
	lastSubWave = GameStats.enemy_number % subWaveSize
	
	timerSpawns.start(0)

func _on_timer_spawns_timeout():
	if subWaves > 0:
		spawn_wave(subWaveSize)
		timerSpawns.start(2)
	else:
		spawn_wave(lastSubWave)
	
	subWaves -= 1
