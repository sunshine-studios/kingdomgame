extends Node2D

# Policy Scene Script
# Handles policy selection interface and player stat management

# Reference to player stats
var player_stats: Node

# UI References
@onready var title_label: Label = $UILayer/MainContainer/ContentContainer/TitleLabel
@onready var description_label: Label = $UILayer/MainContainer/ContentContainer/DescriptionLabel

# Stats display
@onready var gold_value: Label = $UILayer/MainContainer/ContentContainer/StatsContainer/GoldContainer/GoldValue
@onready var resources_value: Label = $UILayer/MainContainer/ContentContainer/StatsContainer/ResourcesContainer/ResourcesValue
@onready var happiness_value: Label = $UILayer/MainContainer/ContentContainer/StatsContainer/HappinessContainer/HappinessValue

# Policy UI elements
@onready var policy_a_title: Label = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyA/PolicyATitle
@onready var policy_a_description: Label = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyA/PolicyADescription
@onready var policy_a_effects: Label = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyA/PolicyAEffects
@onready var policy_a_button: Button = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyA/PolicyAButton

@onready var policy_b_title: Label = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyB/PolicyBTitle
@onready var policy_b_description: Label = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyB/PolicyBDescription
@onready var policy_b_effects: Label = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyB/PolicyBEffects
@onready var policy_b_button: Button = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyB/PolicyBButton

@onready var policy_c_title: Label = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyC/PolicyCTitle
@onready var policy_c_description: Label = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyC/PolicyCDescription
@onready var policy_c_effects: Label = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyC/PolicyCEffects
@onready var policy_c_button: Button = $UILayer/MainContainer/ContentContainer/PolicyChoicesContainer/PolicyC/PolicyCButton

# Current policy data
var current_policies: Dictionary = {}
var current_turn: int = 1

func _ready():
	print("Policy Scene initialized")
	
	# Get or create player stats
	setup_player_stats()
	
	# Load policy data from JSON
	load_policy_data()
	
	# Setup UI connections
	setup_ui_connections()
	
	# Update displays
	update_stats_display()

func setup_player_stats():
	# Check if player stats already exists as autoload or create it
	if has_node("/root/PlayerStats"):
		player_stats = get_node("/root/PlayerStats")
	else:
		# Create a new instance and add it to the scene tree
		var player_stats_script = load("res://scripts/player_stats.gd")
		player_stats = player_stats_script.new()
		player_stats.name = "PlayerStats"
		add_child(player_stats)
		
		# Connect to stat change signals
		player_stats.stats_changed.connect(_on_stats_changed)
	
	print("Player stats setup complete")

func setup_ui_connections():
	# Connect policy buttons
	if policy_a_button:
		policy_a_button.pressed.connect(_on_policy_a_selected)
	if policy_b_button:
		policy_b_button.pressed.connect(_on_policy_b_selected)
	if policy_c_button:
		policy_c_button.pressed.connect(_on_policy_c_selected)

func load_policy_data():
	var json_path = "res://jsons/policies_turn01.json"
	var file = FileAccess.open(json_path, FileAccess.READ)
	
	if file == null:
		print("Failed to load policy data from: ", json_path)
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Failed to parse policy JSON")
		return
	
	current_policies = json.data
	print("Policy data loaded successfully")
	
	# Update UI with loaded data
	update_policy_display()

func update_policy_display():
	if current_policies.is_empty():
		return
		
	# Update title and description
	if title_label:
		title_label.text = current_policies.get("title", "Policy Decisions")
	if description_label:
		description_label.text = current_policies.get("description", "Choose a policy.")
	
	var policies = current_policies.get("policies", [])
	
	# Update Policy A
	if policies.size() > 0:
		var policy_a = policies[0]
		if policy_a_title:
			policy_a_title.text = policy_a.get("title", "Policy A")
		if policy_a_description:
			policy_a_description.text = policy_a.get("description", "No description")
		if policy_a_effects:
			var effects = policy_a.get("effects", {})
			policy_a_effects.text = "Gold %+d, Resources %+d, Happiness %+d" % [
				effects.get("gold", 0), 
				effects.get("resources", 0), 
				effects.get("happiness", 0)
			]
		if policy_a_button:
			policy_a_button.text = policy_a.get("button_text", "Choose A")
	
	# Update Policy B
	if policies.size() > 1:
		var policy_b = policies[1]
		if policy_b_title:
			policy_b_title.text = policy_b.get("title", "Policy B")
		if policy_b_description:
			policy_b_description.text = policy_b.get("description", "No description")
		if policy_b_effects:
			var effects = policy_b.get("effects", {})
			policy_b_effects.text = "Gold %+d, Resources %+d, Happiness %+d" % [
				effects.get("gold", 0), 
				effects.get("resources", 0), 
				effects.get("happiness", 0)
			]
		if policy_b_button:
			policy_b_button.text = policy_b.get("button_text", "Choose B")
	
	# Update Policy C
	if policies.size() > 2:
		var policy_c = policies[2]
		if policy_c_title:
			policy_c_title.text = policy_c.get("title", "Policy C")
		if policy_c_description:
			policy_c_description.text = policy_c.get("description", "No description")
		if policy_c_effects:
			var effects = policy_c.get("effects", {})
			policy_c_effects.text = "Gold %+d, Resources %+d, Happiness %+d" % [
				effects.get("gold", 0), 
				effects.get("resources", 0), 
				effects.get("happiness", 0)
			]
		if policy_c_button:
			policy_c_button.text = policy_c.get("button_text", "Choose C")

func update_stats_display():
	if player_stats == null:
		return
		
	if gold_value:
		gold_value.text = str(player_stats.get_gold())
	if resources_value:
		resources_value.text = str(player_stats.get_resources())
	if happiness_value:
		happiness_value.text = str(player_stats.get_happiness())

# Policy selection handlers
func _on_policy_a_selected():
	apply_policy(0)

func _on_policy_b_selected():
	apply_policy(1)

func _on_policy_c_selected():
	apply_policy(2)

func apply_policy(policy_index: int):
	if current_policies.is_empty():
		print("No policies loaded")
		return
		
	var policies = current_policies.get("policies", [])
	if policy_index >= policies.size():
		print("Invalid policy index: ", policy_index)
		return
	
	var selected_policy = policies[policy_index]
	var effects = selected_policy.get("effects", {})
	
	print("Applying policy: ", selected_policy.get("title", "Unknown"))
	
	# Apply effects to player stats
	if player_stats:
		player_stats.apply_policy_effects(
			effects.get("gold", 0),
			effects.get("resources", 0),
			effects.get("happiness", 0)
		)
	
	# Show flavor text
	var flavor_text = selected_policy.get("flavor_text", "")
	if flavor_text != "":
		print("Result: ", flavor_text)
	
	# Disable all buttons after selection
	disable_policy_buttons()
	
	# Could add future functionality here like advancing to next turn

func disable_policy_buttons():
	if policy_a_button:
		policy_a_button.disabled = true
	if policy_b_button:
		policy_b_button.disabled = true
	if policy_c_button:
		policy_c_button.disabled = true
	
	print("Policy enacted! Buttons disabled.")

func _on_stats_changed(stat_type: String, old_value: int, new_value: int):
	print("Stat changed - %s: %d -> %d" % [stat_type, old_value, new_value])
	update_stats_display()

func _on_back_button_pressed() -> void:
	print("back button pressed - Loading Navigation ")
	get_tree().change_scene_to_file("res://scenes/navigation_scene.tscn")
	pass # Replace with function body.
