extends Node2D

# Character portrait references
var portrait_nodes = {}
var current_speaker = ""

# Dialogue data
var dialogue_data = {}
var dialogue_sequence = []
var current_dialogue_index = 0
var current_line_index = 0
var is_typing = false
var type_speed = 0.025

# Node references
@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_text = $UILayer/DialogueBox/DialogueText
@onready var dialogue_button = $UILayer/DialogueBox/DialogueButton

# Configuration
@export var json_file_path: String = ""
@export var auto_start: bool = true
@export var type_speed_override: float = 0.025

func _ready():
	setup_font()
	setup_portraits()
	load_dialogue_data()
	
	if auto_start:
		start_dialogue_sequence()
	
	# Connect button
	dialogue_button.pressed.connect(_on_dialogue_button_pressed)

func setup_font():
	# Set up font and styling for dialogue text
	var font = load("res://fonts/depixel/DePixelBreit.ttf")
	var font_settings = FontFile.new()
	font_settings = font
	dialogue_text.add_theme_font_override("normal_font", font_settings)
	dialogue_text.add_theme_font_size_override("normal_font_size", 32)

func setup_portraits():
	# Find all TextureRect nodes that end with "PortraitStandIn"
	for child in get_children():
		if child is TextureRect and child.name.ends_with("PortraitStandIn"):
			var character_name = child.name.replace("PortraitStandIn", "").to_lower()
			portrait_nodes[character_name] = child
			child.visible = false
			print("Found portrait for: ", character_name)

func load_dialogue_data():
	if json_file_path.is_empty():
		push_error("No JSON file path specified!")
		return
		
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(content)
		if result == OK:
			dialogue_data = json.data
			setup_dialogue_sequence()
			print("Dialogue data loaded successfully")
		else:
			push_error("Error parsing JSON: " + str(result))
		file.close()
	else:
		push_error("Could not open dialogue file: " + json_file_path)

func setup_dialogue_sequence():
	# Get all dialogue IDs from the JSON and sort them
	dialogue_sequence = []
	if dialogue_data.has("portraitDialogue"):
		dialogue_sequence = dialogue_data["portraitDialogue"].keys()
	dialogue_sequence.sort()  # This will ensure consistent ordering
	print("Dialogue sequence: ", dialogue_sequence)

func start_dialogue_sequence():
	current_dialogue_index = 0
	current_line_index = 0
	
	# Make dialogue box visible
	dialogue_box.visible = true
	dialogue_text.text = "Click to start dialogue..."
	
	if not dialogue_sequence.is_empty():
		display_dialogue_line(dialogue_sequence[0])

func display_dialogue_line(dialogue_id: String):
	if not dialogue_data.has("portraitDialogue") or not dialogue_data["portraitDialogue"].has(dialogue_id):
		push_error("No dialogue found for ID: " + dialogue_id)
		return
	
	var dialogue_lines = dialogue_data["portraitDialogue"][dialogue_id]
	
	# Check if there's a line for this index
	var line_key = "line_" + str(current_line_index)
	var expression_key = "expression_" + str(current_line_index)
	
	if line_key in dialogue_lines:
		# Update portrait if expression exists
		if expression_key in dialogue_lines:
			update_portrait(dialogue_id, dialogue_lines[expression_key])
		
		# Start typing the text
		start_typing(dialogue_lines[line_key])
	else:
		# No more lines in this dialogue, move to next dialogue
		advance_to_next_dialogue()

func update_portrait(dialogue_id: String, expression_path: String):
	# Extract character name from dialogue_id (e.g., "merlin_0" -> "merlin")
	var character_name = dialogue_id.split("_")[0]
	
	# Hide all portraits first
	for portrait in portrait_nodes.values():
		portrait.visible = false
	
	# Show the speaking character's portrait
	if portrait_nodes.has(character_name):
		var portrait = portrait_nodes[character_name]
		var texture_path = "res://textures/" + expression_path + ".png"
		
		if ResourceLoader.exists(texture_path):
			portrait.texture = load(texture_path)
			portrait.visible = true
			current_speaker = character_name
		else:
			push_error("Portrait not found: " + texture_path)
	else:
		push_error("No portrait node found for character: " + character_name)

func start_typing(text: String):
	is_typing = true
	dialogue_text.text = ""
	type_text(text, 0)

func type_text(full_text: String, char_index: int):
	if not is_typing:
		return
		
	if char_index < full_text.length():
		dialogue_text.text = full_text.substr(0, char_index + 1)
		await get_tree().create_timer(type_speed).timeout
		type_text(full_text, char_index + 1)
	else:
		is_typing = false

func _on_dialogue_button_pressed():
	if is_typing:
		# Skip typing animation
		is_typing = false
		var dialogue_id = dialogue_sequence[current_dialogue_index]
		var dialogue_lines = dialogue_data["portraitDialogue"][dialogue_id]
		var line_key = "line_" + str(current_line_index)
		if line_key in dialogue_lines:
			dialogue_text.text = dialogue_lines[line_key]
	else:
		# Advance to next line
		advance_dialogue()

func advance_dialogue():
	current_line_index += 1
	var dialogue_id = dialogue_sequence[current_dialogue_index]
	display_dialogue_line(dialogue_id)

func advance_to_next_dialogue():
	current_dialogue_index += 1
	current_line_index = 0
	if current_dialogue_index < dialogue_sequence.size():
		start_dialogue()
	else:
		print("All dialogues complete!")
		# Optionally hide dialogue box or emit a signal
		dialogue_box.visible = false

# Public methods for external control
func start_dialogue():
	if current_dialogue_index < dialogue_sequence.size():
		var dialogue_id = dialogue_sequence[current_dialogue_index]
		display_dialogue_line(dialogue_id)

func skip_current_dialogue():
	advance_to_next_dialogue()

func reset_dialogue():
	current_dialogue_index = 0
	current_line_index = 0
	start_dialogue()

func set_json_path(path: String):
	json_file_path = path
	load_dialogue_data()

func add_character_portrait(character_name: String, portrait_node: TextureRect):
	portrait_nodes[character_name.to_lower()] = portrait_node
	portrait_node.visible = false