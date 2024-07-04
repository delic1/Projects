extends Node

@export var max_health = 1 : set = set_max_health
var health = max_health : set = set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_health(value):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func set_max_health(value):
	max_health = max(value, 1)
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)


func _ready():
	self.health = max_health
