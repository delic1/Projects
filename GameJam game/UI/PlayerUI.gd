extends Control

var hearts = 4:set = set_hearts
var max_hearts = 4:set = set_max_hearts

@onready var heartsUIFull = $HeartsFull
@onready var heartsUIEmpty = $HeartsEmpty
@onready var ironLabel = $IronLabel
@onready var woodLabel = $WoodLabel
@onready var foodLabel = $FoodLabel

@export var craft_ui1:Control
@export var craft_ui2:Control
@export var craft_ui3:Control

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartsUIEmpty != null:
		heartsUIEmpty.size.x = max_hearts * 15

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartsUIFull != null:
		heartsUIFull.size.x = hearts * 15
	

func update_materials():
	ironLabel.text = str(Inventory.iron_count) + 'i'
	woodLabel.text = str(Inventory.wood_count) + 'w'
	foodLabel.text = str(Inventory.food_count) + 'f'

func _ready():
	update_materials()
	
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	if craft_ui1 != null:
		craft_ui1.crafted.connect(update_materials)
	if craft_ui2 != null:
		craft_ui2.crafted.connect(update_materials)
	if craft_ui3 != null:
		craft_ui3.crafted.connect(update_materials)
	
	PlayerStats.health_changed.connect(set_hearts)
	PlayerStats.max_health_changed.connect(set_max_hearts)
	GameStats.pick_up_items.connect(update_materials)
