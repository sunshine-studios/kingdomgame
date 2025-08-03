extends Node2D

# Node references
@onready var player_portrait = $PlayerPortraitStandIn
@onready var kingdoma_portrait = $KingdomaPortraitStandIn
@onready var dialogue_box = $UILayer/DialogueBox
@onready var dialogue_text = $UILayer/DialogueBox/DialogueText
@onready var dialogue_button = $UILayer/DialogueBox/DialogueButton

# Dialogue data
var dialogue_data = {}
var dialogue_sequence = []
var current_dialogue_index = 0
var current_line_index = 0
var is_typing = false
var type_speed = 0.025

func _ready():
	print("Chapter 01 Scene 01 Loaded")
	load_dialogue_data()
	setup_dialogue_sequence()
	
	# Connect button
	dialogue_button.pressed.connect(_on_dialogue_button_pressed)
	
	# Initially hide KingdomA, show Player
	kingdoma_portrait.visible = false
	player_portrait.visible = true
	
	# Start dialogue after everything is set up
	call_deferred("start_dialogue")

func load_dialogue_data():
	var file = FileAccess.open("res://jsons/Chapter01_Scene01.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(content)
		if result == OK:
			dialogue_data = json.data
			print("Dialogue data loaded successfully")
		else:
			print("Error parsing JSON: ", result)
		file.close()
	else:
		print("Could not open dialogue file")

func setup_dialogue_sequence():
	# Define the linear sequence of dialogues
	dialogue_sequence = [
		"player_0",
		"kingdoma_0",
		"player_1", 
		"kingdoma_1"
	]

func start_dialogue():
	if current_dialogue_index >= dialogue_sequence.size():
		print("All dialogues complete!")
		return
	
	var dialogue_id = dialogue_sequence[current_dialogue_index]
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
	
	# Determine which portrait to update based on dialogue_id
	if dialogue_id.begins_with("player"):
		if ResourceLoader.exists(texture_path):
			player_portrait.texture = load(texture_path)
			# Make sure Player is visible, KingdomA is hidden
			player_portrait.visible = true
			kingdoma_portrait.visible = false
		else:
			print("Portrait not found: ", texture_path)
	elif dialogue_id.begins_with("kingdoma"):
		if ResourceLoader.exists(texture_path):
			kingdoma_portrait.texture = load(texture_path)
			# Make sure KingdomA is visible, Player is hidden
			kingdoma_portrait.visible = true
			player_portrait.visible = false
		else:
			print("Portrait not found: ", texture_path)

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
	start_dialogue()
