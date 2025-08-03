extends Node2D

# EASY SCENE CONFIGURATION - Just change these values for new scenes!
@export var json_file_path: String = "res://jsons/portrait_dialogue_template.json"
@export var scene_dialogue_sequence: Array[String] = ["player_0", "kingdoma_0", "player_1", "kingdoma_1"]
@export var scene_end_behavior: SceneEndBehavior = SceneEndBehavior.HOLD

enum SceneEndBehavior {
	HOLD,           # Stay on scene with "Scene Complete" message
	FADE_OUT,       # Fade to black
	NEXT_SCENE      # Transition to next scene (requires next_scene_path)
}

@export var next_scene_path: String = ""  # Path to next scene if using NEXT_SCENE behavior

# Character portrait mapping - easily add new characters here
var character_portraits = {}

# Node references
@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_text = $UILayer/DialogueBox/DialogueText
@onready var dialogue_button = $UILayer/DialogueBox/DialogueButton

# Dialogue data
var dialogue_data = {}
var current_dialogue_index = 0
var current_line_index = 0
var is_typing = false
var type_speed = 0.025
var scene_complete = false

func _ready():
	print("Portrait Dialogue Tool v01 Loaded")
	setup_character_portraits()
	load_dialogue_data()
	
	# Set up font and styling for dialogue text
	var font = load("res://fonts/bygonest_typewriter/Bygonest Typewriter.ttf")
	var font_settings = FontFile.new()
	font_settings = font
	dialogue_text.add_theme_font_override("normal_font", font_settings)
	dialogue_text.add_theme_font_size_override("normal_font_size", 32)
	
	# Make sure dialogue box is visible and positioned
	dialogue_box.visible = true
	dialogue_text.text = "Click to start dialogue..."
	
	# Connect button
	dialogue_button.pressed.connect(_on_dialogue_button_pressed)
	
	# Hide all portraits initially
	hide_all_portraits()
	
	# Start dialogue after everything is set up
	call_deferred("start_dialogue")

func setup_character_portraits():
	# Automatically find and map all portrait nodes
	# This makes it easy to add new characters - just add nodes with "PortraitStandIn" in the name!
	character_portraits.clear()
	
	# Get all children and find portrait nodes
	for child in get_children():
		if child.name.ends_with("PortraitStandIn"):
			var character_name = child.name.replace("PortraitStandIn", "").to_lower()
			character_portraits[character_name] = child
			print("Found character portrait: ", character_name, " -> ", child.name)

func hide_all_portraits():
	for portrait in character_portraits.values():
		portrait.visible = false

func load_dialogue_data():
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(content)
		if result == OK:
			dialogue_data = json.data
			print("Dialogue data loaded successfully from: ", json_file_path)
		else:
			print("Error parsing JSON: ", result)
		file.close()
	else:
		print("Could not open dialogue file: ", json_file_path)

func start_dialogue():
	if current_dialogue_index >= scene_dialogue_sequence.size():
		print("All dialogues complete!")
		handle_scene_end()
		return
	
	var dialogue_id = scene_dialogue_sequence[current_dialogue_index]
	current_line_index = 0
	print("Starting dialogue: ", dialogue_id)
	display_dialogue_line(dialogue_id)

func display_dialogue_line(dialogue_id: String):
	if not dialogue_data.has("portraitDialogue") or not dialogue_data["portraitDialogue"].has(dialogue_id):
		print("No dialogue found for ID: ", dialogue_id)
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
	var texture_path = "res://textures/" + expression_path + ".png"
	
	# Hide all portraits first
	hide_all_portraits()
	
	# Find which character this dialogue belongs to
	var character_name = ""
	if dialogue_id.begins_with("player"):
		character_name = "player"
	elif dialogue_id.begins_with("kingdoma"):
		character_name = "kingdoma"
	else:
		# Extract character name from dialogue_id (e.g., "harry_0" -> "harry")
		var parts = dialogue_id.split("_")
		if parts.size() > 0:
			character_name = parts[0]
	
	# Show the appropriate character portrait
	if character_name in character_portraits:
		if ResourceLoader.exists(texture_path):
			character_portraits[character_name].texture = load(texture_path)
			character_portraits[character_name].visible = true
			print("Showing ", character_name, " with texture: ", texture_path)
		else:
			print("Portrait not found: ", texture_path)
			# Still show the portrait with default texture if available
			character_portraits[character_name].visible = true
	else:
		print("Character not found in portrait mapping: ", character_name)

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
	# Check if scene is complete
	if scene_complete:
		handle_scene_end_click()
		return
	
	# Check bounds before accessing array
	if current_dialogue_index >= scene_dialogue_sequence.size():
		handle_scene_end()
		return
	
	if is_typing:
		# Skip typing animation
		is_typing = false
		var dialogue_id = scene_dialogue_sequence[current_dialogue_index]
		var dialogue_lines = dialogue_data["portraitDialogue"][dialogue_id]
		var line_key = "line_" + str(current_line_index)
		if line_key in dialogue_lines:
			dialogue_text.text = dialogue_lines[line_key]
	else:
		# Advance to next line
		advance_dialogue()

func advance_dialogue():
	# Check bounds before accessing array
	if current_dialogue_index >= scene_dialogue_sequence.size():
		handle_scene_end()
		return
		
	current_line_index += 1
	var dialogue_id = scene_dialogue_sequence[current_dialogue_index]
	display_dialogue_line(dialogue_id)

func advance_to_next_dialogue():
	current_dialogue_index += 1
	current_line_index = 0
	start_dialogue()

# HELPER FUNCTIONS FOR EASY SCENE SETUP:

# Call this function to easily change the dialogue sequence for a new scene
func set_dialogue_sequence(new_sequence: Array[String]):
	scene_dialogue_sequence = new_sequence

# Call this function to easily change the JSON file for a new scene
func set_json_file(new_path: String):
	json_file_path = new_path

# SCENE END HANDLING:

func handle_scene_end():
	scene_complete = true
	hide_all_portraits()
	
	match scene_end_behavior:
		SceneEndBehavior.HOLD:
			dialogue_text.text = "Scene Complete - Click to continue or close"
			print("Scene complete - holding")
		SceneEndBehavior.FADE_OUT:
			dialogue_text.text = "Scene Complete"
			fade_out_scene()
		SceneEndBehavior.NEXT_SCENE:
			if next_scene_path != "":
				dialogue_text.text = "Loading next scene..."
				transition_to_next_scene()
			else:
				dialogue_text.text = "Scene Complete - No next scene configured"
				print("Warning: NEXT_SCENE behavior selected but no next_scene_path provided")

func handle_scene_end_click():
	match scene_end_behavior:
		SceneEndBehavior.HOLD:
			print("Scene held - user can close or restart manually")
		SceneEndBehavior.FADE_OUT:
			fade_out_scene()
		SceneEndBehavior.NEXT_SCENE:
			if next_scene_path != "":
				transition_to_next_scene()

func fade_out_scene():
	print("Fading out scene...")
	# Create a fade to black effect
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport().size
	get_tree().current_scene.add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5)
	await tween.finished
	
	dialogue_text.text = "Scene faded out - Click to restart or close"

func transition_to_next_scene():
	print("Transitioning to next scene: ", next_scene_path)
	if ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Error: Next scene not found: ", next_scene_path)
		dialogue_text.text = "Error: Next scene not found"

# Helper function to restart the scene
func restart_scene():
	current_dialogue_index = 0
	current_line_index = 0
	scene_complete = false
	is_typing = false
	hide_all_portraits()
	call_deferred("start_dialogue")
