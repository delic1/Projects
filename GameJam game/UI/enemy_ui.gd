extends Control

var hearts = 4: set = set_hearts
var max_hearts = 4: set = set_max_hearts
var move = null: set = set_move

var Circle = preload("res://UI/Shapes/circle.png")
var Lightning = preload("res://UI/Shapes/lightning.png")
var HLine = preload("res://UI/Shapes/h_line.png")
var VLine = preload("res://UI/Shapes/v_line.png")
var North = preload("res://UI/Shapes/north.png")
var South = preload("res://UI/Shapes/south.png")
var East = preload("res://UI/Shapes/east.png")
var West = preload("res://UI/Shapes/west.png")

@onready var health_label = $health
@onready var move_label = $move
@onready var textureRect = $TextureRect

@export var stats: Node
@export var player: CharacterBody2D

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if health_label != null:
		health_label.text = "HP = " + str(hearts)

func set_max_hearts(value):
	max_hearts = max(value, 1)

func set_move(value):
	move = value
	if move_label != null:
		if str(move) == "horizontal line":
			textureRect.texture = HLine
		elif str(move) == "vertical line":
			textureRect.texture = VLine
		elif str(move) == "circle":
			textureRect.texture = Circle
		elif str(move) == "simple_lightning":
			textureRect.texture = Lightning
		elif str(move) == "triangle_no_bottom_west":
			textureRect.texture = West
		elif str(move) == "triangle_no_bottom_east":
			textureRect.texture = East
		elif str(move) == "triangle_no_bottom_north":
			textureRect.texture = North
		elif str(move) == "triangle_no_bottom_south":
			textureRect.texture = South
		
		move_label.text = str(move)

func _ready():
	hearts = stats.health
	max_hearts = stats.max_health
	stats.health_changed.connect(set_hearts)
	player.picked_shape.connect(set_move)
