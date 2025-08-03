extends Node

# Global Game State Manager
# This script manages global variables that persist throughout the game

# Global Variables
@onready var kingdom_gold: int = 0
@onready var kingdom_happiness: int = 0
@onready var kingdom_resources: int = 0
@onready var game_turn: int = 0
var kingdom_gold_label: Label
var kingdom_happiness_label: Label
var kingdom_resources_label: Label
var game_turn_label: Label



# Signal for when variables change (useful for UI updates)
signal kingdom_gold_changed(new_value: int)
signal kingdom_happiness_changed(new_value: int)
signal kingdom_resources_changed(new_value: int)
signal game_turn_changed(new_value: int)


func _ready():
	# Reference the GameSystem autoload instead of current scene
	var game_system = get_node("/root/GameSystem")
	kingdom_gold_label = game_system.get_node("StatsContainer/GoldContainer/GoldValue") as Label
	kingdom_happiness_label = game_system.get_node("StatsContainer/HappinessContainer/HappinessValue") as Label
	kingdom_resources_label = game_system.get_node("StatsContainer/ResourcesContainer/ResourcesValue") as Label
	game_turn_label = game_system.get_node("StatsContainer/TurnContainer/TurnValue") as Label

	set_kingdom_gold(50)
	set_kingdom_happiness(50)
	set_kingdom_resources(50)
	set_game_turn(0)
	print("Global Game State initialized")
	print("Initial kingdom_gold Factor: ", kingdom_gold)
	print("Initial kingdom_happiness Factor: ", kingdom_happiness)
	print("Initial kingdom_happiness Factor: ", kingdom_resources)

func modify_game_turn(amount: int):
	var old_value = game_turn
	game_turn += amount
	print("game_turn modified by ", amount, " (", old_value, " -> ", game_turn, ")")
	game_turn_changed.emit(game_turn)
	game_turn_label.text = str(game_turn)

func set_game_turn(value: int):
	var old_value = game_turn
	game_turn = value
	print("game_turn set to ", value, " (was ", old_value, ")")
	game_turn_changed.emit(game_turn)
	game_turn_label.text = str(game_turn)


func get_game_turn() -> int:
	return game_turn

# kingdom_gold Factor Functions
func modify_kingdom_gold(amount: int):
	var old_value = kingdom_gold
	kingdom_gold += amount
	kingdom_gold_label.text = str(kingdom_gold)
	print("kingdom_gold modified by ", amount, " (", old_value, " -> ", kingdom_gold, ")")
	kingdom_gold_changed.emit(kingdom_gold)

func set_kingdom_gold(value: int):
	var old_value = kingdom_gold
	kingdom_gold = value
	print("kingdom_gold set to ", value, " (was ", old_value, ")")
	kingdom_gold_changed.emit(kingdom_gold)
	kingdom_gold_label.text = str(kingdom_gold)


func get_kingdom_gold() -> int:
	return kingdom_gold

# kingdom_happiness Factor Functions
func modify_kingdom_happiness(amount: int):
	var old_value = kingdom_happiness
	kingdom_happiness += amount
	kingdom_happiness_label.text = str(kingdom_happiness)

	kingdom_gold_label.text = str(kingdom_gold)
	print("kingdom_happiness modified by ", amount, " (", old_value, " -> ", kingdom_happiness, ")")
	kingdom_happiness_changed.emit(kingdom_happiness)

func set_kingdom_happiness(value: int):
	var old_value = kingdom_happiness
	kingdom_happiness = value
	print("kingdom_happiness set to ", value, " (was ", old_value, ")")
	kingdom_happiness_changed.emit(kingdom_happiness)
	kingdom_happiness_label.text = str(kingdom_happiness)


func get_kingdom_happiness() -> int:
	return kingdom_happiness

func modify_kingdom_resources(amount: int):
	var old_value = kingdom_resources
	kingdom_resources += amount
	kingdom_resources_label.text = str(kingdom_resources)

	print("kingdom_resources modified by ", amount, " (", old_value, " -> ", kingdom_resources, ")")
	kingdom_resources_changed.emit(kingdom_resources)

func set_kingdom_resources(value: int):
	var old_value = kingdom_resources
	kingdom_resources = value
	print("kingdom_resources set to ", value, " (was ", old_value, ")")
	kingdom_resources_changed.emit(kingdom_resources)
	kingdom_resources_label.text = str(kingdom_resources)

func get_kingdom_resources() -> int:
	return kingdom_resources


# Reset all variables (useful for testing or new game)
func reset_all_variables():
	kingdom_gold = 0
	kingdom_happiness = 0
	kingdom_resources = 0
	kingdom_gold_changed.emit(kingdom_gold)
	kingdom_happiness_changed.emit(kingdom_happiness)
	kingdom_resources_changed.emit(kingdom_resources)
	print("All global variables reset to 0")

# Debug function to get all variables as a dictionary
func get_all_variables() -> Dictionary:
	return {
		"kingdom_gold": kingdom_gold,
		"kingdom_happiness": kingdom_happiness,
		"kingdom_resources": kingdom_resources
	}

# Save/Load functions (can be expanded later for persistence)
func save_to_dict() -> Dictionary:
	return get_all_variables()

func load_from_dict(data: Dictionary):
	if data.has("kingdom_gold"):
		kingdom_gold = data["kingdom_gold"]
	if data.has("kingdom_happiness"):
		kingdom_happiness = data["kingdom_happiness"]
	if data.has("kingdom_resources"):
		kingdom_resources = data["kingdom_resources"]
	
	# Emit signals for any listeners
	kingdom_gold_changed.emit(kingdom_gold)
	kingdom_happiness_changed.emit(kingdom_happiness)
	kingdom_resources_changed.emit(kingdom_resources)

	print("Global variables loaded from save data")


func _on_gold_value_test_pressed() -> void:
	modify_kingdom_gold(2)
	pass # Replace with function body.


func _on_resource_value_test_pressed() -> void:
	modify_kingdom_resources(2)
	pass # Replace with function body.


func _on_happiness_value_test_pressed() -> void:
	modify_kingdom_happiness(2)
	pass # Replace with function body.


func _on_turn_value_test_pressed() -> void:
	modify_game_turn(1)
	pass # Replace with function body.
