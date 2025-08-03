extends Node

# Player Stats Resource
# Tracks Gold, Resources, and Happiness for the kingdom

signal stats_changed(stat_type: String, old_value: int, new_value: int)

# Kingdom stats
var gold: int = 50
var resources: int = 50  # Also called "supply" in some contexts
var happiness: int = 50

# Maximum values (optional limits)
var max_gold: int = 999
var max_resources: int = 999
var max_happiness: int = 999

# Minimum values
var min_gold: int = 0
var min_resources: int = 0
var min_happiness: int = 0

func _ready():
	print("Player Stats initialized - Gold: %d, Resources: %d, Happiness: %d" % [gold, resources, happiness])

# Getters
func get_gold() -> int:
	return gold

func get_resources() -> int:
	return resources

func get_happiness() -> int:
	return happiness

# Setters with validation and signals
func set_gold(value: int):
	var old_value = gold
	gold = clamp(value, min_gold, max_gold)
	if old_value != gold:
		stats_changed.emit("gold", old_value, gold)
		print("Gold changed: %d -> %d" % [old_value, gold])

func set_resources(value: int):
	var old_value = resources
	resources = clamp(value, min_resources, max_resources)
	if old_value != resources:
		stats_changed.emit("resources", old_value, resources)
		print("Resources changed: %d -> %d" % [old_value, resources])

func set_happiness(value: int):
	var old_value = happiness
	happiness = clamp(value, min_happiness, max_happiness)
	if old_value != happiness:
		stats_changed.emit("happiness", old_value, happiness)
		print("Happiness changed: %d -> %d" % [old_value, happiness])

# Modify stats by amount (positive or negative)
func modify_gold(amount: int):
	set_gold(gold + amount)

func modify_resources(amount: int):
	set_resources(resources + amount)

func modify_happiness(amount: int):
	set_happiness(happiness + amount)

# Apply multiple stat changes at once (for policies)
func apply_policy_effects(gold_change: int, resources_change: int, happiness_change: int):
	print("Applying policy effects: Gold %+d, Resources %+d, Happiness %+d" % [gold_change, resources_change, happiness_change])
	modify_gold(gold_change)
	modify_resources(resources_change)
	modify_happiness(happiness_change)

# Reset stats to defaults
func reset_stats():
	set_gold(50)
	set_resources(50)
	set_happiness(50)
	print("Player stats reset to defaults")

# Get all stats as a dictionary
func get_all_stats() -> Dictionary:
	return {
		"gold": gold,
		"resources": resources,
		"happiness": happiness
	}

# Debug function
func print_stats():
	print("=== PLAYER STATS ===")
	print("Gold: %d/%d" % [gold, max_gold])
	print("Resources: %d/%d" % [resources, max_resources])
	print("Happiness: %d/%d" % [happiness, max_happiness])
	print("==================")