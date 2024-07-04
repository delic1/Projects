extends CharacterBody2D

@onready var player_stats = PlayerStats
@onready var hurtbox = $HurtBox

func _ready():
	player_stats.no_health.connect(_on_no_health)

func _on_hurt_box_area_entered(area):
	player_stats.health -= area.damage * Inventory.armor_strength
	hurtbox.start_invincibility(1.5)

func _on_no_health():
	get_tree().paused = true
	queue_free()
