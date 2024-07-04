extends Sprite2D

@export var time_active : float = 1.0

@onready var timer: Timer = $Timer
func _ready():
	timer.start(time_active)

func _on_timer_timeout():
	queue_free()
