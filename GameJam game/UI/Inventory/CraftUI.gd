extends Button

@onready var backgroundSprite = $background
@onready var label = $CenterContainer/Panel/Label

@export var itemSprite:Sprite2D

var index

signal crafted

func _ready():
	update_label()
	
	if check_craftable():
		backgroundSprite.frame = 1
	else:
		backgroundSprite.frame = 0

func update_label():
	match itemSprite.name:
		"sword":
			index = 0
			label.text = str(Inventory.amounts[0].x) + 'i ' + str(Inventory.amounts[0].y) + 'w'
		"armor":
			index = 1
			label.text = str(Inventory.amounts[1].x) + 'i ' + str(Inventory.amounts[1].y) + 'w'
		"meal":
			index = 2
			label.text = str(Inventory.amounts[2].x) + 'f '

func check_craftable():
	var craftables = Inventory.check_craftables()
	
	return craftables[index]

func _on_pressed():
	
	if check_craftable():
		match index:
			0:
				Inventory.craft_sword()
			1:
				Inventory.craft_armor()
			2:
				Inventory.craft_meal()
	
	update_label()
	emit_signal("crafted")
	
	if check_craftable():
		backgroundSprite.frame = 1
	else:
		backgroundSprite.frame = 0
	
