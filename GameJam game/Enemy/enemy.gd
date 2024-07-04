extends CharacterBody2D

@export var SPEED = 100.0
@export var ACCELERATION = 5000.0
@export var STOP_RADIUS = 50
@export var ITEM_TO_DROP: Node2D
var shapes = ["horizontal line",
			  "vertical line",
			  "circle",
			  "simple_lightning",
			  "triangle_no_bottom_west",
			  "triangle_no_bottom_south",
			  "triangle_no_bottom_east",
			  "triangle_no_bottom_north"]

@onready var enemy_stats = $Stats
@onready var shape = pick_shape(shapes)

var player = null
var chase_vector = Vector2.ZERO

signal picked_shape

func _ready():
	PlayerAttack.attacked.connect(_on_player_attack_attacked)
	GameStats.pick_up_items.connect(pick_up_items)
	SPEED = SPEED * (1 + GameStats.day/10.0)
	enemy_stats.max_health = enemy_stats.max_health * GameStats.day
	enemy_stats.health = enemy_stats.max_health

func _physics_process(delta):
	if player == null:
		chase_vector = Vector2.ZERO
	else:
		var distance = player.global_position - global_position
		if distance.length() < STOP_RADIUS:
			chase_vector = Vector2.ZERO
		else:
			chase_vector = (distance).normalized()
	
	velocity = velocity.move_toward(chase_vector * SPEED, ACCELERATION * delta)
	
	move_and_slide()

func pick_shape(shapes):
	var rand_shape = randi() % shapes.size()
	emit_signal("picked_shape", shapes[rand_shape])
	return shapes[rand_shape]

func damage():
	enemy_stats.health -= Inventory.attack_dmg

func _on_chase_radius_body_entered(body):
	player = body

func _on_chase_radius_body_exited(body):
	player = null

func _on_player_attack_attacked(attack):
	if attack != null && attack == shape:
		damage()
		shape = pick_shape(shapes)

func pick_up_items():
	ITEM_TO_DROP.visible = false

func _on_stats_no_health():
	if $Sprite2D.visible == false:
		return
	
	$EnemyUI.visible = false
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	$ChaseRadius/CollisionShape2D.disabled = true
	$HitBox/CollisionShape2D.disabled = true
	ITEM_TO_DROP.visible = true
	
	if ITEM_TO_DROP.name == "iron":
		Inventory.iron_count += 1
	elif ITEM_TO_DROP.name == "wood":
		Inventory.wood_count += 1
	elif ITEM_TO_DROP.name == "food":
		Inventory.food_count += 1
	
	GameStats.enemy_number -= 1
