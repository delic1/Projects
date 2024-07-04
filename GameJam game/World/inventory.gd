extends Node

var iron_count = 0: set = set_iron_count
var wood_count = 0: set = set_wood_count
var food_count = 0: set = set_food_count

var attack_dmg = 1
var armor_strength = 1


var items = ["iron", "wood", "food"]
var recipes = ["sword", "armor", "meal"]
var amounts = [Vector2(2 , 0), Vector2(0, 2), Vector2(2 , 0)]
var craftables = [false, false, false]
var upgrades = [0, 0, 0]
# drveni mac, metalni mac, drveni armor, metalni armor, obrok

func check_craftables():
	craftables = [false, false, false]
	
	if iron_count >= amounts[0].x && wood_count >= amounts[0].y:
		craftables[0] = true
	if iron_count >= amounts[1].x && wood_count >= amounts[1].y:
		craftables[1] = true
	if food_count >= amounts[2].x:
		craftables[2] = true 
	
	return craftables

func craft_sword():
	if craftables[0]:
		iron_count -= amounts[0].x
		wood_count -= amounts[0].y
		amounts[0] = Vector2(amounts[0].x + 2, amounts[0].y + 1)
		attack_dmg += 1
		upgrades[0] += 1
	else:
		return
	
	check_craftables()

func craft_armor():
	if craftables[1]:
		iron_count -= amounts[1].x
		wood_count -= amounts[1].y
		amounts[1] = Vector2(amounts[1].x + 1, amounts[1].y + 2)
		armor_strength -= 0.1
		clamp(armor_strength, 0.2 , 1)
		upgrades[1] += 1
	else:
		return
	
	check_craftables()

func craft_meal():
	if craftables[2]:
		food_count -= amounts[2].x
		PlayerStats.health += 1
	else:
		return
	
	check_craftables()

func set_iron_count(value):
	iron_count = value

func set_wood_count(value):
	wood_count = value

func set_food_count(value):
	food_count = value
